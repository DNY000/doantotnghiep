import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkStatusService {
  static final NetworkStatusService _instance =
      NetworkStatusService._internal();
  factory NetworkStatusService() => _instance;
  NetworkStatusService._internal();

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<User?>? _authSub;

  bool _isConnectedToNetwork = true;
  bool _isConnectedToFirebase = true;
  bool _isInitialized = false;

  // Stream controller để thông báo thay đổi trạng thái mạng
  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionState => _connectionStateController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Kiểm tra trạng thái mạng ban đầu
    await _checkInitialConnectivity();

    // Lắng nghe mạng vật lý
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection =
          results.any((result) => result != ConnectivityResult.none);
      _isConnectedToNetwork = hasConnection;

      if (!hasConnection) {
        print('Mất kết nối mạng');
        _connectionStateController.add(false);
      } else {
        print('Đã kết nối lại mạng');
        await _checkFirebaseConnection();
      }
    });

    // Lắng nghe Firebase auth
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _isConnectedToFirebase = true;
        _connectionStateController
            .add(_isConnectedToNetwork && _isConnectedToFirebase);
      }
    });
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnectedToNetwork = !results.contains(ConnectivityResult.none);
      _connectionStateController.add(_isConnectedToNetwork);
    } catch (e) {
      print('Lỗi kiểm tra kết nối ban đầu: $e');
      _isConnectedToNetwork = false;
      _connectionStateController.add(false);
    }
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      print('Kết nối Firebase OK');
      _isConnectedToFirebase = true;
      _connectionStateController.add(true);
    } catch (e) {
      print('Lỗi kết nối Firebase: $e');
      _isConnectedToFirebase = false;
      _connectionStateController.add(false);
    }
  }

  Future<void> retryConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection =
          connectivityResult.any((result) => result != ConnectivityResult.none);
      _isConnectedToNetwork = hasConnection;

      if (hasConnection) {
        await _checkFirebaseConnection();
      } else {
        _connectionStateController.add(false);
      }
    } catch (e) {
      print('Lỗi khi thử kết nối lại: $e');
      _isConnectedToNetwork = false;
      _connectionStateController.add(false);
    }
  }

  bool get isConnected => _isConnectedToNetwork && _isConnectedToFirebase;
  bool get isNetworkConnected => _isConnectedToNetwork;
  bool get isFirebaseConnected => _isConnectedToFirebase;

  void dispose() {
    _connectivitySub?.cancel();
    _authSub?.cancel();
    _connectionStateController.close();
    _isInitialized = false;
  }
}
