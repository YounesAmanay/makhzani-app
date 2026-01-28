# Makhzani App - Backend API Documentation

**Version:** 1.0.0
**Base URL:** `http://localhost:3000` or `http://192.168.3.43:3000`
**Environment:** Development

---

## Table of Contents
1. [Authentication](#authentication)
2. [Merchants](#merchants)
3. [Products](#products)
4. [Suppliers](#suppliers)
5. [Orders](#orders)
6. [Utilities](#utilities)

---

## Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer <your_jwt_token>
```

### 1. Send OTP
**Endpoint:** `POST /api/auth/send-otp`
**Auth Required:** No
**Code Reference:** `backend/routes/auth.js:63-110`

**Description:** Generates and sends a 4-digit OTP to merchant's phone number. In development mode, returns OTP in response.

**Request Body:**
```json
{
  "phone_number": "+212XXXXXXXXX"
}
```

**Validation:**
- Phone must match Morocco format: `+212[5-7]XXXXXXXX`

**Success Response (200):**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "phone_number": "+212612345678",
    "merchant_exists": true,
    "development_otp": "1234"
  }
}
```

**Notes:**
- OTP expires in 5 minutes
- Stored in memory (use Redis in production)
- `development_otp` only included in dev mode

---

### 2. Verify OTP
**Endpoint:** `POST /api/auth/verify-otp`
**Auth Required:** No
**Code Reference:** `backend/routes/auth.js:116-226`

**Description:** Verifies OTP and returns JWT token. Creates new merchant account if phone number doesn't exist.

**Request Body:**
```json
{
  "phone_number": "+212612345678",
  "otp": "1234"
}
```

**Validation:**
- Phone must match Morocco format
- OTP must be 4 numeric digits
- Maximum 3 attempts before OTP invalidation

**Success Response (200):**
```json
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "merchant": {
      "id": "uuid",
      "phone_number": "+212612345678",
      "name": "New Merchant",
      "shop_name": "My Shop",
      "region": null,
      "subscription_status": "trial",
      "trial_ends_at": "2024-02-01T00:00:00.000Z",
      "is_new_user": true
    }
  }
}
```

**Error Codes:**
- `OTP_NOT_FOUND` - No OTP found, request new one
- `OTP_EXPIRED` - OTP expired, request new one
- `TOO_MANY_ATTEMPTS` - Too many failed attempts
- `INVALID_OTP` - Wrong OTP code

---

### 3. Refresh Token
**Endpoint:** `POST /api/auth/refresh-token`
**Auth Required:** Yes (expired token accepted)
**Code Reference:** `backend/routes/auth.js:232-302`

**Description:** Refreshes JWT token with extended expiration.

**Headers:**
```
Authorization: Bearer <old_or_expired_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "merchant": {
      "id": "uuid",
      "phone_number": "+212612345678",
      "name": "John Doe",
      "shop_name": "Best Shop",
      "region": "Casablanca",
      "subscription_status": "active"
    }
  }
}
```

---

## Merchants

### 1. Get Profile
**Endpoint:** `GET /api/merchants/profile`
**Auth Required:** Yes
**Code Reference:** `backend/routes/merchants.js:44-107`

**Description:** Retrieves merchant profile with complete information including suppliers, products, and statistics.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "merchant": {
      "id": "uuid",
      "name": "John Doe",
      "shop_name": "Best Shop",
      "phone_number": "+212612345678",
      "email": null,
      "address": "123 Main St",
      "region": "Casablanca",
      "subscription_status": "trial",
      "trial_ends_at": "2024-02-01T00:00:00.000Z",
      "last_login": "2024-01-15T10:30:00.000Z",
      "created_at": "2024-01-01T00:00:00.000Z"
    },
    "statistics": {
      "total_products": 25,
      "low_stock_products": 3,
      "total_suppliers": 5
    }
  }
}
```

---

### 2. Update Profile
**Endpoint:** `PUT /api/merchants/profile`
**Auth Required:** Yes
**Code Reference:** `backend/routes/merchants.js:113-159`

**Description:** Updates merchant profile information.

**Request Body:**
```json
{
  "name": "John Doe",
  "shop_name": "Best Shop Updated",
  "address": "456 New Street",
  "region": "Rabat"
}
```

**Validation:**
- `name`: 2-100 characters (optional)
- `shop_name`: 2-100 characters (optional)
- `address`: max 500 characters (optional)
- `region`: one of ['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'] (optional)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "merchant": {
      "id": "uuid",
      "name": "John Doe",
      "shop_name": "Best Shop Updated",
      "phone_number": "+212612345678",
      "address": "456 New Street",
      "region": "Rabat",
      "updated_at": "2024-01-15T10:35:00.000Z"
    }
  }
}
```

---

### 3. Get Dashboard Stats
**Endpoint:** `GET /api/merchants/dashboard-stats`
**Auth Required:** Yes
**Code Reference:** `backend/routes/merchants.js:165-244`

**Description:** Retrieves comprehensive dashboard statistics including product counts, supplier info, low stock items, and recent orders.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_products": 25,
      "low_stock_products": 3,
      "total_suppliers": 5,
      "total_orders": 42
    },
    "low_stock_items": [
      {
        "id": "uuid",
        "name": "Product A",
        "current_stock": 2,
        "reorder_threshold": 10,
        "unit": "piece",
        "shortage": 8
      }
    ],
    "recent_orders": [
      {
        "id": "uuid",
        "order_number": "PO-20240115-001",
        "supplier_name": "Supplier ABC",
        "created_at": "2024-01-15T10:00:00.000Z",
        "pdf_generated": true,
        "sent": false
      }
    ]
  }
}
```

---

## Products

### 1. Get Products (List)
**Endpoint:** `GET /api/products`
**Auth Required:** Yes
**Code Reference:** `backend/routes/products.js:98-167`

**Description:** Retrieves merchant's product inventory with pagination, search, and filtering.

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)
- `search`: Search by name or barcode
- `low_stock`: Filter low stock items (true/false)

**Example:**
```
GET /api/products?page=1&limit=20&search=milk&low_stock=true
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "uuid",
        "name": "Milk 1L",
        "current_stock": 5,
        "reorder_threshold": 10,
        "unit": "piece",
        "barcode": "123456789",
        "price": "8.50",
        "created_at": "2024-01-01T00:00:00.000Z",
        "updated_at": "2024-01-15T10:00:00.000Z",
        "needs_reorder": true,
        "stock_status": "low"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_products": 50,
      "has_next_page": true,
      "has_prev_page": false,
      "per_page": 20
    }
  }
}
```

---

### 2. Create Product
**Endpoint:** `POST /api/products`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/products.js:173-251`

**Description:** Adds a new product to merchant's inventory.

**Request Body:**
```json
{
  "name": "Milk 1L",
  "current_stock": 10,
  "reorder_threshold": 5,
  "unit": "piece",
  "barcode": "123456789",
  "price": "8.50"
}
```

**Validation:**
- `name`: 2-100 characters (required)
- `current_stock`: positive integer (optional, default: 0)
- `reorder_threshold`: positive integer (optional, default: 5)
- `unit`: one of ['piece', 'kg', 'liter', 'box', 'carton', 'bottle'] (optional, default: 'piece')
- `barcode`: 8-50 characters (optional)
- `price`: decimal with max 2 decimal places (optional)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Product added successfully",
  "data": {
    "product": {
      "id": "uuid",
      "name": "Milk 1L",
      "current_stock": 10,
      "reorder_threshold": 5,
      "unit": "piece",
      "barcode": "123456789",
      "price": "8.50",
      "needs_reorder": false,
      "created_at": "2024-01-15T10:00:00.000Z"
    }
  }
}
```

**Error Codes:**
- `DUPLICATE_PRODUCT_NAME` - Product name already exists
- `DUPLICATE_BARCODE` - Barcode already exists

---

### 3. Get Product Details
**Endpoint:** `GET /api/products/:id`
**Auth Required:** Yes
**Code Reference:** `backend/routes/products.js:257-293`

**Description:** Retrieves detailed information about a specific product.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "product": {
      "id": "uuid",
      "name": "Milk 1L",
      "current_stock": 5,
      "reorder_threshold": 10,
      "unit": "piece",
      "barcode": "123456789",
      "price": "8.50",
      "needs_reorder": true,
      "stock_status": "low",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  }
}
```

---

### 4. Update Product
**Endpoint:** `PUT /api/products/:id`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/products.js:299-391`

**Description:** Updates product information. All fields are optional.

**Request Body:**
```json
{
  "name": "Milk 1L Premium",
  "current_stock": 15,
  "reorder_threshold": 8,
  "unit": "piece",
  "barcode": "987654321",
  "price": "9.00"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Product updated successfully",
  "data": {
    "product": {
      "id": "uuid",
      "name": "Milk 1L Premium",
      "current_stock": 15,
      "reorder_threshold": 8,
      "unit": "piece",
      "barcode": "987654321",
      "price": "9.00",
      "needs_reorder": false,
      "stock_status": "ok"
    }
  }
}
```

---

### 5. Delete Product
**Endpoint:** `DELETE /api/products/:id`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/products.js:397-432`

**Description:** Soft deletes a product (marks as inactive).

**Success Response (200):**
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

---

### 6. Adjust Stock
**Endpoint:** `POST /api/products/:id/adjust-stock`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/products.js:438-504`

**Description:** Adjusts product stock by adding or subtracting quantity.

**Request Body:**
```json
{
  "adjustment": -5,
  "reason": "Sold to customer"
}
```

**Validation:**
- `adjustment`: non-zero integer (required)
- `reason`: optional string
- Cannot result in negative stock

**Success Response (200):**
```json
{
  "success": true,
  "message": "Stock adjusted successfully",
  "data": {
    "product": {
      "id": "uuid",
      "name": "Milk 1L",
      "old_stock": 10,
      "new_stock": 5,
      "adjustment": -5,
      "reason": "Sold to customer",
      "needs_reorder": true
    }
  }
}
```

---

## Suppliers

### 1. Get Suppliers (List)
**Endpoint:** `GET /api/suppliers`
**Auth Required:** Yes
**Code Reference:** `backend/routes/suppliers.js:66-122`

**Description:** Retrieves merchant's suppliers with relationship details.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "suppliers": [
      {
        "id": "uuid",
        "name": "Ahmed Supplier",
        "business_name": "Ahmed Trading Co.",
        "phone_number": "+212612345678",
        "email": "ahmed@example.com",
        "address": "123 Market Street",
        "city": "Casablanca",
        "supplier_type": "wholesaler",
        "relationship": {
          "preferred_contact_method": "whatsapp",
          "payment_terms": "Net 30",
          "merchant_notes": "Good quality products",
          "last_order_date": "2024-01-10T00:00:00.000Z",
          "total_orders": 15,
          "linked_since": "2023-12-01T00:00:00.000Z"
        }
      }
    ]
  }
}
```

---

### 2. Add/Link Supplier
**Endpoint:** `POST /api/suppliers`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/suppliers.js:128-258`

**Description:** Creates new supplier or links existing supplier to merchant account.

**Request Body:**
```json
{
  "name": "Ahmed Supplier",
  "phone_number": "+212612345678",
  "business_name": "Ahmed Trading Co.",
  "email": "ahmed@example.com",
  "address": "123 Market Street",
  "city": "Casablanca",
  "preferred_contact_method": "whatsapp",
  "payment_terms": "Net 30",
  "merchant_notes": "Good quality products"
}
```

**Validation:**
- `name`: 2-100 characters (required)
- `phone_number`: Morocco format +212[5-7]XXXXXXXX (required)
- `business_name`: 2-100 characters (optional)
- `email`: valid email format (optional)
- `address`: max 500 characters (optional)
- `city`: one of ['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'] (optional)
- `preferred_contact_method`: one of ['whatsapp', 'phone', 'email'] (optional, default: 'whatsapp')
- `payment_terms`: max 100 characters (optional)
- `merchant_notes`: max 500 characters (optional)

**Success Response (201):**
```json
{
  "success": true,
  "message": "New supplier created and linked",
  "data": {
    "supplier": {
      "id": "uuid",
      "name": "Ahmed Supplier",
      "business_name": "Ahmed Trading Co.",
      "phone_number": "+212612345678",
      "email": "ahmed@example.com",
      "address": "123 Market Street",
      "city": "Casablanca",
      "is_new_supplier": true
    },
    "relationship": {
      "preferred_contact_method": "whatsapp",
      "payment_terms": "Net 30",
      "merchant_notes": "Good quality products",
      "created_at": "2024-01-15T10:00:00.000Z"
    }
  }
}
```

**Error Codes:**
- `SUPPLIER_ALREADY_LINKED` - Supplier already linked to merchant
- `DUPLICATE_PHONE_NUMBER` - Phone number already exists

**Notes:**
- If supplier with phone number exists, links to existing record
- Updates missing fields on existing supplier records

---

### 3. Get Supplier Details
**Endpoint:** `GET /api/suppliers/:id`
**Auth Required:** Yes
**Code Reference:** `backend/routes/suppliers.js:264-339`

**Description:** Retrieves detailed supplier information and order history.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "supplier": {
      "id": "uuid",
      "name": "Ahmed Supplier",
      "business_name": "Ahmed Trading Co.",
      "phone_number": "+212612345678",
      "email": "ahmed@example.com",
      "address": "123 Market Street",
      "city": "Casablanca",
      "supplier_type": "wholesaler",
      "relationship": {
        "preferred_contact_method": "whatsapp",
        "payment_terms": "Net 30",
        "merchant_notes": "Good quality products",
        "last_order_date": "2024-01-10T00:00:00.000Z",
        "total_orders": 15,
        "linked_since": "2023-12-01T00:00:00.000Z"
      }
    },
    "recent_orders": [
      {
        "id": "uuid",
        "order_number": "PO-20240110-001",
        "created_at": "2024-01-10T00:00:00.000Z",
        "pdf_generated": true,
        "sent": true
      }
    ]
  }
}
```

---

### 4. Update Supplier Relationship
**Endpoint:** `PUT /api/suppliers/:id`
**Auth Required:** Yes
**Code Reference:** `backend/routes/suppliers.js:345-398`

**Description:** Updates merchant-specific supplier relationship details (not supplier base info).

**Request Body:**
```json
{
  "preferred_contact_method": "phone",
  "payment_terms": "Net 15",
  "merchant_notes": "Updated notes"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Supplier relationship updated successfully",
  "data": {
    "supplier_id": "uuid",
    "supplier_name": "Ahmed Supplier",
    "relationship": {
      "preferred_contact_method": "phone",
      "payment_terms": "Net 15",
      "merchant_notes": "Updated notes",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  }
}
```

---

### 5. Remove Supplier
**Endpoint:** `DELETE /api/suppliers/:id`
**Auth Required:** Yes
**Code Reference:** `backend/routes/suppliers.js:404-458`

**Description:** Removes supplier relationship (soft delete). Cannot remove if orders exist.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Supplier removed from your account successfully"
}
```

**Error Codes:**
- `SUPPLIER_HAS_ORDERS` - Cannot remove supplier with existing orders

---

## Orders

### 1. Get Orders (List)
**Endpoint:** `GET /api/orders`
**Auth Required:** Yes
**Code Reference:** `backend/routes/orders.js:72-168`

**Description:** Retrieves purchase orders with filtering and pagination.

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)
- `supplier_id`: Filter by supplier UUID
- `status`: Filter by status ('draft', 'sent', 'all' - default: 'all')

**Example:**
```
GET /api/orders?page=1&limit=20&supplier_id=uuid&status=sent
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "uuid",
        "order_number": "PO-20240115-001",
        "supplier": {
          "id": "uuid",
          "name": "Ahmed Supplier",
          "business_name": "Ahmed Trading Co.",
          "phone_number": "+212612345678"
        },
        "total_items": 5,
        "total_quantity": 50,
        "total_value": 1250.50,
        "notes": "Urgent delivery needed",
        "status": {
          "pdf_generated": true,
          "sent": true,
          "sent_via": "whatsapp"
        },
        "pdf_url": "/uploads/pdfs/order-uuid-timestamp.pdf",
        "created_at": "2024-01-15T10:00:00.000Z",
        "pdf_generated_at": "2024-01-15T10:05:00.000Z",
        "sent_at": "2024-01-15T10:10:00.000Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_orders": 42,
      "has_next_page": true,
      "has_prev_page": false,
      "per_page": 20
    }
  }
}
```

---

### 2. Create Order
**Endpoint:** `POST /api/orders`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/orders.js:174-297`

**Description:** Creates a new purchase order with items.

**Request Body:**
```json
{
  "supplier_id": "uuid",
  "items": [
    {
      "product_id": "uuid",
      "quantity": 10,
      "unit_price": 25.00
    },
    {
      "product_id": "uuid",
      "quantity": 5,
      "unit_price": 50.00
    }
  ],
  "notes": "Urgent delivery needed"
}
```

**Validation:**
- `supplier_id`: valid UUID (required)
- `items`: array with min 1 item (required)
- `items[].product_id`: valid UUID (required)
- `items[].quantity`: positive number > 0 (required)
- `items[].unit_price`: positive number (optional)
- `notes`: max 500 characters (optional)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Purchase order created successfully",
  "data": {
    "order": {
      "id": "uuid",
      "order_number": "PO-20240115-001",
      "supplier": {
        "id": "uuid",
        "name": "Ahmed Supplier",
        "business_name": "Ahmed Trading Co.",
        "phone_number": "+212612345678"
      },
      "items": [
        {
          "id": "uuid",
          "product": {
            "id": "uuid",
            "name": "Milk 1L",
            "unit": "piece"
          },
          "product_name_snapshot": "Milk 1L",
          "quantity": 10,
          "unit_price": 25.00,
          "total_price": 250.00
        }
      ],
      "total_value": 500.00,
      "notes": "Urgent delivery needed",
      "created_at": "2024-01-15T10:00:00.000Z"
    }
  }
}
```

**Notes:**
- Verifies supplier relationship exists
- Verifies all products belong to merchant
- Auto-generates order number (PO-YYYYMMDD-XXX)

---

### 3. Get Order Details
**Endpoint:** `GET /api/orders/:id`
**Auth Required:** Yes
**Code Reference:** `backend/routes/orders.js:303-388`

**Description:** Retrieves detailed order information including all items and supplier details.

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "order": {
      "id": "uuid",
      "order_number": "PO-20240115-001",
      "supplier": {
        "id": "uuid",
        "name": "Ahmed Supplier",
        "business_name": "Ahmed Trading Co.",
        "phone_number": "+212612345678",
        "email": "ahmed@example.com",
        "address": "123 Market Street"
      },
      "items": [
        {
          "id": "uuid",
          "product": {
            "id": "uuid",
            "name": "Milk 1L",
            "unit": "piece",
            "current_stock": 5
          },
          "product_name_snapshot": "Milk 1L",
          "quantity": 10,
          "unit_price": 25.00,
          "total_price": 250.00
        }
      ],
      "summary": {
        "total_items": 2,
        "total_quantity": 15,
        "total_value": 500.00
      },
      "notes": "Urgent delivery needed",
      "pdf_url": "/uploads/pdfs/order-uuid-timestamp.pdf",
      "status": {
        "pdf_generated": true,
        "sent": true,
        "sent_via": "whatsapp"
      },
      "timestamps": {
        "created_at": "2024-01-15T10:00:00.000Z",
        "updated_at": "2024-01-15T10:10:00.000Z",
        "pdf_generated_at": "2024-01-15T10:05:00.000Z",
        "sent_at": "2024-01-15T10:10:00.000Z"
      }
    }
  }
}
```

---

### 4. Generate PDF
**Endpoint:** `POST /api/orders/:id/generate-pdf`
**Auth Required:** Yes + Subscription
**Code Reference:** `backend/routes/orders.js:394-464`

**Description:** Generates a PDF file for the order with merchant and supplier details.

**Success Response (200):**
```json
{
  "success": true,
  "message": "PDF generated successfully",
  "data": {
    "order_id": "uuid",
    "order_number": "PO-20240115-001",
    "pdf_generated_at": "2024-01-15T10:05:00.000Z",
    "pdf_url": "/uploads/pdfs/order-uuid-timestamp.pdf",
    "pdf_filename": "order-uuid-timestamp.pdf"
  }
}
```

**Notes:**
- PDF stored in `backend/uploads/pdfs/`
- Auto-updates `pdf_generated_at` timestamp
- Uses `backend/utils/pdfGenerator.js` utility

---

### 5. Mark Order as Sent
**Endpoint:** `POST /api/orders/:id/mark-sent`
**Auth Required:** Yes
**Code Reference:** `backend/routes/orders.js:470-522`

**Description:** Marks order as sent via specified delivery method.

**Request Body:**
```json
{
  "sent_via": "whatsapp"
}
```

**Validation:**
- `sent_via`: one of ['whatsapp', 'email', 'phone', 'in_person'] (required)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Order marked as sent via whatsapp",
  "data": {
    "order_id": "uuid",
    "order_number": "PO-20240115-001",
    "sent_at": "2024-01-15T10:10:00.000Z",
    "sent_via": "whatsapp",
    "pdf_generated_at": "2024-01-15T10:05:00.000Z"
  }
}
```

**Notes:**
- Auto-generates PDF timestamp if not already generated

---

### 6. Download PDF
**Endpoint:** `GET /api/orders/:id/download-pdf`
**Auth Required:** Yes
**Code Reference:** `backend/routes/orders.js:528-578`

**Description:** Downloads the order PDF file.

**Success Response (200):**
- Content-Type: application/pdf
- File download with name: `order-{order_number}.pdf`

**Error Cases:**
- Order not found
- PDF not generated yet
- PDF file not found on disk

---

## Utilities

### 1. Health Check
**Endpoint:** `GET /health`
**Auth Required:** No
**Code Reference:** `backend/server.js:25-33`

**Description:** Server health check endpoint.

**Success Response (200):**
```json
{
  "status": "OK",
  "message": "Makhzani API is running",
  "timestamp": "2024-01-15T10:00:00.000Z",
  "environment": "development",
  "version": "1.0.0"
}
```

---

### 2. API Documentation
**Endpoint:** `GET /api/docs`
**Auth Required:** No
**Code Reference:** `backend/server.js:63-104`

**Description:** Returns quick API documentation overview.

---

### 3. Test Authentication
**Endpoint:** `GET /api/me`
**Auth Required:** Yes
**Code Reference:** `backend/server.js:44-60`

**Description:** Test endpoint to verify authentication token.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Authenticated successfully",
  "data": {
    "merchant": {
      "id": "uuid",
      "name": "John Doe",
      "shop_name": "Best Shop",
      "phone_number": "+212612345678",
      "region": "Casablanca",
      "subscription_status": "trial",
      "trial_ends_at": "2024-02-01T00:00:00.000Z"
    }
  }
}
```

---

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE",
  "errors": [ ... ]
}
```

### Validation Error
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "msg": "Invalid Morocco phone number",
      "param": "phone_number",
      "location": "body"
    }
  ]
}
```

---

## Middleware

### Authentication
**File:** `backend/middleware/auth.js`

**authenticateToken:**
- Verifies JWT token from Authorization header
- Adds `merchantId` and `merchant` to request object
- Returns 401 if token invalid/missing

**checkSubscription:**
- Verifies merchant subscription status
- Allows trial users
- Returns 403 if subscription inactive

---

## Database Models

**Main Models:**
- `Merchant` - Merchant accounts
- `Product` - Product inventory
- `Supplier` - Supplier information
- `MerchantSupplier` - Many-to-many relationship
- `PurchaseOrder` - Order headers
- `PurchaseOrderItem` - Order line items

**Relationships:**
- Merchant has many Products
- Merchant has many Suppliers (through MerchantSupplier)
- PurchaseOrder belongs to Merchant and Supplier
- PurchaseOrder has many PurchaseOrderItems
- PurchaseOrderItem belongs to Product

---

## Environment Variables

```env
PORT=3000
NODE_ENV=development
JWT_SECRET=your_secret_key
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=makhzani
```

---

## Error Codes Reference

| Code | Description | Endpoint |
|------|-------------|----------|
| `OTP_NOT_FOUND` | No OTP found for phone number | POST /api/auth/verify-otp |
| `OTP_EXPIRED` | OTP has expired | POST /api/auth/verify-otp |
| `TOO_MANY_ATTEMPTS` | Too many failed OTP attempts | POST /api/auth/verify-otp |
| `INVALID_OTP` | Wrong OTP code | POST /api/auth/verify-otp |
| `DUPLICATE_PRODUCT_NAME` | Product name already exists | POST/PUT /api/products |
| `DUPLICATE_BARCODE` | Barcode already exists | POST/PUT /api/products |
| `SUPPLIER_ALREADY_LINKED` | Supplier already linked to merchant | POST /api/suppliers |
| `DUPLICATE_PHONE_NUMBER` | Phone number already in use | POST /api/suppliers |
| `SUPPLIER_HAS_ORDERS` | Cannot remove supplier with orders | DELETE /api/suppliers/:id |

---

## Notes for Future Implementation

1. **Authentication:**
   - Implement actual SMS service for OTP (currently development mode only)
   - Move OTP storage to Redis for production
   - Add rate limiting for OTP requests

2. **Products:**
   - Consider adding product categories
   - Add product images support
   - Implement batch import/export

3. **Orders:**
   - Add order status workflow (pending, confirmed, delivered)
   - Implement automatic stock reduction on order receipt
   - Add order editing capability

4. **General:**
   - Add comprehensive logging
   - Implement audit trails
   - Add analytics endpoints
   - Implement WebSocket for real-time updates

---

**Last Updated:** 2024-01-15
**Maintained By:** Makhzani Development Team
