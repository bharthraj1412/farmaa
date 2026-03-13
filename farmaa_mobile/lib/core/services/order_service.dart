import '../api/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final _dio = ApiClient().dio;

  /// Fetches the current user's order history.
  Future<List<OrderModel>> getMyOrders() async {
    final response = await _dio.get('/orders/my-orders');
    final list = (response.data as List<dynamic>?) ?? [];
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Places a new order.
  Future<OrderModel> createOrder({
    required String cropId,
    required double quantityKg,
    String? paymentId,
    String? razorpayOrderId,
    String? signature,
  }) async {
    final response = await _dio.post('/orders/', data: {
      'crop_id': cropId,
      'quantity_kg': quantityKg,
      if (paymentId != null) 'payment_id': paymentId,
      if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
      if (signature != null) 'razorpay_signature': signature,
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches orders received by a farmer.
  Future<List<OrderModel>> getReceivedOrders() async {
    final response = await _dio.get('/orders/my-orders');
    final list = (response.data as List<dynamic>?) ?? [];
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Updates the status of an order (e.g., confirm, shipper, cancel).
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await _dio.patch(
      '/orders/$orderId/status',
      data: {'status': status},
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
