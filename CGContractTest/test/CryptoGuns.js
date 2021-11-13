const CryptoGuns = artifacts.require("CryptoGuns");
const utils = require("./helpers/utils");
const time = require("./helpers/time");
var expect = require('chai').expect;
const swatNames = ["Sniper", "Swat 2", "Swat 3", "Swat 4"];
contract("CryptoGuns", (accounts) => {
    let [owner, alice, bob, steve] = accounts;
    let contractInstance;
    beforeEach(async () => {
        this.contractInstance = await CryptoGuns.new({from: owner});
         await this.contractInstance.initialize();
    });

    it("should be able to mint a new swat, returns balance of owner", async () => {

        const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
        const balance = await this.contractInstance.balanceOf(alice);
        expect(result.receipt.status).to.equal(true);
        expect(balance.toString()).to.equal("1");
    })

    context("with the single-step transfer scenario", async () => {
        it("should transfer a swat", async () => {
            const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swatId = result.logs[1].args._swatId.toNumber();
            await this.contractInstance.safeTransferFrom(alice, bob, swatId, {from: alice});
            const newOwner = await this.contractInstance.ownerOf(swatId);
            expect(newOwner).to.equal(bob);
        })
        it("should not transfer a swat when called by a third party", async () => {
            const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swatId = result.logs[1].args._swatId.toNumber();
            await  utils.shouldThrow(this.contractInstance.safeTransferFrom(alice, bob, swatId, {from: steve}));

        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a swat when the approved address calls transferFrom", async () => {
            const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swatId = result.logs[1].args._swatId.toNumber();
            await this.contractInstance.approve(bob, swatId, {from: alice});
            await this.contractInstance.safeTransferFrom(alice, bob, swatId, {from: bob});
            const newOwner = await this.contractInstance.ownerOf(swatId);
           expect(newOwner).to.equal(bob);
        })
    })

    context("Get Token IDs", async () => {
        it("should grab the tokenID at the specified location in the tokenID array", async () => {
           const swat1 = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swat2 = await this.contractInstance.mintRandomSwat(alice, {from: alice});
           const swat3 = await this.contractInstance.mintRandomSwat(alice, {from: alice});
           const tokens = await this.contractInstance.userOwnedSwats(alice, 1);
           const tokenstest = 1;
            expect(tokenstest).to.equal(tokens.toNumber());
         })

       })


       context("Duplicate Upgrade", async () => {
           it("should burn the duplicate swat", async () => {
              const swat1 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
              const swat2 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
              await this.contractInstance.duplicateUpgrade(0, 1, {from: alice});
              const balance = await this.contractInstance.balanceOf(alice);
              const upgraded = await this.contractInstance.getUpgraded(0, {from: alice});
              expect(balance.toString()).to.equal("1");
              expect(upgraded.toString()).to.equal("true");
            })
          })

         context("TokenURI", async () => {
                 it("concat token URI to base URI", async () => {
                    const swat1 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
                    const result = await this.contractInstance.tokenURI(0);
                    expect(result).to.equal("https://www.cryptoguns.io/json/nightmare")
                  })
                })

})
