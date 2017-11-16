const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const Ownable = artifacts.require("./Ownable.sol");

const Reward       = artifacts.require("./rewards/Reward.sol");
const TieredPayoff = artifacts.require("./rewards/TieredPayoff.sol");

const ReferralTree = artifacts.require("./ReferralTree.sol");
const Campaign     = artifacts.require("./Campaign.sol");
const VyralSale    = artifacts.require("./VyralSale.sol");


module.exports = function(deployer) {
    // deployer.deploy(MultiSigWallet);

    deployer.deploy(Ownable);

    deployer.deploy(Reward);
    deployer.deploy(TieredPayoff);

    deployer.link(Reward, ReferralTree);
    deployer.deploy(ReferralTree);

    deployer.link(Reward, Campaign);
    deployer.link(ReferralTree, Campaign);
    deployer.deploy(Campaign);

    deployer.link(Ownable, VyralSale);
    deployer.link(TieredPayoff, VyralSale);
    deployer.link(ReferralTree, VyralSale);
    deployer.deploy(VyralSale);
};
