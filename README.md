## Vyral
Smart contract for [Vyral](https://vyral.network) crowdsale.

* [VyralSale.sol](contracts/VyralSale.sol) Driver contract that runs presale and crowdsale. Presale begins Dec 2, 2017 9AM EST 
  and runs for 23 days. Crowdsale is can be initialized after presale ends.

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
