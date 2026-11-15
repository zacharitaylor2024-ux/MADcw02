import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/challenge_service.dart';
import '../services/reward_service.dart';
import '../services/coach_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final service = ChallengeService();
  final rewardService = RewardService();

  late Future<Map<String, dynamic>> quest;

  bool isCompleting = false;
  String? rewardMessage;

  final coachService = CoachService();
  final questionController = TextEditingController();

  bool isAsking = false;
  String? coachReply;

  Future<void> askCoach() async {
    if (isAsking) return;

    setState(() {
      isAsking = true;
      coachReply = null;
    });

    try {
      final reply = await coachService.getHint(questionController.text);

      if (!mounted) return;

      setState(() => coachReply = reply);
    } catch (e) {
      debugPrint('Coach error: $e');

      if (!mounted) return;

      setState(() {
        coachReply = 'Quest Coach unavailable. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => isAsking = false);
      }
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    quest = service.loadToday();
  }

  Future<void> completeChallenge() async {
    if (isCompleting) return;

    setState(() {
      isCompleting = true;
      rewardMessage = null;
    });

    try {
      final result = await rewardService.completeChallenge();

      if (!mounted) return;

      setState(() {
        rewardMessage = result['alreadyCompleted'] == true
            ? 'Challenge already completed. No extra points awarded.'
            : 'Challenge completed! You earned 10 points and the First Quest badge!';

        quest = service.loadToday();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        rewardMessage = 'Unable to complete challenge. Please try again.';
      });

      debugPrint('Completion failed: $e');
    } finally {
      if (mounted) {
        setState(() => isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: quest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final challenge = snapshot.data!['challenge'] as Map<String, dynamic>;

          final progress = snapshot.data!['progress'] as Map<String, dynamic>?;

          final completed = progress?['completed'] == true;
          final points = progress?['points'] ?? 0;
          final badgeId = progress?['badgeId'];

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                challenge['title'] ?? "Today's Challenge",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              Text(challenge['prompt'] ?? ''),

              const SizedBox(height: 24),

              Text('Points: $points'),

              Text(completed ? 'Completed!' : 'Not completed yet'),

              if (badgeId != null) Text('Badge: $badgeId'),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: isCompleting ? null : completeChallenge,
                child: Text(
                  isCompleting ? 'Completing...' : 'Complete Challenge',
                ),
              ),

              if (rewardMessage != null) ...[
                const SizedBox(height: 12),
                Text(rewardMessage!),
              ],

              const SizedBox(height: 28),

              const Divider(),

              const SizedBox(height: 16),

              Text(
                'AI Quest Coach',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: questionController,
                maxLength: 300,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ask for a hint',
                  hintText: 'How should I approach this challenge?',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              FilledButton(
                onPressed: isAsking ? null : askCoach,
                child: Text(isAsking ? 'Thinking...' : 'Get Hint'),
              ),

              if (coachReply != null) ...[
                const SizedBox(height: 16),
                Text(coachReply!),
              ],
            ],
          );
        },
      ),
    );
  }
}
