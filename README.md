# 🏢 Apartment Manager - Flutter App

A feature-rich **Apartment Management System** built with **Flutter** and **Sqflite**, designed to handle daily operations like credit payments, debit vouchers, account summaries, and reports with visual analytics.

---

## ✨ Features

### 🔐 User Panels
- Admin interface for managing all data locally
- No login required (for simplicity)

### 💳 Credit Payment
- Record credit payments (Maintenance, Rent, Bills)
- Auto-generated Receipt Number
- View/Edit credit transactions
- Export individual receipts as PDF

### 🧾 Debit Vouchers
- Record monthly expenses with vouchers
- Editable fields: Month, Date, Particular, Amount
- View vouchers in a tabbed layout
- Export voucher receipts as PDF

### 📊 Account Screen
- Combined statement of credit & debit
- Total Credit, Debit, Balance
- Month-wise filter
- Transaction Type tabs (All / Credit / Debit)
- Export complete statement as PDF or Excel

### 📈 Report Screen (Advanced Analytics)
- Monthly summary (Credit, Debit, Balance)
- Category-wise debit breakdown (Pie Chart)
- Top 5 Expenses & Incomes
- Visual Reports with Charts
- Month-wise dropdown selector
- Export full reports

---

## 🛠 Tech Stack

- **Flutter** (Frontend)
- **Sqflite** (Local SQLite DB)
- **Provider** (State Management)
- **fl_chart** (Pie & Bar Charts)
- **pdf** & **printing** (PDF Export)
- **path_provider** (File Access)

---

