import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/screens/login/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/services/database.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on firebase user
  DojoUser? _userFromFirebaseUser(User? user) {
    return user != null ? DojoUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<DojoUser?> get user {
    return _auth
        .authStateChanges()
        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  Future signInWithEmailAndPassword(String email, String password, context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      await FirebaseFirestore.instance
          .collection('users')
          .where("User_ID", isEqualTo: user!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        globals.nickname = querySnapshot.docs[0]['Nickname'];
      });

      return user;
    } on FirebaseAuthException catch  (error) {

      print(error.toString());

      //Check if email is already in use and redirect to sign-in if true
      if (error.code == 'user-not-found') {
        final snackBar = SnackBar(content: Text('There is no user with that email'),
          duration: const Duration(milliseconds: 5000),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return null;
      }
      else if (error.code == 'wrong-password'){
        final snackBar = SnackBar(content: Text('Password is incorrect'),
          duration: const Duration(milliseconds: 5000),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return null;
      }

    }
  }



// register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String nickname,context) async {
    try {
      //Call Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      //Add user to firebase collection
      await DatabaseService(uid: user!.uid).addUser(user.uid, nickname);

      //Get nickname from firebase and set to global variable
      await FirebaseFirestore.instance
          .collection('users')
          .where("User_ID", isEqualTo: user.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        globals.nickname = querySnapshot.docs[0]['Nickname'];
      });

      return _userFromFirebaseUser(user);

    } on FirebaseAuthException catch  (error) {

      print(error.toString());

      //Check if email is already in use and redirect to sign-in if true
      if (error.code == 'email-already-in-use')
        {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return SignIn(existingUser: true,);
          }));
        }
      else {
        return null;

      }

    }
  }

// sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}



