
import 'package:cloud_functions/cloud_functions.dart';

class RewardService {
  Future<Map<String, dynamic>> completeChallenge() async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('completeToday');

    final result = await callable.call({
      'challengeId': 'today',
    });

    return Map<String, dynamic>.from(result.data as Map);
  }
}
