const Cryptoguns = artifacts.require("Cryptoguns");

module.exports = function (deployer) {
  deployer.deploy(Cryptoguns);
};
