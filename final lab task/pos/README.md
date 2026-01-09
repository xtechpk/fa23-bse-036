# 📱 Smart POS (Point of Sale) System
**A Complete Mobile-Based Retail Management Solution**

---

## 📌 Project Introduction

The **Smart POS (Point of Sale) System** is a mobile-based retail application developed using **Flutter**.  
This system is designed to replace traditional manual billing systems by providing a **digital, fast, reliable, and offline-capable POS solution**.

It helps shop owners manage **inventory, categories, sales, receipts, and returns** efficiently through a clean and user-friendly interface.

---

## 🎯 Project Objectives

- Automate retail sales and billing processes  
- Manage inventory efficiently with real-time stock updates  
- Minimize human errors in billing  
- Generate professional digital receipts  
- Support offline usage using a local database  
- Provide a scalable foundation for future upgrades  

---

## 🧩 Problem Statement

Many small and medium businesses still rely on manual billing systems which are:

- Time-consuming  
- Error-prone  
- Difficult to maintain  
- Lacking proper sales records  

The **Smart POS System** solves these problems by offering a **modern mobile-based solution** with structured data storage and automated workflows.

---

## ✨ Functional Features

### 📦 Inventory Management
- Add, Update, and Delete products (CRUD)
- Real-time stock quantity tracking
- Low-stock visual indicators
- Product image support
- SKU-based product identification
- Category-wise product organization

---

### 📂 Category Management
- Create, update, and delete product categories
- Faster product access
- Improved navigation

---

### 🛒 Point of Sale (Checkout)
- Dynamic shopping cart
- Real-time price calculations
- Multiple payment options:
  - Net Payment
  - Installment Payment
- Automatic invoice generation

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
- Automatic inventory update after returns

---

## 🏗️ System Architecture

The system follows a **layered architecture**:

1. **Presentation Layer** – Flutter UI & Material Design  
2. **Business Logic Layer** – Cart, Orders, Payments  
3. **Data Layer** – SQLite (Offline-first storage)

---

## 🗄️ Database Design Overview

- **Products** (ID, Name, Price, Stock, Category, Image)
- **Categories** (ID, Name)
- **Orders** (ID, Date, Total, Payment Method)
- **Order Items** (Order ID, Product ID, Quantity, Price)

---

## 🛠️ Technology Stack

| Component | Technology |
|--------|-----------|
| Framework | Flutter (Dart) |
| Database | SQLite (`sqflite`) |
| PDF & Printing | `pdf`, `printing` |
| Image Picker | `image_picker` |
| Utilities | `intl`, `uuid` |

---

## 📸 Application Screenshots

> The following screenshots demonstrate the complete working flow of the Smart POS System.

### 🏠 Inventory & Product Management

| Inventory Screen | Add Product | Edit Product |
|------------------|------------|--------------|
| ![Inventory](screenshots/inventory.png) | ![Add Product](screenshots/add_product.png) | ![Edit Product](screenshots/edit_product.png) |

---

### 🛒 Cart & Checkout Process

| Cart Screen | Checkout | Payment Method |
|------------|----------|----------------|
| ![Cart](screenshots/cart.png) | ![Checkout](screenshots/checkout.png) | ![Payment](screenshots/payment.png) |

---

### 📄 Receipt & Order History

| PDF Receipt | Order History | Order Details |
|-------------|---------------|---------------|
| ![Receipt](screenshots/receipt.png) | ![Orders](screenshots/orders.png) | ![Order Details](screenshots/order_details.png) |

---

### ↩️ Returns Management

| Returns Screen | Partial Return |
|----------------|----------------|
| ![Returns](screenshots/returns.png) | ![Partial Return](screenshots/partial_return.png) |

---

## 🚀 Application Workflow

1. User opens inventory dashboard
2. Categories and products are managed
3. Products are added to cart
4. Checkout is initiated
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

### Steps

```bash
flutter pub get
flutter run
