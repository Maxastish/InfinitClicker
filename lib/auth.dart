// auth.dart - Авторизация через Google
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


void saveCompletionTime(User user, Duration runTime) async {
  final db = FirebaseFirestore.instance;
  await db.collection("leaderboard").doc(user.uid).set({
    "name": user.displayName,
    "time": runTime.inSeconds,
    "timestamp": FieldValue.serverTimestamp(),
  });
}

Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // Отмена входа

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final UserCredential userCredential =
  await FirebaseAuth.instance.signInWithCredential(credential);
  return userCredential.user;
}
