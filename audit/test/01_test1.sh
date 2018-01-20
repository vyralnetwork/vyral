#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

CAMPAIGNSOL=`grep ^CAMPAIGNSOL= settings.txt | sed "s/^.*=//"`
CAMPAIGNJS=`grep ^CAMPAIGNJS= settings.txt | sed "s/^.*=//"`
DATETIMESOL=`grep ^DATETIMESOL= settings.txt | sed "s/^.*=//"`
DATETIMEJS=`grep ^DATETIMEJS= settings.txt | sed "s/^.*=//"`
PRESALEBONUSESSOL=`grep ^PRESALEBONUSESSOL= settings.txt | sed "s/^.*=//"`
PRESALEBONUSESJS=`grep ^PRESALEBONUSESJS= settings.txt | sed "s/^.*=//"`
REFERRALSOL=`grep ^REFERRALSOL= settings.txt | sed "s/^.*=//"`
REFERRALJS=`grep ^REFERRALJS= settings.txt | sed "s/^.*=//"`
SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHJS=`grep ^SAFEMATHJS= settings.txt | sed "s/^.*=//"`
SHARESOL=`grep ^SHARESOL= settings.txt | sed "s/^.*=//"`
SHAREJS=`grep ^SHAREJS= settings.txt | sed "s/^.*=//"`
TIEREDPAYOFFSOL=`grep ^TIEREDPAYOFFSOL= settings.txt | sed "s/^.*=//"`
TIEREDPAYOFFJS=`grep ^TIEREDPAYOFFJS= settings.txt | sed "s/^.*=//"`
VESTINGSOL=`grep ^VESTINGSOL= settings.txt | sed "s/^.*=//"`
VESTINGJS=`grep ^VESTINGJS= settings.txt | sed "s/^.*=//"`
VYRALSALESOL=`grep ^VYRALSALESOL= settings.txt | sed "s/^.*=//"`
VYRALSALEJS=`grep ^VYRALSALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

PRESALE_START_DATE=`echo "$CURRENTTIME+90" | bc`
PRESALE_START_DATE_S=`date -r $PRESALE_START_DATE -u`
PRESALE_END_DATE=`echo "$CURRENTTIME+150" | bc`
PRESALE_END_DATE_S=`date -r $PRESALE_END_DATE -u`
START_DATE=`echo "$CURRENTTIME+155" | bc`
START_DATE_S=`date -r $START_DATE -u`
END_DATE=`echo "$CURRENTTIME+210" | bc`
END_DATE_S=`date -r $END_DATE -u`

printf "MODE               = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT    = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD           = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR          = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "CAMPAIGNSOL        = '$CAMPAIGNSOL'\n" | tee -a $TEST1OUTPUT
printf "CAMPAIGNJS         = '$CAMPAIGNJS'\n" | tee -a $TEST1OUTPUT
printf "DATETIMESOL        = '$DATETIMESOL'\n" | tee -a $TEST1OUTPUT
printf "DATETIMEJS         = '$DATETIMEJS'\n" | tee -a $TEST1OUTPUT
printf "PRESALEBONUSESSOL  = '$PRESALEBONUSESSOL'\n" | tee -a $TEST1OUTPUT
printf "PRESALEBONUSESJS   = '$PRESALEBONUSESJS'\n" | tee -a $TEST1OUTPUT
printf "REFERRALSOL        = '$REFERRALSOL'\n" | tee -a $TEST1OUTPUT
printf "REFERRALJS         = '$REFERRALJS'\n" | tee -a $TEST1OUTPUT
printf "SAFEMATHSOL        = '$SAFEMATHSOL'\n" | tee -a $TEST1OUTPUT
printf "SAFEMATHJS         = '$SAFEMATHJS'\n" | tee -a $TEST1OUTPUT
printf "SHARESOL           = '$SHARESOL'\n" | tee -a $TEST1OUTPUT
printf "SHAREJS            = '$SHAREJS'\n" | tee -a $TEST1OUTPUT
printf "TIEREDPAYOFFSOL    = '$TIEREDPAYOFFSOL'\n" | tee -a $TEST1OUTPUT
printf "TIEREDPAYOFFJS     = '$TIEREDPAYOFFJS'\n" | tee -a $TEST1OUTPUT
printf "VESTINGSOL         = '$VESTINGSOL'\n" | tee -a $TEST1OUTPUT
printf "VESTINGJS          = '$VESTINGJS'\n" | tee -a $TEST1OUTPUT
printf "VYRALSALESOL       = '$VYRALSALESOL'\n" | tee -a $TEST1OUTPUT
printf "VYRALSALEJS        = '$VYRALSALEJS'\n" | tee -a $TEST1OUTPUT
printf "DEPLOYMENTDATA     = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS          = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT        = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS       = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME        = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "PRESALE_START_DATE = '$PRESALE_START_DATE' '$PRESALE_START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "PRESALE_END_DATE   = '$PRESALE_END_DATE' '$PRESALE_END_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "START_DATE         = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT
printf "END_DATE           = '$END_DATE' '$END_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp -rp $SOURCEDIR/* .`
`cp -rp ../ethereum-datetime-contracts/* .`
`cp -rp ../../installed_contracts/tokens/contracts/HumanStandardToken.sol .`
`cp -rp ../../installed_contracts/tokens/contracts/StandardToken.sol .`
`cp -rp ../../installed_contracts/tokens/contracts/Token.sol .`
`cp -rp modifiedContracts/PresaleBonuses.sol .`
`cp -rp modifiedContracts/TieredPayoff.sol ./referral/`
`cp -rp modifiedContracts/Campaign.sol .`

# --- Modify parameters ---
`perl -pi -e "s/installed_contracts\/tokens\/contracts\//\.\//" *.sol`
`perl -pi -e "s/\.\.\/lib\/ethereum-datetime\/contracts\//\.\//" *.sol`
`perl -pi -e "s/contracts\/math\//math\//" *.sol`
`perl -pi -e "s/contracts\/traits\//traits\//" *.sol`
`perl -pi -e "s/bool isTransferable \= false;/bool public isTransferable \= false;/" $SHARESOL`
`perl -pi -e "s/bool isBonusLocked \= true;/bool public isBonusLocked \= true;/" $SHARESOL`
#`perl -pi -e "s/revert\(\);/return applyPercentage\(_purchased\, 0\);/" $PRESALEBONUSESSOL`
#`perl -pi -e "s/Referral\.Tree vyralTree;/Referral\.Tree public vyralTree;/" $CAMPAIGNSOL`


for FILE in Campaign.sol PresaleBonuses.sol Share.sol Vesting.sol VyralSale.sol
do
  DIFFS1=`diff $SOURCEDIR/$FILE $FILE`
  echo "--- Differences $SOURCEDIR/$FILE $FILE ---" | tee -a $TEST1OUTPUT
  echo "$DIFFS1" | tee -a $TEST1OUTPUT
done


solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "Compiling ---------- $CAMPAIGNSOL ----------"
echo "var campaignOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $CAMPAIGNSOL`;" > $CAMPAIGNJS
echo "Compiling ---------- $DATETIMESOL ----------"
echo "var dateTimeOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $DATETIMESOL`;" > $DATETIMEJS
echo "Compiling ---------- $PRESALEBONUSESSOL ----------"
echo "var presaleBonusesOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $PRESALEBONUSESSOL`;" > $PRESALEBONUSESJS
echo "Compiling ---------- referral/$REFERRALSOL ----------"
echo "var referralOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface referral/$REFERRALSOL`;" > $REFERRALJS
echo "Compiling ---------- $SAFEMATHSOL ----------"
echo "var safeMathOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface math/$SAFEMATHSOL`;" > $SAFEMATHJS
echo "Compiling ---------- $SHARESOL ----------"
echo "var shareOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $SHARESOL`;" > $SHAREJS
echo "Compiling ---------- referral/$TIEREDPAYOFFSOL ----------"
echo "var tieredPayoffOutput=`solc_0.4.18 --allow-paths . --optimize --pretty-json --combined-json abi,bin,interface referral/$TIEREDPAYOFFSOL`;" > $TIEREDPAYOFFJS
echo "Compiling ---------- $VESTINGSOL ----------"
echo "var vestingOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VESTINGSOL`;" > $VESTINGJS
echo "Compiling ---------- $VYRALSALESOL ----------"
echo "var vyralSaleOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $VYRALSALESOL`;" > $VYRALSALEJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$CAMPAIGNJS");
loadScript("$DATETIMEJS");
loadScript("$PRESALEBONUSESJS");
loadScript("$REFERRALJS");
loadScript("$SAFEMATHJS");
loadScript("$SHAREJS");
loadScript("$TIEREDPAYOFFJS");
loadScript("$VESTINGJS");
loadScript("$VYRALSALEJS");
loadScript("functions.js");

var campaignAbi = JSON.parse(campaignOutput.contracts["$CAMPAIGNSOL:Campaign"].abi);
var campaignBin = "0x" + campaignOutput.contracts["$CAMPAIGNSOL:Campaign"].bin;
var dateTimeAbi = JSON.parse(dateTimeOutput.contracts["$DATETIMESOL:DateTime"].abi);
var dateTimeBin = "0x" + dateTimeOutput.contracts["$DATETIMESOL:DateTime"].bin;
var presaleBonusesAbi = JSON.parse(presaleBonusesOutput.contracts["$PRESALEBONUSESSOL:PresaleBonuses"].abi);
var presaleBonusesBin = "0x" + presaleBonusesOutput.contracts["$PRESALEBONUSESSOL:PresaleBonuses"].bin;
var referralAbi = JSON.parse(referralOutput.contracts["referral/$REFERRALSOL:Referral"].abi);
var referralBin = "0x" + referralOutput.contracts["referral/$REFERRALSOL:Referral"].bin;
var safeMathAbi = JSON.parse(safeMathOutput.contracts["math/$SAFEMATHSOL:SafeMath"].abi);
var safeMathBin = "0x" + safeMathOutput.contracts["math/$SAFEMATHSOL:SafeMath"].bin;
var shareAbi = JSON.parse(shareOutput.contracts["$SHARESOL:Share"].abi);
var shareBin = "0x" + shareOutput.contracts["$SHARESOL:Share"].bin;
var tieredPayoffAbi = JSON.parse(tieredPayoffOutput.contracts["referral/$TIEREDPAYOFFSOL:TieredPayoff"].abi);
var tieredPayoffBin = "0x" + tieredPayoffOutput.contracts["referral/$TIEREDPAYOFFSOL:TieredPayoff"].bin;
var vestingAbi = JSON.parse(vestingOutput.contracts["$VESTINGSOL:Vesting"].abi);
var vestingBin = "0x" + vestingOutput.contracts["$VESTINGSOL:Vesting"].bin;
var vyralSaleAbi = JSON.parse(vyralSaleOutput.contracts["$VYRALSALESOL:VyralSale"].abi);
var vyralSaleBin = "0x" + vyralSaleOutput.contracts["$VYRALSALESOL:VyralSale"].bin;

// console.log("DATA: campaignAbi=" + JSON.stringify(campaignAbi));
// console.log("DATA: campaignBin=" + JSON.stringify(campaignBin));
// console.log("DATA: dateTimeAbi=" + JSON.stringify(dateTimeAbi));
// console.log("DATA: dateTimeBin=" + JSON.stringify(dateTimeBin));
// console.log("DATA: presaleBonusesAbi=" + JSON.stringify(presaleBonusesAbi));
// console.log("DATA: presaleBonusesBin=" + JSON.stringify(presaleBonusesBin));
// console.log("DATA: referralAbi=" + JSON.stringify(referralAbi));
// console.log("DATA: referralBin=" + JSON.stringify(referralBin));
// console.log("DATA: safeMathAbi=" + JSON.stringify(safeMathAbi));
// console.log("DATA: safeMathBin=" + JSON.stringify(safeMathBin));
// console.log("DATA: shareAbi=" + JSON.stringify(shareAbi));
// console.log("DATA: shareBin=" + JSON.stringify(shareBin));
// console.log("DATA: tieredPayoffAbi=" + JSON.stringify(tieredPayoffAbi));
// console.log("DATA: tieredPayoffBin=" + JSON.stringify(tieredPayoffBin));
// console.log("DATA: vestingAbi=" + JSON.stringify(vestingAbi));
// console.log("DATA: vestingBin=" + JSON.stringify(vestingBin));
// console.log("DATA: vyralSaleAbi=" + JSON.stringify(vyralSaleAbi));
// console.log("DATA: vyralSaleBin=" + JSON.stringify(vyralSaleBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deploy1_Message = "Deploy Contracts #1";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + deploy1_Message + " ---");
var safeMathContract = web3.eth.contract(safeMathAbi);
// console.log(JSON.stringify(safeMathContract));
var safeMathTx = null;
var safeMathAddress = null;
var safeMath = safeMathContract.new({from: contractOwnerAccount, data: safeMathBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        safeMathTx = contract.transactionHash;
      } else {
        safeMathAddress = contract.address;
        addAccount(safeMathAddress, "SafeMath");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: safeMathAddress=" + safeMathAddress);
      }
    }
  }
);
var dateTimeContract = web3.eth.contract(dateTimeAbi);
// console.log(JSON.stringify(dateTimeContract));
var dateTimeTx = null;
var dateTimeAddress = null;
var dateTime = dateTimeContract.new({from: contractOwnerAccount, data: dateTimeBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        dateTimeTx = contract.transactionHash;
      } else {
        dateTimeAddress = contract.address;
        addAccount(dateTimeAddress, "DateTime");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: dateTimeAddress=" + dateTimeAddress);
      }
    }
  }
);
var presaleBonusesContract = web3.eth.contract(presaleBonusesAbi);
// console.log(JSON.stringify(presaleBonusesContract));
var presaleBonusesTx = null;
var presaleBonusesAddress = null;
var presaleBonuses = presaleBonusesContract.new({from: contractOwnerAccount, data: presaleBonusesBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        presaleBonusesTx = contract.transactionHash;
      } else {
        presaleBonusesAddress = contract.address;
        addAccount(presaleBonusesAddress, "PresaleBonuses");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: presaleBonusesAddress=" + presaleBonusesAddress);
      }
    }
  }
);
var referralContract = web3.eth.contract(referralAbi);
// console.log(JSON.stringify(referralContract));
var referralTx = null;
var referralAddress = null;
var referral = referralContract.new({from: contractOwnerAccount, data: referralBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        referralTx = contract.transactionHash;
      } else {
        referralAddress = contract.address;
        addAccount(referralAddress, "Referral");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: referralAddress=" + referralAddress);
      }
    }
  }
);
var shareContract = web3.eth.contract(shareAbi);
// console.log(JSON.stringify(shareContract));
var shareTx = null;
var shareAddress = null;
var share = shareContract.new({from: contractOwnerAccount, data: shareBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        shareTx = contract.transactionHash;
      } else {
        shareAddress = contract.address;
        addAccount(shareAddress, "Share");
        addTokenContractAddressAndAbi(shareAddress, shareAbi);
        console.log("DATA: shareAddress=" + shareAddress);
      }
    }
  }
);
var tieredPayoffContract = web3.eth.contract(tieredPayoffAbi);
// console.log(JSON.stringify(tieredPayoffContract));
var tieredPayoffTx = null;
var tieredPayoffAddress = null;
var tieredPayoff = tieredPayoffContract.new({from: contractOwnerAccount, data: tieredPayoffBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tieredPayoffTx = contract.transactionHash;
      } else {
        tieredPayoffAddress = contract.address;
        addAccount(tieredPayoffAddress, "TieredPayoff");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tieredPayoffAddress=" + tieredPayoffAddress);
      }
    }
  }
);
var vestingContract = web3.eth.contract(vestingAbi);
// console.log(JSON.stringify(vestingContract));
var vestingTx = null;
var vestingAddress = null;
var vesting = vestingContract.new({from: contractOwnerAccount, data: vestingBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vestingTx = contract.transactionHash;
      } else {
        vestingAddress = contract.address;
        addAccount(vestingAddress, "Vesting");
        // addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: vestingAddress=" + vestingAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(safeMathTx, deploy1_Message + " - SafeMath");
printTxData("safeMathAddress=" + safeMathAddress, safeMathTx);
failIfTxStatusError(dateTimeTx, deploy1_Message + " - DateTime");
printTxData("dateTimeAddress=" + dateTimeAddress, dateTimeTx);
failIfTxStatusError(presaleBonusesTx, deploy1_Message + " - PresaleBonuses");
printTxData("presaleBonusesAddress=" + presaleBonusesAddress, presaleBonusesTx);
failIfTxStatusError(referralTx, deploy1_Message + " - Referral");
printTxData("referralAddress=" + referralAddress, referralTx);
failIfTxStatusError(shareTx, deploy1_Message + " - Share");
printTxData("shareAddress=" + shareAddress, shareTx);
failIfTxStatusError(tieredPayoffTx, deploy1_Message + " - TieredPayoff");
printTxData("tieredPayoffAddress=" + tieredPayoffAddress, tieredPayoffTx);
failIfTxStatusError(vestingTx, deploy1_Message + " - Vesting");
printTxData("vestingAddress=" + vestingAddress, vestingTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var deploy2_Message = "Deploy Contracts #2";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + deploy2_Message + " ---");
// console.log("RESULT: old='" + campaignBin + "'");
var newCampaignBin1 = campaignBin.replace(/__referral\/Referral\.sol:Referral________/g, referralAddress.substring(2, 42));
var newCampaignBin2 = newCampaignBin1.replace(/__referral\/TieredPayoff\.sol:TieredPayo__/g, tieredPayoffAddress.substring(2, 42));
// console.log("RESULT: new='" + newCampaignBin2 + "'");
var campaignContract = web3.eth.contract(campaignAbi);
// console.log(JSON.stringify(campaignContract));
var campaignTx = null;
var campaignAddress = null;
// function Campaign(address _token, uint256 _budgetAmount)
var campaign = campaignContract.new(shareAddress, new BigNumber("1000000").shift(18), {from: contractOwnerAccount, data: newCampaignBin2, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        campaignTx = contract.transactionHash;
      } else {
        campaignAddress = contract.address;
        addAccount(campaignAddress, "Campaign");
        addCampaignContractAddressAndAbi(campaignAddress, campaignAbi);
        console.log("DATA: campaignAddress=" + campaignAddress);
      }
    }
  }
);
// console.log("RESULT: old='" + vyralSaleBin + "'");
var newVyralSaleBin1 = vyralSaleBin.replace(/__referral\/Referral\.sol:Referral________/g, referralAddress.substring(2, 42));
var newVyralSaleBin2 = newVyralSaleBin1.replace(/__referral\/TieredPayoff\.sol:TieredPayo__/g, tieredPayoffAddress.substring(2, 42));
// console.log("RESULT: new='" + newVyralSaleBin2 + "'");
var vyralSaleContract = web3.eth.contract(vyralSaleAbi);
// console.log(JSON.stringify(vyralSaleContract));
var vyralSaleTx = null;
var vyralSaleAddress = null;
var vyralSale = vyralSaleContract.new(shareAddress, dateTimeAddress, {from: contractOwnerAccount, data: newVyralSaleBin2, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        vyralSaleTx = contract.transactionHash;
      } else {
        vyralSaleAddress = contract.address;
        addAccount(vyralSaleAddress, "VyralSale");
        addCrowdsaleContractAddressAndAbi(vyralSaleAddress, vyralSaleAbi);
        console.log("DATA: vyralSaleAddress=" + vyralSaleAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(campaignTx, deploy2_Message + " - Campaign");
printTxData("campaignAddress=" + campaignAddress, campaignTx);
failIfTxStatusError(vyralSaleTx, deploy2_Message + " - VyralSale");
printTxData("vyralSaleAddress=" + vyralSaleAddress, vyralSaleTx);
printCrowdsaleContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup1_Message = "Setup #1";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + setup1_Message + " ---");
var setup1_1Tx = vyralSale.setCampaign(campaignAddress, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
var setup1_2Tx = vyralSale.setVesting(vestingAddress, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
var setup1_3Tx = share.transfer(vyralSaleAddress, vyralSale.SALE_ALLOCATION().plus(vyralSale.VYRAL_REWARDS()), {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
var setup1_4Tx = share.addTransferrer(vyralSaleAddress, {from: contractOwnerAccount, gas: 1400000, gasPrice: defaultGasPrice});
var setup1_5Tx = share.addTransferrer(campaignAddress, {from: contractOwnerAccount, gas: 1400000, gasPrice: defaultGasPrice});
var setup1_6Tx = campaign.transferOwnership(vyralSaleAddress, {from: contractOwnerAccount, gas: 1400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup1_7Tx = vyralSale.initPresale(wallet, $PRESALE_START_DATE, $PRESALE_END_DATE, web3.toWei(5000, "ether"), 1000, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup1_8Tx = vyralSale.startPresale({from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup1_1Tx, setup1_Message + " - vyralSale.setCampaign(...)");
failIfTxStatusError(setup1_2Tx, setup1_Message + " - vyralSale.setVesting(...)");
failIfTxStatusError(setup1_3Tx, setup1_Message + " - share.transfer(vyralSaleAddress, vyralSale.SALE_ALLOCATION())");
failIfTxStatusError(setup1_4Tx, setup1_Message + " - share.addTransferrer(vyralSaleAddress)");
failIfTxStatusError(setup1_5Tx, setup1_Message + " - share.addTransferrer(campaignAddress)");
failIfTxStatusError(setup1_6Tx, setup1_Message + " - campaign.transferOwnership(vyralSaleAddress)");
failIfTxStatusError(setup1_7Tx, setup1_Message + " - vyralSale.initPresale(...)");
failIfTxStatusError(setup1_8Tx, setup1_Message + " - vyralSale.startPresale()");
printTxData("setup1_1Tx", setup1_1Tx);
printTxData("setup1_2Tx", setup1_2Tx);
printTxData("setup1_3Tx", setup1_3Tx);
printTxData("setup1_4Tx", setup1_4Tx);
printTxData("setup1_5Tx", setup1_5Tx);
printTxData("setup1_6Tx", setup1_6Tx);
printTxData("setup1_7Tx", setup1_7Tx);
printTxData("setup1_8Tx", setup1_8Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


waitUntil("vyralSale.presaleStartTimestamp()", vyralSale.presaleStartTimestamp(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: vyralSaleAddress, gas: 400000, value: web3.toWei("1000", "ether")});
// var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: vyralSaleAddress, gas: 400000, value: web3.toWei("250", "ether")});
// var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: vyralSaleAddress, gas: 400000, value: web3.toWei("250", "ether")});
// var sendContribution1_4Tx = eth.sendTransaction({from: account6, to: vyralSaleAddress, gas: 400000, value: web3.toWei("251", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 1000 ETH");
// failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 250 ETH");
// failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac5 250 ETH");
// failIfTxStatusError(sendContribution1_4Tx, sendContribution1Message + " - ac5 251 ETH");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
// printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
// printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
// printTxData("sendContribution1_4Tx", sendContribution1_4Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup2_Message = "Setup #2";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + setup2_Message + " ---");
var setup2_1Tx = vyralSale.endPresale({from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup2_2Tx = vyralSale.initSale($START_DATE, $END_DATE, 1000, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup2_3Tx = vyralSale.startSale({from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup2_1Tx, setup2_Message + " - vyralSale.endPresale()");
failIfTxStatusError(setup2_2Tx, setup2_Message + " - vyralSale.initSale(...)");
failIfTxStatusError(setup2_3Tx, setup2_Message + " - vyralSale.startSale()");
printTxData("setup2_1Tx", setup2_1Tx);
printTxData("setup2_2Tx", setup2_2Tx);
printTxData("setup2_3Tx", setup2_3Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("vyralSale.saleStartTimestamp()", vyralSale.saleStartTimestamp(), 0);


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = vyralSale.buySale(account3, {from: account4, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac4(referred by ac3) 1,000 ETH");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution3Message);
var sendContribution3_1Tx = vyralSale.buySale(account3, {from: account5, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac5(referred by ac3) 1,000 ETH");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution4Message = "Send Contribution #4";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution4Message);
var sendContribution4_1Tx = vyralSale.buySale(account3, {from: account6, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution4_1Tx, sendContribution4Message + " - ac6(referred by ac3) 1,000 ETH");
printTxData("sendContribution4_1Tx", sendContribution4_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution5Message = "Send Contribution #5";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution5Message);
var sendContribution5_1Tx = vyralSale.buySale(account3, {from: account7, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution5_1Tx, sendContribution5Message + " - ac7(referred by ac3) 1,000 ETH");
printTxData("sendContribution5_1Tx", sendContribution5_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution6Message = "Send Contribution #6";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution6Message);
var sendContribution6_1Tx = vyralSale.buySale(account5, {from: account4, gas: 400000, value: web3.toWei("1000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution6_1Tx, sendContribution6Message + " - ac4(referred by ac5) 1,000 ETH");
printTxData("sendContribution6_1Tx", sendContribution6_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account3, to: vyralSaleAddress, gas: 400000, value: web3.toWei("250", "ether")});
var sendContribution2_2Tx = eth.sendTransaction({from: account4, to: vyralSaleAddress, gas: 400000, value: web3.toWei("250", "ether")});
var sendContribution2_3Tx = vyralSale.buySale(account3, {from: account5, gas: 400000, value: web3.toWei("250", "ether")});
var sendContribution2_4Tx = vyralSale.buySale(account5, {from: account6, gas: 400000, value: web3.toWei("251", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac3 250 ETH");
failIfTxStatusError(sendContribution2_2Tx, sendContribution2Message + " - ac4 250 ETH");
failIfTxStatusError(sendContribution2_3Tx, sendContribution2Message + " - ac5 250 ETH");
failIfTxStatusError(sendContribution2_4Tx, sendContribution2Message + " - ac5 251 ETH");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTxData("sendContribution2_2Tx", sendContribution2_2Tx);
printTxData("sendContribution2_3Tx", sendContribution2_3Tx);
printTxData("sendContribution2_4Tx", sendContribution2_4Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution3Message = "Send Contribution #3";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution3Message);
var sendContribution3_1Tx = vyralSale.buySale(account6, {from: account7, gas: 400000, value: web3.toWei("250", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac7 250 ETH");
printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
printCrowdsaleContractDetails();
printTokenContractDetails();
printCampaignContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var treasuryMessage = "Deploy Treasury Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + treasuryMessage + " ---");
var treasuryContract = web3.eth.contract(treasuryAbi);
// console.log(JSON.stringify(treasuryContract));
var treasuryTx = null;
var treasuryAddress = null;
var treasury = treasuryContract.new(teamWallet, {from: contractOwnerAccount, data: treasuryBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        treasuryTx = contract.transactionHash;
      } else {
        treasuryAddress = contract.address;
        addAccount(treasuryAddress, "Treasury");
        addTreasuryContractAddressAndAbi(treasuryAddress, treasuryAbi);
        console.log("DATA: treasuryAddress=" + treasuryAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(treasuryTx, treasuryMessage);
printTxData("treasuryAddress=" + treasuryAddress, treasuryTx);
printTreasuryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var votingProxyMessage = "Deploy Voting Proxy Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + votingProxyMessage + " ---");
var votingProxyContract = web3.eth.contract(votingProxyAbi);
// console.log(JSON.stringify(votingProxyContract));
var votingProxyTx = null;
var votingProxyAddress = null;
var votingProxy = votingProxyContract.new(treasuryAddress, tokenAddress, {from: contractOwnerAccount, data: votingProxyBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        votingProxyTx = contract.transactionHash;
      } else {
        votingProxyAddress = contract.address;
        addAccount(votingProxyAddress, "VotingProxy");
        addVotingProxyContractAddressAndAbi(votingProxyAddress, votingProxyAbi);
        console.log("DATA: votingProxyAddress=" + votingProxyAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("votingProxyAddress=" + votingProxyAddress, votingProxyTx);
failIfTxStatusError(votingProxyTx, votingProxyMessage);
printVotingProxyContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup1_Message = "Setup #1";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + setup1_Message + " ---");
var setup1_1Tx = treasury.setupOwners([owner1, owner2], {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup1_2Tx = treasury.setTokenContract(tokenAddress, {from: owner1, gas: 400000, gasPrice: defaultGasPrice});
var setup1_3Tx = treasury.setVotingProxy(votingProxyAddress, {from: owner2, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup1_1Tx, setup1_Message + " - treasury.setupOwners([owner1, owner2])");
failIfTxStatusError(setup1_2Tx, setup1_Message + " - treasury.setTokenContract(token)");
failIfTxStatusError(setup1_3Tx, setup1_Message + " - treasury.setVotingProxy(votingProxy)");
printTxData("setup1_1Tx", setup1_1Tx);
printTxData("setup1_2Tx", setup1_2Tx);
printTxData("setup1_3Tx", setup1_3Tx);
printTreasuryContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy Crowdsale Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + crowdsaleMessage + " ---");
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
// console.log(JSON.stringify(crowdsaleContract));
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new([owner1, owner2], treasuryAddress, teamWallet, {from: contractOwnerAccount, data: crowdsaleBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        crowdsaleTx = contract.transactionHash;
      } else {
        crowdsaleAddress = contract.address;
        addAccount(crowdsaleAddress, "Crowdsale");
        addCrowdsaleContractAddressAndAbi(crowdsaleAddress, crowdsaleAbi);
        console.log("DATA: crowdsaleAddress=" + crowdsaleAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setup2_Message = "Setup #2";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + setup2_Message + " ---");
var setup2_1Tx = treasury.setCrowdsaleContract(crowdsaleAddress, {from: owner1, gas: 400000, gasPrice: defaultGasPrice});
var setup2_2Tx = token.transferOwnership(crowdsaleAddress, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var setup2_3Tx = crowdsale.setTokenContract(tokenAddress, {from: owner1, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setup2_1Tx, setup2_Message + " - treasury.setCrowdsaleContract(crowdsale)");
failIfTxStatusError(setup2_2Tx, setup2_Message + " - token.transferOwnership(crowdsale)");
failIfTxStatusError(setup2_3Tx, setup2_Message + " - crowdsale.setTokenContract(token)");
printTxData("setup2_1Tx", setup2_1Tx);
printTxData("setup2_2Tx", setup2_2Tx);
printTxData("setup2_3Tx", setup2_3Tx);
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("crowdsale.saleStartDate()", crowdsale.saleStartDate(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("25000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("25000", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: crowdsaleAddress, gas: 400000, value: web3.toWei("25000", "ether")});
var sendContribution1_4Tx = eth.sendTransaction({from: account6, to: crowdsaleAddress, gas: 400000, value: web3.toWei("25001", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
printTxData("sendContribution1_4Tx", sendContribution1_4Tx);
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 25000 ETH");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 25000 ETH");
failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac5 25000 ETH");
failIfTxStatusError(sendContribution1_4Tx, sendContribution1Message + " - ac5 25001 ETH");
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finalise_Message = "Finalise";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + finalise_Message + " ---");
var finalise_1Tx = crowdsale.finalizeByAdmin({from: owner1, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(finalise_1Tx, finalise_Message + " - crowdsale.finalize()");
printTxData("finalise_1Tx", finalise_1Tx);
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var withdrawTeamFunds_Message = "Withdraw Refunds";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + withdrawTeamFunds_Message + " ---");
var withdrawTeamFunds_1Tx = treasury.withdrawTeamFunds({from: owner1, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(withdrawTeamFunds_1Tx, withdrawTeamFunds_Message + " - treasury.withdrawTeamFunds()");
printTxData("withdrawTeamFunds_1Tx", withdrawTeamFunds_1Tx);
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var refundVote_Message = "Refund Vote";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + refundVote_Message + " ---");
var refundVote_1Tx = votingProxy.startRefundInvestorsBallot({from: owner1, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
var refundInvestorsBallot = eth.contract(refundInvestorsBallotAbi).at(votingProxy.currentRefundInvestorsBallot());
var refundVote_2Tx = refundInvestorsBallot.vote("yes", {from: account3, gas: 1000000, gasPrice: defaultGasPrice});
var refundVote_3Tx = refundInvestorsBallot.vote("yes", {from: account4, gas: 1000000, gasPrice: defaultGasPrice});
var refundVote_4Tx = refundInvestorsBallot.vote("yes", {from: account5, gas: 1000000, gasPrice: defaultGasPrice});
 while (txpool.status.pending > 0) {
}
var refundVote_5Tx = refundInvestorsBallot.vote("yes", {from: account6, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(refundVote_1Tx, refundVote_Message + " - votingProxy.startRefundInvestorsBallot()");
failIfTxStatusError(refundVote_2Tx, refundVote_Message + " - refundInvestorsBallot.vote(yes) ac3");
failIfTxStatusError(refundVote_3Tx, refundVote_Message + " - refundInvestorsBallot.vote(yes) ac4");
failIfTxStatusError(refundVote_4Tx, refundVote_Message + " - refundInvestorsBallot.vote(yes) ac5");
passIfTxStatusError(refundVote_5Tx, refundVote_Message + " - refundInvestorsBallot.vote(yes) ac6. Expecting failure as vote closed");
printTxData("refundVote_1Tx", refundVote_1Tx);
printTxData("refundVote_2Tx", refundVote_2Tx);
printTxData("refundVote_3Tx", refundVote_3Tx);
printTxData("refundVote_4Tx", refundVote_4Tx);
printTxData("refundVote_5Tx", refundVote_5Tx);
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
printVotingProxyContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var refundInvestor_Message = "Withdraw Team Funds";
// -----------------------------------------------------------------------------
console.log("RESULT: --- " + refundInvestor_Message + " ---");
var refundInvestor_1Tx = token.approve(treasuryAddress, "30000000000000000000", {from: account3, gas: 100000});
while (txpool.status.pending > 0) {
}
var refundInvestor_2Tx = treasury.refundInvestor("30000000000000000000", {from: account3, gas: 1000000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(refundInvestor_1Tx, refundInvestor_Message + " - token.approve(treasuryAddress, 30) by account3");
failIfTxStatusError(refundInvestor_2Tx, refundInvestor_Message + " - treasury.refundInvestor() by account3");
printTxData("refundInvestor_1Tx", refundInvestor_1Tx);
printTxData("refundInvestor_2Tx", refundInvestor_2Tx);
printCrowdsaleContractDetails();
printTreasuryContractDetails();
printTokenContractDetails();
printVotingProxyContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var deployLibraryMessage = "Deploy SafeMath Library";
// -----------------------------------------------------------------------------
console.log("RESULT: " + deployLibraryMessage);
var libContract = web3.eth.contract(libAbi);
var libTx = null;
var libAddress = null;
var lib = libContract.new({from: contractOwnerAccount, data: libBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        libTx = contract.transactionHash;
      } else {
        libAddress = contract.address;
        addAccount(libAddress, "Lib SafeMath");
        console.log("DATA: libAddress=" + libAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("libAddress=" + libAddress, libTx);
failIfTxStatusError(libTx, deployLibraryMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Crowdsale/Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
// console.log("RESULT: old='" + tokenBin + "'");
var newTokenBin = tokenBin.replace(/__GizerTokenPresale\.sol\:SafeMath________/g, libAddress.substring(2, 42));
// console.log("RESULT: new='" + newTokenBin + "'");
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: newTokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("tokenAddress=" + tokenAddress, tokenTx);
failIfTxStatusError(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setupMessage = "Setup";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setupMessage);
var setup1Tx = token.setWallet(wallet, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
var setup2Tx = token.setRedemptionWallet(redemptionWallet, {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("setup1Tx", setup1Tx);
printTxData("setup2Tx", setup2Tx);
failIfTxStatusError(setup1Tx, setupMessage + " - setWallet(...)");
failIfTxStatusError(setup2Tx, setupMessage + " - setRedemptionWallet(...)");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendPrivateSaleContrib1Message = "Send Private Sale Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendPrivateSaleContrib1Message);
var sendPrivateSaleContrib1_1Tx = token.privateSaleContribution(account3, web3.toWei("100", "ether"), {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
var sendPrivateSaleContrib1_2Tx = token.privateSaleContribution(account4, web3.toWei("200", "ether"), {from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("sendPrivateSaleContrib1_1Tx", sendPrivateSaleContrib1_1Tx);
printTxData("sendPrivateSaleContrib1_2Tx", sendPrivateSaleContrib1_2Tx);
failIfTxStatusError(sendPrivateSaleContrib1_1Tx, sendPrivateSaleContrib1Message + " - ac3 100 ETH");
failIfTxStatusError(sendPrivateSaleContrib1_2Tx, sendPrivateSaleContrib1Message + " - ac4 200 ETH");
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("DATE_PRESALE_START", token.DATE_PRESALE_START(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution In Presale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution1_3Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("100", "ether")});
var sendContribution1_4Tx = eth.sendTransaction({from: account6, to: tokenAddress, gas: 400000, value: web3.toWei("100.01", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTxData("sendContribution1_3Tx", sendContribution1_3Tx);
printTxData("sendContribution1_4Tx", sendContribution1_4Tx);
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 100 ETH");
failIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac4 100 ETH");
failIfTxStatusError(sendContribution1_3Tx, sendContribution1Message + " - ac5 100 ETH");
passIfTxStatusError(sendContribution1_4Tx, sendContribution1Message + " - ac5 100.01 ETH - Expecting failure as over the contrib limit");
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("DATE_PRESALE_END", token.DATE_PRESALE_END(), 0);


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution After Presale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
passIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 1 ETH - Expecting failure as sale over");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken1_Message = "Move Tokens After Presale - To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken1_Message);
var moveToken1_1Tx = token.transfer(redemptionWallet, "1000000", {from: account3, gas: 100000});
var moveToken1_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken1_3Tx = token.transferFrom(account4, redemptionWallet, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken1_1Tx", moveToken1_1Tx);
printTxData("moveToken1_2Tx", moveToken1_2Tx);
printTxData("moveToken1_3Tx", moveToken1_3Tx);
failIfTxStatusError(moveToken1_1Tx, moveToken1_Message + " - transfer 1 token ac3 -> redemptionWallet. CHECK for movement");
failIfTxStatusError(moveToken1_2Tx, moveToken1_Message + " - approve 30 tokens ac4 -> ac6");
failIfTxStatusError(moveToken1_3Tx, moveToken1_Message + " - transferFrom 30 tokens ac4 -> redemptionWallet by ac6. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken2_Message = "Move Tokens After Presale - Not To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken2_Message);
var moveToken2_1Tx = token.transfer(account5, "1000000", {from: account3, gas: 100000});
var moveToken2_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken2_3Tx = token.transferFrom(account4, account7, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken2_1Tx", moveToken2_1Tx);
printTxData("moveToken2_2Tx", moveToken2_2Tx);
printTxData("moveToken2_3Tx", moveToken2_3Tx);
passIfTxStatusError(moveToken2_1Tx, moveToken2_Message + " - transfer 1 token ac3 -> ac5. Expecting failure");
failIfTxStatusError(moveToken2_2Tx, moveToken2_Message + " - approve 30 tokens ac4 -> ac6");
passIfTxStatusError(moveToken2_3Tx, moveToken2_Message + " - transferFrom 30 tokens ac4 -> ac7 by ac6. Expecting failure");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var freezeMessage = "Freeze Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + freezeMessage);
var freeze1Tx = token.freezeTokens({from: contractOwnerAccount, gas: 400000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("freeze1Tx", freeze1Tx);
failIfTxStatusError(freeze1Tx, freezeMessage + " - freezeTokens()");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken3_Message = "Move Tokens After Presale - To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken3_Message);
var moveToken3_1Tx = token.transfer(redemptionWallet, "1000000", {from: account3, gas: 100000});
var moveToken3_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken3_3Tx = token.transferFrom(account4, redemptionWallet, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken3_1Tx", moveToken3_1Tx);
printTxData("moveToken3_2Tx", moveToken3_2Tx);
printTxData("moveToken3_3Tx", moveToken3_3Tx);
passIfTxStatusError(moveToken3_1Tx, moveToken3_Message + " - transfer 1 token ac3 -> redemptionWallet. Expecting failure as tokens frozen");
failIfTxStatusError(moveToken3_2Tx, moveToken3_Message + " - approve 30 tokens ac4 -> ac6");
passIfTxStatusError(moveToken3_3Tx, moveToken3_Message + " - transferFrom 30 tokens ac4 -> redemptionWallet by ac6. Expecting failure as tokens frozen");
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
