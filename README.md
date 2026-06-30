# Project Name

A Flutter-based mobile application that serves as the frontend interface for the graduation project system. This app communicates directly with the backend API to handle all data operations.

## Architecture Overview
This application is part of a larger project, where the backend logic and database management are handled by a .NET Core API. The Flutter app is responsible for the UI/UX and consuming the RESTful APIs provided by the backend.

## Prerequisites
To run this application successfully, you must have the backend service running locally or on a server.

## Getting Started

### 1. Backend Setup (Required)
The mobile application depends on the backend API. Please follow these steps to set up the backend:

- **Repository:** [Graduation Web Repository](https://github.com/mohamed-alkasem/graduation_web)
- **Clone the backend:**
  ```bash
  git clone [https://github.com/mohamed-alkasem/graduation_web.git](https://github.com/mohamed-alkasem/graduation_web.git)
  Configuration: - Navigate to the backend project folder.

Create an appsettings.json file.

Add your database connection string and API keys to the appsettings.json file to ensure the service runs correctly.

Run: Ensure the backend project is running before launching the Flutter app.

# 2. Frontend (Flutter) Setup
Once the backend is configured and running, you can set up the Flutter application:

Clone this repository.

Ensure your Flutter environment is set up correctly.

Update the API base URL in the Flutter app (if necessary) to point to your local backend address.

Run the project:

Bash
flutter run
Notes
This application is designed specifically to interface with the Graduation Web API.

Ensure that your local machine can communicate with the backend service.
