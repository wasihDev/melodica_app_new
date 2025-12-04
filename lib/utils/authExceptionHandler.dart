import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHandler {
  static String handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "User not found";

      case 'wrong-password':
        return "Wrong password";

      case 'invalid-email':
        return "Invalid email";

      case 'user-disabled':
        return "User disabled";

      case 'email-already-in-use':
        return "emailAlreadyInUse";

      case 'weak-password':
        return "weakPassword";

      case 'operation-not-allowed':
        return "operationNotAllowed";

      case 'account-exists-with-different-credential':
        return "accountExistsWithDifferentCredential";

      case 'credential-already-in-use':
        return "credentialAlreadyInUse";

      case 'too-many-requests':
        return "tooManyRequests";

      case 'network-request-failed':
        return "networkRequestFailed";

      /// 🔥 Added cases for invalid credentials:
      case 'firebase_auth/invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
      case 'invalid-password':
        return 'Invalid credentials. Please check your email or password.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
