# BacktrackX

BacktrackX is a mobile learning project for understanding backtracking algorithms. It pairs a Flutter app with an Express API and MongoDB backend, with visualisers and practice activities for problems such as Sudoku, N-Queens, and Rat in a Maze.

## What you can explore

- **Sudoku:** follow the solver as it tries values, checks constraints, reaches a dead end, and returns to an earlier state.
- **N-Queens:** see how the algorithm places queens while checking for conflicts.
- **Rat in a Maze:** follow path exploration and observe what happens when a route cannot lead to a solution.
- **Playback controls:** step through algorithm states and inspect the decisions made during a run.
- **Learning and practice:** the app also contains lessons, quizzes, challenges, and progress-related screens.

The visualisers are the central part of the project: the aim is to make the recursive search process easier to follow than reading code alone.

## Architecture

```text
Flutter app
    |
 HTTP / REST
    |
Express backend
    |
  MongoDB
```

## Technologies

| Part | Technologies |
| --- | --- |
| Mobile app | Flutter, Dart |
| State management | Provider |
| HTTP requests | http |
| Local preferences | shared_preferences |
| Backend | Node.js, Express |
| Database | MongoDB, Mongoose |
| Authentication | JWT, bcryptjs |

## Project layout

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
    ├── assets/
    ├── lib/
    ├── android/
    ├── ios/
    └── pubspec.yaml
```

## Run the project

You need Node.js, npm, MongoDB, Flutter, and a configured Android emulator or device.

### Backend

```bash
git clone https://github.com/padmanaban-mu/BacktrackX.git
cd BacktrackX/backend
npm install
```

Create a `.env` file based on `.env.example` and set the MongoDB connection string and JWT secret. Then start the API:

```bash
npm run dev
```

### Flutter app

Open a second terminal:

```bash
cd backtrackx_new
flutter pub get
flutter run
```

Make sure the API base URL in the Flutter app points to an address reachable by your selected device. For an Android emulator, the host computer is usually reached through `10.0.2.2`, not `localhost`.

## Backend routes

The backend is divided into route and controller groups for authentication, learning content, progress, challenges, and leaderboard functionality. See `backend/routes/` for the current route definitions.

## Before release

Keep local environment files and secrets out of Git. Test the app on the target devices, and review authentication, authorisation, request validation, and consistency of progress updates before using real accounts.

## License

The repository includes an MIT license badge. Refer to the [LICENSE](LICENSE) file for the actual license terms.
