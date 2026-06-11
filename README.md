# User Check API

A Ruby on Rails API application that evaluates user integrity based on country, device rooting status, and VPN/Proxy/Tor detection.

## Tech Stack

* Ruby 3.2.4
* Rails 8.1.3
* PostgreSQL
* Redis
* RSpec
* RuboCop
* Brakeman
* Faraday
* VPNAPI

---

## Prerequisites

Before running the application, ensure the following are installed:

* Ruby 3.2.4
* PostgreSQL
* Redis
* Bundler

Verify installation:

```bash
ruby -v
psql --version
redis-server --version
bundle -v
```

---

## Installation

Clone the repository:

```bash
git clone <repository_url>
cd user-check-api
```

Install dependencies:

```bash
bundle install
```

---

## Environment Variables

Create a `.env` file in the project root:

```env
VPNAPI_KEY=your_vpnapi_key
REDIS_URL=redis://localhost:6379/0
```

---

## Database Setup

Create the database:

```bash
rails db:create
```

Run migrations:

```bash
rails db:migrate
```

Seed the whitelist countries:

```bash
rails db:seed
```

---

## Running Redis

Start Redis locally:

```bash
redis-server
```

Verify Redis is running:

```bash
redis-cli ping
```

Expected output:

```text
PONG
```

---

## Running the Application

Start the Rails server:

```bash
rails server
```

The API will be available at:

```text
http://localhost:3000
```

---

## API Endpoint

### Check User Status

**POST**

```http
/v1/user/check_status
```

Example Request:

```json
{
  "idfa": "user-123",
  "rooted_device": false
}
```

Required Headers:

```http
CF-IPCountry: GB
CF-Connecting-IP: 8.8.8.8
```

Example Response:

```json
{
  "ban_status": "not_banned"
}
```

Possible responses:

```json
{
  "ban_status": "not_banned"
}
```

```json
{
  "ban_status": "banned"
}
```

---

## Business Rules

A user is marked as **banned** when any of the following conditions are met:

* Country is not in the whitelist
* Device is rooted
* VPN detected
* Proxy detected
* Tor detected

Users are identified by their IDFA.

Integrity logs are created:

* When a new user is created
* When an existing user's status changes

---

## Running Tests

Run all tests:

```bash
bundle exec rspec
```

Run a specific test file:

```bash
bundle exec rspec spec/services/user_check_status_service_spec.rb
```

---

## Code Quality

Run RuboCop:

```bash
bundle exec rubocop
```

Auto-correct offenses:

```bash
bundle exec rubocop -A
```

---

## Security Scan

Run Brakeman:

```bash
bin/brakeman --no-pager
```

---

## Project Structure

```text
app/
├── controllers/
├── models/
├── services/

spec/
├── models/
├── requests/
├── services/
```

### Main Services

* UserCheckStatusService
* VpnApiService
* IntegrityLoggerService

---

## Author

Hamza Rao
