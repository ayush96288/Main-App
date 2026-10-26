# ScribeLink

A marketplace where people who need text written by hand can order it from people who write by hand.

> **Status: early development.** Nothing here is a finished or tested product yet. See "Current status" below.

## What it does

1. A customer uploads the text they want handwritten (they supply all the content).
2. The platform counts billable pages and shows a price.
3. The customer picks a writer (a "scribe") by looking at that scribe's handwriting sample.
4. The scribe writes it out following the customer's pen, ink and margin choices.
5. The finished pages are packed and delivered, and the scribe is paid after delivery.

ScribeLink only copies out the text it is given. It does not research, solve or write original content.

## Who it is for

Anyone who needs something handwritten but cannot or does not have time to write it: invitations, letters, forms, notes, archival copies, and accessibility support for people who cannot write by hand.

## Rules for users

- You must have the right to submit the text you upload.
- You are responsible for checking whether handwritten work made by someone else is acceptable for your purpose. For example, many schools and colleges do not accept it as your own work, and it must not be used for exams or supervised work.
- Disabled students may be entitled to an official scribe through their institution. ScribeLink is not a replacement for that.

## Pricing (draft, not final)

| Item | Customer price |
|---|---|
| Base rate | INR 30 per billable page |
| Billable pages | CEIL(word count / 200) |

Add-ons for drawings, graphs, custom templates and rigid packaging are planned. Final prices, fees and payout terms are still to be decided.

## Tech

| Part | Technology |
|---|---|
| App (phone and web) | Expo / React Native, TypeScript |
| Database | PostgreSQL 17 (schema in `backend/schema.sql`) |
| File storage (local development) | MinIO |
| Local services | Docker Compose |

## Run it locally

Requires Node.js and Docker.

```bash
# 1. Start the local database and file storage
docker compose up -d

# 2. Install packages
npm install

# 3. Copy the example settings, then fill in your own values
cp .env.example .env

# 4. Start the app
npm run web
```

The passwords in `docker-compose.yml` are for local development only. Never use them anywhere public.

Check types with `npm run typecheck`.

## Current status

- [x] App skeleton (Expo)
- [x] Database schema file
- [ ] Which screens and backend features work: **not yet documented**
- [ ] Automated tests: none yet
- [ ] Payments: not set up
- [ ] Deliveries: not set up

Update this list as you confirm each item works.

## Before launch

These need decisions or professional review first:

- Whether your payment provider allows this service, under its current written terms.
- Rules for users under 18.
- Terms of service, privacy policy, and data protection for uploaded documents and handwriting samples.
- Whether holding customer money until delivery counts as "escrow". Do not use that word unless a lawyer or provider confirms it.
- Refund and dispute rules.

## Secrets

Never commit passwords, API keys or tokens. Keep them in `.env` (already in `.gitignore`) and in your hosting provider's secret settings.

## License

See `LICENSE`.
