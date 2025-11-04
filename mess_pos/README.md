# Lab-Mid: Doctor App

A Flutter application for doctors to manage patient information efficiently. The app supports full CRUD (Create, Read, Update, Delete) operations for patient records, stores data locally using a mock service, and allows for uploading patient-related images.

## Features

- **Patient Management**: Add, view, edit, and delete patient records.
- **Local Data Storage**: Uses a mock service that simulates a local database for offline data persistence.
- **File Management**: Upload and manage patient profile images.
- **Modern UI**: A clean, doctor-friendly interface with a blue and white theme.
- **Search Functionality**: Easily search for patients by name or phone number.

## 📸 Screenshots

*(Screenshots of the main screen, add/edit patient form, and patient details view would be placed here.)*

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A configured editor (e.g., VS Code, Android Studio)

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/your-repo-name.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd Lab-Mid
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```

## 🏗️ Project Structure

The application is structured into several key components for better organization:

- **Data Models**: The `Patient` class (`lib/patient.dart`) defines the structure for patient records.
- **Database Service**: `PatientDatabaseService` (`lib/patient_database_service.dart`) simulates a local SQLite database for CRUD operations.
- **UI Widgets**:
  - `PatientListScreen`: The main screen that displays a list of all patients.
  - `PatientEditScreen`: A form for adding and editing patient information.

## 🔮 Future Improvements

- **Implement SQLite**: Replace the mock database service with a real `sqflite` implementation for robust local storage.
- **Document Management**: Allow uploading and viewing of multiple documents (PDFs, images) for each patient.
- **Enhanced UI/UX**: Add animations, improved layouts, and more detailed patient view screens.
- **State Management**: Integrate a state management solution like Provider or BLoC for more complex state handling.
