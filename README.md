# 🚌 Bus Booking Application

A full-stack **Bus Booking Application** built with **Flutter, Dart, Firebase, and Cloud Firestore**.

The application has three roles:

* **Normal User**
* **Bus Admin**
* **Super Admin**

Each role has different access and responsibilities.

---

## 👤 Normal User

Normal users are the customers of the application.

They can:

* Register and log in
* Search buses by source, destination, and date
* View available bus schedules
* Select boarding and dropping points
* View boarding and dropping times
* Select available seats
* Enter passenger details
* Book a bus
* View their own bookings and booking details

### User Booking Flow


Search Bus
    ↓
Select Schedule
    ↓
Select Boarding Point
    ↓
Select Dropping Point
    ↓
Select Seat
    ↓
Passenger Details
    ↓
Book Bus
    ↓
View Booking


Normal users cannot access administrative management features.


## 🚌 Bus Admin

A Bus Admin manages the bus assigned to them.

They have similar management features to the Super Admin, but their access is limited to **their own bus and its related data**.

They can manage:

* Their bus information
* Bus seats and layout
* Schedules
* Boarding points
* Dropping points
* Boarding and dropping times
* Bookings related to their bus
* Revenue related to their bus

### Example

If a Bus Admin is assigned:


Demo Volvo AC


they can manage the data related to that bus but cannot manage another Bus Admin's bus.

---

## 👑 Super Admin

The Super Admin has **application-wide administrative access**.

They can manage:

* All users
* All Bus Admins
* All buses
* Cities
* Routes
* All schedules
* Boarding and dropping points
* Timetables
* Seats
* All bookings
* Revenue across buses
* Other application management data

Unlike a Bus Admin, the Super Admin is not restricted to a particular bus.

---

## 🔐 Role Permissions

| Feature                  | User |   Bus Admin  | Super Admin |
| ------------------------ | :--: | :----------: | :---------: |
| Search Buses             |   ✅  |       —      |      —      |
| Book Bus                 |   ✅  |       —      |      —      |
| View Own Bookings        |   ✅  |       —      |      —      |
| Manage Bus               |   ❌  |    Own Bus   |  All Buses  |
| Manage Schedules         |   ❌  |    Own Bus   |  All Buses  |
| Manage Seats             |   ❌  |    Own Bus   |  All Buses  |
| Manage Boarding/Dropping |   ❌  |    Own Bus   |     All     |
| Manage Timetable         |   ❌  | Own Schedule |     All     |
| View Bookings            |  Own   |    Own Bus  |     All     |
| View Revenue             |   ❌  |    Own Bus   |     All     |
| Manage Cities            |   ❌  |       ❌      |      ✅      |
| Manage Routes            |   ❌  |  Own/Related |     All     |
| Manage Users             |   ❌  |       ❌      |      ✅      |
| Manage Bus Admins        |   ❌  |       ❌      |      ✅      |

---

## 🗄️ Main Application Structure

The application's main data relationship is:


Cities
  ↓
Routes
  ↓
Buses
  ↓
Schedules
  ↓
Boarding & Dropping Points
  ↓
Timetables
  ↓
Seats
  ↓
Bookings
  ↓
Users


For example:


Kolkata → Siliguri
       ↓
   Demo Volvo AC
       ↓
  Bus Schedule
       ↓
Boarding: Esplanade
Dropping: Siliguri Junction
       ↓
   Seat Selection
       ↓
     Booking
       ↓
      User


## 🛠️ Technology Stack

**Frontend**

* Flutter
* Dart

**Backend**

* Firebase
* Cloud Firestore
* Firebase Authentication

**Database**

Cloud Firestore stores application data such as:


Users
Buses
Cities
Routes
Schedules
Seats
Bookings
Boarding Points
Dropping Points
Timetables



##  Key Features

* Role-based authentication and access
* User bus search and booking
* Real-time seat availability
* Bus and schedule management
* City and route management
* Boarding and dropping point management
* Schedule-specific timetables
* Booking history
* Bus-specific Bus Admin access
* Application-wide Super Admin control
* Firebase-based real-time data management
