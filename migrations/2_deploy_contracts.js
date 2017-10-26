let Lockable  = artifacts.require("./Lockable.sol");
let Ownable   = artifacts.require("./Ownable.sol");
let Stoppable = artifacts.require("./Stoppable.sol");

let Reward           = artifacts.require("./rewards/Reward.sol");
let RewardAllocation = artifacts.require("./rewards/RewardAllocation.sol");
let DirectPayoff     = artifacts.require("./rewards/DirectPayoff.sol");
let GeometricPayoff  = artifacts.require("./rewards/GeometricPayoff.sol");
let ShapleyPayoff    = artifacts.require("./rewards/ShapleyPayoff.sol");

let ReferralTree = artifacts.require("./ReferralTree.sol");
let Campaign     = artifacts.require("./Campaign.sol");
let Vyral        = artifacts.require("./Vyral.sol");


module.exports = function(deployer) {
    deployer.deploy(Lockable);
    deployer.deploy(Ownable);
    deployer.deploy(Stoppable);

    deployer.deploy(Reward);
    deployer.deploy(RewardAllocation);
    deployer.deploy(DirectPayoff);
    deployer.deploy(GeometricPayoff);
    deployer.deploy(ShapleyPayoff);

    deployer.link(Reward, ReferralTree);
    deployer.deploy(ReferralTree);

    // FIXME: Campaign can't be deployed
    // deployer.link(Stoppable, Campaign);
    deployer.link(Reward, Campaign);
    // deployer.link(RewardPayoffStrategy, Campaign);
    deployer.link(ReferralTree, Campaign);
    deployer.deploy(Campaign);

    deployer.link(Ownable, Vyral);
    deployer.link(ReferralTree, Vyral);
    deployer.deploy(Vyral);
};
