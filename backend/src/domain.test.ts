import{strict as assert}from"node:assert";import{canTransition,orderAmounts}from"./domain.js";
assert.equal(canTransition("DRAFT","PAID_PENDING_ACCEPTANCE"),true);assert.equal(canTransition("SETTLED","IN_PROGRESS"),false);assert.deepEqual(orderAmounts(10),{pricePaise:30000,payoutPaise:20000});
console.log("ScribeLink domain tests passed");