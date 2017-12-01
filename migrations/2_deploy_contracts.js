const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const DateTime = artifacts.require("../lib/ethereum-datetime/contracts/DateTime.sol");

const SafeMath = artifacts.require("./math/SafeMath.sol");
const Ownable  = artifacts.require("./traits/Ownable.sol");

const Referral     = artifacts.require("./referral/Referral.sol");
const TieredPayoff = artifacts.require("./referral/TieredPayoff.sol");

const Share          = artifacts.require("./Share.sol");
const Vesting        = artifacts.require("./Vesting.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const PresaleBonuses = artifacts.require("./PresaleBonuses.sol");

const config = require("../config");
const fs     = require("fs");

let saleInstance, shareInstance, campaignAddress;

module.exports = function test(deployer) {
    deployer.deploy(MultiSigWallet,
    config.get("wallet:owners"),
    config.get("wallet:required"))
    .then(() => {
        return deployer.deploy([SafeMath, Ownable]);
    })
    .then(() => {
        return deployer.deploy(Share);
    })
    .then(() => {
        return deployer.deploy(Vesting, Share.address);
    })
    .then(() => {
        return deployer.deploy(DateTime);
    })
    .then(() => {
        return deployer.deploy(Referral);
    })
    .then(() => {
        return deployer.deploy(TieredPayoff);
    })
    .then(() => {
        return deployer.deploy(PresaleBonuses);
    })
    .then(() => {
        deployer.link(Ownable, VyralSale);
        deployer.link(TieredPayoff, VyralSale);
        deployer.link(Referral, VyralSale);
        deployer.link(PresaleBonuses, VyralSale);

        return deployer.deploy(VyralSale,
        Share.address,
        Vesting.address,
        DateTime.address);
    })
    .then(() => {
        return Share.deployed();
    })
    .then((share) => {
        shareInstance = share;
        return Promise.all([
            share.addTransferrer(Share.address),
            share.addTransferrer(VyralSale.address),
            share.addTransferrer(Vesting.address),
        ]);
    })
    .then(() => {
        return VyralSale.deployed()
    })
    .then((vyralSale) => {
        saleInstance = vyralSale;

        console.log("Sale deployed with these arguments",
        MultiSigWallet.address,
        config.get("presale:startTime"),
        config.get("presale:endTime"),
        web3.toWei(config.get("presale:cap")),
        config.get("rate"));

        return vyralSale.TOTAL_SUPPLY.call();
    })
    .then((totalSupply) => {
        // console.log(totalSupply.toNumber())
        return shareInstance.transfer(saleInstance.address, totalSupply.toNumber());
    })
    .then((txs) => {
        // console.log(txs)
        return saleInstance.initPresale(
        MultiSigWallet.address,
        config.get("presale:startTime"),
        config.get("presale:endTime"),
        web3.toWei(config.get("presale:cap")),
        config.get("rate"));
    })
    .then((txs) => {
        // console.log(txs);
        return saleInstance.campaign.call();
    })
    .then((campaignAddr) => {
        campaignAddress = campaignAddr;
        return Promise.all([
            shareInstance.addTransferrer(campaignAddr)
        ]);
    })
    .then((txs) => {
        fs.writeFileSync('contracts.txt', `LIST OF CONTRACTS
${"-".repeat(30)}
Campaign:      ${campaignAddress}
DateTime:      ${DateTime.address}
MultiSig:      ${MultiSigWallet.address}
PresaleBonuses:${PresaleBonuses.address}
Referral:      ${Referral.address}
SafeMath:      ${SafeMath.address}
Share:         ${Share.address}
TieredPayoff:  ${TieredPayoff.address}
Vesting:       ${Vesting.address}
VyralSale:     ${VyralSale.address}
        `);
    })
    .catch((err) => {
        console.error("Deployment failed", err);
    })
};