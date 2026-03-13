import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Service to automatically discover the backend IP on the local network.
class DiscoveryService {
  DiscoveryService._();
  static final DiscoveryService instance = DiscoveryService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 1), // Increased from 500ms
    receiveTimeout: const Duration(seconds: 1),
  ));

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Scans the local subnet for a FastAPI backend on port 8000.
  Future<String?> discoverBackend() async {
    if (_isSearching) return null;
    _isSearching = true;

    try {
      debugPrint('[Discovery] Starting local network scan...');

      // 1. Try the current baseUrl first (it might have been fixed or be 10.0.2.2)
      if (await _probeIp(AppConstants.baseUrl)) {
        debugPrint('[Discovery] Current baseUrl is valid.');
        return AppConstants.baseUrl;
      }

      // 2. Get local interfaces
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;

          final subnet = ip.substring(0, ip.lastIndexOf('.'));
          debugPrint('[Discovery] Probing subnet: $subnet.x');

          // Probe common suffix (computer is often .1 or .100 or close to the phone)
          // We scan in parallel chunks to avoid overwhelming the socket limit
          final found = await _scanSubnet(subnet, ip);
          if (found != null) return found;
        }
      }
    } catch (e) {
      debugPrint('[Discovery] Scan failed: $e');
    } finally {
      _isSearching = false;
    }
    return null;
  }

  Future<String?> _scanSubnet(String subnetPrefix, String myFullIp) async {
    final mySuffix = int.tryParse(myFullIp.split('.').last) ?? 100;

    // Prioritize: 1. Gateway (.1), 2. Immediate neighbors (+/- 5), 3. Common suffixes
    final Set<int> priorities = {1, 100, 101, 102, 2};
    for (var i = -5; i <= 5; i++) {
      int s = mySuffix + i;
      if (s > 0 && s < 255) priorities.add(s);
    }

    final List<int> others = List.generate(254, (i) => i + 1)
      ..removeWhere((i) => priorities.contains(i));

    final allToScan = [...priorities, ...others];

    // Scan in chunks of 15 (politer to mobile network stack to avoid freezes)
    for (var i = 0; i < allToScan.length; i += 15) {
      final chunk = allToScan.skip(i).take(15);
      final results = await Future.wait(
        chunk.map((suffix) {
          final target = 'http://$subnetPrefix.$suffix:10000';
          return _probeIp(target).then((ok) => ok ? target : null);
        }),
      );

      final winner = results.firstWhere((r) => r != null, orElse: () => null);
      if (winner != null) return winner;

      // Small breather to prevent OS congestion
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return null;
  }

  Future<bool> _probeIp(String url) async {
    try {
      // Use short timeout for local proximity
      final response =
          await _dio.get(url).timeout(const Duration(milliseconds: 400));
      return response.statusCode != null;
    } catch (_) {
      return false;
    }
  }
}
