import{Pool,PoolClient}from"pg";
const databaseUrl=process.env.DATABASE_URL;
if(!databaseUrl)throw new Error("DATABASE_URL is required");
const parsedDatabaseUrl=new URL(databaseUrl);
for(const key of ["sslmode","sslcert","sslkey","sslrootcert"])parsedDatabaseUrl.searchParams.delete(key);
export const pool=new Pool({connectionString:parsedDatabaseUrl.toString(),max:10,ssl:process.env.NODE_ENV==="production"?{rejectUnauthorized:false}:undefined});
export async function withTx<T>(fn:(client:PoolClient)=>Promise<T>){const c=await pool.connect();try{await c.query("BEGIN");const v=await fn(c);await c.query("COMMIT");return v}catch(e){await c.query("ROLLBACK");throw e}finally{c.release()}}
