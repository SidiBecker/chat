import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBaseUtil {
  static FirebaseUser _currentUser;

  static GoogleSignIn googleSignIn = GoogleSignIn();

  static Future<FirebaseUser> getUser() async {
    if (_currentUser != null) return _currentUser;

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });

    try {
      //Login Google
      final GoogleSignInAccount googleSigningAccount =
          await googleSignIn.signIn();

      //Dados da Autenticação com Google
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSigningAccount.authentication;

      //Extrai as credenciais
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      //Login com Firebase
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (e) {
      //Se der erro executa aqui
      return null;
    }
  }
}
