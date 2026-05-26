/// सारी ऐप UI पाठ — केवल हिंदी।
abstract final class AppStrings {
  static const String appTitle = 'भक्ति साधना';
  static const String appTagline = 'पूजा • आरती • मंत्र';
  static const String bellPlaying = 'मंदिर की घंटी बज रही है…';
  static const String webEnterHint = 'मंदिर में प्रवेश — स्क्रीन पर स्पर्श करें';
  static const String homePrompt = 'आज क्या करना चाहेंगे?';
  static const String homeSubPrompt = 'अपनी भक्ति का मार्ग चुनें';

  static const String navPuja = 'पूजा';
  static const String navMandir = 'मंदिर';
  static const String navDaan = 'दान पुण्य';

  static const String mandirTitle = 'आभासी मंदिर';
  static const String mandirTopHint = 'गर्भगृह में दर्शन कर आरती करें';
  static const String mandirPhotoSwipeHint =
      'फोटो पर बाएँ–दाएँ स्वाइप करें — भगवान बदलें';
  static const String mandirGarbhagriha = '— गर्भगृह —';
  static const String mandirBellButton = 'घंटी';

  static const String donationHomeTitle = 'दान पुण्य';
  static const String donationHomeHint =
      'गौ दान, मंदिर ट्रस्ट, या ऐप विकास — दान का उद्देश्य चुनें';
  static const String donationTitle = 'दान पुण्य';
  static const String donationSubtitle =
      'श्रद्धा से दान करें — राशि चुनें और QR स्कैन करके UPI से भुगतान करें।';
  static const String donationAmount = 'दान राशि चुनें';
  static const String donationCustomAmount = 'अन्य राशि (₹)';
  static const String donationCopyDetails = 'दान विवरण कॉपी करें';
  static const String donationQrTitle = 'दान QR — स्कैन करें';
  static const String donationQrHint =
      'PhonePe, GPay या किसी भी UPI ऐप से QR स्कैन करें और भुगतान पूरा करें।';
  static const String donationQrSelectAmount = 'दान राशि चुनें — QR यहाँ दिखेगा';
  static const String donationCopyUpiId = 'UPI ID कॉपी करें';
  static const String donationUpiIdCopied = 'UPI ID कॉपी हो गई';
  static const String donationCopied = 'विवरण कॉपी हो गया';
  static const String donationSelectAmount = 'कृपया दान राशि चुनें या भरें';
  static const String donationDisclaimer =
      'दान संबंधित भुगतान आपके UPI/बैंक ऐप से होगा। राशि सत्यापन के बाद ही पुष्टि मानें।';
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
  static const String kathaSune = 'कथा सुनें';
  static const String kathaHubHint = 'पढ़ें — किताब जैसे पृष्ठ पलटें; सुनें — आवाज़ में कथा';
  static const String kathaChooseStory = 'कौन सी कथा?';
  static const String kathaTapToPlay = 'सुनने के लिए चलाएँ दबाएँ';
  static const String kathaSwipeHint = 'बाएँ–दाएँ स्वाइप';
  static const String kathaTurnPage = 'अगला पृष्ठ पलटें →';
  static const String kathaPageLabel = 'पृष्ठ';
  static const String kathaPagesShort = 'पृष्ठ';
  static const String kathaParagraphsLabel = 'अनुच्छेद';
  static const String kathaPartLabel = 'भाग';
  static const String kathaPrev = 'पिछला';
  static const String kathaNext = 'अगला';
  static const String kathaListenNow = 'अभी सुन रहे हैं';
  static const String kathaNoPages = 'इस कथा के पृष्ठ उपलब्ध नहीं हैं।';
  static const String kathaNoAudioText = 'सुनने के लिए पाठ उपलब्ध नहीं।';
  static const String kathaTtsError =
      'आवाज़ चल नहीं सकी। डिवाइस में हिंदी TTS सक्षम है या नहीं, जाँचें।';
  static const String aartiChalaye = 'आरती चलाएँ';
  static const String stepCounter = 'चरण';
  static const String festival = 'त्योहार';
  static const String vratKatha = 'व्रत कथा';
  static const String comingSoonAarti = 'इस देवता की आरती जल्द जोड़ी जाएगी।';
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
