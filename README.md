# StudyBros - Daily Study Planner

## Project Structure
- **backend/**: Node.js + Express + MongoDB API
- **frontend/**: Flutter Application

## Setup & Run Instructions

### Prerequisites
- Node.js installed
- Flutter SDK installed
- MongoDB installed and running (or use a cloud URI in `.env`)

### 1. Start the Backend
1. Open a terminal.
2. Navigate to the `backend` folder:
   ```bash
   cd backend
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm run dev
   ```
   The server will run on `http://localhost:5000`.

### 2. Run the Flutter App
1. Open a new terminal.
2. Navigate to the `frontend` folder:
   ```bash
   cd frontend
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
   Select your device (Edge, Chrome, or Android Emulator).

## Features Implemented
- **Backend**:
  - MongoDB connection
  - APIs for Tasks, Notes, Exams, Habits
- **Frontend**:
  - Modern, minimal design with soft colors
  - **Dashboard**: Focus Timer UI, Quick Overview
  - **Daily Planner**: View, Add, and Complete tasks (connected to backend)

## Troubleshooting
- **Android Emulator**: If using Android Emulator, the app connects to `http://10.0.2.2:5000` to reach the localhost backend.
- **Web/Windows**: Connects to `http://localhost:5000`.
- **Flutter Command Not Found**: If `flutter` command fails, use the full path or add it to your PATH.
