/// सारी ऐप UI पाठ — केवल हिंदी।
abstract final class AppStrings {
  static const String appTitle = 'भक्ति साधना';
  static const String appTagline = 'पूजा • आरती • भजन';
  static const String bellPlaying = 'मंदिर की घंटी बज रही है…';
  static const String webEnterHint = 'मंदिर में प्रवेश — स्क्रीन पर स्पर्श करें';
  static const String homePrompt = 'आज क्या करना चाहेंगे?';
  static const String homeSubPrompt = 'अपनी भक्ति का मार्ग चुनें';
  static const String disclaimer =
      'विधि सम्प्रदायानुसार भिन्न हो सकती है। स्थानीय परंपरा के अनुसार पूजा करें।';

  static const String errorInvalidCategory = 'अमान्य श्रेणी';
  static const String errorTitle = 'त्रुटि';
  static const String errorLoadContent = 'सामग्री लोड नहीं हो सकी';
  static const String errorDeityNotFound = 'देवता नहीं मिली';

  static const String selectDeity = 'देवी-देवता चुनें';
  static const String deityCountLabel = 'देवी-देवता';
  static const String pujaSamagri = 'पूजा सामग्री';
  static const String pujaSteps = 'पूजा के चरण';
  static const String kathaPadhe = 'कथा पढ़ें';
  static const String stepCounter = 'चरण';
  static const String festival = 'त्योहार';
  static const String vratKatha = 'व्रत कथा';
  static const String comingSoonAarti = 'इस देवता की आरती जल्द जोड़ी जाएगी।';
  static const String comingSoonBhajan = 'भजन जल्द जोड़े जाएंगे।';
  static const String comingSoonMantra = 'मंत्र जल्द जोड़े जाएंगे।';
  static const String comingSoonSection = 'जल्द जोड़ा जाएगा।';

  static const String aartiListen = 'आरती सुनें (ऐप में)';
  static const String aartiPlay = 'चलाएँ';
  static const String aartiPause = 'रोकें';
  static const String aartiStop = 'बंद करें';
  static const String aartiPlayError =
      'आरती चल नहीं सकी। इंटरनेट जाँचें और MP3 Supabase bucket में upload है या नहीं, यह देखें।';
  static const String aartiSupabaseSetup =
      'Supabase URL/Key configure करें और bucket "aartis" में MP3 upload करें (scripts/setup_supabase.sh देखें)।';
}
