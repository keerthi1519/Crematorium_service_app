# Crematorium Service App 🕊️

A complete Flutter-based cremation slot booking and document verification system powered by **Supabase**.

---
## Project Structure
<pre>
lib/
├── helpers/
│   └── time_helper.dart
├── models/
│   └── booking_model.dart
├── screens/
│   ├── admin_dashboard.dart
│   ├── admin_login_screen.dart
│   ├── booking_form.dart
│   ├── booking_status_screen.dart
│   ├── date_selection.dart
│   ├── document_upload.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── medical_certificate.dart
│   ├── signup_screen.dart
│   ├── slot_availability_screen.dart
│   ├── splash_screen.dart
│   ├── user_dashboard.dart
│   └── waiting_confirmation_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── storage_service.dart
│   └── supabase_service.dart
├── theme/
│   └── app_theme.dart
├── use_cases/
│   ├── auth_provider.dart
│   └── use_cases.dart
├── widgets/
│   └── custom_appbar.dart
├── main.dart
└── supabase_config.dart
</pre>
## About the App

This app simplifies the cremation process by enabling users to:
- Book cremation slots (max 6 per day)
- Upload required documents securely
- Get real-time status updates from the admin
- Receive reminders & notifications

The app supports **user and admin login**, handles **slot availability**, and provides a **dashboard for admins** to manage bookings and documents.

---

## Features

### 👤 User Features
- Secure signup/login using Supabase Auth
- View available slots based on selected date
- Upload necessary documents:
  - Deceased Photo
  - Aadhaar Card
  - Death Certificate
  - Doctor Verification
  - Applicant Aadhar card
- Slot booking with real-time status

### Admin Features
- Admin login (username & password)
- View all booking requests
- Access uploaded documents via Supabase
- Accept or decline requests
- View user & deceased details
- Monitor slot usage per day

---

## Tech Stack

- **Flutter** – Frontend UI
- **Supabase** – Auth, Realtime DB, and Storage
- **Dart** – Logic and State Management

---

## Getting Started

### Requirements
- Flutter SDK
- Supabase account (configured with Auth, Database, and Storage)
- Android Studio or VS Code

### Run the app
<pre>
Run the app
flutter pub get
flutter run
</pre>



![Home screen](https://github.com/user-attachments/assets/e2611b41-c1a3-4452-b077-fd9090c2b84e)
![User Login](https://github.com/user-attachments/assets/c6ba92da-e0f6-4ece-b5bf-cb777a63b0a6)
![Admin Login](https://github.com/user-attachments/assets/6bc6d66e-b210-46ed-ab40-361d4c89868e)
![User Dashboard](https://github.com/user-attachments/assets/a4ed474a-76f1-49a4-b694-e0efd7f62626)
![Medical form](https://github.com/user-attachments/assets/9aa4264b-0f70-4197-9df1-ee4f1e261ed5)
![Medical form1](https://github.com/user-attachments/assets/1b7386a0-6dea-4102-a9ef-9dbf142cdf1c)
![Document Upload screen](https://github.com/user-attachments/assets/42cabf7c-6465-4788-816c-f26652c83bfb)
![Document Upload Screen1](https://github.com/user-attachments/assets/5951d068-45ed-4f14-9b80-ab397f33e0ef)
![screen](https://github.com/user-attachments/assets/9fd4b7ed-eae7-4edd-8963-24e665b90834)
![Booking status](https://github.com/user-attachments/assets/13a4c6db-68e8-4d73-a1d0-f204efaa3f89)
![Admin Dahboard](https://github.com/user-attachments/assets/37f4d60d-413b-4eae-9777-64a31522bc76)










