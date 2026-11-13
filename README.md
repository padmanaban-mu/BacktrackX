# BacktrackX 🧩
### *Interactive Backtracking Algorithm Visualizer & Learning Platform*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📖 Overview

**BacktrackX** is a full-stack educational and visualization platform engineered to demystify complex backtracking algorithms. Designed with students, interview candidates, and computer science enthusiasts in mind, the platform bridges the gap between abstract algorithmic concepts and intuitive understanding through **real-time step-by-step visualizations**, **interactive state-space exploration**, **gamified challenges**, and **guided lessons**.

Whether tackling the **N-Queens problem**, solving a **Sudoku puzzle**, or navigating a **Rat in a Maze**, BacktrackX makes recursion, state exploration, and pruning immediately tangible.

---

## ✨ Key Features

### 1. 🔍 Interactive Algorithm Visualizers
* **Sudoku Solver:** Watch the backtracking solver place numbers, validate row/column/box constraints, hit dead ends, and backtrack to previous states.
* **N-Queens Problem:** Visualize placing $N$ non-attacking queens on an $N \times N$ chessboard with dynamic conflict checks across rows, columns, and diagonals.
* **Rat in a Maze:** Track maze traversal step-by-step, highlighting open paths, blocked obstacles, dead ends, and solution routes.

### 2. 🎮 Playback & State Inspector
* **Fine-Grained Playback:** Play, pause, step forward, step backward, or scrub through execution states.
* **Variable Speed Control:** Slow down execution to study intricate branch choices or speed up to observe complete state-space searches.
* **Live Decision & Explanation Panel:** Every step explains *why* a choice was made, *which* constraint was violated, and *why* a backtrack occurred in clear natural language.

### 3. 🧠 Practice, Prediction & Challenges
* **Manual Solve Mode:** Test your problem-solving skills against the puzzles before viewing the automated visualizer.
* **Predict Next Step:** Test your intuition by guessing whether the algorithm will proceed to a new branch or backtrack from a dead end.
* **Timed & Daily Challenges:** Complete challenges under time pressure to sharpen algorithmic problem-solving instincts.

### 4. 📚 Comprehensive Learning Hub
* **Curated Curriculum:** Bite-sized lessons covering recursion fundamentals, state-space trees, pruning, constraint propagation, and time/space complexity analysis.
* **Interactive Quizzes:** Reinforce conceptual knowledge with chapter quizzes and track your test scores.

### 5. 🏆 Gamification & Progress Tracking
* **XP & Level Progression:** Earn experience points (XP) for completing lessons, solving puzzles, and finishing daily challenges.
* **Global Leaderboard:** Compete with peers and climb the ranks based on solved problems and earned XP.
* **Personalized Dashboard:** Track completed lessons, quizzes, Sudoku, N-Queens, and Maze completion metrics.

---

## 🏗 System Architecture

```text
┌────────────────────────────────────────────────────────┐
│               BacktrackX Flutter Client                │
│  (Mobile Android/iOS, Web, Desktop - Provider State)   │
└───────────────────────────┬────────────────────────────┘
                            │  HTTPS / REST + JWT
                            ▼
┌────────────────────────────────────────────────────────┐
│                Express.js REST API Server              │
│       Routes: /auth, /content, /progress, /challenge   │
└───────────────────────────┬────────────────────────────┘
                            │  Mongoose ODM
                            ▼
┌────────────────────────────────────────────────────────┐
│                     MongoDB Database                   │
│          (Users, Progress, Lessons, Leaderboard)       │
└────────────────────────────────────────────────────────┘
```

---

## 📂 Repository Structure

```
BacktrackX/
├── backend/                       # Node.js + Express REST API
│   ├── config/                    # Database connection (MongoDB)
│   ├── controllers/               # Auth, progress, content, leaderboard logic
│   ├── middleware/                # JWT verification & error handling
│   ├── models/                    # Mongoose database schemas
│   ├── routes/                    # API endpoints
│   ├── utils/                     # Token generation, helpers, formatting
│   ├── .env.example               # Backend environment variable template
│   ├── package.json               # Backend dependencies and scripts
│   └── server.js                  # Backend entry point
│
├── backtrackx_new/                # Flutter frontend application
│   ├── assets/                    # App icons, images, and static resources
│   ├── lib/
│   │   ├── constants/             # App colors, strings, and API constants
│   │   ├── models/                # Dart data models
│   │   ├── providers/             # State management via Provider
│   │   ├── routes/                # Application navigation routes
│   │   ├── screens/               # UI screens (Auth, Visualizers, Hubs)
│   │   │   ├── auth/              # Login & Registration screens
│   │   │   ├── dashboard/         # User dashboard & stats
│   │   │   ├── learning/          # Lessons & Quiz screens
│   │   │   ├── maze/              # Maze visualizer & manual play
│   │   │   ├── nqueens/           # N-Queens visualizer & manual play
│   │   │   ├── practice/          # Practice hub & challenges
│   │   │   ├── predict/           # Step prediction game mode
│   │   │   ├── progress/          # User progress overview
│   │   │   └── sudoku/            # Sudoku visualizer & manual play
│   │   ├── services/              # HTTP clients & API service integrations
│   │   ├── utils/                 # Formatting, validators, helpers
│   │   ├── widgets/               # Reusable UI components & visualizer widgets
│   │   ├── app.dart               # MaterialApp routing & theme setup
│   │   └── main.dart              # Flutter application entry point
│   └── pubspec.yaml               # Flutter package dependencies
│
└── README.md                      # Project documentation
```

---

## 🚀 Getting Started

Follow these instructions to run both the backend server and Flutter frontend locally.

### Prerequisites

Ensure you have the following installed on your machine:
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (v18.x or later) & `npm`
- [MongoDB](https://www.mongodb.com/) (Local Community Server or a free [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) cluster)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.3.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter/Dart extensions

---

### 1. Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   Create a `.env` file in the `backend/` folder based on `.env.example`:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your settings:
   ```env
   PORT=5000
   NODE_ENV=development
   MONGO_URI=mongodb://127.0.0.1:27017/backtrackx
   JWT_SECRET=your_jwt_secret_key_here
   JWT_EXPIRES_IN=7d
   ```

4. **Start the backend server:**
   ```bash
   # Development mode with nodemon auto-restart:
   npm run dev

   # Or standard production mode:
   npm start
   ```

   Once running, you should see:
   ```text
   MongoDB connected: 127.0.0.1
   BacktrackX API running on port 5000 [development]
   ```

---

### 2. Frontend (Flutter) Setup

1. **Navigate to the Flutter app directory:**
   ```bash
   cd backtrackx_new
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Backend Network Configuration:**
   The app's API host is configured in [api_constants.dart](file:///C:/Project/BacktrackX/backtrackx_new/lib/constants/api_constants.dart) and auto-detects standard environments:
   * **Chrome / Web:** connects to `http://localhost:5000/api`
   * **Android Emulator:** connects to `http://10.0.2.2:5000/api` (standard emulator alias for localhost)
   * **Physical Device:** update the IP in `api_constants.dart` to your computer's local Wi-Fi IP address (e.g., `http://192.168.1.X:5000/api`).

4. **Launch the application:**
   ```bash
   # Run in Chrome (Web):
   flutter run -d chrome

   # Run on connected Android device / emulator:
   flutter run -d android

   # Run on Windows desktop:
   flutter run -d windows
   ```

---

## 📡 API Endpoints Reference

The backend exposes a clean REST API running under `/api`:

### 🔐 Authentication (`/api/auth`)
| Method | Endpoint | Description | Auth Required |
|:-------|:---------|:------------|:-------------:|
| `POST` | `/api/auth/register` | Register new user account | No |
| `POST` | `/api/auth/login` | Authenticate user & receive JWT | No |
| `GET` | `/api/auth/me` | Retrieve profile of authenticated user | Yes |
| `POST` | `/api/auth/logout` | Client logout clearance | Yes |

### 📖 Content & Curriculum (`/api/content`)
| Method | Endpoint | Description | Auth Required |
|:-------|:---------|:------------|:-------------:|
| `GET` | `/api/content/lessons` | Fetch all interactive learning lessons | No |
| `GET` | `/api/content/lessons/:id` | Fetch detailed lesson content | No |
| `GET` | `/api/content/lessons/:id/quiz` | Fetch quizzes linked to a lesson | No |

### 📈 Progress & Gamification (`/api/progress`)
| Method | Endpoint | Description | Auth Required |
|:-------|:---------|:------------|:-------------:|
| `GET` | `/api/progress` | Fetch current user's progress & XP | Yes |
| `POST` | `/api/progress/lesson` | Mark lesson as completed | Yes |
| `POST` | `/api/progress/quiz` | Submit quiz score | Yes |
| `POST` | `/api/progress/sudoku` | Increment Sudoku puzzles solved count | Yes |
| `POST` | `/api/progress/nqueens` | Increment N-Queens solved count | Yes |
| `POST` | `/api/progress/maze` | Increment Maze solved count | Yes |
| `POST` | `/api/progress/xp` | Award XP for game activities | Yes |

### 🏆 Challenges & Leaderboard
| Method | Endpoint | Description | Auth Required |
|:-------|:---------|:------------|:-------------:|
| `GET` | `/api/leaderboard` | Get global user rankings & scores | Yes |
| `GET` | `/api/challenge/daily` | Fetch current daily challenge | Yes |
| `POST` | `/api/challenge/daily/complete` | Complete daily challenge & claim reward | Yes |

---

## 🛠 Tech Stack

### Frontend (Client)
* **Framework:** [Flutter](https://flutter.dev/) (Dart 3.x)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Animations:** [flutter_animate](https://pub.dev/packages/flutter_animate)
* **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts)
* **Networking:** [http](https://pub.dev/packages/http)
* **Local Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences)

### Backend (Server)
* **Runtime:** [Node.js](https://nodejs.org/) (>= 18.x)
* **Framework:** [Express.js](https://expressjs.com/)
* **Database:** [MongoDB](https://www.mongodb.com/) via [Mongoose ODM](https://mongoosejs.com/)
* **Authentication:** JSON Web Tokens ([jsonwebtoken](https://github.com/auth0/node-jsonwebtoken)) & [bcryptjs](https://github.com/dcodeIO/bcrypt.js)
* **Validation:** [express-validator](https://express-validator.github.io/)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
