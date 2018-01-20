# Vyral Network Crowdsale Contract Audit

<br />

## Summary

[Vyral Network](https://vyral.network) intends to run a crowdsale commencing in Dec 2017.

Bok Consulting Pty Ltd was commissioned to perform an audit on the Vyral Network's crowdsale and token Ethereum smart contract.

This audit has been conducted on Vyral Network's source code in commit
[1306a68](https://github.com/vyralnetwork/vyral/commit/1306a688cddba31cce19b0cb149b2f4e38aa54bb) and
[1c5b12d](https://github.com/vyralnetwork/vyral/commit/1c5b12d46532f516984904e2869ff664112353e8).

No potential vulnerabilities have been identified in the crowdsale, token, campaign and vesting contracts.

<br />

### Deployed Contracts

The following contracts were deployed to the Ethereum mainnet, but the source code was not verified at the addresses except for the MultiSig:

* Campaign:      [0x1f204b70832b0df002ff7500e7b2fac62b5dbe33](https://etherscan.io/address/0x1f204b70832b0df002ff7500e7b2fac62b5dbe33#code)
* DateTime:      [0x3bbc4826daf4ac26c4365e83299db54015341512](https://etherscan.io/address/0x3bbc4826daf4ac26c4365e83299db54015341512#code)
* MultiSig:      [0x4e4aE4B72c960Ad91fab1e18253D16cDAc6a091c](https://etherscan.io/address/0x4e4aE4B72c960Ad91fab1e18253D16cDAc6a091c#code)
* PresaleBonuses:[0x9cd2a58a1c700c5cc13f04c4fddc215b7af89c7e](https://etherscan.io/address/0x9cd2a58a1c700c5cc13f04c4fddc215b7af89c7e#code)
* Referral:      [0x94f6ced94445ef07a0e8d5e7394c365a7b43bf62](https://etherscan.io/address/0x94f6ced94445ef07a0e8d5e7394c365a7b43bf62#code)
* SafeMath:      [0x84bfc103e575cc4f3f5b24437cccef4ee93c309b](https://etherscan.io/address/0x84bfc103e575cc4f3f5b24437cccef4ee93c309b#code)
* Share:         [0x6f69ef58ddec9cd6ee428253c607a0acd13da05f](https://etherscan.io/address/0x6f69ef58ddec9cd6ee428253c607a0acd13da05f#code)
* TieredPayoff:  [0x57efbaf2e135ad73018aed5f07273b7a0bb2ab54](https://etherscan.io/address/0x57efbaf2e135ad73018aed5f07273b7a0bb2ab54#code)
* Vesting:       [0x6dfbeaf92d8d4455d74bc56bd37a165c5970a4d7](https://etherscan.io/address/0x6dfbeaf92d8d4455d74bc56bd37a165c5970a4d7#code)
  * [x] Note that this original deployed Vesting contract has a bug and will need to be replaced with the fixes in
    [1c5b12d](https://github.com/vyralnetwork/vyral/commit/1c5b12d46532f516984904e2869ff664112353e8)
* VyralSale:     [0x708352cd28ea06e6bbd5c1a9408b4966ac1226e4](https://etherscan.io/address/0x708352cd28ea06e6bbd5c1a9408b4966ac1226e4#code)


<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

* **LOW IMPORTANCE** *SafeMath* could possibly use `require(...)` instead of `assert(...)` to save on gas in the case of an error
* **LOW IMPORTANCE** *Ownable* could be improved by using the `acceptOwnership(...)` [pattern](https://github.com/openanx/OpenANXToken/blob/master/contracts/Owned.sol#L51-L55)
* **LOW IMPORTANCE** *HumanStandardToken* should have a `Transfer(address(0), msg.sender, _initialAmount)` event logged in the constructor
* **MEDIUM IMPORTANCE** The logic in `Vesting.revokeSchedule(...)` seems to duplicate the amount of tokens that is transferred to 
  `_addressToRevoke` and `_addressToRefund`
  * [x] Developer has confirmed the bug. `amountRefundable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);` should be
    replaced with `amountRefundable = vestingSchedule.totalAmount.sub(totalAmountVested);`
  * [x] Fixed in [1c5b12d](https://github.com/vyralnetwork/vyral/commit/1c5b12d46532f516984904e2869ff664112353e8)

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the crowdsale, token, campaign and vesting contracts.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is that
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the Vyral Network's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* This crowdsale contract has a low risk of having the ETH hacked or stolen, as any contributions by participants are immediately transferred
  to the team wallet

<br />

<hr />

## Testing

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy SafeMath library
* [x] Deploy DateTime contract
* [x] Deploy PresaleBonuses contract
* [x] Deploy Referral contract
* [x] Deploy Share token contract
* [x] Deploy TieredPayoff library
* [x] Deploy Vesting contract
* [x] Deploy Campaign contract
* [x] Deploy VyralSale contract
* [x] Link contracts together
* [x] Start presale
* [x] Send presale contributions
* [x] End presale
* [x] Start crowdsale
* [x] Send crowdsale contributions with referrals

Details of the testing environment can be found in [test](test).

[ethereum-datetime-contracts/api.sol](ethereum-datetime-contracts/api.sol) and [ethereum-datetime-contracts/DateTime.sol](ethereum-datetime-contracts/DateTime.sol)
from commit [1c8e514](https://github.com/pipermerriam/ethereum-datetime/commit/1c8e514adc57673d367ab91af4fd86186f1ea7f4) were used in the testing.

<br />

<hr />

## Code Review

* [x] [code-review/math/SafeMath.md](code-review/math/SafeMath.md)
  * [x] library SafeMath
* [x] [code-review/traits/Ownable.md](code-review/traits/Ownable.md)
  * [x] contract Ownable
* [x] [code-review/referral/Referral.md](code-review/referral/Referral.md)
  * [x] library Referral
* [x] [code-review/referral/TieredPayoff.md](code-review/referral/TieredPayoff.md)
  * [x] library TieredPayoff
* [x] [code-review/Campaign.md](code-review/Campaign.md)
  * [x] contract Campaign is Ownable
* [x] [code-review/PresaleBonuses.md](code-review/PresaleBonuses.md)
  * [x] library PresaleBonuses
* [x] [code-review/Share.md](code-review/Share.md)
  * [x] contract Share is HumanStandardToken, Ownable
* [x] [code-review/Vesting.md](code-review/Vesting.md)
  * [x] contract Vesting is Ownable
* [x] [code-review/VyralSale.md](code-review/VyralSale.md)
  * [x] contract VyralSale is Ownable

<br />

### Tokens

* [x] [code-review-tokens/Token.md](code-review-tokens/Token.md)
  * [x] contract Token
* [x] [code-review-tokens/StandardToken.md](code-review-tokens/StandardToken.md)
  * [x] contract StandardToken is Token
* [x] [code-review-tokens/HumanStandardToken.md](code-review-tokens/HumanStandardToken.md)
  * [x] contract HumanStandardToken is StandardToken


<br />

### Not Reviewed

The following files are for the testing framekwork:

* [ ] [../contracts/Migrations.sol](../contracts/Migrations.sol)
  * [ ] contract Migrations

<br />

### Compiler Warnings

```
Compiling ---------- Campaign.sol ----------
Token.sol:20:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance);
    ^--------------------------------------------------------------------^
Token.sol:26:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success);
    ^--------------------------------------------------------------------^
Token.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    ^---------------------------------------------------------------------------------------^
Token.sol:39:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success);
    ^------------------------------------------------------------------------^
Token.sol:44:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    ^----------------------------------------------------------------------------------------^
StandardToken.sol:15:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:27:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:38:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance) {
    ^
Spanning multiple lines.
StandardToken.sol:42:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:48:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    ^
Spanning multiple lines.
HumanStandardToken.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function HumanStandardToken(
    ^
Spanning multiple lines.
HumanStandardToken.sol:47:5: Warning: No visibility specified. Defaulting to "public".
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    ^
Spanning multiple lines.
Share.sol:114:5: Warning: No visibility specified. Defaulting to "public".
    function lockedBalanceOf(
    ^
Spanning multiple lines.
referral/TieredPayoff.sol:62:9: Warning: Variable is declared as a storage pointer. Use an explicit "storage" keyword to silence this warning.
        Referral.Node node = self.nodes[_referrer];
        ^----------------^
HumanStandardToken.sol:54:46: Warning: "sha3" has been deprecated in favour of "keccak256"
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
                                             ^----------------------------------------------------^
Compiling ---------- DateTime.sol ----------
Compiling ---------- PresaleBonuses.sol ----------
api.sol:6:9: Warning: No visibility specified. Defaulting to "public".
        function isLeapYear(uint16 year) constant returns (bool);
        ^-------------------------------------------------------^
api.sol:7:9: Warning: No visibility specified. Defaulting to "public".
        function getYear(uint timestamp) constant returns (uint16);
        ^---------------------------------------------------------^
api.sol:8:9: Warning: No visibility specified. Defaulting to "public".
        function getMonth(uint timestamp) constant returns (uint8);
        ^---------------------------------------------------------^
api.sol:9:9: Warning: No visibility specified. Defaulting to "public".
        function getDay(uint timestamp) constant returns (uint8);
        ^-------------------------------------------------------^
api.sol:10:9: Warning: No visibility specified. Defaulting to "public".
        function getHour(uint timestamp) constant returns (uint8);
        ^--------------------------------------------------------^
api.sol:11:9: Warning: No visibility specified. Defaulting to "public".
        function getMinute(uint timestamp) constant returns (uint8);
        ^----------------------------------------------------------^
api.sol:12:9: Warning: No visibility specified. Defaulting to "public".
        function getSecond(uint timestamp) constant returns (uint8);
        ^----------------------------------------------------------^
api.sol:13:9: Warning: No visibility specified. Defaulting to "public".
        function getWeekday(uint timestamp) constant returns (uint8);
        ^-----------------------------------------------------------^
api.sol:14:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp);
        ^------------------------------------------------------------------------------------------^
api.sol:15:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);
        ^------------------------------------------------------------------------------------------------------^
api.sol:16:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp);
        ^--------------------------------------------------------------------------------------------------------------------^
api.sol:17:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp);
        ^----------------------------------------------------------------------------------------------------------------------------------^
api.sol:1:1: Warning: Source file does not specify required compiler version!Consider adding "pragma solidity ^0.4.18
contract DateTimeAPI {
^
Spanning multiple lines.
Compiling ---------- referral/Referral.sol ----------
Compiling ---------- SafeMath.sol ----------
Compiling ---------- Share.sol ----------
Token.sol:20:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance);
    ^--------------------------------------------------------------------^
Token.sol:26:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success);
    ^--------------------------------------------------------------------^
Token.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    ^---------------------------------------------------------------------------------------^
Token.sol:39:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success);
    ^------------------------------------------------------------------------^
Token.sol:44:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    ^----------------------------------------------------------------------------------------^
StandardToken.sol:15:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:27:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:38:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance) {
    ^
Spanning multiple lines.
StandardToken.sol:42:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:48:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    ^
Spanning multiple lines.
HumanStandardToken.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function HumanStandardToken(
    ^
Spanning multiple lines.
HumanStandardToken.sol:47:5: Warning: No visibility specified. Defaulting to "public".
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    ^
Spanning multiple lines.
Share.sol:114:5: Warning: No visibility specified. Defaulting to "public".
    function lockedBalanceOf(
    ^
Spanning multiple lines.
HumanStandardToken.sol:54:46: Warning: "sha3" has been deprecated in favour of "keccak256"
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
                                             ^----------------------------------------------------^
Compiling ---------- referral/TieredPayoff.sol ----------
referral/TieredPayoff.sol:62:9: Warning: Variable is declared as a storage pointer. Use an explicit "storage" keyword to silence this warning.
        Referral.Node node = self.nodes[_referrer];
        ^----------------^
Compiling ---------- Vesting.sol ----------
Token.sol:20:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance);
    ^--------------------------------------------------------------------^
Token.sol:26:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success);
    ^--------------------------------------------------------------------^
Token.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    ^---------------------------------------------------------------------------------------^
Token.sol:39:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success);
    ^------------------------------------------------------------------------^
Token.sol:44:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    ^----------------------------------------------------------------------------------------^
Compiling ---------- VyralSale.sol ----------
Token.sol:20:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance);
    ^--------------------------------------------------------------------^
Token.sol:26:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success);
    ^--------------------------------------------------------------------^
Token.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    ^---------------------------------------------------------------------------------------^
Token.sol:39:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success);
    ^------------------------------------------------------------------------^
Token.sol:44:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    ^----------------------------------------------------------------------------------------^
StandardToken.sol:15:5: Warning: No visibility specified. Defaulting to "public".
    function transfer(address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:27:5: Warning: No visibility specified. Defaulting to "public".
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:38:5: Warning: No visibility specified. Defaulting to "public".
    function balanceOf(address _owner) constant returns (uint256 balance) {
    ^
Spanning multiple lines.
StandardToken.sol:42:5: Warning: No visibility specified. Defaulting to "public".
    function approve(address _spender, uint256 _value) returns (bool success) {
    ^
Spanning multiple lines.
StandardToken.sol:48:5: Warning: No visibility specified. Defaulting to "public".
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    ^
Spanning multiple lines.
HumanStandardToken.sol:33:5: Warning: No visibility specified. Defaulting to "public".
    function HumanStandardToken(
    ^
Spanning multiple lines.
HumanStandardToken.sol:47:5: Warning: No visibility specified. Defaulting to "public".
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    ^
Spanning multiple lines.
Share.sol:114:5: Warning: No visibility specified. Defaulting to "public".
    function lockedBalanceOf(
    ^
Spanning multiple lines.
api.sol:6:9: Warning: No visibility specified. Defaulting to "public".
        function isLeapYear(uint16 year) constant returns (bool);
        ^-------------------------------------------------------^
api.sol:7:9: Warning: No visibility specified. Defaulting to "public".
        function getYear(uint timestamp) constant returns (uint16);
        ^---------------------------------------------------------^
api.sol:8:9: Warning: No visibility specified. Defaulting to "public".
        function getMonth(uint timestamp) constant returns (uint8);
        ^---------------------------------------------------------^
api.sol:9:9: Warning: No visibility specified. Defaulting to "public".
        function getDay(uint timestamp) constant returns (uint8);
        ^-------------------------------------------------------^
api.sol:10:9: Warning: No visibility specified. Defaulting to "public".
        function getHour(uint timestamp) constant returns (uint8);
        ^--------------------------------------------------------^
api.sol:11:9: Warning: No visibility specified. Defaulting to "public".
        function getMinute(uint timestamp) constant returns (uint8);
        ^----------------------------------------------------------^
api.sol:12:9: Warning: No visibility specified. Defaulting to "public".
        function getSecond(uint timestamp) constant returns (uint8);
        ^----------------------------------------------------------^
api.sol:13:9: Warning: No visibility specified. Defaulting to "public".
        function getWeekday(uint timestamp) constant returns (uint8);
        ^-----------------------------------------------------------^
api.sol:14:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp);
        ^------------------------------------------------------------------------------------------^
api.sol:15:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) constant returns (uint timestamp);
        ^------------------------------------------------------------------------------------------------------^
api.sol:16:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp);
        ^--------------------------------------------------------------------------------------------------------------------^
api.sol:17:9: Warning: No visibility specified. Defaulting to "public".
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp);
        ^----------------------------------------------------------------------------------------------------------------------------------^
api.sol:1:1: Warning: Source file does not specify required compiler version!Consider adding "pragma solidity ^0.4.18
contract DateTimeAPI {
^
Spanning multiple lines.
referral/TieredPayoff.sol:62:9: Warning: Variable is declared as a storage pointer. Use an explicit "storage" keyword to silence this warning.
        Referral.Node node = self.nodes[_referrer];
        ^----------------^
HumanStandardToken.sol:54:46: Warning: "sha3" has been deprecated in favour of "keccak256"
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
                                             ^----------------------------------------------------^
VyralSale.sol:82:33: Warning: Initial value for constant variable has to be compile-time constant. This will fail to compile with the next breaking version change.
    uint public constant TEAM = TOTAL_SUPPLY.div(7);
                                ^-----------------^
VyralSale.sol:84:37: Warning: Initial value for constant variable has to be compile-time constant. This will fail to compile with the next breaking version change.
    uint public constant PARTNERS = TOTAL_SUPPLY.div(7);
                                    ^-----------------^
VyralSale.sol:86:42: Warning: Initial value for constant variable has to be compile-time constant. This will fail to compile with the next breaking version change.
    uint public constant VYRAL_REWARDS = TOTAL_SUPPLY.div(7).mul(2);
                                         ^------------------------^
VyralSale.sol:88:44: Warning: Initial value for constant variable has to be compile-time constant. This will fail to compile with the next breaking version change.
    uint public constant SALE_ALLOCATION = TOTAL_SUPPLY.div(7).mul(3);
                                           ^------------------------^
```

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Vyral Network - Jan 18 2017. The MIT Licence.