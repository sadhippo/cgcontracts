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
    it("should throw error when minting is called by not the receiver of the swat unit", async () => {

        await utils.shouldThrow(this.contractInstance.mintRandomSwat(bob, {from: alice}));
    })
    it("should allow only the owner of the Cryptoguns Contract to mint specific swats", async () => {
        const result = await this.contractInstance.mintSpecificSwat(accounts[0], "nightmare", "legendary", {from: owner});
        expect(result.receipt.status).to.equal(true);
        expect(result.logs[1].args.name).to.equal("nightmare");
    })

    it("should not allow five swats", async () => {
        await this.contractInstance.mintRandomSwat(alice, {from: alice});
        await this.contractInstance.mintRandomSwat(alice, {from: alice});
        await this.contractInstance.mintRandomSwat(alice, {from: alice});
        await this.contractInstance.mintRandomSwat(alice, {from: alice});
        await utils.shouldThrow(this.contractInstance.mintRandomSwat(alice, {from: alice}));
    })
    context("with the single-step transfer scenario", async () => {
        it("should transfer a swat", async () => {
            const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swatId = result.logs[1].args.swatId.toNumber();
            await this.contractInstance.safeTransferFrom(alice, bob, swatId, {from: alice});
            const newOwner = await this.contractInstance.ownerOf(swatId);
            expect(newOwner).to.equal(bob);
        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a swat when the approved address calls transferFrom", async () => {
            const result = await this.contractInstance.mintRandomSwat(alice, {from: alice});
            const swatId = result.logs[1].args.swatId.toNumber();
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
            assert.equal(tokenstest, tokens);
         })

       })


       context("Duplicate Upgrade", async () => {
           it("should burn the duplicate swat", async () => {
              const swat1 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
              const swat2 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
              await this.contractInstance.duplicateUpgrade(0, 1, {from: alice});
              const balance = await this.contractInstance.balanceOf(alice);
              const upgraded = await this.contractInstance.getUpgraded(0, {from: owner});
              expect(balance.toString()).to.equal("1");
              expect(upgraded.toString()).to.equal("true");
            })
          })

          context("LevelUp", async () => {
              it("should levelup swat", async () => {
                 const swat1 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
                 const swat2 = await this.contractInstance.mintSpecificSwat(alice, "nightmare", "legendary", {from: owner});
                 await this.contractInstance.levelUp(0, {from: owner});
                 const level = await this.contractInstance.getLevel(0, {from: owner});
                 expect(level.toNumber()).to.equal(2);
               })
             })



})
