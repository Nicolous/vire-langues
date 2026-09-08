import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Clé pour stocker l'heure de la notification
  static const String _notificationTimeKey = 'notification_time';
  
  // Heure par défaut : 20h00
  static const int _defaultHour = 20;
  static const int _defaultMinute = 0;

  Future<void> init() async {
    // Initialiser les données de timezone
    tz.initializeTimeZones();
    
    // Obtenir le fuseau horaire local
    final String currentTimeZone = await _getLocalTimeZone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Configuration Android
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuration iOS
    final DarwinInitializationSettings initializationSettingsDarwin = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Gérer la réception de la notification
      },
    );

    // Configuration initiale
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Initialiser le plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Gérer le clic sur la notification
        _handleNotificationClick(response.payload);
      },
    );

    // Demander les permissions
    await _requestPermissions();

    // Planifier la notification quotidienne
    await _scheduleDailyNotification();
  }

  Future<String> _getLocalTimeZone() async {
    // Pour Android, on peut obtenir le timezone directement
    // Pour iOS, on utilise une approche différente
    try {
      final DateTime now = DateTime.now();
      final String timeZoneName = now.timeZoneName;
      
      // Mapper le nom du timezone à un identifiant tz
      // Cela peut nécessiter une correspondance personnalisée
      // Pour simplifier, on utilise le timezone par défaut
      return 'Europe/Paris'; // Par défaut pour la France
    } catch (e) {
      return 'Europe/Paris';
    }
  }

  Future<void> _requestPermissions() async {
    // Demander les permissions pour Android
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // Demander les permissions pour iOS
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _scheduleDailyNotification() async {
    // Obtenir l'heure de notification depuis les préférences
    final prefs = await SharedPreferences.getInstance();
    final String? savedTime = prefs.getString(_notificationTimeKey);
    
    TimeOfDay notificationTime;
    
    if (savedTime != null) {
      final parts = savedTime.split(':');
      notificationTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      // Heure par défaut : 20h00
      notificationTime = const TimeOfDay(hour: _defaultHour, minute: _defaultMinute);
      await _saveNotificationTime(notificationTime);
    }

    // Planifier la notification pour aujourd'hui à l'heure spécifiée
    await _scheduleNotificationAtTime(notificationTime);
  }

  Future<void> _scheduleNotificationAtTime(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si l'heure est déjà passée aujourd'hui, planifier pour demain
    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(const Duration(days: 1));
    }

    // Calculer la différence
    final durationUntilNotification = scheduledTime.difference(now);

    // Planifier la notification
    await _notificationsPlugin.zonedSchedule(
      0, // ID unique pour la notification quotidienne
      'Rappel Vire-Langues',
      "N'oubliez pas de pratiquer vos vire-langues aujourd'hui !",
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Rappels Quotidiens',
          channelDescription: 'Notifications quotidiennes pour pratiquer les vire-langues',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: 'default',
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Notification planifiée pour ${scheduledTime.toString()}');
  }

  Future<void> _saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, '${time.hour}:${time.minute}');
  }

  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTime = prefs.getString(_notificationTimeKey);
    
    if (savedTime != null) {
      final parts = savedTime.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    
    return const TimeOfDay(hour: _defaultHour, minute: _defaultMinute);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _saveNotificationTime(time);
    await _rescheduleDailyNotification(time);
  }

  Future<void> _rescheduleDailyNotification(TimeOfDay time) async {
    // Annuler la notification existante
    await _notificationsPlugin.cancel(0);
    
    // Planifier une nouvelle notification
    await _scheduleNotificationAtTime(time);
  }

  Future<void> _handleNotificationClick(String? payload) async {
    debugPrint('Notification cliquée avec payload: $payload');
    // Ici, on pourrait naviguer vers une page spécifique
    // Par exemple, ouvrir l'écran d'accueil ou de pratique
  }

  Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      1,
      'Test Notification',
      'Ceci est une notification de test pour Vire-Langues',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Canal de test pour les notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelDailyNotification() async {
    await _notificationsPlugin.cancel(0);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (enabled) {
      await _scheduleDailyNotification();
    } else {
      await cancelDailyNotification();
    }
  }
}
