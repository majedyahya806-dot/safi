"""
صافي - Backend FastAPI
13 endpoints per PRD §3.7
"""
from fastapi import FastAPI, Depends, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List
import sqlite3
import time
import hashlib
import secrets
import os
from datetime import datetime, timedelta
import json

app = FastAPI(title="Safi API", version="2.0")

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

DB_PATH = "./safi.db"

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        first_name TEXT, last_name TEXT,
        email TEXT UNIQUE, phone TEXT UNIQUE,
        password_hash TEXT,
        created_at TEXT,
        deleted_at TEXT
    )""")
    cur.execute("""CREATE TABLE IF NOT EXISTS devices (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        type TEXT, os_version TEXT,
        last_scan TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
    )""")
    cur.execute("""CREATE TABLE IF NOT EXISTS findings (
        id TEXT PRIMARY KEY,
        device_id TEXT,
        finding_id TEXT,
        severity TEXT,
        weight REAL,
        ts TEXT,
        score INTEGER,
        payload TEXT,
        FOREIGN KEY(device_id) REFERENCES devices(id)
    )""")
    cur.execute("""CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        device_id TEXT,
        access_token TEXT,
        refresh_token TEXT,
        created_at TEXT,
        expires_at TEXT,
        revoked INTEGER DEFAULT 0
    )""")
    cur.execute("""CREATE TABLE IF NOT EXISTS rules (
        version TEXT PRIMARY KEY,
        content TEXT,
        updated_at TEXT
    )""")
    conn.commit()
    conn.close()

init_db()

# Models
class SignupRequest(BaseModel):
    first_name: str = Field(..., min_length=1, max_length=40)
    last_name: str = Field(..., min_length=1, max_length=40)
    email: Optional[str] = None
    phone: Optional[str] = None
    password: str = Field(..., min_length=10)
    language: str = "ar"
    country: Optional[str] = None

class LoginRequest(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None
    password: str

class OTPRequest(BaseModel):
    phone: str

class OTPVerify(BaseModel):
    phone: str
    code: str

class PairDeviceRequest(BaseModel):
    device_id: str
    type: str
    os_version: str

class EventRequest(BaseModel):
    device_id: str
    finding_id: str
    severity: str
    weight: float
    ts: str
    score: int

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    country: Optional[str] = None

# Helpers
def hash_password(pw: str) -> str:
    # argon2id in production, here sha256 for demo
    return hashlib.sha256(pw.encode()).hexdigest()

def generate_tokens():
    access = secrets.token_urlsafe(32)
    refresh = secrets.token_urlsafe(48)
    return access, refresh

def assert_no_forbidden_content(payload: dict):
    forbidden = ["sms", "call_log", "audio", "camera", "location", "message_content", "password", "photo"]
    payload_str = json.dumps(payload).lower()
    for f in forbidden:
        if f in payload_str:
            raise HTTPException(status_code=400, detail=f"Forbidden field: {f}")

def get_current_user(authorization: str = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing token")
    token = authorization.split(" ")[1]
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM sessions WHERE access_token=? AND revoked=0", (token,))
    sess = cur.fetchone()
    if not sess:
        conn.close()
        raise HTTPException(status_code=401, detail="Invalid token")
    # check expiry
    if datetime.fromisoformat(sess["expires_at"]) < datetime.utcnow():
        conn.close()
        raise HTTPException(status_code=401, detail="Token expired")
    cur.execute("SELECT * FROM users WHERE id=?", (sess["user_id"],))
    user = cur.fetchone()
    conn.close()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return dict(user), dict(sess)

# Endpoints per PRD
@app.post("/api/v1/auth/signup")
def signup(req: SignupRequest):
    if not req.email and not req.phone:
        raise HTTPException(status_code=400, detail="Email or phone required")
    conn = get_db()
    cur = conn.cursor()
    user_id = secrets.token_hex(12)
    try:
        cur.execute("INSERT INTO users (id, first_name, last_name, email, phone, password_hash, created_at) VALUES (?,?,?,?,?,?,?)",
                    (user_id, req.first_name, req.last_name, req.email, req.phone, hash_password(req.password), datetime.utcnow().isoformat()))
        conn.commit()
    except sqlite3.IntegrityError:
        conn.close()
        raise HTTPException(status_code=400, detail="User exists")
    conn.close()
    access, refresh = generate_tokens()
    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO sessions (id, user_id, access_token, refresh_token, created_at, expires_at) VALUES (?,?,?,?,?,?)",
                (secrets.token_hex(8), user_id, access, refresh, datetime.utcnow().isoformat(), (datetime.utcnow()+timedelta(minutes=15)).isoformat()))
    conn.commit()
    conn.close()
    return {"user_id": user_id, "access_token": access, "refresh_token": refresh, "expires_in": 900}

@app.post("/api/v1/auth/verify/email")
def verify_email(email: str):
    # In production send email link
    return {"status": "sent", "email": email}

@app.post("/api/v1/auth/otp/request")
def otp_request(req: OTPRequest):
    # In production use SMS gateway, if no gateway fallback to email per PRD Q C
    code = str(secrets.randbelow(900000)+100000)
    # store in memory/db for demo
    return {"status": "sent", "phone": req.phone, "expires_in": 60, "demo_code": code}

@app.post("/api/v1/auth/otp/verify")
def otp_verify(req: OTPVerify):
    # demo accepts any 6 digits
    if len(req.code) != 6:
        raise HTTPException(status_code=400, detail="Invalid code")
    return {"status": "verified"}

@app.post("/api/v1/auth/login")
def login(req: LoginRequest):
    conn = get_db()
    cur = conn.cursor()
    if req.email:
        cur.execute("SELECT * FROM users WHERE email=?", (req.email,))
    elif req.phone:
        cur.execute("SELECT * FROM users WHERE phone=?", (req.phone,))
    else:
        raise HTTPException(status_code=400, detail="Email or phone required")
    user = cur.fetchone()
    if not user or user["password_hash"] != hash_password(req.password):
        conn.close()
        raise HTTPException(status_code=401, detail="Invalid credentials")
    # Check lock 5 attempts - simplified
    conn.close()
    access, refresh = generate_tokens()
    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO sessions (id, user_id, access_token, refresh_token, created_at, expires_at) VALUES (?,?,?,?,?,?)",
                (secrets.token_hex(8), user["id"], access, refresh, datetime.utcnow().isoformat(), (datetime.utcnow()+timedelta(minutes=15)).isoformat()))
    conn.commit()
    conn.close()
    return {"access_token": access, "refresh_token": refresh, "user_id": user["id"]}

@app.post("/api/v1/auth/refresh")
def refresh(refresh_token: str):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM sessions WHERE refresh_token=? AND revoked=0", (refresh_token,))
    sess = cur.fetchone()
    if not sess:
        conn.close()
        raise HTTPException(status_code=401, detail="Invalid refresh")
    # rotate
    new_access, new_refresh = generate_tokens()
    cur.execute("UPDATE sessions SET revoked=1 WHERE id=?", (sess["id"],))
    cur.execute("INSERT INTO sessions (id, user_id, access_token, refresh_token, created_at, expires_at) VALUES (?,?,?,?,?,?)",
                (secrets.token_hex(8), sess["user_id"], new_access, new_refresh, datetime.utcnow().isoformat(), (datetime.utcnow()+timedelta(minutes=15)).isoformat()))
    conn.commit()
    conn.close()
    return {"access_token": new_access, "refresh_token": new_refresh}

@app.post("/api/v1/auth/logout")
def logout(auth = Depends(get_current_user)):
    user, sess = auth
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE sessions SET revoked=1 WHERE id=?", (sess["id"],))
    conn.commit()
    conn.close()
    return {"status": "logged out"}

@app.get("/api/v1/auth/me")
def me(auth = Depends(get_current_user)):
    user, sess = auth
    return {"id": user["id"], "first_name": user["first_name"], "last_name": user["last_name"], "email": user["email"], "phone": user["phone"]}

@app.patch("/api/v1/users/me")
def update_me(update: UserUpdate, auth = Depends(get_current_user)):
    user, sess = auth
    conn = get_db()
    cur = conn.cursor()
    if update.first_name:
        cur.execute("UPDATE users SET first_name=? WHERE id=?", (update.first_name, user["id"]))
    if update.last_name:
        cur.execute("UPDATE users SET last_name=? WHERE id=?", (update.last_name, user["id"]))
    conn.commit()
    conn.close()
    return {"status": "updated"}

@app.post("/api/v1/devices/pair")
def pair_device(req: PairDeviceRequest, auth = Depends(get_current_user)):
    user, sess = auth
    # check 5 devices limit per PRD
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) as c FROM devices WHERE user_id=?", (user["id"],))
    count = cur.fetchone()["c"]
    if count >= 5:
        conn.close()
        raise HTTPException(status_code=400, detail="Device limit 5 reached")
    cur.execute("INSERT OR REPLACE INTO devices (id, user_id, type, os_version, last_scan) VALUES (?,?,?,?,?)",
                (req.device_id, user["id"], req.type, req.os_version, datetime.utcnow().isoformat()))
    conn.commit()
    conn.close()
    return {"status": "paired", "device_id": req.device_id}

@app.post("/api/v1/events")
def post_event(req: EventRequest, auth = Depends(get_current_user)):
    assert_no_forbidden_content(req.dict())
    user, sess = auth
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM devices WHERE id=? AND user_id=?", (req.device_id, user["id"]))
    dev = cur.fetchone()
    if not dev:
        conn.close()
        raise HTTPException(status_code=404, detail="Device not found or not owned")
    cur.execute("INSERT INTO findings (id, device_id, finding_id, severity, weight, ts, score, payload) VALUES (?,?,?,?,?,?,?,?)",
                (secrets.token_hex(8), req.device_id, req.finding_id, req.severity, req.weight, req.ts, req.score, json.dumps(req.dict())))
    conn.commit()
    conn.close()
    return {"status": "recorded"}

@app.get("/api/v1/rules/version")
def rules_version():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM rules ORDER BY updated_at DESC LIMIT 1")
    row = cur.fetchone()
    conn.close()
    if row:
        return {"version": row["version"], "updated_at": row["updated_at"]}
    return {"version": "v1.3", "updated_at": datetime.utcnow().isoformat()}

@app.get("/api/v1/dashboard/data")
def dashboard_data(auth = Depends(get_current_user)):
    user, sess = auth
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM devices WHERE user_id=?", (user["id"],))
    devices = [dict(r) for r in cur.fetchall()]
    cur.execute("""SELECT f.* FROM findings f JOIN devices d ON f.device_id=d.id WHERE d.user_id=? ORDER BY f.ts DESC LIMIT 100""", (user["id"],))
    findings = [dict(r) for r in cur.fetchall()]
    conn.close()
    # Group open findings
    open_findings = [f for f in findings if True]  # simplified
    # Score curve
    curve = [{"ts": f["ts"], "score": f["score"]} for f in findings[:20]]
    return {
        "user": {"first_name": user["first_name"], "last_name": user["last_name"]},
        "devices": devices,
        "findings": open_findings,
        "curve": curve,
        "devices_count": len(devices),
        "can_export_pdf": True
    }

@app.get("/")
def root():
    return {"name": "Safi API", "version": "2.0", "docs": "/docs"}
