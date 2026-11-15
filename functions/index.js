
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

exports.completeToday = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in first.");
  }

  if (request.data?.challengeId !== "today") {
    throw new HttpsError("invalid-argument", "Unknown challenge.");
  }

  const uid = request.auth.uid;
  const progressRef = db.doc(`users/${uid}/progress/today`);

  return db.runTransaction(async (transaction) => {
    const progress = await transaction.get(progressRef);

    if (progress.exists && progress.data().completed === true) {
      return {
        completed: true,
        points: progress.data().points,
        badgeId: progress.data().badgeId,
        alreadyCompleted: true,
      };
    }

    const reward = {
      completed: true,
      points: 10,
      badgeId: "first-quest",
      completedAt: FieldValue.serverTimestamp(),
    };

    transaction.set(progressRef, reward);

    return {
      completed: true,
      points: 10,
      badgeId: "first-quest",
      alreadyCompleted: false,
    };
  });
});

exports.askQuestCoach = require("./questCoach").askQuestCoach;
