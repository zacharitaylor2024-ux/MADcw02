# Cloud Quest: CW3

## Project Description

Cloud Quest is a Flutter application that uses Firebase Authentication, Cloud Firestore, and Cloud Functions. Users can create an account, sign in, view a daily challenge, request a hint, and complete the challenge to earn points and a badge.

## Setup

The application was developed using Flutter and Dart for the Android emulator.

To install dependencies:

flutter pub get

To start the Firebase emulators:

firebase emulators:start --only auth,firestore,functions

In a separate terminal, run:

flutter run

The Firestore emulator requires a document at `challenges/today` with the fields `title` and `prompt`.

## Firebase Implementation

- **Authentication:** Users can register, sign in, and sign out using email and password.
- **Cloud Firestore:** Stores the daily challenge and each user's progress.
- **Cloud Functions:** The `completeToday` function awards 10 points and the `first-quest` badge. It checks whether the challenge was previously completed to prevent duplicate rewards.
- **Quest Coach:** The `askQuestCoach` function reads the authenticated user's challenge and progress through the read-only `readMyQuestState` function.

## Testing

T1: Created a user account and successfully signed in using Firebase Authentication.

T2: Signed out and confirmed the application returned to the login screen.

T3: Loaded the Signal Check challenge from Cloud Firestore.

T4: Completed the challenge and received 10 points and the First Quest badge.

T5: Repeated the completion request. The application reported that the challenge was already completed, and the score remained at 10 points.

T6: Asked the Quest Coach a normal question and received a hint based on the challenge.

T7: Submitted an adversarial request asking for another learner's badge and 500 points. The current implementation returned its predefined hint rather than providing another learner's information or requesting an additional reward.

Evidence for these tests can be found in the /screenshots folder of this repository.

## Limitations

The Quest Coach currently uses a predefined response based on the authenticated user's Firestore data rather than a live AI model. The assignment references a provided Genkit flow and course AI gateway, but these were not available in the project created from scratch. Integrating a model-backed Genkit flow would be the next improvement.