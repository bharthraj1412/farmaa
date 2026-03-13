// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Farmaa';

  @override
  String get tagline => 'From Farm to Future';

  @override
  String get login => 'Login';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String otpSentTo(String phone) {
    return 'OTP sent to +91 $phone';
  }

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get iAmA => 'I am a...';

  @override
  String get farmer => 'Farmer';

  @override
  String get buyer => 'Buyer';

  @override
  String get farmerDesc => 'List your grains & manage crops';

  @override
  String get buyerDesc => 'Browse and order grains';

  @override
  String get continue_btn => 'Continue';

  @override
  String get createAccount => 'Create Account 🌱';

  @override
  String get changeNumber => '← Change number';

  @override
  String get back => '← Back';

  @override
  String get enterPhoneStep => 'Enter your mobile number to continue';

  @override
  String get verifyOtpStep => 'Verify OTP and select your role';

  @override
  String get profileStep => 'Tell us a little about yourself';

  @override
  String get yourName => 'Your Name *';

  @override
  String get fullName => 'Full name';

  @override
  String get village => 'Village';

  @override
  String get district => 'District *';

  @override
  String get selectDistrict => 'Select district';

  @override
  String get organization => 'Organization / Company';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get browse => 'Browse';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get marketPrice => 'Market Price';

  @override
  String get pricePerKg => 'Price / kg';

  @override
  String get stockAvailable => 'Stock Available';

  @override
  String get minOrder => 'Min. Order';

  @override
  String get quantity => 'Quantity';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get allGrains => 'All Grains';

  @override
  String listingsFound(int count) {
    return '$count listings found';
  }

  @override
  String get searchCrops => 'Search grains...';

  @override
  String get noGrainsFound => 'No grains found';

  @override
  String get tryDifferentSearch => 'Try a different search or category';

  @override
  String get loading => 'Loading...';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get viewCart => 'View Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get payNow => 'Pay Now';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get enterDeliveryAddress => 'Enter full delivery address';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Go back to the marketplace and add items.';

  @override
  String get browseGrains => 'Browse Grains';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get remove => 'Remove';

  @override
  String get orderPlaced => 'Order Placed! 🎉';

  @override
  String get orderConfirmed =>
      'Your order has been confirmed and sent to the farmer.';

  @override
  String get trackOrder => 'Track Order';

  @override
  String get continueShopping => 'Continue Shopping';

  @override
  String get orderId => 'Order ID';

  @override
  String get crop => 'Crop';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get myOrders => 'My Orders';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get ordersAppearHere => 'Your orders will appear here';

  @override
  String get orderDetail => 'Order Detail';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get farmerContact => 'Farmer Contact';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get paid => 'Paid';

  @override
  String get failed => 'Failed';

  @override
  String get refunded => 'Refunded';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get shipOrder => 'Mark as Shipped';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get buyerInfo => 'Buyer Info';

  @override
  String get listNewGrain => 'List New Grain';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get grainCategory => 'Grain Category *';

  @override
  String get grainName => 'Grain Name *';

  @override
  String get grainNameHint => 'e.g., Basmati Rice';

  @override
  String get variety => 'Variety (optional)';

  @override
  String get varietyHint => 'e.g., HHB 67, K 9107';

  @override
  String get priceKgLabel => 'Price per kg (₹) *';

  @override
  String get stockKgLabel => 'Stock Available (kg) *';

  @override
  String get minOrderLabel => 'Minimum Order (kg)';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'Describe grain quality, growing conditions, certifications...';

  @override
  String get submitForReview => 'Submit for Review';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get qaNotice =>
      'Your listing will be reviewed by our quality team before going live.';

  @override
  String get cropUpdated => 'Grain updated! Pending QA review.';

  @override
  String get cropSubmitted => 'Grain submitted for QA approval! ✅';

  @override
  String get marketPrices => 'Market Prices';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get receivedOrders => 'Received Orders';

  @override
  String get myCrops => 'My Grains';

  @override
  String get addGrain => 'Add Grain';

  @override
  String get verifiedAccount => 'Verified Account';

  @override
  String get verificationPending => 'Verification Pending ⓘ';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveChangesBtn => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Receive app notifications';

  @override
  String get priceAlerts => 'Price Alerts';

  @override
  String get priceAlertsSubtitle => 'Notify when market prices change';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderUpdatesSubtitle => 'Notify on order status changes';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get accountActions => 'Account Actions';

  @override
  String get account => 'Account';

  @override
  String get networkError => 'Network Error';

  @override
  String get networkErrorMsg =>
      'Could not connect to server. Please check your internet connection.';

  @override
  String get retry => 'Retry';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get verifyIdentity => 'Verify Identity';

  @override
  String get kycDesc =>
      'To become a verified seller, please upload your Aadhaar or PAN card details.';

  @override
  String get submitDocuments => 'Submit Documents';

  @override
  String get documentsSubmitted =>
      'Documents submitted! Verification will complete in 24 hours.';

  @override
  String get aboutCrop => 'About';

  @override
  String priceGuarantee(String date) {
    return 'Price updated: $date';
  }

  @override
  String get aiPriceInsight => 'AI Market Insight';

  @override
  String farmerDistrict(String district) {
    return '$district District';
  }

  @override
  String stockKg(String stock) {
    return '$stock kg available';
  }

  @override
  String get grainRice => 'Rice';

  @override
  String get grainWheat => 'Wheat';

  @override
  String get grainMillet => 'Millet';

  @override
  String get grainBarley => 'Barley';

  @override
  String get grainSorghum => 'Sorghum';

  @override
  String get grainMaize => 'Maize';

  @override
  String get grainPulses => 'Pulses';

  @override
  String get grainOther => 'Other';

  @override
  String get howCanIHelp =>
      'Hello! I\'m your Farmaa AI Assistant. How can I help you today? You can ask me about crop prices, yield tips, or order assistance.';

  @override
  String get askAnything => 'Ask anything...';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get yieldPrediction => 'Yield Prediction';

  @override
  String get sustainability => 'Sustainability';

  @override
  String get area => 'Area';

  @override
  String get season => 'Season';

  @override
  String get soilType => 'Soil Type';

  @override
  String get irrigation => 'Irrigation';

  @override
  String get predictYieldBtn => 'Predict Yield ✨';

  @override
  String get predictedYield => 'Predicted Yield';

  @override
  String confidence(String percentage) {
    return '$percentage% confidence';
  }

  @override
  String get sustainabilityDesc =>
      'Evaluate your farming practices and get an AI sustainability score (0–100).';

  @override
  String get irrigationMethod => 'Irrigation Method';

  @override
  String get fertilizerType => 'Fertilizer Type';

  @override
  String get cropRotationPracticed => 'Crop Rotation Practiced';

  @override
  String get calculateScoreBtn => 'Calculate Score ♻️';

  @override
  String get needsImprovement => 'Needs Improvement ⚠️';

  @override
  String get good => 'Good 👍';

  @override
  String get excellent => 'Excellent 🌟';

  @override
  String get improvementTips => 'Improvement Tips';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get youreAllCaughtUp => 'You\'re all caught up!';

  @override
  String timeAgoM(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeAgoH(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeAgoD(int days) {
    return '${days}d ago';
  }

  @override
  String get noPriceData => 'No price data available';

  @override
  String get todaysRate => 'Today\'s Rate';

  @override
  String get quintal => '/quintal';

  @override
  String get sevenDayTrend => '7-Day Price Trend';

  @override
  String get historicalData => 'Historical Data';

  @override
  String get simulatedUploadReady => 'Simulated Upload Ready';

  @override
  String get onboardingTitle1 => 'Sell Your Seeds\nDirectly';

  @override
  String get onboardingSub1 =>
      'List millet and wheat crops with ease. Connect with verified buyers across India — no middlemen, higher profits.';

  @override
  String get onboardingTitle2 => 'Fair Prices,\nEvery Season';

  @override
  String get onboardingSub2 =>
      'Prices anchored to real market rates. AI-powered insights help you set competitive prices and maximize your profits.';

  @override
  String get onboardingTitle3 => 'Trusted\nTransactions';

  @override
  String get onboardingSub3 =>
      'Verified farmers, quality-checked listings, and secure payments via Razorpay. Your harvest, your earnings — protected.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started 🌱';
}
