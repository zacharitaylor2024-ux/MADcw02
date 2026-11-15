
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore } = require("firebase-admin/firestore");

const db = getFirestore();

// Read-only tool: uses the verified signed-in user.
async function readMyQuestState(uid) {
  const challenge = await db.doc("challenges/today").get();
  const progress = await db.doc(`users/${uid}/progress/today`).get();

  if (!challenge.exists) {
    throw new HttpsError("not-found", "Challenge not found.");
  }

  return {
    challenge: challenge.data(),
    progress: progress.exists ? progress.data() : null,
  };
}

exports.askQuestCoach = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  const question = request.data?.question;

  if (
    typeof question !== "string" ||
    !question.trim() ||
    question.length > 300
  ) {
    throw new HttpsError("invalid-argument", "Invalid question.");
  }

  // Always read only the authenticated learner's state.
  const state = await readMyQuestState(request.auth.uid);

  // Temporary emulator response until Genkit is connected.
  const reply =
    `Your challenge is "${state.challenge.title}". ` +
    `Think about who should control rewards: ` +
    `the mobile app or the trusted server. ` +
    `Current points: ${state.progress?.points ?? 0}.`;

  return { reply };
});
