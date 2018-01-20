#!/bin/sh

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"

loadScript("deploymentDataMainnet.js");

console.log("RESULT: ---------- CROWDSALE ----------");
console.log("RESULT: ");

console.log("vyralSaleAddress: " + vyralSaleAddress);
var crowdsale = eth.contract(vyralSaleAbi).at(vyralSaleAddress);
console.log("RESULT: crowdsale.owner()=" + crowdsale.owner());
console.log("RESULT: crowdsale.MIN_CONTRIBUTION=" + crowdsale.MIN_CONTRIBUTION() + " " + crowdsale.MIN_CONTRIBUTION().shift(-18) + " ETH");
console.log("RESULT: crowdsale.phase=" + crowdsale.phase());

console.log("RESULT: crowdsale.presaleStartTimestamp=" + crowdsale.presaleStartTimestamp() + " " + new Date(crowdsale.presaleStartTimestamp() * 1000).toUTCString());
console.log("RESULT: crowdsale.presaleEndTimestamp=" + crowdsale.presaleEndTimestamp() + " " + new Date(crowdsale.presaleEndTimestamp() * 1000).toUTCString());
console.log("RESULT: crowdsale.presaleRate=" + crowdsale.presaleRate());
console.log("RESULT: crowdsale.presaleCap=" + crowdsale.presaleCap() + " " + crowdsale.presaleCap().shift(-18));
console.log("RESULT: crowdsale.presaleCapReached=" + crowdsale.presaleCapReached());
console.log("RESULT: crowdsale.soldPresale=" + crowdsale.soldPresale() + " " + crowdsale.soldPresale().shift(-18));

console.log("RESULT: crowdsale.saleStartTimestamp=" + crowdsale.saleStartTimestamp() + " " + new Date(crowdsale.saleStartTimestamp() * 1000).toUTCString());
console.log("RESULT: crowdsale.saleEndTimestamp=" + crowdsale.saleEndTimestamp() + " " + new Date(crowdsale.saleEndTimestamp() * 1000).toUTCString());
console.log("RESULT: crowdsale.saleRate=" + crowdsale.saleRate());
console.log("RESULT: crowdsale.saleCap=" + crowdsale.saleCap());
console.log("RESULT: crowdsale.saleCapReached=" + crowdsale.saleCapReached());
console.log("RESULT: crowdsale.soldSale=" + crowdsale.soldSale());

console.log("RESULT: crowdsale.wallet=" + crowdsale.wallet());
console.log("RESULT: crowdsale.vestingWallet=" + crowdsale.vestingWallet());
console.log("RESULT: crowdsale.shareToken=" + crowdsale.shareToken());
console.log("RESULT: crowdsale.campaign=" + crowdsale.campaign());
console.log("RESULT: crowdsale.dateTime=" + crowdsale.dateTime());
console.log("RESULT: crowdsale.vestingRegistered=" + crowdsale.vestingRegistered());

console.log("RESULT: crowdsale.TOTAL_SUPPLY=" + crowdsale.TOTAL_SUPPLY().shift(-18));
console.log("RESULT: crowdsale.TEAM=" + crowdsale.TEAM().shift(-18));
console.log("RESULT: crowdsale.PARTNERS=" + crowdsale.PARTNERS().shift(-18));
console.log("RESULT: crowdsale.VYRAL_REWARDS=" + crowdsale.VYRAL_REWARDS().shift(-18));
console.log("RESULT: crowdsale.SALE_ALLOCATION=" + crowdsale.SALE_ALLOCATION().shift(-18));
console.log("RESULT: crowdsale.vestingRegistered=" + crowdsale.vestingRegistered());

var i;

var logContributionEvents = crowdsale.LogContribution({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
logContributionEvents.watch(function (error, result) {
  console.log("RESULT: LogContribution " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
logContributionEvents.stopWatching();

var logReferralEvents = crowdsale.LogReferral({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
logReferralEvents.watch(function (error, result) {
  console.log("RESULT: LogReferral " + i++ + " #" + result.blockNumber + " referrer=" + result.args.referrer +
    " invitee=" + result.args.invitee +
    " referralReward=" + result.args.referralReward.shift(-18) +
    " txHash=" + result.transactionHash);
});
logReferralEvents.stopWatching();

console.log("RESULT: ");
console.log("RESULT: ---------- CAMPAIGN ----------");
console.log("RESULT: ");

console.log("campaignAddress: " + campaignAddress);
var campaign = eth.contract(campaignAbi).at(campaignAddress);

console.log("RESULT: campaign.owner()=" + campaign.owner());
console.log("RESULT: campaign.token()=" + campaign.token());
console.log("RESULT: campaign.budget=" + campaign.budget() + " " + campaign.budget().shift(-18));
console.log("RESULT: campaign.cost=" + campaign.cost() + " " + campaign.cost().shift(-18));

var ownershipTransferredEvents = campaign.OwnershipTransferred({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
ownershipTransferredEvents.watch(function (error, result) {
  console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
ownershipTransferredEvents.stopWatching();

var logCampaignCreatedEvents = campaign.LogCampaignCreated({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
logCampaignCreatedEvents.watch(function (error, result) {
  console.log("RESULT: LogCampaignCreated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
logCampaignCreatedEvents.stopWatching();

var logRewardAllocatedEvents = campaign.LogRewardAllocated({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
logRewardAllocatedEvents.watch(function (error, result) {
  console.log("RESULT: LogRewardAllocated " + i++ + " #" + result.blockNumber + " referrer=" + result.args.referrer +
    " inviteeShares=" + result.args.inviteeShares.shift(-18) +
    " referralReward=" + result.args.referralReward.shift(-18) +
    " txHash=" + result.transactionHash);
});
logRewardAllocatedEvents.stopWatching();


EOF