pragma solidity ^0.4.0;


/**
 * Creates a new referral key for a node in a campaign.
 */
contract ReferralKeyGenerator {

    int64 x = 123456789;

    int64 y = 362436069;

    int64 z = 521288629;

    int64 w = 88675123;

    int64 v = 886756453;

    int64 k = 0;

    /**
     * Initialize the contract by generating "k" number of integers.
     */
    function ReferralKeyGenerator(){
    }


    /**
     * XORShift algorithm generate random numbers. The period of this
     * algorithm is about  2^160 sufficient for referral key generation.
     * Sample output after 200 rounds:
     *
     *  Entropy = 7.196371 bits per byte.
     *
     *  Optimum compression would reduce the size
     *  of this 3600 byte file by 10 percent.
     *
     *  Chi square distribution for 3600 samples is 23107.34, and randomly
     *  would exceed this value less than 0.01 percent of the times.
     *
     *  Arithmetic mean value of data bytes is 114.8503 (127.5 = random).
     *   Monte Carlo value for Pi is 3.080000000 (error 1.96 percent).
     *  Serial correlation coefficient is 0.198466 (totally uncorrelated = 0.0).
     */
    function xorshift() {
        int64 t = (x ^ (x >> 7));
        x = y;
        y = z;
        z = w;
        w = v;
        v = (v ^ (v << 6)) ^ (t ^ (t << 13));
        return (y + y + 1) * v;
    }

}
