# 🎾 Vamos Arena / Digital Padel Booking System
**[Live Official Website ↗](https://vamos-arena-indo.vercel.app/)**

*Note: This repository is an architectural showcase and case study. The actual source code is proprietary and owned by the client, so this repo serves to document the system design, features, and technical workflows.*

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](#)
[![Next.js](https://img.shields.io/badge/Framework-Next.js%2016-black.svg?style=flat&logo=next.js)](https://nextjs.org/)
[![Tailwind CSS v4](https://img.shields.io/badge/Styles-Tailwind%20CSS%20v4-38bdf8.svg?style=flat&logo=tailwind-css)](https://tailwindcss.com/)
[![Database](https://img.shields.io/badge/Database-Google%20Sheets%20(Serverless)-34a853.svg?style=flat&logo=google-sheets)](https://www.google.com/sheets/about/)

---

## Overview

**Vamos Arena** is web application designed for a premium Padel tennis facility that streamlines arena operations, court bookings, facility previews, and booking verifications. 

---

## Technology Stack

- **Frontend Framework:** Next.js (App Router, React 19, TypeScript)
- **Styling:** Tailwind CSS
- **State & Routing:** Next.js Server & Client components, local storage session persistence
- **Backend / Database:** Serverless Google Apps Script API acting as a database router and file storage
- **Data Persistence:** Google Sheets (real-time booking ledger) + Google Drive (receipt image storage)

---

## System Architecture

### Component Diagram
```mermaid
graph TD
    subgraph Client [Client App - Next.js]
        LP[Landing & Calendar Page] --> |View Court Slots| CD[Court Booking Slots Grid]
        CD --> |Proceed to Book| CO[Checkout & Payment Upload]
        CO --> |Successful Booking| SP[Validation Code / Access Ticket]
        AD[Admin Desk Dashboard] --> |Live Auto-Refresh Logs| GL[Google Apps Script Gateway]
    end

    subgraph Serverless Backend [Google Cloud Services]
        GL -->|GET / POST| GAS[Google Apps Script Web App]
        GAS -->|Read / Write Booking Row| GS[Google Sheets Database]
        GAS -->|Store Payment Receipt Image| GD[Google Drive Storage]
    end

    LP -.->|Read Active Slots| CD
    CO -.->|Upload Receipt File < 1MB| CO
    SP -.->|Read local state code| LP
```

### Sequence Flow (Booking & Verification)
```mermaid
sequenceDiagram
    autonumber
    actor Customer as Padel Player
    participant SPA as Next.js SPA
    participant API as Google Apps Script API
    participant Sheet as Google Sheets DB
    participant Desk as Receptionist Desk

    Customer->>SPA: View Arena Calendar & Select Date/Slot
    SPA->>API: Fetch Booked Slots (GET Request)
    API->>Sheet: Scan Booking Rows
    Sheet-->>API: Active Booked Slots List
    API-->>SPA: Return Booked Slots Array
    SPA-->>Customer: Display Slots (Available / Booked)
    
    Customer->>SPA: Selects Time & Enters Details
    Customer->>SPA: Uploads Payment Receipt (Auto Base64 & size validation)
    Customer->>SPA: Click "Confirm & Book"
    SPA->>API: Submit Payload & base64 image (POST Request)
    API->>Sheet: Insert Booking Row (Pending Verification)
    API-->>SPA: Return Status 200 & Unique Access Code
    SPA->>Customer: Display Access Code & Pending Verification status

    Note over Desk, Sheet: Receptionist verifies status
    Desk->>API: Fetch All Bookings (GET Request, Auto-Refreshes every 10s)
    API->>Sheet: Scan all rows
    Sheet-->>API: Full log array
    API-->>Desk: Display live bookings
    Desk->>Desk: Verify BCA bank transfer matches uploaded screenshot
    Desk->>Sheet: Mark code status as "VERIFIED" (Admin Sheet side)
    Customer->>SPA: Re-checks Validation Code on Home screen
    SPA->>API: Fetch Live Code Status
    API->>Sheet: Read current Code Status
    Sheet-->>API: Verified
    API-->>SPA: Verified Status response
    SPA-->>Customer: Render "VERIFIED" status (Green Badge)
```

---

## Key Features

1. **Interactive Padel Calendar & Availability Grid**: Displays 31 rolling booking days starting from a configurable local window, updating the number of remaining spots dynamically.
2. **Double-Session Courts System**: Supports **Center Court** and **Courts 1-9** with 9 set two-hour daily time slots.
3. **Receipt Validation & File Handling**: Checkout form with custom file upload handler that automatically rejects screenshots > 1MB, encodes proof of transfer to Base64, and pushes it asynchronously to the database.
4. **Auto-refreshing Front Desk Admin Console**: Real-time admin dashboard with continuous polling (every 10 seconds), full search bar filtering (by name or verification code), and direct indicators for reception verification.
5. **Session Ticket Sync**: Local storage integration ensures customers do not lose access to their latest ticket, letting them recheck verification status directly from the home banner.

---

## Visual Walkthrough

### 1. Landing Page & Court Reservation
![Landing Page Screenshot](assets/5.png)
### 2. Facilities Showcase
Displays the facilities of the Arena.
![Facilities Page Screenshot](assets/4.png)

### 3. Court Detail slots grid
Shows live-synced reservation slots. Red slots indicate court bookings already verified or under review.
![Court Slots Screenshot](assets/3.png)

### 4. Custom Checkout & Payment Upload
Fully functional payment verification flow. Features input fields for PIC details, WhatsApp connection, and receipt screenshot upload.
![Checkout Page Screenshot](assets/2.png)

### 5. Access Ticket & Code Delivery
Unique 5-digit alpha-numeric ticket generation. Displayed clearly for the receptionist to verify arrival.
![Success Page Screenshot](assets/6.png)

### 6. Receptionist Desk (Admin Control Panel)
Allows the arena staff to view all bookings in real time, search for codes/names, view receipt screenshots, and verify payments.
![Admin Desk Page Screenshot](assets/1.png)

---

## Confidentiality Notice

This repository contains **only presentation materials** and documentation for showcase purposes. No proprietary source code is hosted here. Copying, distributing, or attempting to decompile this system without authorization is strictly prohibited.

For inquiries or custom software integration, contact the repository owner.
