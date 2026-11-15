
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadToday() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('You must sign in first.');
    }

    final challenge = await db
        .collection('challenges')
        .doc('today')
        .get();

    if (!challenge.exists) {
      throw Exception("Today's challenge was not found.");
    }

    final progress = await db
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc('today')
        .get();

    return {
      'challenge': challenge.data(),
      'progress': progress.data(),
    };
  }
}
