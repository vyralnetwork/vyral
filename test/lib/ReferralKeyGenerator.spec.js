/**
 * ReferralKeyGenerator methods
 */

"use strict";
const {assert} = require('chai');
const fs       = require('fs');
const Int64BE  = require("int64-buffer").Int64BE;

let ReferralKeyGenerator = require("../../lib/ReferralKeyGenerator");

describe("Referral Key", () => {


    describe("XORShift", () => {

        before(() => {
            this.rkg = new ReferralKeyGenerator();
        });

        it("should create a new referral key", (done) => {
            let buffer = new Buffer(400);
            for(let i = 1; i <= 200; i++) {
                let buf = new Int64BE(this.rkg.xorshift()).toBuffer();
                buffer  = Buffer.concat([buffer, buf]);
            }

            fs.writeFile('random_output', buffer, "binary", (err) => {
                if(err) throw err;

                console.log('Random data saved!');
            });
            done();
        });
    });

});
