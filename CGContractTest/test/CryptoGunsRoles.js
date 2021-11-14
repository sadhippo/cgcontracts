const CryptoGuns = artifacts.require("CryptoGuns");
const utils = require("./helpers/utils");
const time = require("./helpers/time");
var expect = require('chai').expect;
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
// const vrfCoordinator = 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C;
// const linkToken = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
// const keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;

contract("CryptoGuns (proxy)", (accounts) => {
    let [owner, other] = accounts;
    let contractInstance;
    beforeEach(async () => {
        this.contractInstance = await CryptoGuns.new({from: owner});
         await this.contractInstance.initialize();
    });


    // it("sets the accepted token", async () => {
    //   const contractAddress = 0x0FE6Ed84bd640660c8f0389CfcA0821204369858;
    //  const result = await debug(this.contractInstance.setAcceptedToken(contractAddress, {from:owner}));
    //   expect(result.receipt.status).to.equal(true);
    //
    // })
    it("grants Minter Role to other, confirms getSwatName", async () => {

     const result = await this.contractInstance.addMinter(other, {from:owner});
      expect(result.receipt.status).to.equal(true);
      const swat1 = await this.contractInstance.mintSpecificSwat(other, "nightmare", "legendary", {from: other});
      const name = await this.contractInstance.getSwatName(0);

      expect(name).to.equal("nightmare");
    })
    it("Gets swat count", async () => {

     const result = await this.contractInstance.addMinter(other, {from:owner});
      expect(result.receipt.status).to.equal(true);
      const swat1 = await this.contractInstance.mintSpecificSwat(other, "nightmare", "legendary", {from: other});
      const swatCount = await this.contractInstance.getSwatsOwnedBy(other);
      expect(swatCount.toNumber()).to.equal(1);
    })
    it("gets Rarity", async () => {

     const result = await this.contractInstance.addMinter(other, {from:owner});
      expect(result.receipt.status).to.equal(true);
      const swat1 = await this.contractInstance.mintSpecificSwat(other, "nightmare", "legendary", {from: other});
      const rarity = await this.contractInstance.getRarity(0);

      expect(rarity).to.equal("legendary");
    })


    it("sets swatPrice to 5", async () => {
      const admin = await this.contractInstance.addAdmin(other, {from:owner});
     const result = await this.contractInstance.setSwatPrice(5, {from:other});
      expect(result.receipt.status).to.equal(true);
      const swatPrice = await this.contractInstance.getSwatPrice({from: other});
        expect(swatPrice.toNumber()).to.equal(5);
    })

    it("should throw when other tries to swatPrice to 5", async () => {
      await utils.shouldThrow(this.contractInstance.setSwatPrice(5, {from:other}));

    })

    it("should throw when other tries to swatPrice to 5", async () => {
      await utils.shouldThrow(this.contractInstance.mintSpecificSwat("BasicBob", {from:other}));

    })
});
