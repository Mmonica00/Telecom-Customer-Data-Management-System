# Telecom Customer Data Management System

A full-stack web application that simulates a telecom company’s customer service platform, built as part of the Databases I course at the German University in Cairo (Winter 2024).

## 🧠 Project Overview

The system manages customer profiles, accounts, service plans, usage patterns, payments, vouchers, benefits, and support tickets. It includes an SQL Server relational database, stored procedures for logic, and a responsive React frontend for faculty/admin and customer interactions.

---

## 🔧 Technologies Used

- **Database:** Microsoft SQL Server  
- **Backend Logic:** Stored Procedures, Functions, Views  
- **Frontend:** React, TailwindCSS  
- **Icons/UI Components:** Lucide-react, ShadCN  
- **PDF Generation (Placeholder):** File download buttons

---

## 🎯 Key Features

### 📊 Faculty/Admin Dashboard
- View real-time statistics: Accepted/flagged reports, review times, top-rated companies and courses.
- Filter reports by major or status (pending, flagged, rejected, accepted).
- View detailed student internship reports.
- Accept, reject, or flag reports.
- Submit clarifications and download reports as PDFs.

### 👤 Customer Features
- Login using mobile number and password.
- View and manage service plans, usage, cashback, and vouchers.
- Make payments, renew plans, recharge balances, redeem vouchers.
- Submit and view support tickets.

### ⚙️ Database Functionalities
Over 40 stored procedures and functions including:
- `createAllTables`, `dropAllTables`, `clearAllTables`
- `Account_Usage_Plan`, `Wallet_Cashback_Amount`, `Account_Highest_Voucher`
- `Initiate_plan_payment`, `Payment_wallet_cashback`, `Redeem_voucher_points`


