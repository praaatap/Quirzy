import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quirzy/service/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Call markAsRead only once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).markAsRead();
      
      // ✅ Log FCM token to console for testing
      final fcmToken = ref.read(notificationProvider).fcmToken;
      if (fcmToken != null) {
        debugPrint('═' * 60);
        debugPrint('📱 FCM TOKEN FOR TESTING');
        debugPrint('═' * 60);
        debugPrint(fcmToken);
        debugPrint('═' * 60);
        debugPrint('Copy this token and use it in Firebase Console → Messaging → Send test message');
        debugPrint('═' * 60);
      } else {
        debugPrint('⚠️ No FCM token available yet');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () => _showClearAllDialog(context),
            ),
        ],
      ),
      body: notificationState.notifications.isEmpty
          ? _buildEmptyState(context, notificationState.fcmToken)
          : Column(
              children: [
                // FCM Token Section (collapsible)
                _buildTokenSection(context, notificationState.fcmToken),
                const Divider(height: 1),
                // Notifications List
                Expanded(
                  child: ListView.builder(
                    itemCount: notificationState.notifications.length,
                    itemBuilder: (context, index) {
                      final message = notificationState.notifications[index];
                      return _buildNotificationItem(context, message, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? fcmToken) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ✅ Show FCM token even when no notifications
          if (fcmToken != null) ...[
            _buildTokenSection(context, fcmToken),
            const Divider(height: 1),
            const SizedBox(height: 40),
          ],
          // Empty state
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll see challenge invites and updates here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // ✅ Helper card for testing
                if (fcmToken != null)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, size: 40, color: Colors.blue),
                          const SizedBox(height: 12),
                          const Text(
                            'Test Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap on "FCM Token" above to copy your token, then send a test notification from Firebase Console.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSection(BuildContext context, String? fcmToken) {
    return ExpansionTile(
      leading: const Icon(Icons.vpn_key),
      title: const Text('FCM Token'),
      subtitle: Text(
        fcmToken != null ? 'Tap to view and copy' : 'No token available',
        style: const TextStyle(fontSize: 12),
      ),
      // ✅ Expanded by default if no notifications
      initiallyExpanded: ref.read(notificationProvider).notifications.isEmpty,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Show token status
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fcmToken != null ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      fcmToken != null ? Icons.check_circle : Icons.error,
                      color: fcmToken != null ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fcmToken != null 
                            ? 'Token is active and ready for notifications'
                            : 'Token not available - check permissions',
                        style: TextStyle(
                          fontSize: 12,
                          color: fcmToken != null ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Token display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  fcmToken ?? 'No token available',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: fcmToken != null
                          ? () {
                              Clipboard.setData(ClipboardData(text: fcmToken));
                              // ✅ Also log to console when copied
                              debugPrint('📋 FCM Token copied to clipboard');
                              debugPrint('Token: $fcmToken');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Token copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Token'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ✅ Add refresh button
                  IconButton(
                    onPressed: () {
                      final token = ref.read(notificationProvider).fcmToken;
                      if (token != null) {
                        debugPrint('═' * 60);
                        debugPrint('🔄 REFRESHED FCM TOKEN');
                        debugPrint('═' * 60);
                        debugPrint(token);
                        debugPrint('═' * 60);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check console for token'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Print token to console',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ✅ Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How to test notifications:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Copy the token above\n'
                      '2. Go to Firebase Console → Messaging\n'
                      '3. Click "New campaign"\n'
                      '4. Click "Send test message"\n'
                      '5. Paste your token and click Test',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, dynamic message, int index) {
    final notification = message.notification;
    final data = message.data as Map<String, dynamic>;
    final type = data['type'] ?? 'unknown';

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'challenge_invite':
        icon = Icons.emoji_events;
        iconColor = Colors.orange;
        break;
      case 'challenge_accepted':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'challenge_rejected':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blue;
    }

    return Dismissible(
      key: Key(message.messageId ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(notificationProvider.notifier).deleteNotification(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            notification?.title ?? 'Notification',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification?.body ?? 'No message'),
              const SizedBox(height: 4),
              Text(
                message.sentTime != null
                    ? timeago.format(message.sentTime!)
                    : 'Just now',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showNotificationDetails(context, message),
        ),
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, dynamic message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notification Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow('Title', message.notification?.title ?? 'N/A'),
              _buildDetailRow('Body', message.notification?.body ?? 'N/A'),
              _buildDetailRow('Type', message.data['type'] ?? 'unknown'),
              _buildDetailRow('Sent Time', message.sentTime?.toString() ?? 'Unknown'),
              const SizedBox(height: 16),
              const Text(
                'Data Payload',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  message.data.toString(),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
