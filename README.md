## Vyral
Smart contract for [Vyral](https://vyral.network) crowdsale.

* [VyralSale.sol](contracts/VyralSale.sol) Driver contract that runs presale and crowdsale. Presale begins Dec 2, 2017 9AM EST 
  and runs for 23 days. Crowdsale will be initialized after presale ends.
* [Campaign.sol](contracts/Campaign.sol) Campaign manager contract that keeps track of the Referral tree and sends rewards for new referrals.
* [Share.sol](contracts/Share.sol) Standard ERC20 token with some added logic to make it compatible with the referral mechanisms.
* [Vesting.sol](contracts/Vesting.sol) A wallet with vesting logic that keeps track of registered vesting schedules and unlocks tokens over time for team and partners.
* [PresaleBonuses.sol](contracts/PresaleBonuses.sol) Library contract that calculates the bonus rewards during the presale phase of the sale.

## Development

Clone this repository including submodules:
```
git clone --recursive git@github.com:vyralnetwork/vyral.git
```

**NOTE:** Tell git not to track `secrets.json` and `truffle.js` like so:
```
$ git update-index --assume-unchanged secrets.json truffle.js
```

Install NPM dependencies (local and global):
```
$ npm install
$ npm install -g web3@0.19.1 ethereumjs-testrpc truffle 
``` 
Run TestRPC in one shell and run Truffle tests in another.
```
$ testrpc -u0 -u1 -u2 -u3 -u4 -u5
```
```
$ truffle develop
truffle(develop)> migrate
truffle(develop)> test
```

#### Testnet
Add private key or mnemonic to `secrets.json` and deploy to testnet:
```
$ truffle migrate --network rinkeby
```
