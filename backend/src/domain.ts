import crypto from"node:crypto";
export const transitions:Record<string,string[]>={DRAFT:["PAID_PENDING_ACCEPTANCE","CANCELLED"],PAID_PENDING_ACCEPTANCE:["SCRIBE_ACCEPTED","CANCELLED"],SCRIBE_ACCEPTED:["IN_PROGRESS","CANCELLED"],IN_PROGRESS:["QUALITY_CHECK","CANCELLED"],QUALITY_CHECK:["DISPATCHED","IN_PROGRESS","CANCELLED"],DISPATCHED:["DELIVERED_TO_GATE","CANCELLED"],DELIVERED_TO_GATE:["ESCROW_HOLD"],ESCROW_HOLD:["SETTLED","CANCELLED"],SETTLED:[],CANCELLED:[]};
export function canTransition(from:string,to:string){return transitions[from]?.includes(to)??false}
export function orderAmounts(pages:number){return{pricePaise:pages*3000,payoutPaise:pages*2000}}
export function publicOrderId(){return `SL-${crypto.randomUUID().replaceAll("-","").slice(0,8).toUpperCase()}`}
