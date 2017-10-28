## vyral


## Testing

#### Development
Start a test client: `testrpc -u1 -u2 -u3`

```
$ DEBUG=vyral:* npm test
```

#### Testnet
```
$ NODE_ENV=test DEBUG=vyral:* npm test
```

#### ToDo

- [ ] Vyral Campaign and Referrals
    - [X] Referral tree library
    - [X] Reward library
    - [X] Reward payoff interface
    - [ ] Tiered reward payoff based on percentages
    - [ ] Tests
        - [X] Deploy new campaign


- [ ] Crowdsale
    - [X] Fallback to exchange ETH for SHARE
    - [X] Minting and token allocation
    - [X] Add Consensys MultiSig wallet    
    - [ ] Vesting
    - [ ] Tests
        - [ ] Invalid MultiSig
        - [ ] Total supply must match sum of all allocations


- [ ] SHARE Token
    - [X] Standard token implementation
    - [X] Minting
    - [ ] Tests
