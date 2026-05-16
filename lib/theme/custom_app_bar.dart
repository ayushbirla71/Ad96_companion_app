import 'package:cms_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onRefresh;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onRefresh,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      leading: showBack
          ? IconButton(
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
            )
          : null,

      title: Text(
        title,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

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

        const SizedBox(width: 4),
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
