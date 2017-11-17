const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const Ownable = artifacts.require("./Ownable.sol");

const Reward       = artifacts.require("./rewards/Reward.sol");
const TieredPayoff = artifacts.require("./rewards/TieredPayoff.sol");

const ReferralTree = artifacts.require("./ReferralTree.sol");
const Campaign     = artifacts.require("./Campaign.sol");
const VyralSale    = artifacts.require("./VyralSale.sol");

const config = require("../config");

module.exports = function(deployer) {
    deployer.deploy(MultiSigWallet,
    config.get("wallet:owners"),
    config.get("wallet:required"))
    .then(() => {
        return deployer.deploy([Ownable, Reward, TieredPayoff]);
    })
    .then(() => {
        deployer.link(Reward, ReferralTree);
        return deployer.deploy(ReferralTree);
    })
    .then(() => {
        deployer.link(Reward, Campaign);
        deployer.link(ReferralTree, Campaign);
        return deployer.deploy(Campaign);
    })
    .then(() => {
        deployer.link(Ownable, VyralSale);
        deployer.link(TieredPayoff, VyralSale);
        deployer.link(ReferralTree, VyralSale);

        deployer.deploy(VyralSale,
        config.get("crowdsale:owner"),
        MultiSigWallet.address,
        config.get("crowdsale:team"),
        config.get("crowdsale:partnerships"));
    });
};