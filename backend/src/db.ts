import{Pool,PoolClient}from"pg";
export const pool=new Pool({connectionString:process.env.DATABASE_URL,max:10,ssl:process.env.NODE_ENV==="production"?{rejectUnauthorized:true}:undefined});
export async function withTx<T>(fn:(client:PoolClient)=>Promise<T>){const c=await pool.connect();try{await c.query("BEGIN");const v=await fn(c);await c.query("COMMIT");return v}catch(e){await c.query("ROLLBACK");throw e}finally{c.release()}}
