# ScribeLink backend

ScribeLink's backend is split into small security-focused layers so the app can stay simple while the server enforces the real rules.

## Current architecture

- Express + TypeScript API with Helmet, CORS allowlisting, request IDs and global/sensitive-route rate limits.
- PostgreSQL for users, OTP challenges, refresh sessions, orders and immutable order events.
- Opaque refresh tokens are random, stored only as SHA-256 hashes, rotated on refresh, and revocable.
- Short-lived JWT access tokens carry only the user id, role and token type.
- RBAC + object ownership is enforced server-side; the client never decides what a user may access.
- Order state machine rejects invalid lifecycle jumps and records each accepted transition.
- MinIO is the local/self-hosted object-storage foundation for private documents.
- Tesseract is the default self-hosted OCR direction; provider adapters keep external services optional.

## Order economics

The specification's pricing is encoded as a server-side rule: ₹30/page customer price and ₹20/page scribe payout. Values are stored as integer paise to avoid floating-point money errors.

## Authentication

1. Client requests an OTP for an E.164 phone number.
2. Server stores only a hash of the OTP, with a five-minute expiry and attempt limit.
3. Successful verification creates the user session.
4. Server issues a short-lived access token and a random refresh token.
5. Refresh tokens are rotated and revoked server-side; logout revokes the active session.
6. Browser refresh tokens use an HttpOnly cookie. Native clients should use OS secure storage rather than AsyncStorage.

No credentials or provider API keys belong in Git. Use .env locally and a managed secret store in production.

## Local services

Docker Compose starts PostgreSQL and MinIO. The SQL schema is mounted into PostgreSQL's initialization directory for a fresh local volume.

Then run: cd backend, npm install, npm run build, npm test.

## Provider strategy

The application should prefer self-hosted/open-source components where technically appropriate. Payments, SMS, APNs/FCM and some delivery integrations are external regulated/provider services rather than something that can safely be replaced by a pretend open-source API key. Those integrations stay behind narrow adapters and their secrets never enter the repository.

## Production hardening still required

Before accepting real customer documents or money, add authenticated private upload URLs, MIME/content validation and malware scanning, OCR worker queues, payment-provider webhooks with signature verification, escrow ledger reconciliation, delivery OTP hashing, dispute workflows, audit-log retention, backups, monitoring and integration/security tests.