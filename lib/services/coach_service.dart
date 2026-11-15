
import 'package:cloud_functions/cloud_functions.dart';

class CoachService {
  Future<String> getHint(String question) async {
    final trimmed = question.trim();

    if (trimmed.isEmpty || trimmed.length > 300) {
      throw Exception('Enter a question of 1–300 characters.');
    }

    final callable =
        FirebaseFunctions.instance.httpsCallable('askQuestCoach');

    final result = await callable.call({
      'question': trimmed,
    });

    return result.data['reply'] as String;
  }
}
