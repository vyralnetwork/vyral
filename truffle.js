const fs               = require("fs");
const HDWalletProvider = require("truffle-hdwallet-provider");

const ethereumjsWallet  = require("ethereumjs-wallet");
const ProviderEngine    = require("web3-provider-engine");
const WalletSubprovider = require("web3-provider-engine/subproviders/wallet.js");
const Web3Subprovider   = require("web3-provider-engine/subproviders/web3.js");
const Web3              = require("web3");
const FilterSubprovider = require("web3-provider-engine/subproviders/filters.js");

let secrets;
let mnemonic;
let wallet;
let privateKey;
let address;

if(fs.existsSync("secrets.json")) {
    secrets    = JSON.parse(fs.readFileSync("secrets.json", "utf8"));
    mnemonic   = secrets.mnemonic;
    privateKey = secrets.privateKey;
    wallet     = ethereumjsWallet.fromPrivateKey(new Buffer(privateKey, "hex"));
    address    = "0x" + wallet.getAddress().toString("hex");
} else {
    console.log("no secrets.json found. You can only deploy to the testrpc.");
    mnemonic   = "";
    privateKey = "";
}

let initProvider = (providerUrl) => {
    let engine = new ProviderEngine();
    engine.addProvider(new FilterSubprovider());
    engine.addProvider(new WalletSubprovider(wallet, {}));
    engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(providerUrl)));
    engine.start();
    return engine;
};

module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            gas: 4712388,
            network_id: "*"
        },
        ropsten: {
            provider: new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/[key]'),
            network_id: '*',
            gas: 4500000,
            gasPrice: 25000000000,
        },
        kovan: {
            provider: function() {
                return initProvider("https://kovan.infura.io/[key]");
            },
            from: address,
            network_id: "*",
            gas: 4500000,
            gasPrice: 25000000000,
        },
        rinkeby: {
            provider: function() {
                return initProvider("https://rinkeby.infura.io/[key]");
            },
            from: address,
            network_id: "*",
            gas: 4500000,
            gasPrice: 25000000000
        }
    }
};
