import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vire_langues/services/notification_service.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/services/data_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationService = NotificationService();
    _notificationsEnabled = await notificationService.areNotificationsEnabled();
    _notificationTime = await notificationService.getNotificationTime();
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notifications
            _buildNotificationsSection(),
            const SizedBox(height: 24),

            // Heure de notification
            _buildNotificationTimeSection(),
            const SizedBox(height: 24),

            // Données
            _buildDataSection(),
            const SizedBox(height: 24),

            // À propos
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recevez un rappel quotidien pour pratiquer vos vire-langues.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Activer les notifications'),
              subtitle: const Text('Recevoir un rappel quotidien à 20h00'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                final notificationService = NotificationService();
                await notificationService.setNotificationsEnabled(value);
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTimeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Heure de Notification',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez l\'heure à laquelle vous souhaitez recevoir le rappel quotidien.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showTimePicker(),
                  child: const Text('Modifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final notificationService = NotificationService();
      await notificationService.setNotificationTime(pickedTime);
      
      setState(() {
        _notificationTime = pickedTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Heure de notification mise à jour: ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildDataSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Données',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Réinitialiser les données
            OutlinedButton.icon(
              onPressed: () => _showResetDataDialog(),
              icon: const Icon(Icons.refresh, color: AppColors.error),
              label: const Text(
                'Réinitialiser toutes les données',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cela supprimera tous vos vire-langues personnalisés, séries et progression.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetDataDialog() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les données'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toutes vos données ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      await DataService().resetAllData(ref);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les données ont été réinitialisées'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'À propos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              trailing: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text('Développeur'),
              trailing: const Text('Nicolous'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: const Text(
                'Application mobile pour pratiquer les vire-langues avec des rappels quotidiens.',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vire-Langues est une application conçue pour vous aider à améliorer votre élocution et votre prononciation grâce à une collection de vire-langues en français.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
