import 'package:flutter/material.dart';
import 'package:cms_app/theme/app_colors.dart';

// ─── Notification Model ───────────────────────────────────────────────────────

enum NotificationCategory { system, device, schedule, alert, update, welcome }

enum NotificationPriority { low, medium, high, critical }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? detail;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime timestamp;
  bool isRead;
  final bool isPinned;
  final String? actionLabel;
  final VoidCallback? onAction;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.detail,
    required this.category,
    this.priority = NotificationPriority.low,
    required this.timestamp,
    this.isRead = false,
    this.isPinned = false,
    this.actionLabel,
    this.onAction,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── Filter state ──
  NotificationCategory? _activeFilter; // null = All

  // ── Expanded notification id ──
  String? _expandedId;

  // ── Notifications list (seeded with welcome, ready for real data) ──
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _notifications = _seedNotifications();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Seed data (replace with API call when ready) ──────────────────────────

  List<AppNotification> _seedNotifications() {
    return [
      AppNotification(
        id: 'welcome_001',
        title: 'Welcome to CMS Dashboard 🎉',
        body:
            'Your content management system is set up and ready to go. Start by adding your first device or scheduling a campaign.',
        detail:
            'Everything is configured and running smoothly. Here\'s what you can do next:\n\n'
            '• Add your first device group under Devices\n'
            '• Upload media assets under Ads\n'
            '• Create your first schedule under Schedules\n'
            '• Explore Carousels and Live Content for advanced campaigns\n\n'
            'Our team is here to help if you need anything. Reach out to your sales representative anytime.',
        category: NotificationCategory.welcome,
        priority: NotificationPriority.low,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isRead: false,
        isPinned: true,
        actionLabel: 'Get Started',
      ),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<AppNotification> get _filtered {
    if (_activeFilter == null) return _notifications;
    return _notifications.where((n) => n.category == _activeFilter).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    _snack('All notifications marked as read');
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  void _dismiss(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      if (_expandedId == id) _expandedId = null;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: appColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Category helpers ──────────────────────────────────────────────────────

  IconData _categoryIcon(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.welcome:
        return Icons.waving_hand_rounded;
      case NotificationCategory.system:
        return Icons.settings_rounded;
      case NotificationCategory.device:
        return Icons.tv_rounded;
      case NotificationCategory.schedule:
        return Icons.event_note_rounded;
      case NotificationCategory.alert:
        return Icons.warning_amber_rounded;
      case NotificationCategory.update:
        return Icons.system_update_rounded;
    }
  }

  Color _categoryColor(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.welcome:
        return appColors.accent;
      case NotificationCategory.system:
        return appColors.purple;
      case NotificationCategory.device:
        return appColors.teal;
      case NotificationCategory.schedule:
        return appColors.green;
      case NotificationCategory.alert:
        return appColors.orange;
      case NotificationCategory.update:
        return appColors.yellow;
    }
  }

  Color _categoryBg(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.welcome:
        return appColors.accentLight;
      case NotificationCategory.system:
        return appColors.purpleLight;
      case NotificationCategory.device:
        return appColors.tealLight;
      case NotificationCategory.schedule:
        return appColors.greenLight;
      case NotificationCategory.alert:
        return appColors.orangeLight;
      case NotificationCategory.update:
        return appColors.yellowLight;
    }
  }

  Color _priorityColor(NotificationPriority p) {
    switch (p) {
      case NotificationPriority.critical:
        return appColors.red;
      case NotificationPriority.high:
        return appColors.orange;
      case NotificationPriority.medium:
        return appColors.yellow;
      case NotificationPriority.low:
        return appColors.green;
    }
  }

  String _categoryLabel(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.welcome:
        return 'Welcome';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.device:
        return 'Device';
      case NotificationCategory.schedule:
        return 'Schedule';
      case NotificationCategory.alert:
        return 'Alert';
      case NotificationCategory.update:
        return 'Update';
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.bg,
      appBar: _appBar(),
      body: FadeTransition(opacity: _fadeAnim, child: _body()),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: appColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: appColors.surfaceHigh,
          shape: BoxShape.circle,
          border: Border.all(color: appColors.border),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: appColors.textSecondary,
          size: 15,
        ),
      ),
      onPressed: () => Navigator.pop(context),
    ),
    title: Row(
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (_unreadCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: appColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    ),
    actions: [
      if (_unreadCount > 0)
        TextButton(
          onPressed: _markAllRead,
          child: Text(
            'Mark all read',
            style: TextStyle(
              color: appColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      const SizedBox(width: 4),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: appColors.border),
    ),
  );

  Widget _body() {
    final filtered = _filtered;

    return Column(
      children: [
        // ── Filter chips ──
        _filterRow(),

        // ── List ──
        Expanded(
          child: filtered.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final n = filtered[i];
                    return _NotificationCard(
                      notification: n,
                      isExpanded: _expandedId == n.id,
                      categoryIcon: _categoryIcon(n.category),
                      categoryColor: _categoryColor(n.category),
                      categoryBg: _categoryBg(n.category),
                      priorityColor: _priorityColor(n.priority),
                      timeAgo: _timeAgo(n.timestamp),
                      onTap: () {
                        setState(() {
                          _expandedId = _expandedId == n.id ? null : n.id;
                        });
                        if (!n.isRead) _markRead(n.id);
                      },
                      onDismiss: () => _dismiss(n.id),
                      onMarkRead: () => _markRead(n.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Filter chips row ──────────────────────────────────────────────────────

  Widget _filterRow() {
    final categories = [
      null, // All
      NotificationCategory.welcome,
      NotificationCategory.alert,
      NotificationCategory.device,
      NotificationCategory.schedule,
      NotificationCategory.system,
      NotificationCategory.update,
    ];

    return Container(
      color: appColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isActive = _activeFilter == cat;
            final label = cat == null ? 'All' : _categoryLabel(cat);
            final color = cat == null ? appColors.accent : _categoryColor(cat);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : appColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? color : appColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat != null) ...[
                        Icon(
                          _categoryIcon(cat),
                          size: 12,
                          color: isActive ? Colors.white : color,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : appColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: appColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: appColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alerts, device updates, and system\nmessages will appear here.',
            style: TextStyle(
              color: appColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final bool isExpanded;
  final IconData categoryIcon;
  final Color categoryColor;
  final Color categoryBg;
  final Color priorityColor;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onMarkRead;

  const _NotificationCard({
    required this.notification,
    required this.isExpanded,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryBg,
    required this.priorityColor,
    required this.timeAgo,
    required this.onTap,
    required this.onDismiss,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final isUnread = !n.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(n.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: appColors.redLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: appColors.red,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                'Remove',
                style: TextStyle(
                  color: appColors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) => onDismiss(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnread
                    ? categoryColor.withOpacity(0.35)
                    : appColors.border,
                width: isUnread ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? categoryColor.withOpacity(0.08)
                      : appColors.shadow,
                  blurRadius: isUnread ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Main row ──
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with unread dot
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: categoryBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              categoryIcon,
                              color: categoryColor,
                              size: 22,
                            ),
                          ),
                          if (isUnread)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          if (n.isPinned)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: appColors.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.push_pin_rounded,
                                  size: 7,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + time
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: TextStyle(
                                      color: appColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    color: appColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            // Body
                            Text(
                              n.body,
                              style: TextStyle(
                                color: appColors.textSecondary,
                                fontSize: 12,
                                height: 1.5,
                              ),
                              maxLines: isExpanded ? 100 : 2,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Category + expand chevron
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        categoryIcon,
                                        size: 10,
                                        color: categoryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        n.category.name
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            n.category.name.substring(1),
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: appColors.textMuted,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Expanded detail ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child:
                      isExpanded && (n.detail != null || n.actionLabel != null)
                      ? Column(
                          children: [
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: appColors.borderLight,
                              indent: 14,
                              endIndent: 14,
                            ),
                            if (n.detail != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  0,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: appColors.surfaceHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: appColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    n.detail!,
                                    style: TextStyle(
                                      color: appColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.65,
                                    ),
                                  ),
                                ),
                              ),

                            // ── Action row ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                14,
                              ),
                              child: Row(
                                children: [
                                  // Dismiss button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: onDismiss,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: appColors.textMuted,
                                      ),
                                      label: Text(
                                        'Dismiss',
                                        style: TextStyle(
                                          color: appColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        side: BorderSide(
                                          color: appColors.border,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (n.actionLabel != null) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {
                                          n.onAction?.call();
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          n.actionLabel!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: categoryColor,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
