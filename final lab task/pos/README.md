# 📱 Smart POS (Point of Sale) System
**A Complete Mobile-Based Retail Management Solution**

---

## 📌 Project Introduction

The **Smart POS (Point of Sale) System** is a mobile-based retail management application developed using **Flutter**.  
It is designed to digitize and automate retail operations such as **user authentication, inventory management, sales processing, receipt generation, and returns handling**.

The application follows an **offline-first architecture** using **SQLite**, ensuring smooth and reliable performance even without an active internet connection.

---

## 🎯 Project Objectives

- Automate retail billing and sales processes  
- Provide secure **Login & Registration** functionality  
- Manage inventory with real-time stock updates  
- Reduce manual and calculation errors  
- Generate professional digital receipts  
- Support offline data storage  
- Build a scalable system for future enhancements  

---

## 🧩 Problem Statement

Many small and medium-sized retail businesses still rely on manual billing systems, which are:

- Time-consuming  
- Error-prone  
- Difficult to manage  
- Lacking proper sales records  

The **Smart POS System** solves these problems by providing a **secure, fast, and user-friendly mobile POS solution**.

---

## ✨ Functional Features

### 🔐 Authentication System
- User Registration
- Secure Login
- Session-based access control
- Prevents unauthorized usage

---

### 📦 Inventory Management
- Add, Update, and Delete products (CRUD)
- Real-time stock quantity tracking
- Low-stock visual indicators
- Product image support
- SKU-based product identification
- Category-wise organization

---

### 📂 Category Management
- Create, Update, Delete categories
- Improved navigation and product grouping

---

### 🛒 Point of Sale (Checkout)
- Dynamic shopping cart
- Add / remove products in real time
- Automatic price & total calculation
- Multiple payment methods:
  - Net Payment
  - Installment Payment
- Smooth checkout workflow

---

### 📄 Receipt Generation & Printing
- Professional PDF receipt generation
- QR Code integration for order verification
- Print, save, or share receipts digitally

---

### ↩️ Returns & Order History
- Complete transaction history
- Date-wise sorting
- Full and partial product returns
- Automatic inventory synchronization

---

## 🏗️ System Architecture

The application follows a **layered architecture**:

1. **Presentation Layer** – Flutter UI & Material Design  
2. **Business Logic Layer** – Authentication, Cart, Orders, Payments  
3. **Data Layer** – SQLite (Offline-first local database)

---

## 🗄️ Database Design Overview

- **Users** (ID, Name, Email, Password)  
- **Products** (ID, Name, Price, Stock, Category, Image)  
- **Categories** (ID, Name)  
- **Orders** (ID, Date, Total, Payment Method)  
- **Order Items** (Order ID, Product ID, Quantity, Price)

---

## 🛠️ Technology Stack

| Component | Technology |
|---------|------------|
| Framework | Flutter (Dart) |
| Database | SQLite (`sqflite`) |
| Authentication | Local Authentication |
| PDF & Printing | `pdf`, `printing` |
| Image Handling | `image_picker` |
| Utilities | `intl`, `uuid` |

---

## 🎥 Demo Video

▶ **Application Demo Video:**  
👉 https://your-demo-video-link-here

> The demo video demonstrates login, inventory management, checkout, receipt generation, and returns.

---

## 📸 Application Screenshots

> Screenshots below demonstrate the complete workflow of the application.  
> Images are resized for a clean and professional appearance.

### 🔐 Authentication Screens

<p align="center">
  <img src="screenshots/login.png" width="260"/>
  <img src="screenshots/register.png" width="260"/>
</p>

---

### 📦 Inventory & Product Management

<p align="center">
  <img src="screenshots/inventory.png" width="240"/>
  <img src="screenshots/add_product.png" width="240"/>
  <img src="screenshots/edit_product.png" width="240"/>
</p>

---

### 🛒 Cart & Checkout Process

<p align="center">
  <img src="screenshots/cart.png" width="240"/>
  <img src="screenshots/checkout.png" width="240"/>
  <img src="screenshots/payment.png" width="240"/>
</p>

---

### 📄 Receipt & Order History

<p align="center">
  <img src="screenshots/receipt.png" width="240"/>
  <img src="screenshots/orders.png" width="240"/>
  <img src="screenshots/order_details.png" width="240"/>
</p>

---

### ↩️ Returns Management

<p align="center">
  <img src="screenshots/returns.png" width="260"/>
  <img src="screenshots/partial_return.png" width="260"/>
</p>

---

## 🚀 Application Workflow

1. User registers or logs in  
2. Inventory and categories are managed  
3. Products are added to cart  
4. Checkout process is initiated  
5. Payment method is selected  
6. Receipt is generated and printed  
7. Orders are stored in history  
8. Returns are processed if required  

---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Steps to Run

```bash
flutter pub get
flutter run
