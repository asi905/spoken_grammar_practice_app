import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<User?> signInWithGoogle() async {
    try {
      User? user;

      // ✅ ওয়েবের জন্য ফায়ারবেসের নিজস্ব এবং সবচেয়ে নির্ভরযোগ্য মেথড
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);
        user = userCredential.user;
      }
      // ✅ অ্যান্ড্রয়েড/আইওএস এর জন্য সাধারণ মেথড
      else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // ইউজার পপআপ কেটে দিলে

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (user != null) {
        // ফায়ারবেস ডেটাবেসে (Firestore) ইউজারের তথ্য সেভ করা
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Unknown User',
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // লগআউট মেথড
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
