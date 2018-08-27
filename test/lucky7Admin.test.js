var Lucky7Admin = artifacts.require('Lucky7Admin')

contract('Lucky7Admin', function(accounts) {

    const owner = accounts[0]

    it("should change the numberOfLucky7Numbers value", async() => {
        const lucky7Admin = await Lucky7Admin.new()

        await lucky7Admin.modifyNumberOfLucky7Numbers(6, {from: owner})
        const result = await lucky7Admin.numberOfLucky7Numbers()

        assert.equal(result, 6, 'the new value does not match with the numberOfLucky7Numbers value')
    })

    it("should change the sellTicketPrice value", async() => {
        const lucky7Admin = await Lucky7Admin.new()
        const price = web3.toWei(0.013, "ether")
        await lucky7Admin.modifySellTicketPrice(price, {from: owner})
        const result = await lucky7Admin.sellTicketPrice()

        assert.equal(result, price, 'the new value does not match with the sellTicketPrice value')
    })

    it("should change the generateTicketPrice value", async() => {
        const lucky7Admin = await Lucky7Admin.new()
        const price = web3.toWei(0.006, "ether")
        await lucky7Admin.modifyGenerateTicketPrice(price, {from: owner})
        const result = await lucky7Admin.generateTicketPrice()

        assert.equal(result, price, 'the new value does not match with the generateTicketPrice value')
    })

    it("should change the oraclizeGasLimit value", async() => {
        const lucky7Admin = await Lucky7Admin.new()
        const price = 250000
        await lucky7Admin.modifyOraclizeGasLimit(price, {from: owner})
        const result = await lucky7Admin.oraclizeGasLimit()

        assert.equal(result, price, 'the new value does not match with the oraclizeGasLimit value')
    })

    it("should change the oraclizeCustomGasPrice value", async() => {
        const lucky7Admin = await Lucky7Admin.new()
        const price = 4000000000
        await lucky7Admin.modifyOraclizeCustomGasPrice(price, {from: owner})
        const result = await lucky7Admin.oraclizeCustomGasPrice()

        assert.equal(result, price, 'the new value does not match with the oraclizeCustomGasPrice value')
    })

    it("should change the enterprize wallet address value", async() => {
        const lucky7Admin = await Lucky7Admin.new()
        const value = "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"
        await lucky7Admin.modifyEnterpriseWallet(value, {from: owner})
        const result = await lucky7Admin.enterpriseWallet()

        assert.equal(result, value, 'the new value does not match with the p parameter value')
    })

});
