#  Bus Booking Application

A bus booking application built with **Flutter, Dart, Firebase, and Cloud Firestore**.


###  Run the project

Clone the repository:

git clone https://github.com/plama2182-source/bus_booking_app.git

Open the project:

cd bus_booking_app

Install dependencies:

flutter pub get

Run the application:

flutter run

For Flutter Web:

flutter run -d chrome


###  Creating a  Super Admin Account

For creating super admin account , the required Secret code is:
BUS_ADMIN_2026

###  Creating a  Bus  Admin Account

A Bus Admin account must first be validated by the Super Admin.

Until the Super Admin approves/verifies the Bus Admin account, the Bus Admin cannot operate the bus-management features.

After verification, the Bus Admin can manage only their own assigned bus, not other buses in the application.


##  Demo Setup

Before testing the **User Booking** section, create the data in this order:


City
 ↓
Route
 ↓
Bus
 ↓
Bus Schedule
 ↓
Boarding & Dropping Points
 ↓
Boarding & Dropping Timetable


### 1. Add Cities

Login as ** Bus Admin** and add the cities you want to use.

Example:


Kolkata
Siliguri
Durgapur


### 2. Create Route

Create a route using the cities.

Example:


Kolkata → Siliguri


### 3. Create Bus Schedule

Login as **Bus Admin** and create a schedule using the bus and route.

Example:


Bus: Demo Volvo AC
Route: Kolkata → Siliguri
Date: Future Date


### 4. Add Boarding & Dropping Points

Add boarding and dropping points for the **same route**.

Example:


Boarding:
Esplanade
Sealdah

Dropping:
Siliguri Junction


### 5. Create Timetable

Create the **boarding and dropping times for the specific schedule** you created.

Example:


Esplanade → 08:00 AM
Sealdah → 08:30 AM

Siliguri Junction → 06:00 PM


### 6. Test as User

Login as a **User** and:

Search Bus
 ↓
Select Date
 ↓
Select Boarding Point
 ↓
Select Dropping Point
 ↓
Select Seat
 ↓
Book Bus





> **Important:** The schedule must have a **future date**, and the timetable must be linked to the **same schedule** you are testing.
