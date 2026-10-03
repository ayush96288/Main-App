import "dotenv/config";
import { readFile } from "node:fs/promises";
import { pool } from "./db.js";

const enumDefinitions = [
  { name:"user_role", values:["CUSTOMER","SCRIBE","ADMIN"] },
  { name:"order_status", values:["DRAFT","PAID_PENDING_ACCEPTANCE","SCRIBE_ACCEPTED","IN_PROGRESS","QUALITY_CHECK","DISPATCHED","DELIVERED_TO_GATE","ESCROW_HOLD","SETTLED","CANCELLED"] },
] as const;

for (const type of enumDefinitions) {
  const values = type.values.map(value => "'" + value + "'").join(",");
  await pool.query(
    "DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = '" + type.name + "') THEN CREATE TYPE " + type.name + " AS ENUM (" + values + "); END IF; EXCEPTION WHEN duplicate_object THEN NULL; END $$;",
  );
}

const schema = await readFile(new URL("../schema.sql", import.meta.url), "utf8");
await pool.query(schema);
await pool.end();
console.log("database schema initialized");