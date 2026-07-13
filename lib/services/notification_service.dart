import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/app_routes.dart';
import 'service_request_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ServiceRequestService _serviceRequestService = ServiceRequestService();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    // Request permission for iOS/Android
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    }

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications for foreground alerts
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create a high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.notification?.title}');
      final RemoteNotification? notification = message.notification;

      if (notification != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              priority: Priority.high,
              importance: Importance.max,
              playSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle when app is opened from background via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationPayload(message.data);
    });

    // Handle when app is opened from terminated state via notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationPayload(initialMessage.data);
    }
  }

  Future<String?> getToken() async {
    final token = await _fcm.getToken();
    print('🔔 FCM Token: $token');
    return token;
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationPayload(data);
      } catch (e) {
        print("Error parsing notification payload: $e");
      }
    }
  }

  void _handleNotificationPayload(Map<String, dynamic> data) {
    // Direct route key takes priority
    final String? route = data['route'];

    if (route != null) {
      navigatorKey.currentState?.pushNamed(route, arguments: data);
      return;
    }

    final String? type = data['type'];

    switch (type) {
      // Signup flow — admin approved or rejected the distributor request
      case 'signup_approved':
      case 'signup_rejected':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        break;

      // Spare part order accepted by admin
      case 'order_update':
        navigatorKey.currentState?.pushNamed(AppRoutes.myOrdersSpareParts);
        break;

      // Spare part order dispatched (shipped)
      case 'order_dispatched':
        navigatorKey.currentState?.pushNamed(AppRoutes.myOrdersSpareParts);
        break;

      // Order rejected by admin
      case 'order_rejected':
        navigatorKey.currentState?.pushNamed(AppRoutes.myOrdersSpareParts);
        break;

      // Service request updates for party users
      case 'service_request_assigned':
      case 'service_request_in_progress':
      case 'service_request_closed':
      case 'service_request_verified':
      case 'service_request_resolved':
      case 'service_request_update':
        _navigateToServiceRequest(data, forTechnician: false);
        break;

      // New assignment for technicians
      case 'technician_request_assigned':
      case 'technician_service_request':
      case 'technician_service_request_update':
        _navigateToServiceRequest(data, forTechnician: true);
        break;

      default:
        break;
    }
  }

  Future<void> _navigateToServiceRequest(
    Map<String, dynamic> data, {
    required bool forTechnician,
  }) async {
    final orderedBy = data['orderedBy']?.toString();
    final firebasePushId = data['firebasePushId']?.toString();

    if (orderedBy != null &&
        orderedBy.isNotEmpty &&
        firebasePushId != null &&
        firebasePushId.isNotEmpty) {
      try {
        final request = await _serviceRequestService.fetchServiceRequestByKey(
          orderedBy: orderedBy,
          firebasePushId: firebasePushId,
        );

        if (request != null) {
          navigatorKey.currentState?.pushNamed(
            forTechnician
                ? AppRoutes.technicianServiceRequestDetail
                : AppRoutes.serviceRequestDetails,
            arguments: request,
          );
          return;
        }
      } catch (e) {
        print('Failed to load service request for notification: $e');
      }
    }

    navigatorKey.currentState?.pushNamed(
      forTechnician
          ? AppRoutes.technicianServiceRequests
          : AppRoutes.myServiceRequests,
    );
  }
}
