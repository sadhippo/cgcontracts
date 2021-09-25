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
const privateKey = "c3c220d484c8592f5d3f4e7aea2c202c5c8cc12dfa60809691d169416ad2f68f";

module.exports = {

    networks: {

        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
            gas: 9500000
        },

        mainnet: {
            provider: function() {
                return new HDWalletProvider(privateKey, "https://mainnet.infura.io/v3/<YOUR_INFURA_API_KEY>")
            },
            network_id: "1"
        },


            rinkeby: {
            provider: () => new HDWalletProvider(privateKey, `https://rinkeby.infura.io/v3/abcc19e38a814ff3b9145209e6d1891c`),
            network_id: 4,       // Ropsten's id
            gas: 5500000,        // Ropsten has a lower block limit than mainnet
           timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
            skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
             },
          },
    compilers: {
        solc: {
            version: "0.5.5"
        }
    }
};


//rinkeby: {
//    provider: function() {
//        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/abcc19e38a814ff3b9145209e6d1891c")
//    },
//    network_id: 4
//},
