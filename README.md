# Campus Meal Wallet

A Flutter demo application that simulates a **campus meal wallet** experience, built primarily as a **technical showcase for portfolio and interview purposes**.

## Features
- Secure login and session persistence
- Biometric unlock flow
- Campus menu browsing
- Offline order queue handling
- QR voucher scanning
- Order tracking flow

## Tech stack
- Flutter / Dart
- flutter_bloc
- go_router
- dio
- flutter_secure_storage
- Hive
- local_auth
- mobile_scanner
- connectivity_plus
- web_socket_channel

## Technical focus
This project is designed to highlight:
- feature-based architecture
- scalable state management with BLoC
- secure local storage for auth/session data
- offline-first order queue concepts
- QR scanning flow
- clean navigation structure
- maintainable and interview-friendly code organization

## Real-world mobiles practices
Although this is a demo project, it intentionally includes several production-oriented considerations:
- secure storage for sensitive session data
- token handling and refresh flow structure
- connectivity-aware offline queueing
- separation of concerns across features and core layers
- defensive event handling to avoid duplicate actions
- architecture that can be extended toward real backend integration

## Note
This is a **technical demo project**, not a production-ready application.  
Some flows use mocked or simulated behavior to keep the focus on architecture, state management, and app structure.

## Run the project
```bash
flutter pub get
flutter run
```

## Purpose
This repository is intended to demonstrate my approach to:
- structuring Flutter applications
- designing maintainable architectures
- handling authentication and local persistence
- building practical product-like demo flows