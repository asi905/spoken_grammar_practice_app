import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // লেটেস্ট google_sign_in প্যাকেজের জন্য সঠিক সাইন-ইন মেথড
  static Future<User?> signInWithGoogle() async {
    try {
      // গুগল সাইন-ইন ইনস্ট্যান্স তৈরি
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // আগের কোনো সেশন থাকলে তা পরিষ্কার করে পপআপ আনা
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // ইউজার পপআপ কেটে দিলে

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ফায়ারবেসের জন্য ক্রেডেনশিয়াল তৈরি (idToken ব্যবহার করে)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // ফায়ারবেসে লগইন
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

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
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
  }
}
