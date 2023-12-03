import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../info/user.dart';
import '../../themepage/theme.dart';
import '../bottom/bottom.dart';

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPage> {
  void _googleSignIn() async {
    try {
      UserCredential userCredential = await signInWithGoogle();

      // 모달 창을 통해 이름을 입력 받음
      // String? enteredName = await _showNameInputDialog(context);

      final db = FirebaseFirestore.instance;
      final docref =
          db.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);
      await docref.set({
        'email': userCredential.user!.email,
        'status_message': 'I promise to take the test honestly before GOD',
        'uid': userCredential.user!.uid,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  void _anonySignIn() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final db = FirebaseFirestore.instance;
      final docref =
          db.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);
      await docref.set({
        'status_message': 'I promise to take the test honestly before GOD',
        'uid': userCredential.user!.uid,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  Future<String?> _showNameInputDialog(BuildContext context) async {
    String? enteredName;

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이름을 입력해 주세요'),
          content: TextField(
            decoration: InputDecoration(
              //준) 선택되지 않은 밑줄 속성
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEFEFEF)),
              ),
              //준) 선택된 밑줄 속성 둘을 일치시켰음
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEFEFEF)),
              ),
              hintText: "예) 전산전자 공학부 임원단",
              hintStyle: greyw500.copyWith(fontSize: 24),
            ),
            onChanged: (value) {
              enteredName = value;
              UserProvider.userName = enteredName;
            },
          ),
          backgroundColor: Colors.white10,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(enteredName);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _googleSignIn();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: const Color.fromRGBO(54, 209, 0, 1),
                backgroundColor: const Color.fromRGBO(54, 209, 0, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(343, 52),
              ),
              child: Text('구글 로그인', style: whitew700.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _anonySignIn();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromRGBO(54, 209, 0, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(343, 52),
              ),
              child: Text('익명 로그인', style: whitew700.copyWith(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
