import 'package:flutter/material.dart';
import 'package:melodica_app_new/models/student_models.dart';
import 'package:melodica_app_new/views/auth/change_password_screen.dart';
import 'package:melodica_app_new/views/auth/forgot_email_screen.dart';
import 'package:melodica_app_new/views/auth/login_screen.dart';
import 'package:melodica_app_new/views/auth/signup_screen.dart';
import 'package:melodica_app_new/views/auth/verification_code_screen.dart';
import 'package:melodica_app_new/views/dashboard/dashboard_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/receipt_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/home_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/new_student_screen.dart';
import 'package:melodica_app_new/views/onboarding/onboarding_screen.dart';
import 'package:melodica_app_new/views/profile/edit_profile_screen.dart';
import 'package:melodica_app_new/views/profile/order/order_screen.dart';
import 'package:melodica_app_new/views/profile/students/student_details.dart';
import 'package:melodica_app_new/views/profile/students/students_screen.dart';
import 'package:melodica_app_new/views/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const forget = '/forget';
  static const signup = '/signup';
  static const verification = '/verification_code';
  static const changepassword = '/changepassword';
  static const home = '/home';
  static const dashboard = '/dashboard';
  // static const packageSelection = '/packageSelection';
  static const newStudent = '/newStudent';
  static const editprofile = '/editprofile';
  static const ordersScreen = '/ordersScreen';
  static const receiptScreen = '/receiptScreen';
  static const studentsScreen = '/studentsScreen';
  static const studentDetails = '/studentDetails';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => SignUpScreen(),
    forget: (context) => ForgotEmailScreen(),
    verification: (context) => VerificationCodeScreen(),
    changepassword: (context) => ChangePasswordScreen(),
    dashboard: (context) => DashboardScreen(),
    home: (context) => HomeScreen(),
    // packageSelection: (context) => PackageSelectionScreen(),
    newStudent: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final student = args['student'] as Student;
      final isShowBtn = args['isEdit'] as bool;
      return NewStudentScreen(student: student, isEdit: isShowBtn);
    },
    editprofile: (context) => EditProfileScreen(),
    receiptScreen: (context) => ReceiptScreen(),
    ordersScreen: (context) => OrdersScreen(),
    studentsScreen: (context) => StudentsScreen(),

    studentDetails: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final student = args['student'] as Student;
      final isShowBtn = args['isShowBtn'] as bool;

      return StudentDetails(student: student, isShowNextbtn: isShowBtn);
    },
  };
}
