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
        print('Google Sign-In cancelled by user');
        return null;
      }

      final auth = await account.authentication; // Get access token
      print('Signed in: ${account.email}');
      print('displayName: ${account.displayName}');
      print('Photo: ${account.photoUrl}');
      print('Id: ${account.id}');
      print('Access Token: ${auth.accessToken}');

      return {
        'fullname': account.displayName ?? '',
        'email': account.email,
        'google_id': account.id,
        'avatar': account.photoUrl ?? '',
        'access_token': auth.accessToken ?? '', 
      };
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    print('Logged out from Google');
  }
}