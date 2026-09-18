import '../security/rules.dart';

class BotMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  BotMessage(this.text, this.isUser, this.time);
}

class SafiBotService {
  static final Map<String, String> knowledgeBase = {
    'لماذا': 'صافي يكشف التطبيقات التي تملك أذونات مراقبة مثل قراءة الإشعارات، خدمات الوصول، مسؤول الجهاز، شهادات تجسس. لا يقرأ رسائلك أو صورك.',
    'روت': 'الروت يعني جهازك مفتوح لأي تطبيق يأخذ صلاحيات كاملة. هذا خطر جداً للمعاملات البنكية. ننصح بإلغاء الروت أو استخدام جهاز غير مروت للبنوك.',
    'مخفي': 'التطبيقات المخفية هي التي بلا أيقونة في الشاشة الرئيسية. تطبيقات التجسس تخفي نفسها بهذه الطريقة. افتح الإعدادات > التطبيقات > عرض كل التطبيقات لتراها.',
    'إشعارات': 'قارئ الإشعارات يستطيع قراءة كل إشعار يصلك، بما فيها رموز التحقق OTP من البنوك. إذا كان تطبيق غريب يقرأ إشعاراتك، ألغِ وصوله فوراً.',
    'شهادة': 'شهادة CA مزروعة تعني أن أحدهم يستطيع فك تشفير اتصالك المشفر HTTPS ويرى كلمات مرورك. احذفها من الإعدادات > الأمان > التشفير وبيانات الاعتماد.',
    'احتيال': 'المواقع الاحتيالية تقلد مواقع حقيقية لتسرق كلمة مرورك. تحقق دائماً من رابط الموقع، وتأكد أنه HTTPS، واستخدم أدوات الفحص مثل VirusTotal.',
    'جلسة': 'إذا دخل شخص غريب حسابك، ستراه في صفحة الأجهزة النشطة. افتح الرابط الذي نوفره لكل منصة (جوجل، فيسبوك، انستا...) وسجل خروج من الأجهزة الغريبة وغير كلمة المرور فوراً.',
    'إذن': 'كل إذن له سبب: الكاميرا للتصوير، الموقع للخرائط. لكن إذا طلب تطبيق آلة حاسبة إذن قراءة الرسائل والموقع والميكروفون معاً، فهذه تركيبة خطيرة.',
    'آمن': 'لا يوجد هاتف آمن 100%، لكن صافي يعطيك درجة ثقة. فوق 70 آمن، 40-70 انتبه، أقل من 40 خطر. الهدف تقليل المخاطر، ليس حذفها تماماً.',
  };

  static String answer(String question) {
    final q = question.toLowerCase();
    if (q.contains('روت') || q.contains('root')) return knowledgeBase['روت']!;
    if (q.contains('مخفي') || q.contains('hidden')) return knowledgeBase['مخفي']!;
    if (q.contains('اشعار') || q.contains('notification')) return knowledgeBase['إشعارات']!;
    if (q.contains('شهادة') || q.contains('ca') || q.contains('https')) return knowledgeBase['شهادة']!;
    if (q.contains('احتيال') || q.contains('تصيد') || q.contains('phish') || q.contains('موقع')) return knowledgeBase['احتيال']!;
    if (q.contains('جلسة') || q.contains('دخول') || q.contains('session') || q.contains('حساب')) return knowledgeBase['جلسة']!;
    if (q.contains('اذن') || q.contains('permission') || q.contains('صلاحية')) return knowledgeBase['إذن']!;
    if (q.contains('آمن') || q.contains('safe')) return knowledgeBase['آمن']!;
    if (q.contains('لماذا') || q.contains('كيف') || q.contains('what') || q.contains('why')) return knowledgeBase['لماذا']!;

    // Check rule explanations
    for (var rule in SafiRules.v1_3) {
      if (q.contains(rule.id.toLowerCase()) || q.contains(rule.titleAr.substring(0, 4))) {
        return '${rule.titleAr}: ${rule.whyAr}. الحل: ${rule.fixAr}';
      }
    }

    return 'سؤال ممتاز! صافي يفحص 36 نوع من المخاطر. إذا ظهر لك تنبيه معين، اضغط عليه وسأشرح لك بالضبط ماذا يعني وكيف تصلحه بنقرة. أو اسألني عن: روت، تطبيقات مخفية، إشعارات، شهادات، مواقع احتيالية، جلسات دخول.';
  }
}
