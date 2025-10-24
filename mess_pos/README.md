# mess_pos
# Hotel Mess POS System

A new Flutter project.
A comprehensive, responsive Point-of-Sale (POS) system built with Flutter, designed for a hotel mess or small restaurant environment. This application provides a complete solution for managing sales, customers, menu items, and reporting, all within a single, easy-to-use interface.

## Getting Started
## Features

This project is a starting point for a Flutter application.
- **Responsive UI**: Adapts seamlessly from mobile to desktop screen sizes.
- **User Authentication**: Secure login and registration system for staff.
- **Sales Terminal**:
  - **Customer Selection**: Choose from a list of registered customers or select a "Walk-in" customer.
  - **On-the-Fly Customer Registration**: Add new customers directly from the sales screen.
  - **Searchable Menu**: Quickly find menu items by name or category using a live search bar.
  - **Interactive Cart**: Add items to the cart, adjust quantities, and see the total update in real-time.
  - **Partial Payments & Dues**: Handle partial payments at checkout, with the remaining amount automatically added to the customer's pending balance.
  - **Mobile-Friendly Cart**: On smaller screens, the cart is presented as a draggable bottom sheet for an intuitive user experience.
- **Management Dashboard**: A tab-based interface for all administrative tasks.
  - **Menu Management**: Full CRUD (Create, Read, Update, Delete) functionality for menu items.
  - **Category Management**: Easily add, edit, or delete menu categories.
  - **Customer Management**: View all registered customers, their pending balances, and process payments to clear dues.
  - **Sales Reports**: A detailed, searchable log of all transactions. View individual receipts with a complete breakdown of items, totals, and payments.
  - **Profile Section**: A dedicated area for staff to log out.

A few resources to get you started if this is your first Flutter project:
---
## 📸 Screenshots

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
| Mobile View |
| :---: |
| ![Mobile Screenshot](assets/screenshots/mobile_view.png) |

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A configured editor (like VS Code or Android Studio)

### Installation

1.  **Clone the repository:**
    ```sh
    git clone <your-repository-url>
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd mess_pos
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```

---

## 🏗️ Project Structure

The entire application is currently contained within `lib/main.dart`. It is structured into several key components:

- **Data Models**: Classes like `MenuItem`, `Customer`, `Transaction`, etc., define the core data structures.
- **Service Layer**: A mock `SharedPreferencesService` is used to simulate data persistence. This can be easily replaced with a real database or `shared_preferences` implementation.
- **UI Widgets**:
  - `MessPosScreen`: The main stateful widget that manages the application's overall state.
  - `_AuthScreen`: Handles user login and registration.
  - `_ManagementScreen`: The container for the management dashboard tabs.
  - `_Build...` Widgets: Each management tab (e.g., `_BuildMenuManagement`) is its own dedicated widget.

---

## 🔮 Future Improvements

- **Real Database**: Replace the mock `SharedPreferencesService` with a real local database solution like `sqflite` or a backend service like Firebase.
- **Printer Integration**: Add functionality to print receipts to a thermal printer.
- **Enhanced Analytics**: Create a dashboard with charts and graphs to visualize sales data.
- **Refactor to Separate Files**: Break down the large `main.dart` file into smaller, more manageable files for better organization.
