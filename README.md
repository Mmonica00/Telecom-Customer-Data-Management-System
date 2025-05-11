# Telecom Customer Data Management System

A full-stack telecom service management platform built using **ASP.NET Web Forms (ASPX)** and **SQL Server**, as part of the Databases I course at the German University in Cairo (Winter 2024).

## 📌 Overview

This project simulates a telecom company's backend system with:
- Customer account management
- Subscription plans
- Wallets and payment tracking
- Voucher and cashback management
- Technical support handling

---

## 🛠 Technologies

- **Frontend:** ASP.NET Web Forms (ASPX)
- **Backend:** SQL Server 2019
- **Languages:** C#, T-SQL
- **UI Logic:** Code-behind (.aspx.cs) with event-driven interactions
- **Data Logic:** Stored Procedures, Views, and Functions

---

## 🎯 Core Features

### 🛡 Admin Portal
- Login (hardcoded)
- View all customers and their active accounts
- Monitor plan subscriptions and usage per account
- Manage benefit associations and SMS offers
- Audit payment history, cashback activity, and wallet stats
- Update point balances and check wallet associations

### 👤 Customer Portal
- Login using mobile number and password
- View available plans, usage, and unsubscribed offers
- Recharge balance or renew subscriptions
- Redeem vouchers and track cashback
- View open/resolved tickets and transaction summaries

---

### ⚙️ Database Functionalities
Over 40 stored procedures and functions including:
- `createAllTables`, `dropAllTables`, `clearAllTables`
- `Account_Usage_Plan`, `Wallet_Cashback_Amount`, `Account_Highest_Voucher`
- `Initiate_plan_payment`, `Payment_wallet_cashback`, `Redeem_voucher_points`




