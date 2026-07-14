import logging

logging.basicConfig(
    filename='hotel_app.log',
    level=logging.INFO,
    format='%(asctime)s-%(levelname)s-%(message)s'
)

import mysql.connector

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Parthi@1307", 
        database="project"
    )

def get_valid_input(prompt):
    while True:
        try:
            return int(input(prompt))
        except ValueError as err:
            print(f"Only integer values are allowed, Please enter valid input:{err}")  

def show_guests():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM guests")
        guests = cursor.fetchall()
        print("\n--- Current Guests ---")
        if not guests:
            print("No Guests Found")
        else:
            for guest in guests:
                print(f"ID: {guest[0]},Name: {guest[1]},Email: {guest[2]}")
    finally:
        cursor.close()
        conn.close()

def show_empty_rooms():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM room_availability")
        empty_rooms = cursor.fetchall()
        print("--- Empty Rooms ---")
        if not empty_rooms:
            print("No Empty Rooms")
        else:
            for room in empty_rooms:
                print(f"Room Id:{room[0]},Room Number: {room[1]}")
    finally:
        cursor.close()
        conn.close()

def show_bookings():
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM bookings")
        bookings = cursor.fetchall()
        print("--- BOOKINGS ---")
        if not bookings:
            print("There is no Bookings")
        else:
            for booking in bookings:
                print(f"Booking Id:{booking[0]},Guest Id:{booking[1]},Room Id:{booking[2]},CheckIn Date:{booking[3]},CheckOut Date:{booking[4]},Total Amount:{booking[5]}")
    finally:
        cursor.close()
        conn.close()


def book_room_input():
    guest_id = get_valid_input("Enter the Guest ID:")
    room_id = get_valid_input("Enter the Room ID:")
    check_in = input("Enter the Check In Date(YYYY-MM-DD):")
    check_out = input("Enter the Check Out Date(YYYY-MM-DD):")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc("book_room",(guest_id,room_id,check_in,check_out))
        conn.commit()
        logging.info(f"Room booked successfully for guest Id {guest_id} for room ID {room_id}")
        print("Room Booked Successfully!")
    except mysql.connector.Error as err:
        logging.error(f"Booking failed for guest Id {guest_id}:{err}")
        print(f"Error: Booking failed {err}")
    finally:
        cursor.close()
        conn.close()

def checkout():
    booking_id = get_valid_input("Enter the Booking ID")
    payment_method = input("Enter the type of payment(CASH, CREDIT CARD, DEBIT CARD, NET BANKING, UPI)")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc("checkout",(booking_id,payment_method))
        conn.commit()
        logging.info(f"Checkout successful for booking Id {booking_id}")
        print("Checkout Successful!")
    except mysql.connector.Error as err:
        logging.error(f"Error while checking out for booking Id{booking_id}:{err}")
        print(f"Error:{err}")
    finally:
        cursor.close()
        conn.close()


def main():
    while True:
        print("\n--- Hotel Management System ---")
        print("1. Show All Guests")
        print("2. Show Empty Rooms")
        print("3. Show Bookings")
        print("4. Book a Room")
        print("5. Checkout")
        print("6. Exit")
        choice = get_valid_input("Enter your choice (1 or 2 or 3....): ")
        
        if choice == 1:
            show_guests()
        elif choice == 2:
            show_empty_rooms()
        elif choice == 3:
            show_bookings()
        elif choice == 4:
            book_room_input()
        elif choice == 5:
            checkout()
        elif choice == 6:
            print("Exiting...")
            break
        else:
            print("Invalid choice, please try again.") 

if __name__ == "__main__":
    main()
