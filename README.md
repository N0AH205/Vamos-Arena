# 🎾 Vamos Arena – Digital Padel & Arena Booking System

Welcome to the **Vamos Arena** showcase repository. This repository is dedicated to presenting the design, features, architecture, and live flows of the **Vamos Arena** digital platform, while keeping the proprietary client codebase private.

[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](#)
[![Next.js](https://img.shields.io/badge/Framework-Next.js%2016-black.svg?style=flat&logo=next.js)](https://nextjs.org/)
[![Tailwind CSS v4](https://img.shields.io/badge/Styles-Tailwind%20CSS%20v4-38bdf8.svg?style=flat&logo=tailwind-css)](https://tailwindcss.com/)
[![Database](https://img.shields.io/badge/Database-Google%20Sheets%20(Serverless)-34a853.svg?style=flat&logo=google-sheets)](https://www.google.com/sheets/about/)

---

## 📖 Overview

**Vamos Arena** is a modern, high-performance web application designed for a premium Padel tennis facility. It features an aesthetic, neo-brutalist dark-themed design and streamlines arena operations, court bookings, facility previews, and booking verifications. 

To keep operational overhead and server maintenance costs at **zero**, Vamos Arena is built on a **fully serverless architecture** that leverages **Google Sheets** as a real-time database, communicating via a **Google Apps Script web service gateway**.

---

## 🛠️ Technology Stack

- **Frontend Framework:** Next.js (App Router, React 19, TypeScript)
- **Styling:** Tailwind CSS (v4) with high-contrast, modern custom design tokens (Neo-Brutalist elements, neon accents)
- **State & Routing:** Next.js Server & Client components, local storage session persistence
- **Backend / Database:** Serverless Google Apps Script API acting as a database router and file storage
- **Data Persistence:** Google Sheets (real-time booking ledger) + Google Drive (receipt image storage)

---

## 📐 System Architecture

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

## ⚡ Key Features

1. **Interactive Padel Calendar & Availability Grid**: Displays 31 rolling booking days starting from a configurable local window, updating the number of remaining spots dynamically.
2. **Double-Session Courts System**: Supports **Center Court** and **Courts 1-9** with 9 set two-hour daily time slots.
3. **Receipt Validation & File Handling**: Checkout form with custom file upload handler that automatically rejects screenshots > 1MB, encodes proof of transfer to Base64, and pushes it asynchronously to the database.
4. **Auto-refreshing Front Desk Admin Console**: Real-time admin dashboard with continuous polling (every 10 seconds), full search bar filtering (by name or verification code), and direct indicators for reception verification.
5. **Session Ticket Sync**: Local storage integration ensures customers do not lose access to their latest ticket, letting them recheck verification status directly from the home banner.

---

## 🖼️ Visual Walkthrough

### 1. Landing Page & Court Reservation
A premium, dark-themed interface with vibrant neon accents and a custom grid layout. Includes an interactive calendar to select dates.
![Landing Page Screenshot](assets/landing.png)

### 2. Facilities Showcase
Beautifully displays the high-end premium facilities of the Arena.
![Facilities Page Screenshot](assets/facilities.png)

### 3. Court Detail slots grid
Shows live-synced reservation slots. Red slots indicate court bookings already verified or under review.
![Court Slots Screenshot](assets/court_details.png)

### 4. Custom Checkout & Payment Upload
Fully functional payment verification flow. Features input fields for PIC details, WhatsApp connection, and receipt screenshot upload.
![Checkout Page Screenshot](assets/checkout.png)

### 5. Access Ticket & Code Delivery
Unique 5-digit alpha-numeric ticket generation. Displayed clearly for the receptionist to verify arrival.
![Success Page Screenshot](assets/success.png)

### 6. Receptionist Desk (Admin Control Panel)
Allows the arena staff to view all bookings in real time, search for codes/names, view receipt screenshots, and verify payments.
![Admin Desk Page Screenshot](assets/admin_desk.png)

---

## 🚀 How It Works (Development Environment Guide)

If you are modifying this type of serverless project, here is how you can set up a local replica.

### 📋 Prerequisites
- [Node.js](https://nodejs.org/) (v20+ recommended)
- A Google Account (for Google Sheets & Apps Script setup)

### 🚀 Getting Started

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Configure Google Apps Script**:
   Create a Google Apps Script in your Google Drive and bind it to a spreadsheet. Paste the Apps Script handler code (sample structure below):
   ```javascript
   function doGet(e) {
     var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
     var data = sheet.getDataRange().getValues();
     var headers = data[0];
     var list = [];
     for(var i = 1; i < data.length; i++) {
       var row = {};
       for(var j = 0; j < headers.length; j++) {
         row[headers[j]] = data[i][j];
       }
       list.push(row);
     }
     return ContentService.createTextOutput(JSON.stringify(list))
       .setMimeType(ContentService.MimeType.JSON);
   }

   function doPost(e) {
     var params = JSON.parse(e.postData.contents);
     var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
     
     // Handle base64 receipt upload (store file in Google Drive)
     var fileUrl = "";
     if (params.imageBase64) {
       var folder = DriveApp.getFolderById("YOUR_GOOGLE_DRIVE_FOLDER_ID");
       var file = folder.createFile(Utilities.newBlob(Utilities.base64Decode(params.imageBase64), params.mimeType, params.fileName));
       fileUrl = file.getUrl();
     }

     sheet.appendRow([
       params.uniqueCode,
       params.picName,
       params.picWa,
       params.clubName,
       params.clubIg,
       params.reclubLink,
       params.totalMember,
       params.rekNumber,
       params.date,
       params.court,
       params.time,
       fileUrl,
       "PENDING VERIFICATION"
     ]);
     return ContentService.createTextOutput(JSON.stringify({status: "success"}))
       .setMimeType(ContentService.MimeType.JSON);
   }
   ```
   Deploy this Apps Script web app with access set to "Anyone" and copy the Web App URL.

3. **Update Next.js config**:
   Replace the API endpoints in `src/app/page.tsx`, `src/app/court/[id]/page.tsx`, `src/app/checkout/page.tsx`, and `src/app/admin/page.tsx` with your deployed Apps Script web app URL.

4. **Run Dev Mode**:
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000) to view and test the application.

---

## 🔒 Confidentiality Notice

This repository contains **only presentation materials** and documentation for showcase purposes. No proprietary source code is hosted here. Copying, distributing, or attempting to decompile this system without authorization is strictly prohibited.

For inquiries or custom software integration, contact the repository owner.
