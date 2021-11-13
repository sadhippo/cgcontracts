
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const Cryptoguns = artifacts.require("Cryptoguns");

module.exports = async function (deployer) {
  const game =  await deployProxy(Cryptoguns,{ deployer });
  console.log('Deployed', game.address);

};
