var Lucky7FrontEndFunctions = artifacts.require('Lucky7FrontEndFunctions')

contract('Lucky7FrontEndFunctions', function(accounts) {

    const owner = accounts[0]

    it("should read the balance of the contract correctly", async() => {
        //Sending 1 ETH in the contract
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new({value: web3.fromWei(1000000000000000000,"ether")})
        const expectedBalance = web3.fromWei(1000000000000000000,"ether")
        const contractBalance = await lucky7FrontEndFunctions.getBalance()

        assert.equal(expectedBalance, contractBalance, "the balances don't match")
    })
    
    it("should read the lucky7Numbers correctly", async() => {
        //Insert Lucky7Numbers artificially
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new()
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(0,"mu","i",1,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(1,"mu","i",2,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(2,"mu","i",3,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(3,"mu","i",4,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(4,"mu","i",5,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(5,"mu","i",6,0)
        await lucky7FrontEndFunctions.insertCustomizedLucky7Number(6,"mu","i",7,0)
        const lucky7Numbers = await lucky7FrontEndFunctions.getlucky7Numbers()
        //Their values are their position +1
        for(i=0;i<lucky7Numbers.length;i++){
            assert.equal(parseInt(lucky7Numbers[i]),i+1,"not all match")
        }
    })

    it("should read the Lucky7TicketsValue correctly", async() => {
        //They're all empty at the first instance and the front end should acknowledge it
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new()
        const lucky7TicketValues = await lucky7FrontEndFunctions.getlucky7TicketsValue()
        for(i=0;i<lucky7TicketValues.length;i++){
            assert.equal(0,parseInt(lucky7TicketValues[i]),"not all are zero")
        }
    })
    
    it("should read the Lucky7TicketsDifferences correctly", async() => {
        //They're all empty at the first instance and the front end should acknowledge it
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new()
        const lucky7TicketDifferences = await lucky7FrontEndFunctions.getlucky7TicketsValue()
        for(i=0;i<lucky7TicketDifferences.length;i++){
            assert.equal(0,parseInt(lucky7TicketDifferences[i]),"not all are zero")
        }
    })

    it("should read the Lucky7TicketsOwner correctly", async() => {
        //They're all empty at the first instance and the front end should acknowledge it
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new()
        const lucky7TicketOwner = await lucky7FrontEndFunctions.getlucky7TicketsValue()
        for(i=0;i<lucky7TicketOwner.length;i++){
            assert.equal(0,parseInt(lucky7TicketOwner[i]),"not all are zero")
        }
    })

    it("should read the lastLucky7TicketsOwner correctly", async() => {
        //They're empty for every user at first and it should show it like it
        const lucky7FrontEndFunctions = await Lucky7FrontEndFunctions.new()
        var lucky7LastDIfference0 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[0])
        var lucky7LastDIfference1 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[1])
        var lucky7LastDIfference2 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[2])
        var lucky7LastDIfference3 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[3])
        var lucky7LastDIfference4 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[4])
        var lucky7LastDIfference5 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[5])
        var lucky7LastDIfference6 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[6])
        var lucky7LastDIfference7 = await lucky7FrontEndFunctions.getLastLucky7Difference(accounts[7])
        assert.equal(0,lucky7LastDIfference0,"they're not equal for account 0")
        assert.equal(0,lucky7LastDIfference1,"they're not equal for account 1")
        assert.equal(0,lucky7LastDIfference2,"they're not equal for account 2")
        assert.equal(0,lucky7LastDIfference3,"they're not equal for account 3")
        assert.equal(0,lucky7LastDIfference4,"they're not equal for account 4")
        assert.equal(0,lucky7LastDIfference5,"they're not equal for account 5")
        assert.equal(0,lucky7LastDIfference6,"they're not equal for account 6")
        assert.equal(0,lucky7LastDIfference7,"they're not equal for account 7")
    })
});
