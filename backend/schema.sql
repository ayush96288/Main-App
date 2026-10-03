CREATE EXTENSION IF NOT EXISTS pgcrypto;
DO $ BEGIN
  CREATE TYPE user_role AS ENUM ('CUSTOMER','SCRIBE','ADMIN');
EXCEPTION WHEN duplicate_object THEN NULL;
END $;

DO $ BEGIN
  CREATE TYPE order_status AS ENUM ('DRAFT','PAID_PENDING_ACCEPTANCE','SCRIBE_ACCEPTED','IN_PROGRESS','QUALITY_CHECK','DISPATCHED','DELIVERED_TO_GATE','ESCROW_HOLD','SETTLED','CANCELLED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $;
CREATE TABLE IF NOT EXISTS users(id UUID PRIMARY KEY DEFAULT gen_random_uuid(), phone_e164 TEXT NOT NULL UNIQUE, role user_role NOT NULL DEFAULT 'CUSTOMER', is_active BOOLEAN NOT NULL DEFAULT TRUE, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS auth_challenges(id UUID PRIMARY KEY DEFAULT gen_random_uuid(), phone_e164 TEXT NOT NULL, otp_hash TEXT NOT NULL, expires_at TIMESTAMPTZ NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, consumed_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS auth_challenges_phone_idx ON auth_challenges(phone_e164,created_at DESC);
CREATE TABLE IF NOT EXISTS sessions(id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, refresh_token_hash TEXT NOT NULL UNIQUE, expires_at TIMESTAMPTZ NOT NULL, revoked_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS sessions_user_idx ON sessions(user_id,expires_at);
CREATE TABLE IF NOT EXISTS orders(id UUID PRIMARY KEY DEFAULT gen_random_uuid(), public_id TEXT NOT NULL UNIQUE, customer_id UUID NOT NULL REFERENCES users(id), scribe_id UUID REFERENCES users(id), pages INTEGER NOT NULL CHECK(pages BETWEEN 1 AND 500), word_count INTEGER CHECK(word_count>=0), price_paise INTEGER NOT NULL CHECK(price_paise>=0), payout_paise INTEGER NOT NULL CHECK(payout_paise>=0), status order_status NOT NULL DEFAULT 'DRAFT', acceptance_deadline TIMESTAMPTZ, version INTEGER NOT NULL DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS orders_customer_idx ON orders(customer_id,created_at DESC);
CREATE INDEX IF NOT EXISTS orders_scribe_idx ON orders(scribe_id,status,created_at DESC);
CREATE TABLE IF NOT EXISTS order_events(id UUID PRIMARY KEY DEFAULT gen_random_uuid(), order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE, from_status order_status, to_status order_status NOT NULL, actor_user_id UUID REFERENCES users(id), metadata JSONB NOT NULL DEFAULT '{}'::jsonb, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS order_events_order_idx ON order_events(order_id,created_at);

CREATE TABLE IF NOT EXISTS documents(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE, object_key TEXT NOT NULL UNIQUE, original_name TEXT NOT NULL, mime_type TEXT NOT NULL, byte_size BIGINT NOT NULL CHECK(byte_size>0), sha256 TEXT, status TEXT NOT NULL DEFAULT 'PENDING', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), validated_at TIMESTAMPTZ);
CREATE INDEX IF NOT EXISTS documents_order_idx ON documents(order_id);
CREATE TABLE IF NOT EXISTS document_pages(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,page_number INTEGER NOT NULL CHECK(page_number>0),ocr_text TEXT,word_count INTEGER CHECK(word_count>=0),prohibited BOOLEAN NOT NULL DEFAULT FALSE,review_required BOOLEAN NOT NULL DEFAULT FALSE, UNIQUE(document_id,page_number));
CREATE TABLE IF NOT EXISTS handwriting_profiles(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),scribe_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,public_name TEXT NOT NULL,style_tags TEXT[] NOT NULL DEFAULT '{}',sample_object_key TEXT,active BOOLEAN NOT NULL DEFAULT TRUE);
CREATE TABLE IF NOT EXISTS scribe_profiles(user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,available BOOLEAN NOT NULL DEFAULT FALSE,max_pages_per_order INTEGER NOT NULL DEFAULT 100,quality_score NUMERIC(4,2) NOT NULL DEFAULT 5.00,completed_jobs INTEGER NOT NULL DEFAULT 0,updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS payments(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),order_id UUID NOT NULL UNIQUE REFERENCES orders(id),provider TEXT NOT NULL,status TEXT NOT NULL DEFAULT 'PENDING',amount_paise INTEGER NOT NULL CHECK(amount_paise>=0),provider_reference TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT now(),updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS escrow_entries(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),order_id UUID NOT NULL REFERENCES orders(id),kind TEXT NOT NULL CHECK(kind IN ('CUSTOMER_CHARGE','SCRIBE_PAYOUT','PLATFORM_FEE','REFUND')),amount_paise INTEGER NOT NULL CHECK(amount_paise>=0),status TEXT NOT NULL DEFAULT 'PENDING',reference TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS escrow_order_idx ON escrow_entries(order_id,created_at);
CREATE TABLE IF NOT EXISTS delivery_verifications(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),order_id UUID NOT NULL UNIQUE REFERENCES orders(id),otp_hash TEXT NOT NULL,expires_at TIMESTAMPTZ NOT NULL,attempts INTEGER NOT NULL DEFAULT 0,verified_at TIMESTAMPTZ);
CREATE TABLE IF NOT EXISTS disputes(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),order_id UUID NOT NULL REFERENCES orders(id),opened_by UUID NOT NULL REFERENCES users(id),reason TEXT NOT NULL,details TEXT NOT NULL,status TEXT NOT NULL DEFAULT 'OPEN',resolution TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT now(),resolved_at TIMESTAMPTZ);
CREATE INDEX IF NOT EXISTS disputes_order_idx ON disputes(order_id,status);
CREATE TABLE IF NOT EXISTS audit_logs(id UUID PRIMARY KEY DEFAULT gen_random_uuid(),actor_user_id UUID REFERENCES users(id),action TEXT NOT NULL,resource_type TEXT NOT NULL,resource_id TEXT,request_id TEXT,metadata JSONB NOT NULL DEFAULT '{}'::jsonb,created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE INDEX IF NOT EXISTS audit_logs_created_idx ON audit_logs(created_at DESC);
