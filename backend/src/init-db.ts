import { readFile } from "node:fs/promises";
import { pool } from "./db.js";

const sql = await readFile(new URL("../schema.sql", import.meta.url), "utf8");

const enumTypes = [
  {
    name: "user_role",
    values: ["CUSTOMER", "SCRIBE", "ADMIN"],
  },
  {
    name: "order_status",
    values: [
      "DRAFT",
      "PAID_PENDING_ACCEPTANCE",
      "SCRIBE_ACCEPTED",
      "IN_PROGRESS",
      "QUALITY_CHECK",
      "DISPATCHED",
      "DELIVERED_TO_GATE",
      "ESCROW_HOLD",
      "SETTLED",
      "CANCELLED",
    ],
  },
] as const;

for (const type of enumTypes) {
  const existing = await pool.query(
    "SELECT 1 FROM pg_type WHERE typname = $1 LIMIT 1",
    [type.name],
  );

  if (existing.rowCount === 0) {
    const values = type.values.map((value) => "'" + value + "'").join(",");
    await pool.query("CREATE TYPE " + type.name + " AS ENUM (" + values + ")");
  }
}

// The enum types above are created explicitly, so remove their CREATE TYPE blocks
// from the schema before running the remaining idempotent table/index statements.
const schema = sql
  .replace(
    /DO \\$\\$ BEGIN[\\s\\S]*?END \\$\\$;\\n\\n?/g,
    "",
  )
  .replace(
    /CREATE TYPE user_role AS ENUM \\([^;]+\\);\\n?/g,
    "",
  )
  .replace(
    /CREATE TYPE order_status AS ENUM \\([^;]+\\);\\n?/g,
    "",
  );

await pool.query(schema);
await pool.end();
console.log("database schema initialized");
