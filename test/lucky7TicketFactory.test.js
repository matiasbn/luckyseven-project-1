var Lucky7TicketFactory = artifacts.require('Lucky7TicketFactory')
contract('Lucky7TicketFactory', accounts => {

    const owner = accounts[0]
    const user = accounts[1]
    const user2 = accounts[2]
    const user3 = accounts[3]
    
    it("should ask for a new mu paramater for the user", async() => {
        
        const lucky7TicketFactory = await Lucky7TicketFactory.deployed()
        await lucky7TicketFactory._askForMuParameter(user)
        const eventWatcher = promisifyLogWatch(lucky7TicketFactory.NewMuReceived({ fromBlock: 'latest' }))

        log = await eventWatcher
        assert.equal(log.event, 'NewMuReceived', 'NewMuReceived not emitted.')
        assert.isNotNull(log.args.muParameter, 'Mu returned was null.')

    })

    it("should ask for a new i paramater for the user", async() => {
        
        const lucky7TicketFactory = await Lucky7TicketFactory.deployed()
        await lucky7TicketFactory._askForIParameter(user2)
        const eventWatcher = promisifyLogWatch(lucky7TicketFactory.NewIReceived({ fromBlock: 'latest' }))

        log = await eventWatcher
        assert.equal(log.event, 'NewIReceived', 'NewIReceived not emitted.')
        assert.isNotNull(log.args.iParameter, 'I returned was null.')

    })
    
    it("should set the WolframAlpha query correctly", async() => {
        //First, lets ask for both parameters
        //Then, lets call the _setTicketQuery function and check the output to be whats expected
        const lucky7TicketFactory = await Lucky7TicketFactory.deployed()
        let b = await lucky7TicketFactory.b() 
        let n = await lucky7TicketFactory.n() 
        let p = await lucky7TicketFactory.p() 
        let j = await lucky7TicketFactory.j() 
    
        await lucky7TicketFactory._askForMuParameter(owner)
        const eventWatcher1 = promisifyLogWatch(lucky7TicketFactory.NewMuReceived({ fromBlock: 'latest' }))
        log1 = await eventWatcher1
        const mu = log1.args.muParameter
    
        await lucky7TicketFactory._askForIParameter(owner)
        const eventWatcher2 = promisifyLogWatch(lucky7TicketFactory.NewIReceived({ fromBlock: 'latest' }))
        log2 = await eventWatcher2
        const i = log2.args.iParameter
    
        const eventWatcher3 = promisifyLogWatch(lucky7TicketFactory.NewWolframQuery({ fromBlock: 'latest' }))
        log3 = await eventWatcher3
        const queryWolframFromContract = log3.args.description
        //(mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^(i)))/10^i
        let queryWolframFromParameters = "(mod((1/(10^";
        queryWolframFromParameters = queryWolframFromParameters.concat(n,"-",mu,"))*10^",p,",10^(",j,"+",i,"))-mod((1/(10^",n,"-",mu,"))*10^",p,",10^(",i,")))/10^",i)
    
        assert.equal(queryWolframFromContract,queryWolframFromParameters,"The querys doesn't match")
    
    })
    
    it("should ask for both parameters converting the result in a Lucky7Number", async() => {
        //Same as before, but not setting the settingLucky7Numbers to false
        //This way, the callback function knows that we are on the 
        //setting Lucky7Numbers phase


        const lucky7TicketFactory = await Lucky7TicketFactory.new({value: 100000000000000000})
        await lucky7TicketFactory._askForMuParameter(owner)
        const eventWatcher1 = promisifyLogWatch(lucky7TicketFactory.NewMuReceived({ fromBlock: 'latest' }))
        log1 = await eventWatcher1
        assert.equal(log1.event, 'NewMuReceived', 'NewMuReceived not emitted.')
        assert.isNotNull(log1.args.muParameter, 'Mu returned was null.')

        await lucky7TicketFactory._askForIParameter(owner)
        const eventWatcher2 = promisifyLogWatch(lucky7TicketFactory.NewIReceived({ fromBlock: 'latest' }))
        log2 = await eventWatcher2
        assert.equal(log2.event, 'NewIReceived', 'NewIReceived not emitted.')
        assert.isNotNull(log2.args.iParameter, 'I returned was null.')
        
        //Check that the "new ticket" is emited
        const eventWatcher3 = promisifyLogWatch(lucky7TicketFactory.NewTicketReceived({ fromBlock: 'latest' }))
        log3 = await eventWatcher3
        assert.equal(log3.event, 'NewTicketReceived', 'NewTicketReceived not emitted.')
        assert.isNotNull(log3.args.newTicket, 'Lucky7Number received returned was null.')
        //Check if the new ticket is saved for the owner
        let userTicketValue = await lucky7TicketFactory.userValues(owner)
        userTicketValue = parseInt(userTicketValue[2])
        assert.notEqual(userTicketValue,0,'Ticket was not recieved')

    })


    it("should ask for both parameters without saving it as ticket", async() => {
        //Let take advantage of the settingLucky7Numbers circuit breaker
        //With this circuit breaker, while is true, after an i and mu parameters are received
        //the callback function ask for a ticket
        //If it where false, it will not pass the callback to ask for a ticket
        
        //Let start by setting the "settingLucky7Numbers" to false, because is true
        //by default, this way the contract knows we are in the selling ticket phase
        const lucky7TicketFactory = await Lucky7TicketFactory.deployed()
        await lucky7TicketFactory.toggleLucky7Setting()
        const settingLucky7Numbers= await lucky7TicketFactory.settingLucky7Numbers()
        assert.equal(settingLucky7Numbers,false,'Should set the settingLucky7 to false')
        
        
        await lucky7TicketFactory._askForMuParameter(user3)
        const eventWatcher1 = promisifyLogWatch(lucky7TicketFactory.NewMuReceived({ fromBlock: 'latest' }))
        log1 = await eventWatcher1
        assert.equal(log1.event, 'NewMuReceived', 'NewMuReceived not emitted.')
        assert.isNotNull(log1.args.muParameter, 'Mu returned was null.')
        
        await lucky7TicketFactory._askForIParameter(user3)
        const eventWatcher2 = promisifyLogWatch(lucky7TicketFactory.NewIReceived({ fromBlock: 'latest' }))
        log2 = await eventWatcher2
        assert.equal(log2.event, 'NewIReceived', 'NewIReceived not emitted.')
        assert.isNotNull(log2.args.iParameter, 'I returned was null.')
        
        let userTicketValue = await lucky7TicketFactory.userValues(user3)
        userTicketValue = parseInt(userTicketValue[2])
        assert.equal(userTicketValue,0,'Ticket was recieved')
        
    })
});

    
    

function promisifyLogWatch(_event) {
    return new Promise((resolve, reject) => {
      _event.watch((error, log) => {
        _event.stopWatching();
        if (error !== null)
          reject(error);
  
        resolve(log);
      });
    });
}