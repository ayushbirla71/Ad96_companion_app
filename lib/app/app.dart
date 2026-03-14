// import 'package:flutter/material.dart';
// import 'theme.dart';
// import '../pages/login/login_page.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Ad96 CMS',
//       theme: appTheme,
//       home: const LoginPage(),
//     );
//   }
// }


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
//       debugShowCheckedModeBanner: false,
//       home: Consumer<AuthProvider>(
//         builder: (context, auth, _) {
//           // if (auth.loading) {
//           //   return const Scaffold(
//           //     body: Center(child: CircularProgressIndicator()),
//           //   );
//           // }

//           return auth.isAuthenticated
//               ? const HomePage()
//               : const LoginPage();
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


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       navigatorKey: AppNavigator.navigatorKey,
      debugShowCheckedModeBanner: false,
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
