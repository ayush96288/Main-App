import { readFile } from "node:fs/promises";
import { pool } from "./db.js";

const sql = await readFile(new URL("../schema.sql", import.meta.url), "utf8");
// Schema creation is intentionally idempotent so redeploys can reuse the persistent database.
await pool.query(sql);
await pool.end();
console.log("database schema initialized");
