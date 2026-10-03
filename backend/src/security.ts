import crypto from "node:crypto";
import jwt from "jsonwebtoken";

const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret || jwtSecret.length < 32) throw new Error("JWT_SECRET must be set and at least 32 characters");

export function issueAccessToken(sub:string,role:"CUSTOMER"|"SCRIBE"|"ADMIN"){
  return jwt.sign({sub,role,type:"access"},jwtSecret,{expiresIn:"15m",issuer:"scribelink",audience:"scribelink-app"});
}
export function issueRefreshToken(){return crypto.randomBytes(48).toString("base64url")}
export function hashToken(value:string){return crypto.createHash("sha256").update(value).digest("hex")}
export function verifyAccessToken(token:string){
  const p=jwt.verify(token,jwtSecret,{issuer:"scribelink",audience:"scribelink-app"});
  if(typeof p!=="object"||p===null||p.type!=="access"||typeof p.sub!=="string"||!["CUSTOMER","SCRIBE","ADMIN"].includes(String(p.role)))throw new Error("invalid_access_token");
  return p as {sub:string;role:"CUSTOMER"|"SCRIBE"|"ADMIN";type:"access"}
}
export function otp(){return crypto.randomInt(100000,1000000).toString()}
export function requestId(){return crypto.randomUUID()}
