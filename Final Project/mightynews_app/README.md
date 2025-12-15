

````markdown
# 📰 Mighty News Pro

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A robust, full-stack news application engineered with **Flutter** and **PostgreSQL**. Mighty News Pro features a complete Content Management System (CMS) with Role-Based Access Control (RBAC), real-time user interactions, and a clean, adaptive UI.

---

## 🚀 Key Features

### 🔐 Security & Access
* **Secure Authentication:** User registration and login with duplicate username protection.
* **RBAC (Role-Based Access Control):**
    * **Admin:** Full access to the Dashboard, ability to Write, Edit, and Delete articles.
    * **User:** Read-only access with interactive features (Like, Comment, Bookmark).

### 📱 User Experience
* **Live Search:** Real-time database querying for articles using SQL `ILIKE`.
* **Dynamic Categories:** Filter news by categories fetched directly from the database.
* **Smart Metadata:** Automatic calculation of "Read Time" based on content word count.
* **Dark/Light Mode:** Persisted theme preferences using Shared Preferences.

### 💬 Social & Cloud
* **Interactive Comments:** Community discussion section for every article.
* **Live Likes System:** Real-time counter updates synchronized with the backend.
* **Cloud Bookmarks:** Saved stories are stored in PostgreSQL, persisting across devices.
* **Support System:** Integrated ticketing system for user inquiries and bug reports.

---

## 🛠️ Tech Stack

* **Frontend Framework:** Flutter (Dart)
* **State Management:** Provider (Scoped Architecture)
* **Backend Database:** PostgreSQL
* **Database Connector:** `postgres` package (Direct connection)
* **Local Storage:** `shared_preferences` (Theme persistence)
* **Utilities:** `uuid` (Unique Keys), `intl` (Date Formatting), `image_picker`.

---

## 📂 Project Structure

The project follows a **Layered Architecture** to ensure scalability and maintainability.

```text
lib/
├── models/         # Data Models (User, BlogPost, Comment)
├── providers/      # State Management & Business Logic (Auth, Content)
├── screens/        # UI Views (Login, Home, Editor, Profile)
├── services/       # External Services (Database Connection)
└── main.dart       # Entry Point & Theme Config

database/
└── schema.sql      # Database Initialization Script
````

-----

## ⚙️ Installation & Setup

### Prerequisites

1.  **Flutter SDK** installed.
2.  **PostgreSQL** installed and running.

### 1\. Clone the Repository

```bash
git clone <your-repository-url>
cd mightynews_app
```

### 2\. Install Dependencies

```bash
flutter pub get
```

### 3\. Database Configuration

1.  Create a database named `Mightynewsapp` in PostgreSQL.
2.  Run the schema file located in `database/schema.sql`.

**Using Terminal:**

```bash
psql -U postgres -d Mightynewsapp -f database/schema.sql
```

**Note:** The app is configured to connect to `10.0.2.2` (Android Emulator) or `127.0.0.1` (Linux/Desktop). If running on a physical phone, update `lib/services/db_service.dart` with your PC's LAN IP.

### 4\. Run the App

```bash
flutter run
```

-----

## 🔑 Default Credentials

The database includes two default accounts for testing:

| Role | Username | Password | Permissions |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin` | `admin123` | Write Stories, Delete Content, Full Access |
| **User** | `user` | `user123` | Read, Like, Comment, Bookmark, Submit Tickets |

-----

## 📄 License

Distributed under the MIT License.

-----

**Developed by Ali Hassan**

```
```