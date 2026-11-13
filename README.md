# BacktrackX — Interactive Backtracking Learning Platform

BacktrackX is an interactive learning project designed to help learners understand backtracking algorithms through visual exploration, guided lessons, practice challenges, and progress tracking.

The repository contains a Flutter mobile client and a Node.js/Express backend backed by MongoDB.

## Learning experience

The project is organised around four learning areas:

1. **Algorithm visualisation:** explore backtracking problems and their search states.
2. **Playback and state inspection:** follow the algorithm's progression and inspect how choices and backtracking change the state.
3. **Practice and challenges:** attempt questions and prediction-style exercises.
4. **Learning and progress:** access lessons, quizzes, progress records, XP/badges, and leaderboard-related functionality represented in the backend.

## Architecture

```text
Flutter mobile application
          |
       HTTP API
          |
Node.js + Express backend
          |
       MongoDB
```

## Technology

| Component | Technologies |
| --- | --- |
| Mobile client | Flutter, Dart |
| State and API | Provider, http |
| Local preferences | shared_preferences |
| Backend | Node.js, Express |
| Database | MongoDB, Mongoose |
| Authentication | JWT, bcryptjs |

## Repository structure

```text
.
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── utils/
│   └── server.js
└── backtrackx_new/
    ├── lib/
    ├── android/
    ├── ios/
    ├── assets/
    └── pubspec.yaml
```

## Run locally

### Requirements

- Flutter SDK and Dart
- Android Studio or another configured Flutter device/emulator
- Node.js 18+
- MongoDB instance or Atlas cluster

### Backend

```bash
git clone https://github.com/padmanaban-mu/BacktrackX.git
cd BacktrackX/backend
npm install
```

Create a local `.env` file using `.env.example` as a reference. Configure the MongoDB connection string and JWT secret, then run:

```bash
npm run dev
```

### Flutter client

In a second terminal:

```bash
cd backtrackx_new
flutter pub get
flutter run
```

Configure the API base URL in the client for the address reachable from your emulator or device. An Android emulator generally cannot use the host machine's `localhost` address directly.

## API areas

The backend is organised into route/controller groups for:

- Authentication
- Learning content and quizzes
- User progress
- Challenges
- Leaderboards

See `backend/routes/` and the backend README for the current endpoint details.

## Development notes

The repository includes a Flutter project under `backtrackx_new/`. Keep generated build output, local configuration, and secrets out of commits. Before release, test authentication and authorisation, validate user-submitted data, and verify that progress and leaderboard updates are consistent.

## License

A license badge is present in the repository README. Confirm the accompanying license file and its terms before reuse or redistribution.
