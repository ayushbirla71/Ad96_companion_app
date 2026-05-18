

// import 'package:cms_app/utils/app_navigator.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../pages/login/login_page.dart';
// import '../pages/home/home_page.dart';


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//        navigatorKey: AppNavigator.navigatorKey,
//       //  initialRoute: '/',
//       debugShowCheckedModeBanner: false,
//       home: Consumer<AuthProvider>(
//         builder: (_, auth, __) {

//           // 🔄 WAIT STATE (VERY IMPORTANT)
//           if (auth.isChecking) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }

//           // ✅ LOGGED IN
//           if (auth.isAuthenticated) {
//             return const HomePage();
//           }

//           // ❌ NOT LOGGED IN
//           return const LoginPage();
//         },
//       ),
//     );
//   }
// }


import 'package:cms_app/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/login/login_page.dart';
import '../pages/home/home_page.dart';

// 👇 1. IMPORT YOUR COLORS HERE!
import '../theme/app_colors.dart'; // Adjust this path if your colors file is somewhere else!

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      // initialRoute: '/', // Keep this removed!
      debugShowCheckedModeBanner: false,

      // 👇 2. ADD THIS THEME BLOCK FOR YOUR CUSTOM BACK BUTTONS
      theme: ThemeData(
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (BuildContext context) {
            return Container(
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
            );
          },
        ),
      ),
      // 👆 END THEME BLOCK

      home: Consumer<AuthProvider>(
        builder: (_, auth, __) {

          // 🔄 WAIT STATE (VERY IMPORTANT)
          if (auth.isChecking) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ LOGGED IN
          if (auth.isAuthenticated) {
            return const HomePage();
          }

          // ❌ NOT LOGGED IN
          return const LoginPage();
        },
      ),
    );
  }
}