# Caloriz Admin Panel

This is the web-based Admin Panel for the Caloriz app, built with Next.js, Tailwind CSS, and Firebase.

## Setup Instructions

### 1. Install Dependencies
Run the following command to install all required packages:
```bash
npm install
```

### 2. Configure Firebase
Create a file named `.env.local` in the root of the `admin_panel` directory.
Add your Firebase Web API Key (found in Firebase Console > Project Settings > General > Web Apps):

```
NEXT_PUBLIC_FIREBASE_API_KEY=your_web_api_key_here
```

**Note:** You may need to create a Web App in your Firebase project if you haven't already. The Android/iOS API keys might not work for the web client.

### 3. Run the Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Features implemented
- **Dashboard**: Overview of users, revenue, and active partners. 
- **User Management**: View user list and status.
- **Affiliate Management**: View and approve/reject withdrawal requests.
- **Settings**: Configure app-wide settings (minimum withdrawal limit, commission rate, etc.) dynamically via Firestore.

## Authentication
Currently, any valid email/password login in your Firebase Auth works.
For production security, you should implement Admin Claims or a whitelist check in `components/AuthProvider.tsx`.
