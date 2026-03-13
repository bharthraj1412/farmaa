import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';

// ── Tamil Nadu Districts ──────────────────────────────────────────────────────
const List<String> _tnDistricts = [
  'Ariyalur',
  'Chengalpattu',
  'Chennai',
  'Coimbatore',
  'Cuddalore',
  'Dharmapuri',
  'Dindigul',
  'Erode',
  'Kallakurichi',
  'Kancheepuram',
  'Kanyakumari',
  'Karur',
  'Krishnagiri',
  'Madurai',
  'Mayiladuthurai',
  'Nagapattinam',
  'Namakkal',
  'Nilgiris',
  'Perambalur',
  'Pudukkottai',
  'Ramanathapuram',
  'Ranipet',
  'Salem',
  'Sivaganga',
  'Tenkasi',
  'Thanjavur',
  'Theni',
  'Thoothukudi',
  'Tiruchirappalli',
  'Tirunelveli',
  'Tirupathur',
  'Tiruppur',
  'Tiruvallur',
  'Tiruvannamalai',
  'Tiruvarur',
  'Vellore',
  'Viluppuram',
  'Virudhunagar',
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Step tracking
  int _step = 0; // 0=Phone, 1=OTP+Role, 2=Profile

  // Controllers
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();

  String? _selectedDistrict;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGoogleLogin = false;

  // Resend OTP countdown
  int _resendCountdown = 30;
  bool _canResend = false;

  late AnimationController _stepController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _stepController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _stepController, curve: Curves.easeOutCubic));
    _stepController.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _villageCtrl.dispose();
    _orgCtrl.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      if (_resendCountdown <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  Future<void> _goToNextStep() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_step == 0) {
        // Send OTP
        await ref
            .read(authProvider.notifier)
            .sendOtp('+91${_phoneCtrl.text.trim()}');
        _startCountdown();
        _animateStep(1);
      } else if (_step == 1) {
        // Go to profile details
        _animateStep(2);
      } else {
        if (_isGoogleLogin) {
          // Google login — complete with profile
          await ref.read(authProvider.notifier).loginWithGoogle(
                role: AppConstants.roleFarmer, // Send a default unified role
                village: _villageCtrl.text.trim().isNotEmpty ? _villageCtrl.text.trim() : null,
                district: _selectedDistrict,
                organization: _orgCtrl.text.trim().isNotEmpty ? _orgCtrl.text.trim() : null,
              );
        } else {
          // OTP login — verify OTP + create account
          await ref.read(authProvider.notifier).verifyOtp(
                phone: '+91${_phoneCtrl.text.trim()}',
                otp: _otpCtrl.text.trim(),
                role: AppConstants.roleFarmer, // Send a default unified role
                name: _nameCtrl.text.trim(),
                village: _villageCtrl.text.trim().isNotEmpty ? _villageCtrl.text.trim() : null,
                district: _selectedDistrict,
                organization: _orgCtrl.text.trim().isNotEmpty ? _orgCtrl.text.trim() : null,
              );
        }
        // Router will auto-redirect based on role
      }
    } catch (e) {
      setState(
          () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _animateStep(int next) {
    _stepController.reset();
    setState(() => _step = next);
    _stepController.forward();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLogin = true;
      _errorMessage = null;
    });
    // Skip phone/OTP — jump straight to role selection
    _animateStep(1);
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .sendOtp('+91${_phoneCtrl.text.trim()}');
      _startCountdown();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Apply SingleChildScrollView wrap around the whole structure to prevent bottom overflow
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🌾', style: TextStyle(fontSize: 40)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register for ${l.appName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepSubtitle(l),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          // Progress indicators
                          Row(
                            children:
                                List.generate(3, (i) => _buildStepDot(i)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceCream,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildCurrentStep(l),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepSubtitle(AppLocalizations l) {
    switch (_step) {
      case 0:
        return l.enterPhoneStep;
      case 1:
        return l.verifyOtpStep;
      case 2:
        return l.profileStep;
      default:
        return '';
    }
  }

  Widget _buildStepDot(int index) {
    final isActive = _step >= index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l) {
    switch (_step) {
      case 0:
        return _buildPhoneStep(l);
      case 1:
        return _buildOtpStep(l);
      case 2:
        return _buildProfileStep(l);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhoneStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.mobileNumber, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            prefixText: '+91  ',
            prefixStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            hintText: '98765 43210',
            suffixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return l.enterPhone;
            if (v.length != 10) return l.enterPhone;
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(l.enterPhoneStep, style: Theme.of(context).textTheme.bodySmall),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
        const SizedBox(height: 24),
        _buildSubmitButton(l.sendOtp),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR',
                  style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            icon: const Text('G',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4))),
            label: const Text('Sign in with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textDark,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Already have an account? Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isGoogleLogin) ...[
          Text(l.enterOtp, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l.otpSentTo(_phoneCtrl.text),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            decoration: const InputDecoration(hintText: '• • • • • •'),
            validator: (v) {
              if (_isGoogleLogin) return null;
              if (v == null || v.isEmpty) return l.enterOtp;
              if (v.length != 6) return l.enterOtp;
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend ? l.resendOtp : l.resendIn(_resendCountdown),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Text('G',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4))),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Google Account',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Continue to complete profile',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Color(0xFF34A853), size: 22),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
        const SizedBox(height: 24),
        _buildSubmitButton(l.continue_btn),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              if (_isGoogleLogin) {
                setState(() => _isGoogleLogin = false);
              }
              _animateStep(0);
            },
            child: Text(_isGoogleLogin ? l.back : l.changeNumber),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.yourName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l.fullName,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? l.yourName : null,
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        Text(l.village, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _villageCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Kovilpatti',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.district, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
        initialValue: _selectedDistrict,
          items: _tnDistricts
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (v) => setState(() => _selectedDistrict = v),
          decoration: InputDecoration(
            hintText: l.selectDistrict,
            prefixIcon: const Icon(Icons.map_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.organization, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _orgCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., Sri Balaji Traders (Optional)',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],
        const SizedBox(height: 24),
        _buildSubmitButton(l.createAccount),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _animateStep(1),
            child: Text(l.back),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _goToNextStep,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
