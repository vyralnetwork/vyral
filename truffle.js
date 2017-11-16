const fs               = require('fs');
const HDWalletProvider = require('truffle-hdwallet-provider');

let secrets;
let mnemonic;

if(fs.existsSync('secrets.json')) {
    secrets  = JSON.parse(fs.readFileSync('secrets.json', 'utf8'));
    mnemonic = secrets.mnemonic;
} else {
    console.log('no secrets.json found. You can only deploy to the testrpc.');
    mnemonic = '';
}

module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            gas: 4712388,
            network_id: "*" // Match any network id
        },
        kovan: {
            provider: new HDWalletProvider(mnemonic, 'https://kovan.infura.io'),
            network_id: '*',
            gas: 4500000,
            gasPrice: 25000000000,
        }
    }
};