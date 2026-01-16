QuoteVault — AI Powered Quote App

QuoteVault is a modern Flutter-based mobile application that allows users to discover, save, and organize inspirational quotes. The app is built with a clean UI, secure authentication, and cloud-backed data storage using Supabase.

Features:
User Authentication — Login & Signup using Supabase.
Favorites — Save your favorite quotes.
Collections — Organize quotes into custom collections.
Search & Filter — Find quotes by category or author.
Cloud Sync — All data stored securely in Supabase.
Fast Performance — Built with Flutter & Riverpod.
Secure Database — Uses Row Level Security (RLS).

Tech Stack:
Frontend: Flutter (Dart).
State Management: Riverpod.
Backend: Supabase.
Database: PostgreSQL (via Supabase).
Authentication: Supabase Auth.

Screens:
Home — Browse trending quotes.
Search — Search by category or author.
Favorites — View saved quotes.
Profile — Manage user account.

Project Structure:
lib/app
lib/features/auth
lib/features/quotes
lib/features/favorites
lib/shared/models
lib/supabase

Setup Instructions:
Step 1: Clone the repository.
Step 2: Run flutter pub get.
Step 3: Create file lib/supabase/supabase_keys.dart and add your Supabase URL and anon key.
Step 4: Run the app using flutter run.

Learning Outcomes:
Learned Flutter app architecture, Supabase authentication, Row Level Security (RLS), Riverpod state management, and clean coding practices.

Developed by:
Ayush Deshmukh
