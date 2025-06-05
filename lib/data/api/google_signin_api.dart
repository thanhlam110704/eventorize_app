import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, String>?> signIn() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null;
      }
      return {
        'fullname': account.displayName ?? '',
        'email': account.email,
        'google_id': account.id,
        'avatar': account.photoUrl ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}