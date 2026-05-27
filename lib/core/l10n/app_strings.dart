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
  /// Bottom nav — छोटा लेबल (overflow न हो)।
  static const String navLiveDarshan = 'लाइव';
  static const String navDaan = 'दान';

  static const String liveDarshanTitle = 'लाइव मंदिर दर्शन';
  static const String liveDarshanLiveBadge = 'लाइव';
  static const String liveDarshanHeroTitle = 'भारत के पवित्र मंदिर';
  static const String liveDarshanHeroSubtitle =
      'घर बैठे दर्शन — मंदिरों का आधिकारिक लाइव प्रसारण। मंदिर चुनें और दर्शन करें।';
  static const String liveDarshanPickTemple = 'मंदिर चुनें';
  static const String liveDarshanOpenYoutube = 'YouTube पर खोलें';
  static const String liveDarshanWatchOnYoutube = 'लाइव दर्शन — YouTube पर देखें';
  static const String liveDarshanWatchHint =
      'सबसे बेहतर अनुभव YouTube ऐप में — एक टैप में लाइव दर्शन।';
  static const String liveDarshanTryInApp = 'ऐप में देखने की कोशिश करें';
  static const String liveDarshanBackFromEmbed = 'वापस';
  static const String liveDarshanClosePlayer = 'बंद करें';
  static const String liveDarshanResumePlayer = 'लाइव दर्शन देखें';
  static const String liveDarshanOpenError =
      'लिंक नहीं खुल सका। इंटरनेट जाँचें।';
  static const String liveDarshanDisclaimer =
      'लाइव प्रसारण संबंधित मंदिर/चैनल द्वारा उपलब्ध कराया जाता है। कभी-कभी स्ट्रीम बंद या बदल सकती है — तब दूसरा मंदिर चुनें या YouTube पर खोलें। इंटरनेट आवश्यक है।';
  static const String liveDarshanTempleClosed = 'मंदिर बंद है';
  static const String liveDarshanTempleClosedHint =
      'अभी इस मंदिर पर लाइव प्रसारण नहीं चल रहा। जैसे ही लाइव शुरू होगा, यहाँ स्वतः दर्शन दिखेगा।';
  static const String liveDarshanChecking = 'लाइव स्थिति जाँच हो रही है…';
  static const String liveDarshanLiveNow = 'लाइव';
  static const String liveDarshanRefresh = 'फिर जाँचें';
  static const String liveDarshanEmbedBlockedHint =
      'लाइव चल रहा है — कई मंदिर ऐप के अंदर वीडियो नहीं दिखाते। नीचे बटन से YouTube ऐप में दर्शन करें।';
  static const String liveDarshanEmbedFailedHint =
      'ऐप में वीडियो उपलब्ध नहीं। YouTube ऐप में लाइव दर्शन चलता है — नीचे बटन दबाएँ।';
  static const String liveDarshanApiKeyHint =
      'लाइव स्वतः पकड़ने के लिए build में YOUTUBE_API_KEY जोड़ें (Google Cloud → YouTube Data API v3)।';

  static const String mandirTitle = 'आभासी मंदिर';
  static const String mandirTopHint = 'गर्भगृह में दर्शन कर आरती करें';
  static const String mandirPhotoSwipeHint =
      'फोटो पर बाएँ–दाएँ स्वाइप करें — भगवान बदलें';
  static const String mandirGarbhagriha = '— मंदिर —';
  static const String mandirBellButton = 'घंटी';
  static const String mandirAartiButton = 'आरती';
  static const String mandirShankhButton = 'शंख';

  static const String donationHomeTitle = 'दान पुण्य';
  static const String donationHomeHint =
      'श्रद्धा से दान करें — गौ सेवा, मंदिर या भक्ति ऐप में योगदान';
  static const String donationTitle = 'दान पुण्य';
  static const String donationHeroTitle = 'श्रद्धा का दान — पुण्य का फल';
  static const String donationSubtitle =
      'थोड़ा सा दान भी बड़ा आशीर्वाद बन सकता है। अपनी श्रद्धा से किसी पवित्र कार्य में सहयोग करें — UPI से सुरक्षित और आसान।';
  static const String donationTrustLine =
      'आपका दान चुने हुए कार्य में ही लगता है — पारदर्शिता और भक्ति भाव के साथ।';
  static const String donationBenefitShraddha = 'श्रद्धा';
  static const String donationBenefitPunya = 'पुण्य';
  static const String donationBenefitSeva = 'सेवा';
  static const String donationCardCta = 'दान करें';
  static const String donationPopularAmounts = 'लोकप्रिय दान राशि';
  static const String donationCheckoutBlessing =
      '॥ दान करने वाले पर माता-पिता का आशीर्वाद बना रहे ॥';
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
