# Password Reset Flow – Rails API Demo

## Overview

This is a demo Rails API implementing a secure password reset flow. It includes endpoints for requesting a password reset, sending a reset_url via JSON (Should be an email), and resetting the password using the token.

---

## Features

- Secure password storage using industry-standard hashing
- Generates secure, random password reset tokens using strong cryptographic methods
- Stores only a hashed version of the token in the database for enhanced security
- Supports tracking metadata such as IP address and user agent for auditing
- Automatically revokes any previous active tokens to enforce single-use
- Tokens have explicit expiration times to limit their validity window (30 minutes but adjustable)
- Handles password reset requests by verifying user email existence
- Safely updates the user’s password with confirmation and validation

---

## Tech Stack

### Core Technologies
- Ruby on Rails (API only)
- PostgreSQL
- Docker

### Tools & Libraries
- PG Admin (database management)
- bcrypt (password hashing)
- rails_semantic_logger (enhanced logging)
- Postman (API testing)
- RSpec (testing framework)
- Factory Bot (test data factories)

---

## Installation

### Prerequisites
- Visual Studio Code with [Remote - Containers](https://code.visualstudio.com/docs/remote/containers) extension
- Docker Desktop installed and running

### Setup with Dev Container

1. **Clone the repository:**
```bash
git clone https://github.com/santosral/password-reset-rails-api-demo.git
cd password-reset-rails-api-demo
```

2. **Open the project in VS Code.**

3. **Reopen the project in the Dev Container:**

4. **Start the Rails server:**
```bash
bin/rails server -b 0.0.0.0
```

The API will be available at http://localhost:3000.

## API Documentation

The full API documentation and example requests are available in the Postman collection:

[Open Postman Collection](https://www.postman.com/lively-spaceship-99649/workspace/public-applications/collection/16588736-0d295837-3cfe-4324-a182-c87a5d3083e4?action=share&creator=16588736)

You can import this collection into Postman to test all endpoints with sample requests and responses.

## Documentation

For detailed documentation and notes, please visit the [Project Wiki](https://github.com/santosral/password-reset-rails-api-demo/wiki).

