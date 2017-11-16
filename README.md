## vyral


## Testing

#### Development
```
$ truffle develop

truffle(develop)> migrate

truffle(develop)> test
```

*NOTE:* After checking tell git not to track `secrets.json` and `truffle.js` like so:
```
$ git update-index --assume-unchanged secrets.json truffle.js
```

#### Testnet
```
$ truffle migrate --network rinkeby
```

#### ToDo

- [ ] Vyral Campaign and Referrals
    - [X] Referral tree library
    - [X] Reward library
    - [X] Reward payoff interface
    - [ ] Compute campaign cost and remaining budget
    - [ ] Tiered reward payoff based on percentages
    - [ ] Tests
        - [X] Deploy new campaign


- [ ] Crowdsale
    - [X] Fallback to exchange ETH for SHARE
    - [X] Minting and token allocation
    - [X] Add Consensys MultiSig wallet    
    - [X] Vesting
    - [ ] Tests
        - [ ] Invalid MultiSig
        - [ ] Total supply must match sum of all allocations


- [ ] SHARE Token
    - [X] HumanStandardToken
    - [X] Remove minting
    - [ ] Tests

