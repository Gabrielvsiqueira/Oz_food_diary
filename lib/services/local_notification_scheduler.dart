import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../configs/strings/string_extensions.dart';
import 'reminder_planner.dart';
import 'reminder_scheduler.dart';

/// Lembretes pelo `flutter_local_notifications`. No Android, o agendamento é
/// inexato (pode atrasar alguns minutos), o que dispensa a permissão de
/// alarme exato; para lembrar de uma refeição, isso basta.
class LocalNotificationScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'meal_reminders',
      AppStrings.reminderChannelName,
      channelDescription: AppStrings.reminderChannelDescription,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Fuso do aparelho e plugin. Chamado uma vez, antes do `runApp`.
  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (e) {
      debugPrint('Fuso do aparelho desconhecido ($e); usando São Paulo');
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // A permissão é pedida em [requestPermission], no momento certo.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> hasPermission() async {
    if (_android case final android?) {
      return await android.areNotificationsEnabled() ?? false;
    }
    if (_ios case final ios?) {
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    if (_android case final android?) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (_ios case final ios?) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await _plugin.cancelAll();
    for (final reminder in reminders) {
      final at = reminder.when;
      await _plugin.zonedSchedule(
        id: reminder.id,
        scheduledDate: tz.TZDateTime(
          tz.local,
          at.year,
          at.month,
          at.day,
          at.hour,
          at.minute,
        ),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: '${reminder.type.emoji} ${reminder.type.label}',
        body: AppStrings.reminderBody(reminder.type.label),
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
