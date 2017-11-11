/**
 * Referral key generation uses Marsaglia's random number generators.
 * See http://school.anhb.uwa.edu.au/personalpages/kwessen/shared/Marsaglia03.html
 *
 * Marsaglia, George (2003). Random Number Generators
 */
class ReferralKeyGenerator {

    /**
     * Initialize RNG with a seed.
     * @param seed
     */
    constructor() {
        this.x = 123456789;
        this.y = 362436069;
        this.z = 521288629;
        this.w = 88675123;
        this.v = 886756453;

        this.k = 0;

        while(this.k < 5) {
            this.xorshift();
            this.k = this.k + 1;
        }
    }

    /**
     * Get next key
     * @returns {number}
     */
    getKey() {
        return this.xorshift();
    }

    /**
     *
     * @returns {number}
     */
    xorshift() {
        let t = (this.x ^ (this.x >> 7));

        this.x = this.y;
        this.y = this.z;
        this.z = this.w;
        this.w = this.v;
        this.v = (this.v ^ (this.v << 6)) ^ (t ^ (t << 13));
        return (this.y + this.y + 1) * this.v;
    }

    /**
     * Converts an integer to array of Uint8Array[]
     * @param num
     * @returns {ArrayBuffer}
     */
    static toBytesInt32(num) {
        let arr = new Uint8Array([
            (num & 0xff000000) >> 24,
            (num & 0x00ff0000) >> 16,
            (num & 0x0000ff00) >> 8,
            (num & 0x000000ff)
        ]);
        return arr.buffer;
    }
}

module.exports = ReferralKeyGenerator;