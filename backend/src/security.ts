import crypto from "node:crypto";import jwt from "jsonwebtoken";
const secret=()=>{const s=process.env.JWT_SECRET;if(!s||s.length<32)throw new Error("JWT_SECRET must be at least 32 characters");return s};
export function issueAccessToken(sub:string,role:"CUSTOMER"|"SCRIBE"|"ADMIN"){return jwt.sign({sub,role,type:"access"},secret(),{expiresIn:"15m",issuer:"scribelink"})}
export function issueRefreshToken(){return crypto.randomBytes(48).toString("base64url")}
export function hashToken(value:string){return crypto.createHash("sha256").update(value).digest("hex")}
export function verifyAccessToken(token:string){return jwt.verify(token,secret(),{issuer:"scribelink"}) as {sub:string;role:string;type:string}}
export function otp(){return crypto.randomInt(100000,1000000).toString()}
export function requestId(){return crypto.randomUUID()}