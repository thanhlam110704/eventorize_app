import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: dotenv.env['clientID'], 
  );

  static Future<Map<String, dynamic>?> login() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authentication = await account.authentication;
      return {
        'idToken': authentication.idToken,
        'accessToken': authentication.accessToken,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
      };
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}