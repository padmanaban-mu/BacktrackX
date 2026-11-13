# BackTrackX Backend

Node.js + Express + MongoDB backend for the BackTrackX Flutter app. This build implements the **auth module only** (register, login, get current user, logout), matching the endpoints your Flutter app already calls.

## Stack

- Node.js / Express.js
- MongoDB + Mongoose
- JWT authentication (`jsonwebtoken`)
- Password hashing (`bcryptjs`)
- Input validation (`express-validator`)
- `cors`, `dotenv`, `nodemon`

## Folder Structure

```
backend/
├── package.json
├── server.js
├── .env.example
├── .gitignore
├── config/
│   └── db.js
├── models/
│   └── User.js
├── controllers/
│   └── authController.js
├── middleware/
│   ├── authMiddleware.js
│   └── errorMiddleware.js
├── routes/
│   └── authRoutes.js
├── utils/
│   ├── generateToken.js
│   └── ApiResponse.js
└── README.md
```

## Setup

### 1. Install dependencies

```bash
cd backend
npm install
```

### 2. Configure environment variables

Copy `.env.example` to `.env` and fill in your own values:

```bash
cp .env.example .env
```

```env
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb://127.0.0.1:27017/backtrackx
JWT_SECRET=replace_this_with_a_long_random_secret_string
JWT_EXPIRES_IN=7d
```

- **MONGO_URI**: point this at a local MongoDB instance (`mongodb://127.0.0.1:27017/backtrackx`) or a MongoDB Atlas connection string.
- **JWT_SECRET**: use a long random string (e.g. `openssl rand -hex 32`).

### 3. Run MongoDB

If running locally, make sure `mongod` is running before starting the server. If using Atlas, just make sure your IP is allow-listed.

### 4. Start the server

```bash
npm run dev     # nodemon, auto-restarts on file changes
# or
npm start        # plain node
```

You should see:

```
MongoDB connected: 127.0.0.1
BackTrackX API running on port 5000 [development]
```

## Connecting from the Flutter app

Your `api_constants.dart` already points to:

```
http://10.0.2.2:5000/api
```

This is correct for the **Android emulator** (it maps to your host machine's `localhost:5000`). If you're using:

- **iOS simulator** → `http://localhost:5000/api`
- **Physical device** → `http://<your-computer-LAN-IP>:5000/api` (same Wi-Fi network)

## API Endpoints

Base URL: `http://10.0.2.2:5000/api`

### `POST /api/auth/register`

Request body:
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "secret123"
}
```

Success response (`201`):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "665f1c2e8a1b2c3d4e5f6789",
      "name": "Jane Doe",
      "email": "jane@example.com",
      "role": "student"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Account created successfully."
}
```

### `POST /api/auth/login`

Request body:
```json
{
  "email": "jane@example.com",
  "password": "secret123"
}
```

Success response (`200`): same `data.user` / `data.token` shape as register.

### `GET /api/auth/me`

Requires header: `Authorization: Bearer <token>`

Success response (`200`):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "665f1c2e8a1b2c3d4e5f6789",
      "name": "Jane Doe",
      "email": "jane@example.com",
      "role": "student"
    }
  },
  "message": "Current user fetched successfully."
}
```

### `POST /api/auth/logout`

Requires header: `Authorization: Bearer <token>`

Success response (`200`):
```json
{
  "success": true,
  "data": {},
  "message": "Logged out successfully."
}
```

JWTs are stateless, so this endpoint doesn't blacklist the token server-side — it exists so the client has a clean call to make. The actual logout happens client-side by deleting the stored token (which is exactly what your `AuthProvider.logout()` already does).

### Error response format (all endpoints)

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password."
  }
}
```

Common error codes: `VALIDATION_ERROR`, `DUPLICATE_EMAIL`, `INVALID_CREDENTIALS`, `NO_TOKEN`, `INVALID_TOKEN`, `TOKEN_EXPIRED`, `USER_NOT_FOUND`, `NOT_FOUND`, `SERVER_ERROR`.

## Note on the `user` object shape

Your Flutter `UserModel.fromJson` reads `id` (not `_id`) and also expects a `role` field, so this backend's `User.sanitize()` returns exactly `{ id, name, email, role }`. `role` defaults to `"student"` for every new registration.

## Testing quickly with curl

```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com","password":"secret123"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane@example.com","password":"secret123"}'

# Current user (replace TOKEN)
curl http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```
