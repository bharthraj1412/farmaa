// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'பண்ணை';

  @override
  String get tagline => 'விவசாயத்திலிருந்து எதிர்காலத்திற்கு';

  @override
  String get login => 'உள்நுழை';

  @override
  String get enterPhone => 'தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get sendOtp => 'OTP அனுப்பு';

  @override
  String get enterOtp => 'OTP உள்ளிடவும்';

  @override
  String get verifyOtp => 'OTP சரிபார்க்கவும்';

  @override
  String get resendOtp => 'OTP மீண்டும் அனுப்பு';

  @override
  String resendIn(int seconds) {
    return '$seconds வினாடியில் மீண்டும் அனுப்பு';
  }

  @override
  String otpSentTo(String phone) {
    return '+91 $phone க்கு OTP அனுப்பப்பட்டது';
  }

  @override
  String get mobileNumber => 'மொபைல் எண்';

  @override
  String get iAmA => 'நான் ஒரு...';

  @override
  String get farmer => 'விவசாயி';

  @override
  String get buyer => 'வாங்குபவர்';

  @override
  String get farmerDesc => 'உங்கள் தானியங்களை பட்டியலிடுங்கள்';

  @override
  String get buyerDesc => 'தானியங்களை உலாவி ஆர்டர் செய்யுங்கள்';

  @override
  String get continue_btn => 'தொடரவும்';

  @override
  String get createAccount => 'கணக்கு உருவாக்கு 🌱';

  @override
  String get changeNumber => '← எண்ணை மாற்று';

  @override
  String get back => '← திரும்பு';

  @override
  String get enterPhoneStep => 'தொடர உங்கள் மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get verifyOtpStep => 'OTP சரிபார்த்து உங்கள் பங்கை தேர்ந்தெடுக்கவும்';

  @override
  String get profileStep => 'உங்களைப் பற்றி சொல்லுங்கள்';

  @override
  String get yourName => 'உங்கள் பெயர் *';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get village => 'கிராமம்';

  @override
  String get district => 'மாவட்டம் *';

  @override
  String get selectDistrict => 'மாவட்டத்தை தேர்ந்தெடுக்கவும்';

  @override
  String get organization => 'நிறுவனம் / நிறுவனம்';

  @override
  String get dashboard => 'டாஷ்போர்டு';

  @override
  String get browse => 'உலாவு';

  @override
  String get cart => 'கார்ட்';

  @override
  String get orders => 'ஆர்டர்கள்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get marketPrice => 'சந்தை விலை';

  @override
  String get pricePerKg => 'விலை / கிலோ';

  @override
  String get stockAvailable => 'கையிருப்பு';

  @override
  String get minOrder => 'குறைந்தபட்ச ஆர்டர்';

  @override
  String get quantity => 'அளவு';

  @override
  String get totalAmount => 'மொத்த தொகை';

  @override
  String get allGrains => 'அனைத்து தானியங்கள்';

  @override
  String listingsFound(int count) {
    return '$count பட்டியல்கள் கிடைத்தன';
  }

  @override
  String get searchCrops => 'தானியங்களை தேடுங்கள்...';

  @override
  String get noGrainsFound => 'தானியங்கள் இல்லை';

  @override
  String get tryDifferentSearch => 'வேறு தேடல் அல்லது வகையை முயற்சிக்கவும்';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get addToCart => 'கார்ட்டில் சேர்';

  @override
  String get buyNow => 'இப்போது வாங்கு';

  @override
  String get viewCart => 'கார்ட் பார்க்கவும்';

  @override
  String get checkout => 'செலுத்து';

  @override
  String get payNow => 'இப்போது செலுத்துங்கள்';

  @override
  String get orderSummary => 'ஆர்டர் சுருக்கம்';

  @override
  String get deliveryAddress => 'டெலிவரி முகவரி';

  @override
  String get enterDeliveryAddress => 'முழு டெலிவரி முகவரியை உள்ளிடவும்';

  @override
  String get cartEmpty => 'உங்கள் கார்ட் காலியாக உள்ளது';

  @override
  String get cartEmptyHint => 'சந்தைக்கு திரும்பி பொருட்களை சேர்க்கவும்.';

  @override
  String get browseGrains => 'தானியங்கள் உலாவு';

  @override
  String get proceedToCheckout => 'செலுத்துக்கு தொடரவும்';

  @override
  String get remove => 'அகற்று';

  @override
  String get orderPlaced => 'ஆர்டர் வைக்கப்பட்டது! 🎉';

  @override
  String get orderConfirmed =>
      'உங்கள் ஆர்டர் உறுதிப்படுத்தப்பட்டு விவசாயிக்கு அனுப்பப்பட்டது.';

  @override
  String get trackOrder => 'ஆர்டரை கண்காணி';

  @override
  String get continueShopping => 'ஷாப்பிங் தொடரவும்';

  @override
  String get orderId => 'ஆர்டர் ஐடி';

  @override
  String get crop => 'பயிர்';

  @override
  String get amountPaid => 'செலுத்திய தொகை';

  @override
  String get myOrders => 'என் ஆர்டர்கள்';

  @override
  String get noOrdersYet => 'இன்னும் ஆர்டர்கள் இல்லை';

  @override
  String get ordersAppearHere => 'உங்கள் ஆர்டர்கள் இங்கே காட்டப்படும்';

  @override
  String get orderDetail => 'ஆர்டர் விவரம்';

  @override
  String get estimatedDelivery => 'எதிர்பார்க்கப்படும் டெலிவரி';

  @override
  String get farmerContact => 'விவசாயி தொடர்பு';

  @override
  String get pending => 'நிலுவையில்';

  @override
  String get confirmed => 'உறுதிப்படுத்தப்பட்டது';

  @override
  String get processing => 'செயலாக்கப்படுகிறது';

  @override
  String get shipped => 'அனுப்பப்பட்டது';

  @override
  String get delivered => 'வழங்கப்பட்டது';

  @override
  String get cancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get paid => 'செலுத்தப்பட்டது';

  @override
  String get failed => 'தோல்வியடைந்தது';

  @override
  String get refunded => 'திரும்பப் பெறப்பட்டது';

  @override
  String get confirmOrder => 'ஆர்டரை உறுதிசெய்';

  @override
  String get shipOrder => 'அனுப்பியதாக குறி';

  @override
  String get cancelOrder => 'ஆர்டரை ரத்து செய்';

  @override
  String get buyerInfo => 'வாங்குபவர் தகவல்';

  @override
  String get listNewGrain => 'புதிய தானியத்தை பட்டியலிடு';

  @override
  String get editListing => 'பட்டியலை திருத்து';

  @override
  String get grainCategory => 'தானிய வகை *';

  @override
  String get grainName => 'தானியத்தின் பெயர் *';

  @override
  String get grainNameHint => 'எ.கா., பாஸ்மதி அரிசி';

  @override
  String get variety => 'இரகம் (விருப்பமானது)';

  @override
  String get varietyHint => 'எ.கா., HHB 67, K 9107';

  @override
  String get priceKgLabel => 'ஒரு கிலோவிற்கு விலை (₹) *';

  @override
  String get stockKgLabel => 'கையிருப்பு (கிலோ) *';

  @override
  String get minOrderLabel => 'குறைந்தபட்ச ஆர்டர் (கிலோ)';

  @override
  String get description => 'விளக்கம்';

  @override
  String get descriptionHint =>
      'தானிய தரம், வளரும் நிலைகள், சான்றிதழ்களை விளக்குங்கள்...';

  @override
  String get submitForReview => 'மதிப்பாய்வுக்கு சமர்ப்பிக்கவும்';

  @override
  String get saveChanges => 'மாற்றங்களை சேமி';

  @override
  String get qaNotice =>
      'உங்கள் பட்டியல் நேரடியாக செல்வதற்கு முன் எங்கள் தரக் குழுவால் மதிப்பாய்வு செய்யப்படும்.';

  @override
  String get cropUpdated =>
      'தானியம் புதுப்பிக்கப்பட்டது! QA மதிப்பாய்வு நிலுவையில்.';

  @override
  String get cropSubmitted => 'QA அனுமதிக்காக தானியம் சமர்ப்பிக்கப்பட்டது! ✅';

  @override
  String get marketPrices => 'சந்தை விலைகள்';

  @override
  String get aiAssistant => 'AI உதவியாளர்';

  @override
  String get receivedOrders => 'பெற்ற ஆர்டர்கள்';

  @override
  String get myCrops => 'என் தானியங்கள்';

  @override
  String get addGrain => 'தானியம் சேர்க்கவும்';

  @override
  String get verifiedAccount => 'சரிபார்க்கப்பட்ட கணக்கு';

  @override
  String get verificationPending => 'சரிபார்ப்பு நிலுவையில் ⓘ';

  @override
  String get editProfile => 'சுயவிவரம் திருத்து';

  @override
  String get name => 'பெயர்';

  @override
  String get phone => 'தொலைபேசி';

  @override
  String get role => 'பங்கு';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get logoutConfirm => 'நீங்கள் வெளியேற விரும்புகிறீர்களா?';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get save => 'சேமி';

  @override
  String get saveChangesBtn => 'மாற்றங்களை சேமி';

  @override
  String get profileUpdated => 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது';

  @override
  String get updateFailed => 'புதுப்பிப்பு தோல்வியடைந்தது';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get pushNotifications => 'புஷ் அறிவிப்புகள்';

  @override
  String get pushNotificationsSubtitle => 'பயன்பாட்டு அறிவிப்புகளை பெறுங்கள்';

  @override
  String get priceAlerts => 'விலை எச்சரிக்கைகள்';

  @override
  String get priceAlertsSubtitle => 'சந்தை விலைகள் மாறும்போது அறிவிப்பு';

  @override
  String get orderUpdates => 'ஆர்டர் புதுப்பிப்புகள்';

  @override
  String get orderUpdatesSubtitle => 'ஆர்டர் நிலை மாற்றங்களில் அறிவிப்பு';

  @override
  String get language => 'மொழி';

  @override
  String get selectLanguage => 'மொழியை தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get about => 'பற்றி';

  @override
  String get appVersion => 'பயன்பாட்டு பதிப்பு';

  @override
  String get privacyPolicy => 'தனியுரிமை கொள்கை';

  @override
  String get termsOfService => 'சேவை விதிமுறைகள்';

  @override
  String get helpSupport => 'உதவி & ஆதரவு';

  @override
  String get accountActions => 'கணக்கு நடவடிக்கைகள்';

  @override
  String get account => 'கணக்கு';

  @override
  String get networkError => 'நெட்வொர்க் பிழை';

  @override
  String get networkErrorMsg =>
      'சேவையகத்துடன் இணைக்க முடியவில்லை. இணைய இணைப்பை சரிபார்க்கவும்.';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get offlineMode => 'ஆஃப்லைன் முறை';

  @override
  String get verifyIdentity => 'அடையாளத்தை சரிபார்க்கவும்';

  @override
  String get kycDesc =>
      'சரிபார்க்கப்பட்ட விற்பனையாளராக, உங்கள் ஆதார் அல்லது PAN கார்டு விவரங்களை பதிவேற்றவும்.';

  @override
  String get submitDocuments => 'ஆவணங்களை சமர்ப்பிக்கவும்';

  @override
  String get documentsSubmitted =>
      'ஆவணங்கள் சமர்ப்பிக்கப்பட்டன! சரிபார்ப்பு 24 மணி நேரத்தில் முடியும்.';

  @override
  String get aboutCrop => 'பற்றி';

  @override
  String priceGuarantee(String date) {
    return 'விலை புதுப்பிக்கப்பட்டது: $date';
  }

  @override
  String get aiPriceInsight => 'AI சந்தை நுண்ணறிவு';

  @override
  String farmerDistrict(String district) {
    return '$district மாவட்டம்';
  }

  @override
  String stockKg(String stock) {
    return '$stock கிலோ கிடைக்கிறது';
  }

  @override
  String get grainRice => 'அரிசி';

  @override
  String get grainWheat => 'கோதுமை';

  @override
  String get grainMillet => 'சோளம்';

  @override
  String get grainBarley => 'வாற்கோதுமை';

  @override
  String get grainSorghum => 'மக்காச்சோளம்';

  @override
  String get grainMaize => 'சோளம்';

  @override
  String get grainPulses => 'பருப்பு வகைகள்';

  @override
  String get grainOther => 'மற்றவை';

  @override
  String get howCanIHelp =>
      'வணக்கம்! நான் உங்கள் பண்ணை AI உதவியாளர். இன்று நான் உங்களுக்கு எப்படி உதவ முடியும்? பயிர் விலைகள், விளைச்சல் குறிப்புகள் அல்லது ஆர்டர் உதவிகள் பற்றி நீங்கள் என்னிடம் கேட்கலாம்.';

  @override
  String get askAnything => 'எதையும் கேளுங்கள்...';

  @override
  String get aiThinking => 'AI சிந்திக்கிறது...';

  @override
  String get yieldPrediction => 'விளைச்சல் கணிப்பு';

  @override
  String get sustainability => 'நிலைத்தன்மை';

  @override
  String get area => 'பரப்பளவு';

  @override
  String get season => 'பருவம்';

  @override
  String get soilType => 'மண் வகை';

  @override
  String get irrigation => 'பாசனம்';

  @override
  String get predictYieldBtn => 'விளைச்சலை கணி ✨';

  @override
  String get predictedYield => 'கணிக்கப்பட்ட விளைச்சல்';

  @override
  String confidence(String percentage) {
    return '$percentage% நம்பிக்கை';
  }

  @override
  String get sustainabilityDesc =>
      'உங்கள் விவசாய முறைகளை மதிப்பிட்டு, AI நிலைத்தன்மை மதிப்பெண்ணைப் பெறுங்கள் (0–100).';

  @override
  String get irrigationMethod => 'பாசன முறை';

  @override
  String get fertilizerType => 'உர வகை';

  @override
  String get cropRotationPracticed => 'பயிர் சுழற்சி நடைமுறை';

  @override
  String get calculateScoreBtn => 'மதிப்பெண் கணக்கிடு ♻️';

  @override
  String get needsImprovement => 'முன்னேற்றம் தேவை ⚠️';

  @override
  String get good => 'நன்று 👍';

  @override
  String get excellent => 'சிறப்பு 🌟';

  @override
  String get improvementTips => 'முன்னேற்ற குறிப்புகள்';

  @override
  String get markAllRead => 'அனைத்தையும் படித்ததாக குறி';

  @override
  String get noNotificationsYet => 'இன்னும் அறிவிப்புகள் இல்லை';

  @override
  String get youreAllCaughtUp => 'நீங்கள் அனைத்தையும் படித்துவிட்டீர்கள்!';

  @override
  String timeAgoM(int minutes) {
    return '$minutes நிமிடங்களுக்கு முன்';
  }

  @override
  String timeAgoH(int hours) {
    return '$hours மணிநேரங்களுக்கு முன்';
  }

  @override
  String timeAgoD(int days) {
    return '$days நாட்களுக்கு முன்';
  }

  @override
  String get noPriceData => 'விலை தரவு கிடைக்கவில்லை';

  @override
  String get todaysRate => 'இன்றைய விலை';

  @override
  String get quintal => '/குவிண்டால்';

  @override
  String get sevenDayTrend => '7 நாள் விலை போக்கு';

  @override
  String get historicalData => 'வரலாற்று தரவு';

  @override
  String get simulatedUploadReady => 'உருவகப்படுத்தப்பட்ட பதிவேற்றம் விவரம்';

  @override
  String get onboardingTitle1 => 'உங்கள் தானியங்களை\nநேரடியாக விற்கவும்';

  @override
  String get onboardingSub1 =>
      'தினை மற்றும் கோதுமை பயிர்களை எளிதாக பட்டியலிடுங்கள். இந்தியா முழுவதும் சரிபார்க்கப்பட்ட வாங்குபவர்களுடன் இணையுங்கள் — இடைத்தரகர்கள் இல்லை, அதிக லாபம்.';

  @override
  String get onboardingTitle2 => 'நியாமான விலைகள்,\nஒவ்வொரு பருவத்திலும்';

  @override
  String get onboardingSub2 =>
      'விலைகள் உண்மையான சந்தை விகிதங்களுக்கு இணைக்கப்பட்டுள்ளன. போட்டி விலையை நிர்ணயிக்க மற்றும் உங்கள் லாபத்தை அதிகரிக்க AI-இயங்கும் நுண்ணறிவு உதவும்.';

  @override
  String get onboardingTitle3 => 'நம்பகமான\nபரிவர்த்தனைகள்';

  @override
  String get onboardingSub3 =>
      'பரிசோதிக்கப்பட்ட விவசாயிகள், தரம் சரிபார்க்கப்பட்ட தானியங்கள் மற்றும் Razorpay மூலம் பாதுகாப்பான கட்டணங்கள். உங்கள் அறுவடை, உங்கள் வருமானம் — பாதுகாக்கப்பட்டது.';

  @override
  String get skip => 'தவிர்';

  @override
  String get next => 'அடுத்து';

  @override
  String get getStarted => 'தொடங்குங்கள் 🌱';
}
