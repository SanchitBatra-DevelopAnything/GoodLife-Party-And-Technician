import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

/// Listens in real-time to the logged-in party's node in the Firebase
/// Realtime Database under `Distributors/{autoKey}`.
///
/// The correct node is found by matching the `contact` field against the
/// logged-in party's mobile number.
///
/// Call [startListening] with the party's mobile number after login, and
/// [stopListening] on logout.
class OutstandingBalanceProvider extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  StreamSubscription<DatabaseEvent>? _subscription;
  String? _trackedKey; // RTDB auto-key of the matched distributor node

  // null = still loading / not yet fetched
  bool? _payLater;
  double _outstandingBalance = 0.0;
  bool _isLoading = false;

  bool? get payLater => _payLater;
  double get outstandingBalance => _outstandingBalance;
  bool get isLoading => _isLoading;

  /// Start a real-time listener for the party whose `contact` field equals
  /// [mobile] inside the `Distributors` RTDB path.
  Future<void> startListening(String mobile) async {
    if (mobile.isEmpty) return;

    // Avoid duplicate listeners
    stopListening();

    _isLoading = true;
    _payLater = null;
    notifyListeners();

    try {
      // Step 1: One-time query to find the auto-key matching this mobile
      final ref = _db.ref('Distributors');
      final snapshot = await ref
          .orderByChild('contact')
          .equalTo(mobile)
          .limitToFirst(1)
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        // Party not found in RTDB
        _payLater = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Extract the auto-key
      final Map<dynamic, dynamic> data =
          Map<dynamic, dynamic>.from(snapshot.value as Map);
      _trackedKey = data.keys.first as String;

      // Step 2: Subscribe to real-time changes on that specific node
      _subscription = _db
          .ref('Distributors/$_trackedKey')
          .onValue
          .listen(
            (event) {
              if (!event.snapshot.exists || event.snapshot.value == null) {
                _payLater = false;
                _outstandingBalance = 0.0;
              } else {
                final nodeData =
                    Map<dynamic, dynamic>.from(event.snapshot.value as Map);
                _payLater = nodeData['allowPayLater'] as bool? ?? false;
                final rawBalance = nodeData['outstandingBalance'];
                _outstandingBalance = rawBalance != null
                    ? (rawBalance as num).toDouble()
                    : 0.0;
              }
              _isLoading = false;
              notifyListeners();
            },
            onError: (e) {
              debugPrint('OutstandingBalanceProvider RTDB error: $e');
              _payLater = false;
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('OutstandingBalanceProvider init error: $e');
      _payLater = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stop the real-time listener (call on logout).
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _trackedKey = null;
    _payLater = null;
    _outstandingBalance = 0.0;
    _isLoading = false;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
