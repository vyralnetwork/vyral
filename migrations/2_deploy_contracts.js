let Vyral        = artifacts.require("./Vyral.sol");
let Campaign     = artifacts.require("./Campaign.sol");
let ReferralTree = artifacts.require("./ReferralTree.sol");

let Reward           = artifacts.require("./rewards/Reward.sol");
let RewardAllocation = artifacts.require("./rewards/RewardAllocation.sol");
let DirectPayoff     = artifacts.require("./rewards/DirectPayoff.sol");
let GeometricPayoff  = artifacts.require("./rewards/GeometricPayoff.sol");
let ShapleyPayoff    = artifacts.require("./rewards/ShapleyPayoff.sol");


module.exports = function(deployer) {
    deployer.deploy(Vyral);
    deployer.deploy(Campaign);
    deployer.deploy(ReferralTree);

    deployer.deploy(Reward);
    deployer.deploy(RewardAllocation);
    deployer.deploy(DirectPayoff);
    deployer.deploy(GeometricPayoff);
    deployer.deploy(ShapleyPayoff);
};
