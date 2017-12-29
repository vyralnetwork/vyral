/**
 * Scans the blockchain for transactions.
 */
class TxScanner {

    constructor(providerUrl, account) {
        this.account     = account;
        this.providerUrl = providerUrl;
    }

    getTransactions(startBlockNumber, endBlockNumber) {
        if(endBlockNumber == null) {
            endBlockNumber = eth.blockNumber;
            console.log("Using endBlockNumber: " + endBlockNumber);
        }
        if(startBlockNumber == null) {
            startBlockNumber = endBlockNumber - 1000;
            console.log("Using startBlockNumber: " + startBlockNumber);
        }

        for(var i = startBlockNumber; i <= endBlockNumber; i++) {
            if(i % 1000 == 0) {
                console.log("Searching block " + i);
            }
            var block = eth.getBlock(i, true);
            if(block != null && block.transactions != null) {
                block.transactions.forEach(function(e) {
                    if(this.account == "*" || this.account == e.from || this.account == e.to) {
                        console.log("  tx hash          : " + e.hash + "\n"
                        + "   nonce           : " + e.nonce + "\n"
                        + "   blockHash       : " + e.blockHash + "\n"
                        + "   blockNumber     : " + e.blockNumber + "\n"
                        + "   transactionIndex: " + e.transactionIndex + "\n"
                        + "   from            : " + e.from + "\n"
                        + "   to              : " + e.to + "\n"
                        + "   value           : " + e.value + "\n"
                        + "   gasPrice        : " + e.gasPrice + "\n"
                        + "   gas             : " + e.gas + "\n"
                        + "   input           : " + e.input);
                    }
                })
            }
        }
    }
}
