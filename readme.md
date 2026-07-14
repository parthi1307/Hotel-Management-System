# Hotel Management System

A robust, database-driven Hotel Management System designed to handle guest records, room availability, booking transactions, and payments.

## Features
- **Guest Management:** Track guest details and history.
- **Dynamic Booking:** Automatic calculation of total stay costs using MySQL stored procedures.
- **Data Integrity:** Database triggers prevent invalid dates (e.g., checkout before check-in).
- **Audit Trails:** Automatic recording of booking history via database triggers.
- **Professional Logging:** All system actions are recorded in `hotel_app.log` for debugging and maintenance.

## Prerequisites
- **Python 3.x**
- **MySQL Server**
- **Library:** `pip install mysql-connector-python`

## Database Setup
1. Open your MySQL client or Workbench.
2. Execute the contents of `database.sql` to create the schema, tables, triggers, and stored procedures.
3. Ensure your MySQL credentials match those in `hotel_app.py`.

## Running the Application
1. Update `get_db_connection()` in `hotel_app.py` with your database password.
2. Run the application:
   ```bash
   python hotel_app.py