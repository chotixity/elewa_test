# elewa_test

# Company App

## Project Overview

This project is a company management application built with Flutter and Firebase. It allows company employees to view the application’s landing page, sign up, and log in. Depending on their role, users can perform different actions:

- **System Administrator**: Can assign users the manager role.
- **Managers**: Can create departments, assign tasks, move employees, and more.
- **Employees**: Can view and update their tasks.

## Features

- **Authentication**: User sign-up and login with Firebase Auth.
- **Data Persistence**: Using Firestore to store user data, tasks, and departments.
- **Role-Based Access Control**: Different features accessible based on user roles.
- **Task Management**: Create, edit, delete, and assign tasks.
- **Department Management**: Create and manage departments.
- **Persistent Login**: Users remain signed in after a refresh.
- **Email Notifications**: Email notifications for task due dates.
- **Summary Dashboard**: View overall task completion rates and departmental performance.
- **Recurring Tasks**: Schedule recurring tasks.

## File Structure

- `lib/presentation`: Contains all the screen widgets.
- `lib/services`: Contains services for authentication, Firestore operations, notifications, and task management.
- `lib/models`: Contains data models.
- `lib/main.dart`: Main entry point of the application.

## Setup Instructions

1. **Clone the Repository**:
   ```sh
   git clone
   install flutter if you dont have it installed already 
   inside the project direcory run flutter pub get
   run flutter run web --release
