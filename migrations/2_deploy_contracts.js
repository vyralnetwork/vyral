const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const SafeMath = artifacts.require("./math/SafeMath.sol");
const Ownable  = artifacts.require("./traits/Ownable.sol");

const Referral     = artifacts.require("./referral/Referral.sol");
const TieredPayoff = artifacts.require("./referral/TieredPayoff.sol");

const Share     = artifacts.require("./Share.sol");
const Vesting   = artifacts.require("./Vesting.sol");
const Campaign  = artifacts.require("./Campaign.sol");
const VyralSale = artifacts.require("./VyralSale.sol");

const config = require("../config");

module.exports = function(deployer) {
    deployer.deploy(MultiSigWallet,
    config.get("wallet:owners"),
    config.get("wallet:required"))
    .then(() => {
        return deployer.deploy(Share);
    })
    .then(() => {
        return deployer.deploy(Vesting, Share.address);
    })
    .then(() => {
        return deployer.deploy([SafeMath, Ownable]);
    })
    .then(() => {
        return deployer.deploy(Referral);
    })
    .then(() => {
        return deployer.deploy(TieredPayoff);
    })
    .then(() => {
        deployer.link(Ownable, VyralSale);
        deployer.link(TieredPayoff, VyralSale);
        deployer.link(Referral, VyralSale);

        return deployer.deploy(VyralSale);
    })
    // .then((vyralSale) => {
    //     return vyralSale.initialize(Vesting.address,
    //     config.get("presale:startTime"),
    //     config.get("presale:endTime"),
    //     web3.toWei(config.get("presale:cap")),
    //     config.get("rate"));
    // })
    // .then(() => {
    //     return Share.deployed();
    // })
    // .then((share) => {
    //     return share.addTransferrer(VyralSale.address);
    // })
    .catch((err) => {
        console.error("Deployment failed", err);
    })
};