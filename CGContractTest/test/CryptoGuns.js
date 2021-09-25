const swatOwnership = artifacts.require("swatownership");
const utils = require("./helpers/utils");
const time = require("./helpers/time");
var expect = require('chai').expect;
const swatNames = ["Swat 1", "Swat 2"];
contract("swatownership", (accounts) => {
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await swatOwnership.new();
    });
    it("should be able to create a new swat", async () => {
        const result = await contractInstance.createRandomSwat(swatNames[0], {from: alice});
          expect(result.receipt.status).to.equal(true);
        expect(result.logs[0].args.name).to.equal(swatNames[0]);
    })
    it("should not allow two swats", async () => {
        await contractInstance.createRandomSwat(swatNames[0], {from: alice});
        await utils.shouldThrow(contractInstance.createRandomSwat(swatNames[4], {from: alice}));
    })
    context("with the single-step transfer scenario", async () => {
        it("should transfer a swat", async () => {
            const result = await contractInstance.createRandomSwat(swatNames[0], {from: alice});
            const swatId = result.logs[0].args.swatId.toNumber();
            await contractInstance.transferFrom(alice, bob, swatId, {from: alice});
            const newOwner = await contractInstance.ownerOf(swatId);
            expect(newOwner).to.equal(bob);
        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a swat when the approved address calls transferFrom", async () => {
            const result = await contractInstance.createRandomSwat(swatNames[0], {from: alice});
            const swatId = result.logs[0].args.swatId.toNumber();
            await contractInstance.approve(bob, swatId, {from: alice});
            await contractInstance.transferFrom(alice, bob, swatId, {from: bob});
            const newOwner = await contractInstance.ownerOf(swatId);
           expect(newOwner).to.equal(bob);
        })
        it("should approve and then transfer a swat when the owner calls transferFrom", async () => {
            const result = await contractInstance.createRandomSwat(swatNames[0], {from: alice});
            const swatId = result.logs[0].args.swatId.toNumber();
            await contractInstance.approve(bob, swatId, {from: alice});
            await contractInstance.transferFrom(alice, bob, swatId, {from: alice});
            const newOwner = await contractInstance.ownerOf(swatId);
            expect(newOwner).to.equal(bob);
         })
    })
    /* it("swats should be able to attack another swat", async () => {
        let result;
        result = await contractInstance.createRandomSwat(swatNames[0], {from: alice});
        const firstSwatId = result.logs[0].args.swatId.toNumber();
        result = await contractInstance.createRandomSwat(swatNames[1], {from: bob});
        const secondSwatId = result.logs[0].args.swatId.toNumber();
        await time.increase(time.duration.days(1));
        await contractInstance.attack(firstSwatId, secondSwatId, {from: alice});
        expect(result.receipt.status).to.equal(true);
    }) */
})
