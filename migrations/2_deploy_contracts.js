const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const SafeMath = artifacts.require("./math/SafeMath.sol");
const Ownable  = artifacts.require("./traits/Ownable.sol");

const Referral = artifacts.require("./referral/Referral.sol");
const TieredPayoff = artifacts.require("./referral/TieredPayoff.sol");

const Campaign  = artifacts.require("./Campaign.sol");
const VyralSale = artifacts.require("./VyralSale.sol");

const config = require("../config");

module.exports = function(deployer) {
    deployer.deploy(MultiSigWallet,
    config.get("wallet:owners"),
    config.get("wallet:required"))
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

        // console.log([
        // MultiSigWallet.address,
        // config.get("crowdsale:team"),
        // config.get("crowdsale:partnerships"),
        // config.get("crowdsale:period:first:startTime"),
        // config.get("crowdsale:period:second:startTime")
        // ]);

        return deployer.deploy(VyralSale,
        MultiSigWallet.address,
        config.get("crowdsale:team"),
        config.get("crowdsale:partnerships"),
        config.get("crowdsale:period:first:startTime"),
        config.get("crowdsale:period:second:startTime")
        );
    })
    .catch((err) => {
        console.error("Deployment failed", err);
    })
};