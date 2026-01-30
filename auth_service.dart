import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// 🔐 LOGIN EMAIL / PASSWORD
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential res =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        await _userService.saveUser(res.user!);
      }

      return res.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur de connexion";
    }
  }

  /// 📝 REGISTER EMAIL / PASSWORD
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential res =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        await _userService.saveUser(
          res.user!,
          additionalData: {
            'name': name,
            'provider': 'email',
          },
        );
      }

      return res.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Erreur d'inscription";
    }
  }

  /// 🔐 GOOGLE SIGN-IN (FLUTTER WEB – API OFFICIELLE)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider provider = GoogleAuthProvider();

      final UserCredential res =
          await _auth.signInWithPopup(provider);

      final User? user = res.user;

      if (user != null) {
        await _userService.saveUser(
          user,
          additionalData: {
            'name': user.displayName ?? 'Utilisateur Google',
            'provider': 'google',
          },
        );
      }

      return user;
    } catch (e) {
      throw "Erreur Google Sign-In : $e";
    }
  }

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 👤 CURRENT USER
  User? get currentUser => _auth.currentUser;
}
