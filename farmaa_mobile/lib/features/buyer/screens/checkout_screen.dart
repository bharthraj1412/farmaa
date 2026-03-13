import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/order_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../generated/l10n/app_localizations.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final CropModel crop;
  final double quantity;

  const CheckoutScreen({
    super.key,
    required this.crop,
    required this.quantity,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    final totalAmount = widget.crop.pricePerKg * widget.quantity;
    final user = ref.read(currentUserProvider);
    ApiClient().resetCircuitBreaker();

    var options = {
      'key': AppConstants.razorpayKey,
      'amount': (totalAmount * 100).toInt(), // Amount in paise
      'name': 'Farmaa',
      'description': 'Purchase of ${widget.crop.name}',
      'prefill': {
        'contact': user?.phone ?? '9876543210',
        'email':
            '${user?.name.replaceAll(' ', '').toLowerCase() ?? 'user'}@farmaa.in'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    try {
      // POST order to backend via OrderService
      // ignore: unused_local_variable
      final order = await OrderService.instance.createOrder(
        cropId: widget.crop.id,
        quantityKg: widget.quantity,
        paymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        signature: response.signature,
      );

      if (mounted) {
        context.go(
          AppRoutes.orderConfirmation,
          extra: {
            'orderId': response.paymentId ??
                'ORD-${DateTime.now().millisecondsSinceEpoch}',
            'cropName': widget.crop.name,
            'quantity': widget.quantity,
            'totalAmount': widget.crop.pricePerKg * widget.quantity,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to record order: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showError('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showError('External wallet selected: ${response.walletName}');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.crop.pricePerKg * widget.quantity;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.checkout)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.orderSummary, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            _summaryRow(l.crop, widget.crop.name),
            _summaryRow(l.quantity, '${widget.quantity.toStringAsFixed(1)} kg'),
            _summaryRow(
                l.pricePerKg, '₹${widget.crop.pricePerKg.toStringAsFixed(2)}'),
            const Divider(height: 32),
            _summaryRow(l.totalAmount, '₹${totalAmount.toStringAsFixed(2)}',
                isBold: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startPayment,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l.payNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMedium)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              fontSize: isBold ? 18 : 14,
              color: isBold ? AppTheme.primaryGreen : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
