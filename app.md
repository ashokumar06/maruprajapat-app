# 🏺 Maru Prajapat Application — Specification v0.2

> **Platform:** Flutter (Android)
> **Backend:** Firebase (Sirf Free / Spark Plan Services)
> **Default Language:** Hindi (`hi`) | Secondary: English (`en`)
> **Last Updated:** June 2025

---

## 📋 Table of Contents

1. [Introduction](#1-introduction)
2. [Application Objectives](#2-application-objectives)
3. [Technology Stack — Free Firebase Only](#3-technology-stack)
4. [Firebase Free Tier Limits](#4-firebase-free-tier-limits)
5. [User Roles & Permissions](#5-user-roles--permissions)
6. [Authentication Flow](#6-authentication-flow)
7. [Permission Strategy (Play Store Compliant)](#7-permission-strategy)
8. [Membership Approval Flow](#8-membership-approval-flow)
9. [Posting System](#9-posting-system)
10. [Comment & Interaction System](#10-comment--interaction-system)
11. [Notice Management System](#11-notice-management-system)
12. [Events Management Module](#12-events-management-module)
13. [Dynamic Forms Engine](#13-dynamic-forms-engine)
14. [Complaint Management System](#14-complaint-management-system)
15. [Scholarship Portal](#15-scholarship-portal)
16. [Examination & Education Module](#16-examination--education-module)
17. [Marketplace Module](#17-marketplace-module)
18. [Matrimony Module](#18-matrimony-module)
19. [Family Tree Module](#19-family-tree-module)
20. [Community Listings & Registration Services](#20-community-listings--registration-services)
21. [Business & Artisan Directory](#21-business--artisan-directory)
22. [Community Member Addition Requests](#22-community-member-addition-requests)
23. [Automatic Community Feed Updates](#23-automatic-community-feed-updates)
24. [Chat & Messaging System](#24-chat--messaging-system)
25. [Blood Donation Module](#25-blood-donation-module)
26. [Donation & Fundraising Module](#26-donation--fundraising-module)
27. [Notification Strategy (FCM — Free)](#27-notification-strategy)
28. [Single Device Login Policy](#28-single-device-login-policy)
29. [Firestore Security Rules Strategy](#29-firestore-security-rules-strategy)
30. [Administrative Dashboard](#30-administrative-dashboard)
31. [Firestore Database Collections](#31-firestore-database-collections)
32. [Future Enhancements](#32-future-enhancements)

---

## 1. Introduction

Maru Prajapat Application ek **digital ecosystem** hai jo Maru Prajapat community ke liye banaya ja raha hai.

Iska uddeshya hai ki community ke sabhi sadasya ek hi platform par:

- Communication kar sakein
- Information share kar sakein
- Events mein participate kar sakein
- Educational resources access kar sakein
- Scholarships ke liye apply kar sakein
- Business manage kar sakein
- Announcements padh sakein

Yeh application fragmented WhatsApp groups aur Facebook pages ki jagah lega aur ek **unified, secure, aur scalable platform** provide karega — jo puri tarah **Firebase ke free (Spark) plan** par run karega bina kisi paid service ke.

> ⚠️ **Important Design Principle:** Koi bhi paid service use nahi ki jayegi. Sab kuch Firebase Spark Plan (free tier) ke andar hi design kiya gaya hai. Cloud Functions ko avoid kiya jayega jahan tak possible ho; client-side logic aur Firestore Security Rules ko prefer kiya jayega.

---

## 2. Application Objectives

| # | Objective |
|---|-----------|
| 1 | Verified digital community platform establish karna |
| 2 | Members ke beech real-time communication enable karna |
| 3 | Membership verification ko simplify karna |
| 4 | Educational aur scholarship opportunities provide karna |
| 5 | Community businesses ke liye marketplace banana |
| 6 | Events management aur registrations facilitate karna |
| 7 | Complaint resolution aur feedback collect karna |
| 8 | Timely notifications aur announcements deliver karna |
| 9 | Role-based permission system maintain karna |

---

## 3. Technology Stack

### 3.1 Frontend (Flutter)

| Technology | Use |
|-----------|-----|
| **Flutter** | Cross-platform UI framework |
| **Riverpod** | State management |
| **Go Router** | Navigation & deep linking |
| **Material 3** | UI Design System |

### 3.2 Backend — Sirf Free Firebase Services

> Neeche sirf woh Firebase services listed hain jo **Spark Plan (free)** mein available hain aur is app mein use hongi.

| Firebase Service | Kaise Use Hoga | Free Limit |
|-----------------|----------------|------------|
| **Firebase Authentication** | Email/Password login, user identity | 50,000 MAU/month free |
| **Cloud Firestore** | Main database — posts, users, events, sab kuch | 50K reads/day, 20K writes/day, 1GB storage |
| **Firebase Storage** | Images, PDFs, documents upload | 5GB storage, 1GB download/day |
| **Firebase Cloud Messaging (FCM)** | Push notifications | **Unlimited — bilkul free** |
| **Firebase Analytics** | User behavior tracking | **Unlimited — bilkul free** |
| **Firebase Crashlytics** | Crash reports | **Unlimited — bilkul free** |
| **Firebase Remote Config** | App settings remotely change karna | **Unlimited — bilkul free** |
| **Firebase Hosting** | Admin web dashboard host karna | 10GB storage, 360MB/day bandwidth |
| **Firebase App Check** | API abuse se bachao | Free |

### 3.3 Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ Primary |
| iOS | 🔜 Future |
| Web (Admin Dashboard) | ✅ Firebase Hosting par |

### 3.4 ❌ Jo Services Use NAHI Hongi

| Service | Reason |
|---------|--------|
| Firebase Cloud Functions | Blaze plan required hai deployment ke liye |
| Firebase ML Kit (custom models) | Paid features hain |
| Google Maps API | Paid after free limit |
| Any AI/ChatGPT API | Paid service — use nahi karna |
| Razorpay / PhonePe SDK | Payment gateway — Phase 2 ke liye defer |
| Phone OTP Auth | SMS cost lagti hai — future mein |

> 💡 **Cloud Functions Alternative:** Koi bhi logic jo pehle Cloud Functions mein jaata, use **Firestore Security Rules + Client-side Dart code + Scheduled Firestore TTL** se handle kiya jayega.

---

## 4. Firebase Free Tier Limits

Yeh table developer ko guide karegi ki kab optimize karna padega:

| Service | Free Daily/Monthly Limit | Alert Threshold |
|---------|--------------------------|-----------------|
| Firestore Reads | 50,000 / day | >35,000 reads/day |
| Firestore Writes | 20,000 / day | >14,000 writes/day |
| Firestore Deletes | 20,000 / day | >14,000 deletes/day |
| Firestore Storage | 1 GB total | >700 MB |
| Firebase Storage | 5 GB total | >3.5 GB |
| Storage Downloads | 1 GB / day | >700 MB/day |
| FCM Notifications | Unlimited | — |
| Firebase Auth MAU | 50,000 / month | >35,000 users |

### Read Optimization Strategies (Important!)

```
1. Pagination lagao — ek baar mein max 15-20 documents load karo
2. Offline persistence enable karo (Firestore cache)
3. Real-time listeners sirf active screens par lagao, baaki mein one-time fetch
4. Images Firebase Storage se serve karo, Firestore mein URLs store karo
5. Community feed mein "load more" button use karo — auto-infinite scroll avoid karo
```

---

## 5. User Roles & Permissions

App mein **4 roles** hain. Har role ke permissions neeche defined hain.

### 5.1 Role Hierarchy

```
Super Admin  (1 only)
    │
   Admin  (Multiple)
    │
  Member  (Verified community members)
    │
  Guest  (Registered but not yet approved)
```

### 5.2 Permission Matrix

| Feature | Guest | Member | Admin | Super Admin |
|---------|-------|--------|-------|-------------|
| Posts dekhna | ✅ | ✅ | ✅ | ✅ |
| Posts like karna | ✅ | ✅ | ✅ | ✅ |
| Comments karna | ✅ | ✅ | ✅ | ✅ |
| Notices dekhna | ✅ | ✅ | ✅ | ✅ |
| Complaints submit karna | ✅ | ✅ | ✅ | ✅ |
| Forms fill karna | ✅ | ✅ | ✅ | ✅ |
| Membership apply karna | ✅ | ❌ | ❌ | ❌ |
| Posts banana | ❌ | ✅ | ✅ | ✅ |
| Notices publish karna | ❌ | ✅ | ✅ | ✅ |
| Events register karna | ❌ | ✅ | ✅ | ✅ |
| Scholarships apply karna | ❌ | ✅ | ✅ | ✅ |
| Member directory dekhna | ❌ | ✅ | ✅ | ✅ |
| Products sell karna | ❌ | ✅ | ✅ | ✅ |
| Chat access karna | ❌ | ✅ | ✅ | ✅ |
| Membership approve/reject karna | ❌ | ❌ | ✅ | ✅ |
| Posts delete karna (kisi ka bhi) | ❌ | ❌ | ✅ | ✅ |
| Comments moderate karna | ❌ | ❌ | ✅ | ✅ |
| Events manage karna | ❌ | ❌ | ✅ | ✅ |
| Forms banana | ❌ | ❌ | ✅ | ✅ |
| Notifications bhejni | ❌ | ❌ | ✅ | ✅ |
| Analytics dekhna | ❌ | ❌ | ✅ | ✅ |
| Admin accounts banana | ❌ | ❌ | ❌ | ✅ |
| Users ban karna | ❌ | ❌ | ❌ | ✅ |
| Deleted content restore karna | ❌ | ❌ | ❌ | ✅ |
| Reports export karna | ❌ | ❌ | ❌ | ✅ |
| Security logs dekhna | ❌ | ❌ | ❌ | ✅ |

### 5.3 Role Field in Firestore

Har user document mein:

```json
{
  "uid": "firebase_uid",
  "role": "guest",  // "guest" | "member" | "admin" | "superadmin"
  "isVerified": false,
  "isBanned": false
}
```

---

## 6. Authentication Flow

### 6.1 Available Methods

| Method | Status |
|--------|--------|
| Email + Password | ✅ Available now |
| Google Sign-In | 🔜 Future |
| Phone OTP | 🔜 Future (paid SMS avoid karne ke liye later) |

### 6.2 Registration Flow

```
User App Open Karta Hai
        │
        ▼
   Register Screen
   (Email + Password)
        │
        ▼
  Firebase Auth mein
  account create hota hai
        │
        ▼
  Email Verification
  bheja jata hai
        │
        ▼
  User email verify karta hai
        │
        ▼
  Notification Permission
  manga jata hai
  (Sirf pehli baar)
        │
        ▼
  Guest Dashboard
  Access milta hai
  (role = "guest")
        │
        ▼
  Membership Application
  submit karta hai
        │
        ▼
  Admin Review & Approve
        │
        ▼
  role = "member"
  Member Dashboard Access
```

### 6.3 Login Flow

```
Login Screen
     │
     ▼
Firebase Auth se verify
     │
     ├── Email verified? NO → Email verify karne ko kaho
     │
     ├── isBanned = true? → "Aapka account band kar diya gaya hai"
     │
     └── Success → role check → respective dashboard
```

---

## 7. Permission Strategy

Google Play Store guidelines follow kiye jayenge.

| Permission | Kab Manga Jayega |
|-----------|-----------------|
| **Notifications** | App pehli baar open hone par |
| **Camera** | Sirf jab user photo capture kare |
| **Gallery/Storage** | Sirf jab user file upload kare |
| **Location** | Login ke baad, location-based features ke liye (blood donors, nearby businesses) |

> ⚠️ Storage permission Android 13+ par nahi manga jayega. `photo_picker` aur `image_picker` use honge jo bina storage permission ke kaam karte hain.

---

## 8. Membership Approval Flow

### 8.1 Application Form Fields

| Field | Type | Required |
|-------|------|----------|
| Full Name | Text | ✅ |
| Father's Name | Text | ✅ |
| Mother's Name | Text | ✅ |
| Village | Text | ✅ |
| District | Dropdown | ✅ |
| Gotra | Text | ✅ |
| Occupation | Text | ✅ |
| Education | Dropdown | ✅ |
| Aadhaar Number | Number (masked) | ✅ |
| Profile Photo | Image Upload | ✅ |
| Aadhaar Front | Image Upload | ✅ |
| Aadhaar Back | Image Upload | ✅ |
| Reference Person | Text | ✅ |
| Contact Number | Phone | ✅ |

### 8.2 Approval Workflow

```
Guest Application Submit
          │
          ▼
  membership_requests collection mein save
  status = "pending"
          │
          ▼
  Admin ko FCM notification
          │
          ▼
     Admin Review
    /      |      \
   /       |       \
Approve  Reject  Request
           |    Correction
           ▼         ▼
      Application  User ko
      Reject hoti  notification
      hai          milti hai
  Approve  ◄──────────────
     │
     ▼
  users collection mein
  role = "member" update hota hai
     │
     ▼
  User ko FCM notification:
  "Badhai ho! Aap Maru Prajapat
  Community ke verified member
  ban gaye hain."
```

### 8.3 Firestore Collections Used

```
membership_requests/{requestId}
  - userId
  - fullName
  - fatherName
  - motherName
  - village
  - district
  - gotra
  - occupation
  - education
  - aadhaarNumber (last 4 digits only store karo)
  - profilePhotoUrl
  - aadhaarFrontUrl
  - aadhaarBackUrl
  - referencePerson
  - contactNumber
  - status: "pending" | "approved" | "rejected" | "correction_needed"
  - adminNote
  - submittedAt
  - reviewedAt
  - reviewedBy
```

---

## 9. Posting System

### 9.1 Who Can Post?

| Role | Post Create Kar Sakta Hai? |
|------|---------------------------|
| Guest | ❌ Nahi |
| Member | ✅ Haan (immediate publish) |
| Admin | ✅ Haan |
| Super Admin | ✅ Haan |

### 9.2 Supported Post Types

| Post Type | Description |
|-----------|-------------|
| 📝 Text Post | Plain text update |
| 🖼️ Image Post | Photo with caption |
| 🎥 Video Post | Video (Firebase Storage se serve hoga) |
| 📄 PDF Post | Document share karna |
| 📊 Poll | Community voting |
| 🏆 Achievement Post | Kisi member ki uplabdhi share karna |
| 🎓 Scholarship Alert | Scholarship ki jankari |
| 📚 Exam Alert | Exam ki khabar |
| 🩸 Blood Requirement | Emergency blood donation request |
| 🕊️ Obituary | Shraddhanjali/Condolence |
| 🚨 Emergency Announcement | Urgent community alert |

### 9.3 Post Lifecycle

```
Member Post Banata Hai
        │
        ▼
  posts collection mein save
  isDeleted = false
  isVisible = true
        │
        ▼
  Community Feed mein dikhta hai
  (Real-time Firestore listener)
        │
  If Admin inappropriate content dekhe
        │
        ▼
  Soft Delete:
  isDeleted = true
  (Post hide ho jata hai, data delete nahi hota)
        │
  Super Admin restore kar sakta hai
        ▼
  isDeleted = false
```

### 9.4 Firestore Post Document

```
posts/{postId}
  - authorId
  - authorName
  - authorPhotoUrl
  - postType
  - textContent
  - mediaUrl (optional)
  - thumbnailUrl (optional)
  - pollOptions (optional array)
  - pollVotes (map: optionId -> count)
  - isDeleted: false
  - deletedBy (optional)
  - deletedAt (optional)
  - createdAt
  - likesCount
  - commentsCount
```

---

## 10. Comment & Interaction System

### 10.1 Who Can Interact?

| Action | Guest (Logged In) | Member | Admin | Super Admin |
|--------|-------------------|--------|-------|-------------|
| Like karna | ✅ | ✅ | ✅ | ✅ |
| Comment karna | ✅ | ✅ | ✅ | ✅ |
| Reply karna | ✅ | ✅ | ✅ | ✅ |
| Report karna | ✅ | ✅ | ✅ | ✅ |
| Comment delete karna (apna) | ✅ | ✅ | ✅ | ✅ |
| Kisi ka bhi comment delete | ❌ | ❌ | ✅ | ✅ |
| Deleted comment restore karna | ❌ | ❌ | ❌ | ✅ |

> ⛔ **Logged-out visitors (jo app mein login nahi hain) koi bhi interaction nahi kar sakte.**

### 10.2 Nested Comment Structure

```
comments/{commentId}
  - postId
  - authorId
  - authorName
  - content
  - parentCommentId (null = top-level, value = reply)
  - isDeleted: false
  - createdAt
  - likesCount

likes/{likeId}
  - postId (ya commentId)
  - userId
  - createdAt
```

### 10.3 Like Optimization

Likes count directly post document mein `likesCount` field mein store hoga. Firestore **FieldValue.increment(1)** use hoga — isse baar baar document read karne ki zaroorat nahi padegi aur free tier reads bachenge.

---

## 11. Notice Management System

### 11.1 Notice Categories

| Category | Icon |
|----------|------|
| Exam Notice | 📚 |
| Scholarship Notice | 🎓 |
| Admission Notice | 🏫 |
| Job Alert | 💼 |
| Meeting Notice | 📅 |
| Achievement Notice | 🏆 |
| Condolence Message | 🕊️ |
| Blood Requirement | 🩸 |
| Emergency Announcement | 🚨 |
| Lost and Found | 🔍 |

### 11.2 Notice Permissions

| Role | Notice Publish | Notice Pin | Notice Delete |
|------|---------------|------------|---------------|
| Guest | ❌ | ❌ | ❌ |
| Member | ✅ | ❌ | Sirf apna |
| Admin | ✅ | ✅ | Koi bhi |
| Super Admin | ✅ | ✅ | Koi bhi |

### 11.3 Notice Flow

```
Member/Admin Notice Likhta Hai
          │
          ▼
  notices collection mein save
  isPinned = false (default)
          │
          ▼
  Notice Feed mein dikhti hai
          │
  Admin "Pin" karta hai (important notice ke liye)
          │
          ▼
  isPinned = true
  Home screen ke top par dikhti hai
          │
  Admin FCM notification bhi bhej sakta hai
  (urgent notices ke liye)
```

---

## 12. Events Management Module

### 12.1 Supported Event Types

- Community Meetings (Samajik Baithak)
- Blood Donation Camps
- Marriage Introduction Programs (Parichay Sammelan)
- Educational Seminars
- Sports Competitions
- Cultural Events
- Scholarship Distribution Programs

### 12.2 Event Features

| Feature | Description |
|---------|-------------|
| Event Registration | Members directly app se register karein |
| QR Entry Pass | Registration ke baad QR code generate hoga (Flutter QR library — free) |
| Attendance Tracking | QR scan se attendance mark hogi |
| Event Gallery | Photos event ke baad upload ho sakti hain |
| Participation Certificate | PDF certificate generate hoga (Flutter PDF package — free) |

### 12.3 Event Flow

```
Admin Event Create Karta Hai
          │
          ▼
  events/{eventId} mein save
  registrationOpen = true
          │
          ▼
  FCM notification sabko
          │
          ▼
  Member Registration Karta Hai
          │
          ▼
  event_registrations/{regId}
    - eventId
    - userId
    - userName
    - qrCode (unique string)
    - isAttended: false
    - registeredAt
          │
          ▼
  QR Code generate hota hai
  (qr_flutter package — free)
          │
          ▼
  Event Day: Admin QR scan karta hai
  isAttended = true update hota hai
```

---

## 13. Dynamic Forms Engine

Admin bina app update kiye naye forms create kar sakta hai. Forms Firestore mein store hote hain aur app automatically unhe render karta hai.

### 13.1 Supported Field Types

| Field Type | Firestore Type Value |
|-----------|---------------------|
| Single Line Text | `text_single` |
| Multi-line Text | `text_multi` |
| Number | `number` |
| Email | `email` |
| Phone Number | `phone` |
| Dropdown | `dropdown` |
| Radio Buttons | `radio` |
| Checkbox Group | `checkbox` |
| Date Picker | `date` |
| File Upload | `file_upload` |
| Image Upload | `image_upload` |
| PDF Upload | `pdf_upload` |
| Signature Pad | `signature` |

### 13.2 Firestore Structure

```
forms/{formId}
  - title
  - description
  - isActive: true
  - createdBy
  - createdAt

form_fields/{fieldId}
  - formId
  - label
  - fieldType
  - isRequired: true/false
  - options (array, for dropdown/radio/checkbox)
  - order (integer, for sorting)

responses/{responseId}
  - formId
  - userId
  - answers (map: fieldId -> value)
  - submittedAt
  - fileUrls (map: fieldId -> storage URL)
```

### 13.3 Use Cases

- Scholarship Application
- Volunteer Registration
- Event Registration
- Matrimony Registration
- Membership Renewal
- Blood Donation Registration

---

## 14. Complaint Management System

### 14.1 Complaint Form Fields

| Field | Type |
|-------|------|
| Title | Text |
| Description | Textarea |
| Category | Dropdown |
| Supporting Images | Image Upload (max 3) |
| Priority Level | Radio (Low / Medium / High) |

### 14.2 Complaint Categories

- Scholarship Issue
- Membership Problem
- Incorrect Information
- Technical Issue
- Event Related Issue
- Marketplace Complaint
- General Suggestion

### 14.3 Status Workflow

```
User Complaint Submit Karta Hai
          │
          ▼
     status: "open"
          │
          ▼
  Admin complaint assign karta hai
     status: "assigned"
     assignedTo: userId
          │
          ▼
  Kaam shuru hota hai
     status: "in_progress"
          │
          ▼
  Problem solve ho gayi
     status: "resolved"
     resolutionNote: "..."
          │
          ▼
  User ne confirm kar liya
     status: "closed"
```

Har status change par user ko **FCM notification** milti hai — bilkul free.

---

## 15. Scholarship Portal

### 15.1 Supported Scholarships

| Scholarship | Type |
|------------|------|
| NSP (National Scholarship Portal) | Government |
| PM YASASVI | Government |
| State Scholarships | Government |
| Community Scholarships | Community |

### 15.2 Features

| Feature | Implementation |
|---------|---------------|
| Eligibility Criteria | Firestore document mein stored |
| Important Dates | Firestore + FCM reminder |
| Required Documents | Document checklist |
| Online Application | Dynamic Forms Engine se |
| Status Tracking | Complaint module jaisa flow |

### 15.3 Deadline Reminders

> ⚠️ **Cloud Functions nahi hain**, isliye:
> - Admin manually FCM notification bhejega deadline se pehle
> - Alternatively, Remote Config mein dates store karke app startup par check hoga

---

## 16. Examination & Education Module

### 16.1 Available Sections

| Section | Content |
|---------|---------|
| Examination Notices | Upcoming exams ki dates |
| Admission Updates | College admissions |
| Admit Card Links | Direct links |
| Result Announcements | Results |
| Previous Year Papers | PDF uploads |
| Study Materials | PDF Notes |
| Video Lectures | YouTube links (free hosting) |

> 💡 **Video Lectures:** Videos directly Firebase Storage mein upload karne se storage jaldi khatam hogi. Isliye **YouTube links** ya **Google Drive public links** use karein — storage cost zero.

### 16.2 Supported Examinations

JEE, NEET, UPSC, SSC, REET, IIT-JAM, GATE, University Examinations

### 16.3 Bookmark Feature

```
bookmarks/{bookmarkId}
  - userId
  - resourceId
  - resourceType: "exam_notice" | "study_material" | "result"
  - createdAt
```

---

## 17. Marketplace Module

### 17.1 Product Categories

Pottery Products, Decorative Items, Building Materials, Electrical Products, Steel Products, Furniture, Handicrafts, Agricultural Equipment

### 17.2 Features

| Feature | Details |
|---------|---------|
| Product Images | Firebase Storage (max 5 images per product) |
| Product Variants | Firestore array |
| Ratings & Reviews | Sub-collection |
| Wishlist | User document mein array |
| Shopping Cart | Local + Firestore |
| Order Tracking | orders collection |

> 💳 **Payment Integration:** Phase 2 mein — Razorpay/PhonePe. Abhi sirf "Contact Seller" button (WhatsApp/Call).

### 17.3 Firestore Structure

```
marketplace_products/{productId}
  - sellerId
  - sellerName
  - title
  - description
  - category
  - price
  - images: [url1, url2, ...]
  - variants: [{name, price}]
  - isAvailable: true
  - isApproved: false (Admin approve karega)
  - avgRating
  - reviewCount
  - createdAt

orders/{orderId}
  - buyerId
  - sellerId
  - productId
  - status: "pending" | "confirmed" | "shipped" | "delivered"
  - createdAt
```

---

## 18. Matrimony Module

### 18.1 Profile Information

| Field | Type |
|-------|------|
| Full Name | Text |
| Date of Birth | Date |
| Height | Dropdown (in cm) |
| Education | Dropdown |
| Occupation | Text |
| Annual Income | Range |
| Gotra | Text |
| Village | Text |
| District | Dropdown |
| Manglik Status | Radio |

### 18.2 Search Filters

Age, Education, District, Occupation, Income Range

### 18.3 Interaction Flow

```
User Profile Approve hoti hai (Admin verify karta hai)
          │
          ▼
  Profile search mein dikhti hai
          │
          ▼
  User A, User B ko "Interest" bhejta hai
          │
          ▼
  User B ko FCM notification
          │
          ▼
  User B "Accept" karta hai
          │
          ▼
  Dono ke beech contact details
  visible ho jati hain
  (Phone number / WhatsApp)
```

---

## 19. Family Tree Module

### 19.1 Supported Relationships

Father, Mother, Brother, Sister, Spouse, Son, Daughter, Grandparents

### 19.2 Features

- Interactive graphical tree (Flutter custom painter ya `graphview` package)
- Only verified members access kar sakte hain
- Privacy settings — sensitive details hide kar sakte hain

### 19.3 Firestore Structure

```
family_trees/{nodeId}
  - ownerId
  - memberName
  - relation
  - linkedUserId (agar woh bhi app member hai)
  - dateOfBirth
  - isPrivate: false
  - parentNodeId
```

---

## 20. Community Listings & Registration Services

Yeh module ek unified listing system provide karta hai.

### 20.1 Supported Listing Types

| Listing | Description |
|---------|-------------|
| Business Registration | Community businesses |
| Artisan Registration | Craftsmen |
| Pottery Workshop | Workshop registrations |
| Student Registration | Student database |
| Volunteer Registration | Sewadaar list |
| Blood Donor Registration | Emergency donors |
| Scholarship Registration | Scholarship seekers |
| Marriage Introduction | Parichay Sammelan |
| Community Representative | Panchayat/Committee |
| Temple Committee | Mandir Samiti |
| Community Hall Committee | Dharamshala Samiti |
| Social Worker | Samajsewi |
| Coaching/Tuition Listing | Education providers |
| Community Organization | Sangh/Samaj |
| Event Organizer | Event management |
| Job Seeker | Employment seekers |
| Employer Registration | Job providers |

### 20.2 Universal Listing Workflow

```
Member Form Fill Karta Hai (Dynamic Forms Engine se)
          │
          ▼
  responses collection mein save
  approvalStatus = "pending"
          │
          ▼
  Admin review karta hai
          │
   Approve / Reject
          │
          ▼ (if Approved)
  Specific listing collection mein entry
  isPublished = true
          │
          ▼
  Community feed mein auto-update post
```

---

## 21. Business & Artisan Directory

### 21.1 Business Information

| Field | Type |
|-------|------|
| Business Name | Text |
| Owner Name | Text |
| Category | Dropdown |
| Description | Textarea |
| Address | Text |
| Mobile Number | Phone |
| WhatsApp Number | Phone |
| GST Number | Text (optional) |
| Website URL | URL (optional) |
| Location Coordinates | Lat/Long (optional) |
| Profile Images | Image Upload (max 3) |

### 21.2 Contact Integration

App se seedha:
- **📞 Call** — `tel:` URI
- **💬 WhatsApp** — `https://wa.me/` link
- **✉️ Email** — `mailto:` URI

> 💡 **Maps:** Google Maps API paid hai. Isliye coordinates store karo aur user ko seedha Google Maps app mein open karo (`geo:lat,lng` URI) — API key ki zaroorat nahi.

---

## 22. Community Member Addition Requests

Verified members apne relatives ko community mein invite kar sakte hain.

### 22.1 Addition Request Fields

| Field | Type |
|-------|------|
| Full Name | Text |
| Father's Name | Text |
| Village | Text |
| District | Dropdown |
| Gotra | Text |
| Mobile Number | Phone |
| Aadhaar Number | Number |
| Relationship with Applicant | Dropdown |
| Reference Member | Text |

### 22.2 Flow

```
Member Request Submit Karta Hai
          │
          ▼
  membership_requests mein save
  requestType = "member_addition"
  referredBy = currentUserId
          │
          ▼
  Admin approve karta hai
          │
          ▼
  Naya user profile create hota hai
  Invitation notification bheja jata hai
```

---

## 23. Automatic Community Feed Updates

Jab bhi koi important action hota hai, system automatically ek community post generate karta hai.

### 23.1 Auto-Post Triggers & Examples

| Trigger | Feed Message Example |
|---------|---------------------|
| New member approved | "श्री अशोक कुमार जी मारू प्रजापत समुदाय से जुड़ गए हैं।" |
| Business registered | "श्री राम पॉटरी को Business Directory में जोड़ा गया है।" |
| Blood donor added | "राहुल प्रजापत ने Blood Donor के रूप में पंजीकरण किया है।" |
| Volunteer joined | "सुरेश कुमार ने Volunteer के रूप में पंजीकरण किया है।" |
| Event registration | "दिव्या पंचायत ने XYZ Event में Registration किया है।" |

### 23.2 Implementation (Without Cloud Functions)

> **Challenge:** Cloud Functions nahi hain, to auto-post kaun karega?
>
> **Solution:** Jab Admin ya system koi approval action karta hai, us waqt **client-side code** ek system post automatically create karega. Yeh Firestore transaction se safely ho sakta hai.

```dart
// Approval ke saath auto-post create karna
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // 1. Membership approve karo
  transaction.update(membershipRef, {'status': 'approved'});
  
  // 2. Auto-post create karo
  transaction.set(autoPostRef, {
    'postType': 'system',
    'textContent': '$memberName मारू प्रजापत समुदाय से जुड़ गए हैं।',
    'isSystemPost': true,
    'createdAt': FieldValue.serverTimestamp(),
  });
});
```

---

## 24. Chat & Messaging System

### 24.1 Chat Types

| Type | Description |
|------|-------------|
| Member to Member | Private 1-on-1 chat |
| Member to Admin | Support chat |
| Group Discussions | General community group |
| District Level Groups | District-wise groups |
| Event Groups | Event-specific discussion |

### 24.2 Features

| Feature | Implementation |
|---------|---------------|
| Text Messages | Firestore real-time |
| Image Sharing | Firebase Storage |
| PDF Sharing | Firebase Storage |
| Voice Notes | Firebase Storage (recorded audio) |
| Message Reactions | Firestore map field |
| Read Receipts | Firestore timestamp |
| Typing Indicators | Firestore presence field |

> ⚠️ **Guest users chat nahi kar sakte.**

### 24.3 Firestore Chat Structure

```
messages/{conversationId}/chats/{messageId}
  - senderId
  - senderName
  - messageType: "text" | "image" | "pdf" | "voice"
  - content (text ya storage URL)
  - reactions: {emoji: [userId, ...]}
  - readBy: [userId, ...]
  - isDeleted: false
  - createdAt

groups/{groupId}
  - name
  - type: "district" | "event" | "general"
  - members: [userId, ...]
  - admins: [userId, ...]
  - lastMessage
  - lastMessageAt
```

---

## 25. Blood Donation Module

### 25.1 Donor Information

| Field | Type |
|-------|------|
| Blood Group | Dropdown (A+, A-, B+, B-, O+, O-, AB+, AB-) |
| District | Dropdown |
| Village | Text |
| Mobile Number | Phone |
| Last Donation Date | Date |
| Availability Status | Toggle (Available / Not Available) |

### 25.2 Emergency Blood Request Flow

```
Member Emergency Request Publish Karta Hai
          │
          ▼
  posts mein Blood Requirement post save hoti hai
          │
          ▼
  FCM notification sabko (ya district-wise)
          │
          ▼
  Donors directly contact kar sakte hain
  (in-app call/WhatsApp)
```

> 💡 **Location-based Notifications:** Proper geofencing ke liye paid APIs chahiye. Isliye **district-based filtering** use karein — Firestore mein `district` field se query karo, free mein kaam karega.

---

## 26. Donation & Fundraising Module

### 26.1 Supported Campaigns

- Student Education Fund
- Medical Assistance Fund
- Temple Construction Fund
- Community Hall Development Fund
- Disaster Relief Fund

### 26.2 Features

| Feature | Implementation |
|---------|---------------|
| UPI Payments | UPI deep links (`upi://pay?...`) — free, no SDK |
| Donation Receipts | Flutter PDF package se generate |
| Donation History | Firestore |
| Monthly Reports | Admin dashboard table |
| Leaderboards | Firestore query (top donors) |

> 💡 **UPI Deep Links:** Razorpay/PhonePe SDK ki zaroorat nahi. Direct UPI URI se Google Pay, PhonePe, Paytm sab apps open ho jate hain. Yeh bilkul free hai.

```
upi://pay?pa=community@upi&pn=MaruPrajapat&am=500&cu=INR&tn=Education+Fund
```

---

## 27. Notification Strategy

**Firebase Cloud Messaging (FCM) — Bilkul Free, Unlimited**

### 27.1 Notification Categories

| Category | Trigger |
|----------|---------|
| Membership Approval | Admin approve kare |
| Scholarship Deadlines | Admin manually bheje |
| Examination Notices | Admin manually bheje |
| Event Reminders | Admin manually bheje |
| New Posts (Important) | Admin toggle kare |
| Important Notices | Admin "Send Notification" click kare |
| Complaint Status Updates | Status change hone par auto |
| Marketplace Orders | Seller ko order aane par |
| Blood Requests | Blood requirement post hone par |

### 27.2 FCM Topics (Free Notification Groups)

Admin specific groups ko notify kar sakta hai:

```dart
// User subscribe karta hai topics par
FirebaseMessaging.instance.subscribeToTopic('all_members');
FirebaseMessaging.instance.subscribeToTopic('district_jodhpur');
FirebaseMessaging.instance.subscribeToTopic('blood_requests');
```

Admin web dashboard se FCM topic message bheja ja sakta hai — **Cloud Functions ki zaroorat nahi**.

### 27.3 Notification Permission

- Sirf pehli launch par manga jayega
- User decline kare to baad mein Settings mein jaake enable kar sake

---

## 28. Single Device Login Policy

### 28.1 Kiske Liye?

| Role | Single Device? |
|------|---------------|
| Guest | ❌ Multi-device allowed |
| Member | ❌ Multi-device allowed |
| Admin | ✅ Single device only |
| Super Admin | ✅ Single device only |

### 28.2 Implementation

```
Admin Login Karta Hai
        │
        ▼
  Device ID generate hota hai
  users/{uid} mein save:
    deviceId: "current_device_id"
    lastLogin: timestamp
    fcmToken: "new_token"
        │
  Agar Admin kisi aur device se login kare:
        │
        ▼
  App startup par deviceId check karta hai
  Agar stored deviceId != current deviceId
        │
        ▼
  Previous device par:
  "Aapka account doosre device se login hua hai.
   Aap logout ho gaye hain."
  → Forced logout
```

---

## 29. Firestore Security Rules Strategy

Yeh rules **poori app ki security** ke liye critical hain — especially kyunki Cloud Functions nahi hain.

### 29.1 Core Principles

1. **Deny by Default** — Jab tak explicitly allow na ho, sab deny
2. **Role-based Access** — User role Firestore se check hoga
3. **Ownership Check** — User sirf apna data modify kar sake
4. **Admin Bypass** — Admin/SuperAdmin koi bhi document modify kar sake

### 29.2 Security Rules Template

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper Functions
    function isSignedIn() {
      return request.auth != null;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function hasRole(role) {
      return isSignedIn() && getUserData().role == role;
    }

    function isAdmin() {
      return isSignedIn() && (
        getUserData().role == 'admin' ||
        getUserData().role == 'superadmin'
      );
    }

    function isSuperAdmin() {
      return isSignedIn() && getUserData().role == 'superadmin';
    }

    function isMember() {
      return isSignedIn() && (
        getUserData().role == 'member' ||
        getUserData().role == 'admin' ||
        getUserData().role == 'superadmin'
      );
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isNotBanned() {
      return !getUserData().isBanned;
    }

    // Users Collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Posts Collection
    match /posts/{postId} {
      allow read: if isSignedIn();
      allow create: if isMember() && isNotBanned();
      allow update: if isOwner(resource.data.authorId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Comments Collection
    match /comments/{commentId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isNotBanned();
      allow update: if isOwner(resource.data.authorId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Membership Requests
    match /membership_requests/{reqId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isSignedIn();
      allow update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Notices
    match /notices/{noticeId} {
      allow read: if isSignedIn();
      allow create: if isMember() && isNotBanned();
      allow update: if isOwner(resource.data.authorId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Events
    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isAdmin();
    }

    // Event Registrations
    match /event_registrations/{regId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isMember();
      allow update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Marketplace Products
    match /marketplace_products/{productId} {
      allow read: if isSignedIn();
      allow create: if isMember();
      allow update: if isOwner(resource.data.sellerId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Matrimony Profiles
    match /matrimony_profiles/{profileId} {
      allow read: if isMember();
      allow create: if isMember();
      allow update: if isOwner(resource.data.userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Blood Donors
    match /blood_donors/{donorId} {
      allow read: if isSignedIn();
      allow create: if isMember();
      allow update: if isOwner(resource.data.userId) || isAdmin();
      allow delete: if isAdmin();
    }

    // Complaints
    match /complaints/{complaintId} {
      allow read: if isOwner(resource.data.userId) || isAdmin();
      allow create: if isSignedIn();
      allow update: if isAdmin();
      allow delete: if isSuperAdmin();
    }

    // Donations
    match /donations/{donationId} {
      allow read: if isOwner(resource.data.donorId) || isAdmin();
      allow create: if isSignedIn();
      allow update, delete: if isAdmin();
    }

    // Messages/Chats
    match /messages/{conversationId}/chats/{messageId} {
      allow read, create: if isMember();
      allow delete: if isOwner(resource.data.senderId) || isAdmin();
    }

    // Family Trees
    match /family_trees/{nodeId} {
      allow read: if isMember();
      allow create, update: if isOwner(resource.data.ownerId);
      allow delete: if isOwner(resource.data.ownerId) || isAdmin();
    }

    // Settings (Super Admin only)
    match /settings/{document} {
      allow read: if isSignedIn();
      allow write: if isSuperAdmin();
    }
  }
}
```

---

## 30. Administrative Dashboard

Web-based dashboard Firebase Hosting par hosted hoga — **free**.

### 30.1 Dashboard Sections

| Section | Kya Kaam Karega |
|---------|----------------|
| Overview | Total users, posts, complaints ka summary |
| Membership Requests | Pending approvals dekhna aur approve/reject karna |
| User Management | Users ki list, ban/unban karna |
| Community Posts | Posts moderate karna, delete karna |
| Notices | Pin karna, delete karna |
| Events | Events create/edit/delete karna |
| Complaints | Complaints assign aur resolve karna |
| Marketplace | Product listings approve/reject karna |
| Dynamic Forms | Naye forms banana |
| Scholarship Applications | Applications dekhna |
| Matrimony Profiles | Profiles verify karna |
| Blood Donors | Donor list |
| Donations | Donation records |
| FCM Notifications | Push notifications bhejni |
| Analytics | Firebase Analytics data |
| Settings | App configuration |

> Only Super Admin can: Admin accounts banana, users permanently ban karna, deleted content restore karna.

---

## 31. Firestore Database Collections

### Complete Collection List

```
users/
membership_requests/
posts/
comments/
likes/
notices/
events/
event_registrations/
forms/
form_fields/
responses/
complaints/
scholarships/
scholarship_applications/
businesses/
marketplace_products/
orders/
matrimony_profiles/
family_trees/
blood_donors/
donations/
notifications/
messages/{conversationId}/chats/
groups/
reports/
settings/
bookmarks/
```

### Key Indexing Requirements (Firestore Composite Indexes)

```
posts: [authorId ASC, createdAt DESC]
posts: [isDeleted ASC, createdAt DESC]
comments: [postId ASC, createdAt ASC]
notices: [isPinned DESC, createdAt DESC]
blood_donors: [bloodGroup ASC, district ASC]
marketplace_products: [category ASC, isApproved ASC, createdAt DESC]
matrimony_profiles: [district ASC, isApproved ASC]
complaints: [status ASC, createdAt DESC]
```

---

## 32. Future Enhancements

> Yeh features baad mein add kiye jayenge jab app stable ho jaye.

| Feature | Description | Priority |
|---------|-------------|----------|
| Google Sign-In | Social login | High |
| Phone OTP Login | Phone verification (paid — controlled use) | Medium |
| Online Payments | Razorpay/PhonePe integration | Medium |
| iOS Support | Apple platform | Medium |
| OCR Document Upload | Document text extract karna | Low |
| Smart Scholarship Recommendations | Rule-based (no AI) | Low |
| Community Statistics Dashboard | Graphs aur charts | Low |
| QR Code Attendance via Web | Web-based QR scanner | Low |
| Multilingual Support | Regional languages | Low |
| Dark Mode | UI preference | Low |

---

## Appendix A: Firebase Spark Plan — Summary

| Service | Free Limit | App Mein Use |
|---------|-----------|-------------|
| Authentication | 50K MAU/month | ✅ User login |
| Firestore | 50K reads, 20K writes/day | ✅ Main database |
| Storage | 5GB, 1GB download/day | ✅ Images, PDFs |
| FCM | Unlimited | ✅ Push notifications |
| Analytics | Unlimited | ✅ User tracking |
| Crashlytics | Unlimited | ✅ Crash reports |
| Remote Config | Unlimited | ✅ App settings |
| Hosting | 10GB, 360MB/day | ✅ Admin dashboard |
| App Check | Free | ✅ API security |

---
Cloudflare R2
## Appendix B: Glossary

| Term | Meaning |
|------|---------|
| FCM | Firebase Cloud Messaging — Push notifications |
| Firestore | Firebase ka NoSQL database |
| Soft Delete | Data delete nahi hota, sirf `isDeleted = true` hota hai |
| MAU | Monthly Active Users |
| RBAC | Role-Based Access Control |
| Spark Plan | Firebase ka free plan |
| QR Entry Pass | Event mein entry ke liye QR code |
| Dynamic Forms | Bina app update ke naye forms banana |

---
# . Storage Architecture and Optimization Strategy

The Maru Prajapat Application is designed to operate efficiently on the Firebase Spark Plan without requiring a dedicated backend server. To minimize bandwidth consumption, reduce Firestore read operations, and improve application performance, a hybrid storage architecture will be implemented.

Cloudflare R2 will be used as the primary storage solution for publicly accessible media files. This includes profile photographs, post images, marketplace product images, event galleries, matrimony photographs, business listings, and other community-related media assets. Before uploading any image to Cloudflare R2, the application will automatically compress, resize, and convert the image into WEBP format. This optimization significantly reduces storage usage and network bandwidth while maintaining acceptable visual quality.

Video files will not be uploaded directly to Cloudflare R2. Instead, users may share public video links from platforms such as YouTube. The application will store only the video URL inside Firestore and display embedded previews when required.

Firebase Storage use nhi kerni ha , firebase db and runtime db bas

To improve user experience and reduce network usage, the application will implement local data caching using the Isar Database. Frequently accessed information such as posts, notices, viewed content, notifications, application settings, and user preferences will be stored locally on the device. When the application starts, cached content will be displayed immediately, while fresh data will be synchronized from Firestore in the background. This strategy provides faster loading times, offline capabilities, lower Firestore read counts, and improved overall responsiveness.

The Home Screen will prioritize locally cached content and update automatically whenever new posts, notices, or announcements become available. Firebase Cloud Messaging (FCM) will be used to notify users about important updates including membership approvals, examination notices, scholarship deadlines, blood donation requests, event reminders, and newly published posts. Upon receiving a notification, the application will fetch the latest information from Firestore, synchronize the local database, and refresh the user interface without requiring manual intervention.

This architecture enables the Maru Prajapat Application to remain scalable, cost-effective, and fully functional within the limitations of the Firebase Spark Plan while avoiding the complexity of maintaining a custom backend infrastructure


*Specification v0.2 | Maru Prajapat Application | June 2025*
*Designed for Firebase Spark Plan (Free Tier) — No Paid Services*