/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */
require('dotenv').config();
 const HDWalletProvider = require("@truffle/hdwallet-provider");
const privateKey = process.env.PRIVATEKEY;

module.exports = {

    networks: {

        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
            gas: 9500000
        },

        mainnet: {
            provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
                network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
            },
            testnet: {
            provider: () => new HDWalletProvider(privateKey, `https://data-seed-prebsc-1-s1.binance.org:8545`),
            network_id: 97,       // Ropsten's id
            confirmations:10,
           timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
            skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
             },
          },
    compilers: {
        solc: {
            version: "0.8.0",
            settings: {
        optimizer: {
          enabled: true,
          runs: 100000  // Optimize for how many times you intend to run the code
        }}
        }
    }
};


//rinkeby: {
//    provider: function() {
//        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/abcc19e38a814ff3b9145209e6d1891c")
//    },
//    network_id: 4
//},
