var Lucky7Ballot= artifacts.require('Lucky7Ballot')

contract('Lucky7Ballot', accounts => {

    const owner = accounts[0]
    const user1 = accounts[1]
    const user2 = accounts[2]
    const user3 = accounts[3]
    const user4 = accounts[4]
    const user5 = accounts[5]
    const user6 = accounts[6]
    const user7 = accounts[7]
    
    it("should ask for a new Lucky7Number and store it in the Lucky7Numbers array", async() => {
        //For this test, we will call the _generateLucky7Number function
        //Once the Lucky7Number is obtained, it should be stored and saved on the first position
        //of the lucky7Number array of the Lucky7Factory contract and indexForLucky7Array should increase in 1
        const lucky7Ballot = await Lucky7Ballot.new({value: 100000000000000000})
        let indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

        //Check if indexForLucky7Array is initialized on 0
        assert.equal(indexForLucky7Array,0,'Index not initialized on 0')

        //Generate a new Lucky7Number
        await lucky7Ballot._generateLucky7Number({from: owner})
        let eventWatcher = promisifyLogWatch(lucky7Ballot.NewLucky7Number({ fromBlock: 'latest' }))
        log = await eventWatcher
        assert.equal(log.event, 'NewLucky7Number', 'NewLucky7Number not emitted.')
        let generatedLucky7Number= parseInt(log.args.value)
        
        //Check if the first Lucky7Number is on the position 0
        let firstLucky7Number = await lucky7Ballot.lucky7NumbersArray(0)
        firstLucky7Number = parseInt(firstLucky7Number[2])
        assert.equal(generatedLucky7Number,firstLucky7Number, 'First Lucky7Numbers should match')

        //Check if indexForLucky7Numbers was increased
        indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

        //Check if indexForLucky7Array is 1 now
        assert.equal(indexForLucky7Array,1,'Index should be 1')
        
        //Generate a new Lucky7Number to check one last time
        await lucky7Ballot._generateLucky7Number({from: owner})
        eventWatcher = promisifyLogWatch(lucky7Ballot.NewLucky7Number({ fromBlock: 'latest' }))
        log = await eventWatcher
        assert.equal(log.event, 'NewLucky7Number', 'NewLucky7Number not emitted.')
        generatedLucky7Number= parseInt(log.args.value)
        
        //Check if the first Lucky7Number is on the position 0
        let secondLucky7Number = await lucky7Ballot.lucky7NumbersArray(1)
        secondLucky7Number = parseInt(secondLucky7Number[2])
        assert.equal(generatedLucky7Number,secondLucky7Number, 'Second Lucky7Numbers should match')

        //Check if indexForLucky7Numbers was increased
        indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

        //Check if indexForLucky7Array is 2 now
        assert.equal(indexForLucky7Array,2,'Index should be 2')
    })
    
    it("should sort the Lucky7Numbers when _generateLucky7Number is called for the eighth time", async() => {
        //Generating the Lucky7Numbers take time, a lot, even with a local network
        //That's why i'm using the insertCustomizedLucky7Number, insertCustomizedLucky7Ticket and
        //setIndexForLucky7Array of the Lucky7Ballot contract (at the bottom of the contract) to generate them virtually
        //without waiting


        //The mu and i paramaters value don't need to make sense at this point
        //This ticket value can be generated with the mbn.py of the python directory of this project
        //Because numbers of 20 digits are considered BigNumbers for Javascript i'll test with
        //smaller numbers,i.e. 14 digits. The result is the same
        const lucky7Ballot = await Lucky7Ballot.new({value: 100000000000000000})
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",99008528368191,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",77880312560110,0)

        //Check if they were inserted, just by looking up two, the 1 and 4 for example

        let lucky7Number1 = await lucky7Ballot.lucky7NumbersArray(1)
        let lucky7Number4 = await lucky7Ballot.lucky7NumbersArray(4)
        lucky7Number1 = parseInt(lucky7Number1[2])
        lucky7Number4 = parseInt(lucky7Number4[2])
        assert.equal(lucky7Number1,23532579469038, 'Lucky7Numbers1 should match')
        assert.equal(lucky7Number4,88808972694141, 'Lucky7Numbers4 should match')

        //Now we can check if by calling _generateLucky7Number the numbers are going to be sorted
        //First, we have to set the indexForLucky7Array to 7, in this way the _generateLucky7Number function is going
        //to call the _orderLucky7Numbers function
        //Calling the _generateLucky7Number function in this case is the same as doing it for the eighth time
        //as showed on the first test function
        //I will store the state of the settingLucky7Numbers circuit breaker, explained later

        let settingLucky7NumbersFirstState = await lucky7Ballot.settingLucky7Numbers()
        await lucky7Ballot.setIndexForLucky7Array(7)
        await lucky7Ballot._generateLucky7Number({from: owner})
        
        //Now lets check if they were sorted
        //I generated them purposely with the first digit different to easily see
        //which is bigger
        let lucky7Number0 = await lucky7Ballot.lucky7NumbersArray(0)
        lucky7Number1 = await lucky7Ballot.lucky7NumbersArray(1)
        let lucky7Number2 = await lucky7Ballot.lucky7NumbersArray(2)
        let lucky7Number3 = await lucky7Ballot.lucky7NumbersArray(3)
        lucky7Number4 = await lucky7Ballot.lucky7NumbersArray(4)
        let lucky7Number5 = await lucky7Ballot.lucky7NumbersArray(5)
        let lucky7Number6 = await lucky7Ballot.lucky7NumbersArray(6)
        lucky7Number0 = parseInt(lucky7Number0[2])
        lucky7Number1 = parseInt(lucky7Number1[2])
        lucky7Number2 = parseInt(lucky7Number2[2])
        lucky7Number3 = parseInt(lucky7Number3[2])
        lucky7Number4 = parseInt(lucky7Number4[2])
        lucky7Number5 = parseInt(lucky7Number5[2])
        lucky7Number6 = parseInt(lucky7Number6[2])
        assert.equal(lucky7Number0,23532579469038, 'Lucky7Numbers0 should match')
        assert.equal(lucky7Number1,42125129325443, 'Lucky7Numbers1 should match')
        assert.equal(lucky7Number2,55525851604563, 'Lucky7Numbers2 should match')
        assert.equal(lucky7Number3,69776513144870, 'Lucky7Numbers3 should match')
        assert.equal(lucky7Number4,77880312560110, 'Lucky7Numbers4 should match')
        assert.equal(lucky7Number5,88808972694141, 'Lucky7Numbers5 should match')
        assert.equal(lucky7Number6,99008528368191, 'Lucky7Numbers6 should match')

        //Then i'll check if the toggleLucky7Setting() activated the settingLucky7Numbers circuit breaker
        //This circuit breaker is thought to stop players to buy tickets until the Lucky7Numbers are
        //already setted
        //Initial state for this circuit breaker is true, and need to be false to allow users to
        //buy tickets
        let settingLucky7NumbersSecondState = await lucky7Ballot.settingLucky7Numbers()
        assert.equal(settingLucky7NumbersFirstState,true,'settingLucky7Numbers first state was not true')
        assert.equal(settingLucky7NumbersSecondState,false,'settingLucky7Numbers second state was not false')
        assert.notEqual(settingLucky7NumbersFirstState,settingLucky7NumbersSecondState,'settingLucky7Numbers state did not changed')
    })
    
    it("should ask for a new ticket and check if it is a Lucky7Ticket", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //Then, i will insert a ticket with a difference of 2 compared to a Lucky7Number
        //This will generate a Lucky7Ticket (because they're empty)
        //Then i will insert another ticket with a difference of 1 with the same number
        //Of the first Lucky7Number. This should replace the old Lucky7Ticket
        //I will insert another but close to another Lucky7Number and check if the difference are OK
        //Finally i will insert a ticket with 0 diference to check if it's catching ExactLucky7Tickets
        const lucky7Ballot = await Lucky7Ballot.new()
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191,0)
        
        //This number has a difference of 2 with the first Lucky7Number
        //The currentTicketID parameter of the Lucky7Ballot contract contains the id of the last ticket inserted
        //through insertCustomizedTicket function
        //With this we can check the values of the ticket and call the _checkForLucky7Ticket function of the 
        //Lucky7TicketFactory contract
        //The result should be the first element of the tickets array of the Lucky7TicketFactory 
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469040,user1,0)
        let currentTicketID = await lucky7Ballot.currentTicketID()
        let firstTicket = await lucky7Ballot.ticketsArray(currentTicketID);
        assert.equal(currentTicketID,0,'Is not the same currentTicketID')
        //The owner is the fourth parameter of the Tickets struct of the Lucky7TicketFactory
        let ownerOfTheFirstTicket = firstTicket[3]
        assert.equal(ownerOfTheFirstTicket,user1,'Not the same owner')
        //The results of _checkForLucky7Ticket are stored on maps structures called 
        //lucky7TicketDifference,lucky7TicketOwner and lucky7TicketID
        //which _KeyTypes is the Lucky7Number "id" (first, second, third...)
        //that said, lucky7TicketOwner(parameter) where parameter is 0,i.e. first Lucky7Ticket
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        let differenceOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketDifference(0)
        let ownerOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketOwner(0)
        let IDOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketID(0)
        assert.equal(differenceOfFirstLucky7Ticket,2,'Difference distinct than 2')
        assert.equal(ownerOfFirstLucky7Ticket,user1,'Not the same owner')
        assert.equal(parseInt(IDOfFirstLucky7Ticket),parseInt(currentTicketID),'Not the same ticketID')

        //Now i will insert a new Ticket, closer to the first Lucky7Number than the previous inserted
        //but smaller than the first Lucky7Number to test this case
        //Then, i will check if the lucky7TicketDifference,lucky7TicketOwner and lucky7TicketID
        //change it value
        //So it's necessary to use another user
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469037,user2,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        let secondTicket = await lucky7Ballot.ticketsArray(currentTicketID);
        assert.equal(currentTicketID,1,'Is not the same currentTicketID')
        //The owner is the fourth parameter of the Tickets struct of the Lucky7TicketFactory
        let ownerOfTheSecondTicket = secondTicket[3]
        assert.equal(ownerOfTheSecondTicket,user2,'Not the same owner')
        //The results of _checkForLucky7Ticket are stored on maps structures called 
        //lucky7TicketDifference,lucky7TicketOwner and lucky7TicketID
        //which _KeyTypes is the Lucky7Number "id" (first, second, third...)
        //that said, lucky7TicketOwner(parameter) where parameter is 0,i.e. first Lucky7Ticket
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        differenceOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketDifference(0)
        ownerOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketOwner(0)
        IDOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketID(0)
        assert.equal(differenceOfFirstLucky7Ticket,1,'Difference distinct than 1')
        assert.equal(ownerOfFirstLucky7Ticket,user2,'Not the same owner')
        assert.equal(parseInt(IDOfFirstLucky7Ticket),parseInt(currentTicketID),'Not the same ticketID')

        //Finally i'll insert a ticket with difference 0
        //to test it, i'll have to check if the 
        //lucky7TicketDifference,lucky7TicketOwner and lucky7TicketID
        //have new values
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469038,user3,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        let thirdTicket = await lucky7Ballot.ticketsArray(currentTicketID);
        assert.equal(currentTicketID,2,'Is not the same currentTicketID')
        //The owner is the fourth parameter of the Tickets struct of the Lucky7TicketFactory
        let ownerOfTheThirdTicket = thirdTicket[3]
        assert.equal(ownerOfTheThirdTicket,user3,'Not the same owner')
        //The results of _checkForLucky7Ticket are stored on maps structures called 
        //lucky7TicketDifference,lucky7TicketOwner and lucky7TicketID
        //which _KeyTypes is the Lucky7Number "id" (first, second, third...)
        //that said, lucky7TicketOwner(parameter) where parameter is 0,i.e. first Lucky7Ticket
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        differenceOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketDifference(0)
        ownerOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketOwner(0)
        IDOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketID(0)
        assert.equal(differenceOfFirstLucky7Ticket,0,'Difference distinct than 0')
        assert.equal(ownerOfFirstLucky7Ticket,user3,'Not the same owner')
        assert.equal(parseInt(IDOfFirstLucky7Ticket),parseInt(currentTicketID),'Not the same ticketID')


        //And now i'll check if it was inserted on the ExactLucky7Ticket mappings,
        //i.e. ExactLucky7TicketValue, ExactLucky7TicketOwner, ExactLucky7TicketID
        //then i'll check if indexForExactLucky7Ticket is increased by 1
        let firstExactLucky7Ticket = await lucky7Ballot.ExactLucky7TicketValue(0);
        let firstExactLucky7Owner = await lucky7Ballot.ExactLucky7TicketOwner(0);
        let firstExactLucky7ID = await lucky7Ballot.ExactLucky7TicketID(0);
        let indexForExactLucky7Ticket = await lucky7Ballot.indexForExactLucky7Ticket();
        assert.equal(parseInt(firstExactLucky7Ticket),parseInt(thirdTicket[2]),'Not same value for Exact')
        assert.equal(firstExactLucky7Owner,user3,'Not the same owner for Exact')
        assert.equal(parseInt(firstExactLucky7ID),parseInt(currentTicketID),'Not the same ticketID for Exact')
        assert.equal(indexForExactLucky7Ticket,1,'Not same indexForExactLucky7Ticket')
    })
    
    it("should not change the Lucky7Ticket owner if it is exact", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //Then, i will insert a ticket with a difference of 0,i.e. is an ExactLucky7Ticket
        //Then, i will insert the same ticket with different owner
        //Both are going to be registered as ExactLucky7Ticket, but the Lucky7TicketOwner is 
        //not going to change

        const lucky7Ballot = await Lucky7Ballot.new()
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191,0)
        
        //Insert the first ticket, which is exact
        await lucky7Ballot.insertCustomizedTicket("0","0",42125129325443,user1,0)
        let currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        let firstTicket = await lucky7Ballot.ticketsArray(currentTicketID)
        ownerOfFirstTicket = firstTicket[3]
        let ownerOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketOwner(1)
        let ownerOfFirstExactLucky7Ticket = await lucky7Ballot.ExactLucky7TicketOwner(0)
        assert.equal(ownerOfFirstTicket,ownerOfFirstLucky7Ticket,'Not the same owner for Lucky7Number')
        assert.equal(ownerOfFirstTicket,ownerOfFirstExactLucky7Ticket,'Not the same owner for ExactLucky7Number')
        
        //Insert the second ticket, same as the first but different owner
        await lucky7Ballot.insertCustomizedTicket("0","0",42125129325443,user2,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        let secondTicket = await lucky7Ballot.ticketsArray(currentTicketID)
        ownerOfSecondTicket = secondTicket[3]
        ownerOfFirstLucky7Ticket = await lucky7Ballot.lucky7TicketOwner(1)
        let ownerOfSecondExactLucky7Ticket = await lucky7Ballot.ExactLucky7TicketOwner(1)
        assert.equal(ownerOfFirstTicket,ownerOfFirstLucky7Ticket,'First Lucky7Ticket owner changed')
        assert.equal(ownerOfSecondTicket,ownerOfSecondExactLucky7Ticket,'Not the same owner for ExactLucky7Number')
    })
    
    it("should properly store and order the Lucky7Tickets", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //Then, i will insert a ticket with a difference of 0 ,i.e. is an ExactLucky7Ticket
        //Then, i will insert a ticket with a difference of 1
        //Then, i will insert a ticket with a difference of 2
        //Then, i will insert a ticket with a difference of 3
        //Then, i will insert a ticket with a difference of 4
        //Then, i will insert a ticket with a difference of 5
        //Then, i will insert a ticket with a difference of 6
        //All of above with different owners and related to different Lucky7Numbers
        //I'll leave two Lucky7Ticket purposely empty for later tests
        //Finally i'll call _orderLucky7Tickets
        //Result should be Lucky7Tickets sorted from ordered from lowest to highest

        const lucky7Ballot = await Lucky7Ballot.new()
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191,0)
        
        //Insert the purposed tickets
        
        //Difference is 0
        await lucky7Ballot.insertCustomizedTicket("0","0",88808972694141,user1,0)
        let currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        
        //Difference is 1
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469039,user2,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        
        //Difference is 2
        await lucky7Ballot.insertCustomizedTicket("0","0",42125129325441,user3,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)

        //Difference is 3
        await lucky7Ballot.insertCustomizedTicket("0","0",99008528368194,user4,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)

        //Difference is 4
        await lucky7Ballot.insertCustomizedTicket("0","0",55525851604567,user5,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
       
        //Difference is 5
        await lucky7Ballot.insertCustomizedTicket("0","0",69776513144865,user6,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)

        //Difference is 6
        await lucky7Ballot.insertCustomizedTicket("0","0",77880312560104,user7,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)


        //Now i'll call _orderLucky7Tickets and check if they're ordered
        //The owners were putted purposely in order to check the order of the Lucky7Tickets easily
        //The Lucky7Numbers mappings (difference, owner and ticketid) are ordered by Lucky7Number, so
        //is not going to be "straight forward" to order the Lucky7Tickets, i.e. it would have to 
        //compare the lucky7Ticket[0] (the difference of 23532579469038-23532579469039 = 1) with the 
        //difference of lucky7Ticket[1] (the difference of 42125129325443-42125129325441 = 2), then with 
        //lucky7Ticket[2] (55525851604563-55525851604567 = 4) and so on  

        await lucky7Ballot._orderLucky7Tickets()
        let Lucky7Ticket0 = await lucky7Ballot.lucky7TicketsArray(0)
        let Lucky7Ticket1 = await lucky7Ballot.lucky7TicketsArray(1)
        let Lucky7Ticket2 = await lucky7Ballot.lucky7TicketsArray(2)
        let Lucky7Ticket3 = await lucky7Ballot.lucky7TicketsArray(3)
        let Lucky7Ticket4 = await lucky7Ballot.lucky7TicketsArray(4)
        let Lucky7Ticket5 = await lucky7Ballot.lucky7TicketsArray(5)
        let Lucky7Ticket6 = await lucky7Ballot.lucky7TicketsArray(6)
        let differenceOfLucky7Ticket0 = Lucky7Ticket0[0]
        let ownerOfLucky7Ticket0 = Lucky7Ticket0[1]
        let differenceOfLucky7Ticket1 = Lucky7Ticket1[0]
        let ownerOfLucky7Ticket1 = Lucky7Ticket1[1]
        let differenceOfLucky7Ticket2 = Lucky7Ticket2[0]
        let ownerOfLucky7Ticket2 = Lucky7Ticket2[1]
        let differenceOfLucky7Ticket3 = Lucky7Ticket3[0]
        let ownerOfLucky7Ticket3 = Lucky7Ticket3[1]
        let differenceOfLucky7Ticket4 = Lucky7Ticket4[0]
        let ownerOfLucky7Ticket4 = Lucky7Ticket4[1]
        let differenceOfLucky7Ticket5 = Lucky7Ticket5[0]
        let ownerOfLucky7Ticket5 = Lucky7Ticket5[1]
        let differenceOfLucky7Ticket6 = Lucky7Ticket6[0]
        let ownerOfLucky7Ticket6 = Lucky7Ticket6[1]
        
        //Difference of 0, owner user1
        assert.equal(differenceOfLucky7Ticket0,0,'not the same difference for Lucky7Ticket0')
        assert.equal(ownerOfLucky7Ticket0,user1,'not the same owner for Lucky7Ticket0')
        
        //Difference of 1, owner user2
        assert.equal(differenceOfLucky7Ticket1,1,'not the same difference for Lucky7Ticket1')
        assert.equal(ownerOfLucky7Ticket1,user2,'not the same owner for Lucky7Ticket1')
        
        //Difference of 2, owner user3
        assert.equal(differenceOfLucky7Ticket2,2,'not the same difference for Lucky7Ticket2')
        assert.equal(ownerOfLucky7Ticket2,user3,'not the same owner for Lucky7Ticket2')
        
        //Difference of 3, owner user4
        assert.equal(differenceOfLucky7Ticket3,3,'not the same difference for Lucky7Ticket3')
        assert.equal(ownerOfLucky7Ticket3,user4,'not the same owner for Lucky7Ticket3')
        
        //Difference of 4, owner user5
        assert.equal(differenceOfLucky7Ticket4,4,'not the same difference for Lucky7Ticket4')
        assert.equal(ownerOfLucky7Ticket4,user5,'not the same owner for Lucky7Ticket4')

        //Difference of 5, owner user6
        assert.equal(differenceOfLucky7Ticket5,5,'not the same difference for Lucky7Ticket5')
        assert.equal(ownerOfLucky7Ticket5,user6,'not the same owner for Lucky7Ticket5')

        //Difference of 6, owner user7
        assert.equal(differenceOfLucky7Ticket6,6,'not the same difference for Lucky7Ticket6')
        assert.equal(ownerOfLucky7Ticket6,user7,'not the same owner for Lucky7Ticket6')

        //Now i'll try to insert only empty Lucky7Tickets and check if the owners are equal to 0
        //First i'll increase the initialLucky7TicketPosition to 7 to start storing in the next "drawID"
        //Is necessary to call _cleanMappings function to set all the mappings (lucky7Numbers and ExactLucky7Tickets) to 0
        //This function is going to be tested in the next test
        await lucky7Ballot._cleanMappings()
        
        //Check if the initialLucky7TicketPosition is setted to 7
        await lucky7Ballot.setInitialLucky7TicketPosition(7)
        let initialLucky7Position = await lucky7Ballot.initialLucky7TicketPosition()
        assert.equal(parseInt(initialLucky7Position),7,'initialLucky7Position not equal to 7')
        
        //Insert and order the empty Lucky7Tickets
        await lucky7Ballot._orderLucky7Tickets()
        Lucky7Ticket0 = await lucky7Ballot.lucky7TicketsArray(7)
        Lucky7Ticket1 = await lucky7Ballot.lucky7TicketsArray(8)
        Lucky7Ticket2 = await lucky7Ballot.lucky7TicketsArray(9)
        Lucky7Ticket3 = await lucky7Ballot.lucky7TicketsArray(10)
        Lucky7Ticket4 = await lucky7Ballot.lucky7TicketsArray(11)
        Lucky7Ticket5 = await lucky7Ballot.lucky7TicketsArray(12)
        Lucky7Ticket6 = await lucky7Ballot.lucky7TicketsArray(13)
        differenceOfLucky7Ticket0 = Lucky7Ticket0[0]
        ownerOfLucky7Ticket0 = Lucky7Ticket0[1]
        differenceOfLucky7Ticket1 = Lucky7Ticket1[0]
        ownerOfLucky7Ticket1 = Lucky7Ticket1[1]
        differenceOfLucky7Ticket2 = Lucky7Ticket2[0]
        ownerOfLucky7Ticket2 = Lucky7Ticket2[1]
        differenceOfLucky7Ticket3 = Lucky7Ticket3[0]
        ownerOfLucky7Ticket3 = Lucky7Ticket3[1]
        differenceOfLucky7Ticket4 = Lucky7Ticket4[0]
        ownerOfLucky7Ticket4 = Lucky7Ticket4[1]
        differenceOfLucky7Ticket5 = Lucky7Ticket5[0]
        ownerOfLucky7Ticket5 = Lucky7Ticket5[1]
        differenceOfLucky7Ticket6 = Lucky7Ticket6[0]
        ownerOfLucky7Ticket6 = Lucky7Ticket6[1]

        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket0,0,'not the same difference for Lucky7Ticket0')
        assert.equal(ownerOfLucky7Ticket0,0,'not the same owner for Lucky7Ticket0')
        
        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket1,0,'not the same difference for Lucky7Ticket1')
        assert.equal(ownerOfLucky7Ticket1,0,'not the same owner for Lucky7Ticket1')
        
        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket2,0,'not the same difference for Lucky7Ticket2')
        assert.equal(ownerOfLucky7Ticket2,0,'not the same owner for Lucky7Ticket2')
        
        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket3,0,'not the same difference for Lucky7Ticket3')
        assert.equal(ownerOfLucky7Ticket3,0,'not the same owner for Lucky7Ticket3')
        
        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket4,0,'not the same difference for Lucky7Ticket4')
        assert.equal(ownerOfLucky7Ticket4,0,'not the same owner for Lucky7Ticket4')

        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket5,0,'not the same difference for Lucky7Ticket5')
        assert.equal(ownerOfLucky7Ticket5,0,'not the same owner for Lucky7Ticket5')

        //Difference of 0, owner 0
        assert.equal(differenceOfLucky7Ticket6,0,'not the same difference for Lucky7Ticket6')
        assert.equal(ownerOfLucky7Ticket6,0,'not the same owner for Lucky7Ticket6')
    })


    it("should properly clean the mappings ", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //Then, i will insert the same tickets as the previous test
        //Later, i will use the _cleanMapppings function of the Lucky7Ballot to
        //clean the mappings both for lucky7Tickets and ExactLucky7Tickets, i.e
        //lucky7TicketDifference, lucky7TicketOwner, lucky7TicketID, ExactLucky7TicketValue
        //ExactLucky7TicketOwner, and ExactLucky7TicketID
        //The storage of them was already demonstrated in previous tests so is not going to be
        //showed in this one

        //Insert same tickets as the previous test, then call _orderLucky7Tickets
        const lucky7Ballot = await Lucky7Ballot.new()
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191,0)
        await lucky7Ballot.insertCustomizedTicket("0","0",88808972694141,user1,0)
        let currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469039,user2,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",42125129325441,user3,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",99008528368194,user4,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",55525851604567,user5,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",69776513144865,user6,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",77880312560104,user7,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot._orderLucky7Tickets()
        
        //The mappings are not empty at this point
        //After calling _cleanMappings() they're going to be empty
        //the mappings are:
        //lucky7TicketDifference, lucky7TicketOwner, lucky7TicketID, 
        //ExactLucky7TicketValue, ExactLucky7TicketOwner and ExactLucky7TicketID
        //Recalling, there are seven Lucky7Ticket and one ExactLucky7Ticket
        await lucky7Ballot._cleanMappings()
        let lucky7TicketDifference0 = await lucky7Ballot.lucky7TicketDifference(0)
        let lucky7TicketOwner0 = await lucky7Ballot.lucky7TicketOwner(0)
        let lucky7TicketID0 = await lucky7Ballot.lucky7TicketID(0)
        let lucky7TicketDifference1 = await lucky7Ballot.lucky7TicketDifference(1)
        let lucky7TicketOwner1= await lucky7Ballot.lucky7TicketOwner(1)
        let lucky7TicketID1 = await lucky7Ballot.lucky7TicketID(1)
        let lucky7TicketDifference2 = await lucky7Ballot.lucky7TicketDifference(2)
        let lucky7TicketOwner2= await lucky7Ballot.lucky7TicketOwner(2)
        let lucky7TicketID2 = await lucky7Ballot.lucky7TicketID(2)
        let lucky7TicketDifference3 = await lucky7Ballot.lucky7TicketDifference(3)
        let lucky7TicketOwner3= await lucky7Ballot.lucky7TicketOwner(3)
        let lucky7TicketID3 = await lucky7Ballot.lucky7TicketID(3)
        let lucky7TicketDifference4 = await lucky7Ballot.lucky7TicketDifference(4)
        let lucky7TicketOwner4= await lucky7Ballot.lucky7TicketOwner(4)
        let lucky7TicketID4 = await lucky7Ballot.lucky7TicketID(4)
        let lucky7TicketDifference5 = await lucky7Ballot.lucky7TicketDifference(5)
        let lucky7TicketOwner5= await lucky7Ballot.lucky7TicketOwner(5)
        let lucky7TicketID5 = await lucky7Ballot.lucky7TicketID(5)
        let lucky7TicketDifference6 = await lucky7Ballot.lucky7TicketDifference(6)
        let lucky7TicketOwner6 = await lucky7Ballot.lucky7TicketOwner(6)
        let lucky7TicketID6 = await lucky7Ballot.lucky7TicketID(6)
        let ExactLucky7TicketValue0 = await lucky7Ballot.ExactLucky7TicketValue(0)
        let ExactLucky7TicketOwner0 = await lucky7Ballot.ExactLucky7TicketOwner(0)
        let ExactLucky7TicketID0 = await lucky7Ballot.ExactLucky7TicketID(0)
        
        //Checking the differences
        assert.equal(lucky7TicketDifference0,0,'lucky7TicketDifference0 Is not cleared')
        assert.equal(lucky7TicketDifference1,0,'lucky7TicketDifference1 Is not cleared')
        assert.equal(lucky7TicketDifference2,0,'lucky7TicketDifference2 Is not cleared')
        assert.equal(lucky7TicketDifference3,0,'lucky7TicketDifference3 Is not cleared')
        assert.equal(lucky7TicketDifference4,0,'lucky7TicketDifference4 Is not cleared')
        assert.equal(lucky7TicketDifference5,0,'lucky7TicketDifference5 Is not cleared')
        assert.equal(lucky7TicketDifference6,0,'lucky7TicketDifference6 Is not cleared')
        assert.equal(ExactLucky7TicketValue0,0,'ExactLucky7Value0 is not cleared')
        
        //Checking the owners
        assert.equal(lucky7TicketOwner0,0,'lucky7TicketOwner0 is not cleared')
        assert.equal(lucky7TicketOwner1,0,'lucky7TicketOwner1 is not cleared')
        assert.equal(lucky7TicketOwner2,0,'lucky7TicketOwner2 is not cleared')
        assert.equal(lucky7TicketOwner3,0,'lucky7TicketOwner3 is not cleared')
        assert.equal(lucky7TicketOwner4,0,'lucky7TicketOwner4 is not cleared')
        assert.equal(lucky7TicketOwner5,0,'lucky7TicketOwner5 is not cleared')
        assert.equal(lucky7TicketOwner6,0,'lucky7TicketOwner6 is not cleared')
        assert.equal(ExactLucky7TicketOwner0,0,'ExactLucky7Owner0 is not cleared')
        
        //Checking the ticketIDs
        assert.equal(lucky7TicketID0,0,'lucky7TicketID0 is not cleared')
        assert.equal(lucky7TicketID1,0,'lucky7TicketID1 is not cleared')
        assert.equal(lucky7TicketID2,0,'lucky7TicketID2 is not cleared')
        assert.equal(lucky7TicketID3,0,'lucky7TicketID3 is not cleared')
        assert.equal(lucky7TicketID4,0,'lucky7TicketID4 is not cleared')
        assert.equal(lucky7TicketID5,0,'lucky7TicketID5 is not cleared')
        assert.equal(lucky7TicketID6,0,'lucky7TicketID6 is not cleared')
        assert.equal(ExactLucky7TicketID0,0,'ExactLucky7ID0 is not cleared')
    })
    
    it("should properly deliver prizes ", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //insert the same tickets as the previous test
        //and call the _setNewGame function
        //This function will save the current Lucky7Tickets for subsequent revisions
        //activate the settingLucky7Number circuit breaker, order the Lucky7Tickets,
        //deliver the prizes and clean all the mappings
        //Particularly, for this test i'll test the deliver prizes
        //Lucky7Ticket owners are awarded for them differences with a Lucky7Number
        //in ascending order
        //The total prize for the users is 70% of the balance of the contract
        //From that 70%, 60% goes to first prize, 30% to second an 10% to third
        //The contract would be found with 10 ETH, so the first prize is going to be 4.2 ETH,
        //the second is going to be 2.1 ETH and the third would be 0.7 ETH

        //Insert same tickets as the previous test, then call _orderLucky7Tickets
        const lucky7Ballot = await Lucky7Ballot.new({value: web3.toWei(10, "ether")})
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191,0)
        await lucky7Ballot.insertCustomizedTicket("0","0",88808972694141,user1,0)
        let currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469039,user2,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",42125129325441,user3,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",99008528368194,user4,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",55525851604567,user5,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",69776513144865,user6,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        await lucky7Ballot.insertCustomizedTicket("0","0",77880312560104,user7,0)
        currentTicketID = await lucky7Ballot.currentTicketID()
        await lucky7Ballot._checkForLucky7Ticket(currentTicketID)
        
        //Call setNewGame to deliver prizes and restart the game
        //The first prize is for user1 account (difference = 0), so 4.2 ETH
        //The second prize is for user2 account (difference = 1), so 2.1 ETH
        //The third prize is for user3 account (difference = 2), so 0.7 ETH
        //The enterprise prize is 3 ETH
        //Because is a "pushpayment" scheme, contract balance would be 7 ETH still
        //because the enterprise prize is automatically delivered
        //Winners have to ask for them prizes within 1 week or them prizes 
        //are going to be erased through the deliverPrizes function for
        //security reasons
        
        await lucky7Ballot.setNewGame()
        let firstPrizeAmount = await lucky7Ballot.pendingWithdrawals(user1)
        let secondPrizeAmount = await lucky7Ballot.pendingWithdrawals(user2)
        let thirdPrizeAmount = await lucky7Ballot.pendingWithdrawals(user3)
        let contractBalance = web3.eth.getBalance(lucky7Ballot.address)
        firstPrizeAmount = parseFloat(web3.fromWei(firstPrizeAmount, "ether"))
        secondPrizeAmount = parseFloat(web3.fromWei(secondPrizeAmount, "ether"))
        thirdPrizeAmount = parseFloat(web3.fromWei(thirdPrizeAmount, "ether"))
        contractBalance = parseFloat(web3.fromWei(contractBalance, "ether"))
        assert.equal(firstPrizeAmount,parseFloat(4.2),'first prize is not 4.2')
        assert.equal(secondPrizeAmount,parseFloat(2.1),'second prize is not 2.1')
        assert.equal(thirdPrizeAmount,parseFloat(0.7),'third prize is not 0.7')
        assert.equal(contractBalance,7,'contract balance is not 7')

        //Check if the drawNumber and initialLucky7TicketPosition are setted to
        //1 and 7 respectively
        let drawNumber = await lucky7Ballot.drawNumber()
        let initialLucky7Position = await lucky7Ballot.initialLucky7TicketPosition()
        assert.equal(drawNumber,1,'drawNumber not equal to 1')
        assert.equal(parseInt(initialLucky7Position),7,'initialLucky7Position not equal to 7')


        //If we call the setNewGame() again, the pendingWithdrawals of the
        //winners are going to be restored to 0, and after the deliverPrizes function call
        //the first, second and third prize are going to be 0 because there's no tickets,
        //i.e. all the Lucky7Tickets are going to be 0
        //The contract balance would be 4.9 because 0.7*0.3=0.21 would be transfered to 
        //the enterprise wallet
        await lucky7Ballot.setNewGame()
        firstPrizeAmount = await lucky7Ballot.pendingWithdrawals(user1)
        secondPrizeAmount = await lucky7Ballot.pendingWithdrawals(user2)
        thirdPrizeAmount = await lucky7Ballot.pendingWithdrawals(user3)
        contractBalance = web3.eth.getBalance(lucky7Ballot.address)
        firstPrizeAmount = parseFloat(web3.fromWei(firstPrizeAmount, "ether"))
        secondPrizeAmount = parseFloat(web3.fromWei(secondPrizeAmount, "ether"))
        thirdPrizeAmount = parseFloat(web3.fromWei(thirdPrizeAmount, "ether"))
        contractBalance = parseFloat(web3.fromWei(contractBalance, "ether"))
        assert.equal(firstPrizeAmount,0,'first prize is not 0')
        assert.equal(secondPrizeAmount,0,'second prize is not 0')
        assert.equal(thirdPrizeAmount,0,'third prize is not 0')
        assert.equal(contractBalance,4.9,'contract balance is not 4.9')
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