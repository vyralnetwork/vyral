let Ownable  = artifacts.require("./Ownable.sol");

let Reward       = artifacts.require("./rewards/Reward.sol");
let TieredPayoff = artifacts.require("./rewards/TieredPayoff.sol");

let ReferralTree = artifacts.require("./ReferralTree.sol");
let Campaign     = artifacts.require("./Campaign.sol");
let Share        = artifacts.require("./Share.sol");
let VyralSale    = artifacts.require("./VyralSale.sol");


module.exports = function(deployer) {
    // deployer.deploy(Lockable);
    deployer.deploy(Ownable);
    // deployer.deploy(Stoppable);

    deployer.deploy(Reward);
    deployer.deploy(TieredPayoff);

    deployer.link(Reward, ReferralTree);
    deployer.deploy(ReferralTree);

    deployer.link(Reward, Campaign);
    deployer.link(ReferralTree, Campaign);
    deployer.deploy(Campaign);

    deployer.deploy(Share);

    deployer.link(Ownable, VyralSale);
    deployer.link(ReferralTree, VyralSale);
    deployer.deploy(VyralSale);
};
