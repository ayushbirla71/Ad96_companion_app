import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onRefresh;

  final bool showBack;

  const DashboardAppBar({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onRefresh,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,

      /// BACK BUTTON
      // leading: showBack
      //     ? IconButton(
      //         icon: Container(
      //           width: 34,
      //           height: 34,
      //           decoration: BoxDecoration(
      //             color: appColors.surfaceHigh,
      //             shape: BoxShape.circle,
      //             border: Border.all(color: appColors.border),
      //           ),
      //           child: Icon(
      //             Icons.arrow_back_ios_new_rounded,
      //             color: appColors.textSecondary,
      //             size: 15,
      //           ),
      //         ),
      //         onPressed: () => Navigator.pop(context),
      //       )
      //     : null,

      /// TITLE AREA
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColors.accent, const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),

                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: appColors.textMuted,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      /// ACTIONS
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: appColors.surfaceHigh,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.border),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: appColors.textSecondary,
                size: 17,
              ),
            ),
            onPressed: onRefresh,
          ),

        const SizedBox(width: 8),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: appColors.border),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
