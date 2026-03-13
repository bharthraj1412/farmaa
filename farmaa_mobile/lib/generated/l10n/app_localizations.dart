import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Farmaa'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'From Farm to Future'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to +91 {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a...'**
  String get iAmA;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// No description provided for @farmerDesc.
  ///
  /// In en, this message translates to:
  /// **'List your grains & manage crops'**
  String get farmerDesc;

  /// No description provided for @buyerDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse and order grains'**
  String get buyerDesc;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🌱'**
  String get createAccount;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'← Change number'**
  String get changeNumber;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get back;

  /// No description provided for @enterPhoneStep.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to continue'**
  String get enterPhoneStep;

  /// No description provided for @verifyOtpStep.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP and select your role'**
  String get verifyOtpStep;

  /// No description provided for @profileStep.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about yourself'**
  String get profileStep;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name *'**
  String get yourName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District *'**
  String get district;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrict;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization / Company'**
  String get organization;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market Price'**
  String get marketPrice;

  /// No description provided for @pricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price / kg'**
  String get pricePerKg;

  /// No description provided for @stockAvailable.
  ///
  /// In en, this message translates to:
  /// **'Stock Available'**
  String get stockAvailable;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Min. Order'**
  String get minOrder;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @allGrains.
  ///
  /// In en, this message translates to:
  /// **'All Grains'**
  String get allGrains;

  /// No description provided for @listingsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} listings found'**
  String listingsFound(int count);

  /// No description provided for @searchCrops.
  ///
  /// In en, this message translates to:
  /// **'Search grains...'**
  String get searchCrops;

  /// No description provided for @noGrainsFound.
  ///
  /// In en, this message translates to:
  /// **'No grains found'**
  String get noGrainsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category'**
  String get tryDifferentSearch;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @enterDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter full delivery address'**
  String get enterDeliveryAddress;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Go back to the marketplace and add items.'**
  String get cartEmptyHint;

  /// No description provided for @browseGrains.
  ///
  /// In en, this message translates to:
  /// **'Browse Grains'**
  String get browseGrains;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed! 🎉'**
  String get orderPlaced;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed and sent to the farmer.'**
  String get orderConfirmed;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @ordersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get ordersAppearHere;

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetail;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @farmerContact.
  ///
  /// In en, this message translates to:
  /// **'Farmer Contact'**
  String get farmerContact;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @shipOrder.
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get shipOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @buyerInfo.
  ///
  /// In en, this message translates to:
  /// **'Buyer Info'**
  String get buyerInfo;

  /// No description provided for @listNewGrain.
  ///
  /// In en, this message translates to:
  /// **'List New Grain'**
  String get listNewGrain;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @grainCategory.
  ///
  /// In en, this message translates to:
  /// **'Grain Category *'**
  String get grainCategory;

  /// No description provided for @grainName.
  ///
  /// In en, this message translates to:
  /// **'Grain Name *'**
  String get grainName;

  /// No description provided for @grainNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Basmati Rice'**
  String get grainNameHint;

  /// No description provided for @variety.
  ///
  /// In en, this message translates to:
  /// **'Variety (optional)'**
  String get variety;

  /// No description provided for @varietyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., HHB 67, K 9107'**
  String get varietyHint;

  /// No description provided for @priceKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per kg (₹) *'**
  String get priceKgLabel;

  /// No description provided for @stockKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Available (kg) *'**
  String get stockKgLabel;

  /// No description provided for @minOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order (kg)'**
  String get minOrderLabel;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe grain quality, growing conditions, certifications...'**
  String get descriptionHint;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReview;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @qaNotice.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be reviewed by our quality team before going live.'**
  String get qaNotice;

  /// No description provided for @cropUpdated.
  ///
  /// In en, this message translates to:
  /// **'Grain updated! Pending QA review.'**
  String get cropUpdated;

  /// No description provided for @cropSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Grain submitted for QA approval! ✅'**
  String get cropSubmitted;

  /// No description provided for @marketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @receivedOrders.
  ///
  /// In en, this message translates to:
  /// **'Received Orders'**
  String get receivedOrders;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Grains'**
  String get myCrops;

  /// No description provided for @addGrain.
  ///
  /// In en, this message translates to:
  /// **'Add Grain'**
  String get addGrain;

  /// No description provided for @verifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get verifiedAccount;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending ⓘ'**
  String get verificationPending;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChangesBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesBtn;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive app notifications'**
  String get pushNotificationsSubtitle;

  /// No description provided for @priceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price Alerts'**
  String get priceAlerts;

  /// No description provided for @priceAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify when market prices change'**
  String get priceAlertsSubtitle;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify on order status changes'**
  String get orderUpdatesSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// No description provided for @networkErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server. Please check your internet connection.'**
  String get networkErrorMsg;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @kycDesc.
  ///
  /// In en, this message translates to:
  /// **'To become a verified seller, please upload your Aadhaar or PAN card details.'**
  String get kycDesc;

  /// No description provided for @submitDocuments.
  ///
  /// In en, this message translates to:
  /// **'Submit Documents'**
  String get submitDocuments;

  /// No description provided for @documentsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted! Verification will complete in 24 hours.'**
  String get documentsSubmitted;

  /// No description provided for @aboutCrop.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutCrop;

  /// No description provided for @priceGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Price updated: {date}'**
  String priceGuarantee(String date);

  /// No description provided for @aiPriceInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Market Insight'**
  String get aiPriceInsight;

  /// No description provided for @farmerDistrict.
  ///
  /// In en, this message translates to:
  /// **'{district} District'**
  String farmerDistrict(String district);

  /// No description provided for @stockKg.
  ///
  /// In en, this message translates to:
  /// **'{stock} kg available'**
  String stockKg(String stock);

  /// No description provided for @grainRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get grainRice;

  /// No description provided for @grainWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get grainWheat;

  /// No description provided for @grainMillet.
  ///
  /// In en, this message translates to:
  /// **'Millet'**
  String get grainMillet;

  /// No description provided for @grainBarley.
  ///
  /// In en, this message translates to:
  /// **'Barley'**
  String get grainBarley;

  /// No description provided for @grainSorghum.
  ///
  /// In en, this message translates to:
  /// **'Sorghum'**
  String get grainSorghum;

  /// No description provided for @grainMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get grainMaize;

  /// No description provided for @grainPulses.
  ///
  /// In en, this message translates to:
  /// **'Pulses'**
  String get grainPulses;

  /// No description provided for @grainOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get grainOther;

  /// No description provided for @howCanIHelp.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your Farmaa AI Assistant. How can I help you today? You can ask me about crop prices, yield tips, or order assistance.'**
  String get howCanIHelp;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask anything...'**
  String get askAnything;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @yieldPrediction.
  ///
  /// In en, this message translates to:
  /// **'Yield Prediction'**
  String get yieldPrediction;

  /// No description provided for @sustainability.
  ///
  /// In en, this message translates to:
  /// **'Sustainability'**
  String get sustainability;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigation;

  /// No description provided for @predictYieldBtn.
  ///
  /// In en, this message translates to:
  /// **'Predict Yield ✨'**
  String get predictYieldBtn;

  /// No description provided for @predictedYield.
  ///
  /// In en, this message translates to:
  /// **'Predicted Yield'**
  String get predictedYield;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% confidence'**
  String confidence(String percentage);

  /// No description provided for @sustainabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate your farming practices and get an AI sustainability score (0–100).'**
  String get sustainabilityDesc;

  /// No description provided for @irrigationMethod.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Method'**
  String get irrigationMethod;

  /// No description provided for @fertilizerType.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Type'**
  String get fertilizerType;

  /// No description provided for @cropRotationPracticed.
  ///
  /// In en, this message translates to:
  /// **'Crop Rotation Practiced'**
  String get cropRotationPracticed;

  /// No description provided for @calculateScoreBtn.
  ///
  /// In en, this message translates to:
  /// **'Calculate Score ♻️'**
  String get calculateScoreBtn;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement ⚠️'**
  String get needsImprovement;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good 👍'**
  String get good;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent 🌟'**
  String get excellent;

  /// No description provided for @improvementTips.
  ///
  /// In en, this message translates to:
  /// **'Improvement Tips'**
  String get improvementTips;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @youreAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get youreAllCaughtUp;

  /// No description provided for @timeAgoM.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeAgoM(int minutes);

  /// No description provided for @timeAgoH.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeAgoH(int hours);

  /// No description provided for @timeAgoD.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeAgoD(int days);

  /// No description provided for @noPriceData.
  ///
  /// In en, this message translates to:
  /// **'No price data available'**
  String get noPriceData;

  /// No description provided for @todaysRate.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Rate'**
  String get todaysRate;

  /// No description provided for @quintal.
  ///
  /// In en, this message translates to:
  /// **'/quintal'**
  String get quintal;

  /// No description provided for @sevenDayTrend.
  ///
  /// In en, this message translates to:
  /// **'7-Day Price Trend'**
  String get sevenDayTrend;

  /// No description provided for @historicalData.
  ///
  /// In en, this message translates to:
  /// **'Historical Data'**
  String get historicalData;

  /// No description provided for @simulatedUploadReady.
  ///
  /// In en, this message translates to:
  /// **'Simulated Upload Ready'**
  String get simulatedUploadReady;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Sell Your Seeds\nDirectly'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSub1.
  ///
  /// In en, this message translates to:
  /// **'List millet and wheat crops with ease. Connect with verified buyers across India — no middlemen, higher profits.'**
  String get onboardingSub1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fair Prices,\nEvery Season'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSub2.
  ///
  /// In en, this message translates to:
  /// **'Prices anchored to real market rates. AI-powered insights help you set competitive prices and maximize your profits.'**
  String get onboardingSub2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Trusted\nTransactions'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSub3.
  ///
  /// In en, this message translates to:
  /// **'Verified farmers, quality-checked listings, and secure payments via Razorpay. Your harvest, your earnings — protected.'**
  String get onboardingSub3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started 🌱'**
  String get getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
