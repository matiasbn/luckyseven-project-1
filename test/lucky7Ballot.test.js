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
    
    // it("should ask for a new Lucky7Number and store it in the Lucky7Numbers array", async() => {
    //     //For this test, we will call the _generateLucky7Number function
    //     //Once the Lucky7Number is obtained, it should be stored and saved on the first position
    //     //of the lucky7Number array of the Lucky7Factory contract and indexForLucky7Array should increase in 1
    //     const lucky7Ballot = await Lucky7Ballot.new({value: 100000000000000000})
    //     let indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

    //     //Check if indexForLucky7Array is iniitialized on 0
    //     assert.equal(indexForLucky7Array,0,'Index not initialized on 0')

    //     //Generate a new Lucky7Number
    //     await lucky7Ballot._generateLucky7Number({from: owner})
    //     let eventWatcher = promisifyLogWatch(lucky7Ballot.NewLucky7Number({ fromBlock: 'latest' }))
    //     log = await eventWatcher
    //     assert.equal(log.event, 'NewLucky7Number', 'NewLucky7Number not emitted.')
    //     let generatedLucky7Number= parseInt(log.args.value)
        
    //     //Check if the first Lucky7Number is on the position 0
    //     let firstLucky7Number = await lucky7Ballot.lucky7Numbers(0)
    //     firstLucky7Number = parseInt(firstLucky7Number[2])
    //     assert.equal(generatedLucky7Number,firstLucky7Number, 'First Lucky7Numbers should match')

    //     //Check if indexForLucky7Numbers was increased
    //     indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

    //     //Check if indexForLucky7Array is 1 now
    //     assert.equal(indexForLucky7Array,1,'Index should be 1')
        
    //     //Generate a new Lucky7Number to check one last time
    //     await lucky7Ballot._generateLucky7Number({from: owner})
    //     eventWatcher = promisifyLogWatch(lucky7Ballot.NewLucky7Number({ fromBlock: 'latest' }))
    //     log = await eventWatcher
    //     assert.equal(log.event, 'NewLucky7Number', 'NewLucky7Number not emitted.')
    //     generatedLucky7Number= parseInt(log.args.value)
        
    //     //Check if the first Lucky7Number is on the position 0
    //     let secondLucky7Number = await lucky7Ballot.lucky7Numbers(1)
    //     secondLucky7Number = parseInt(secondLucky7Number[2])
    //     assert.equal(generatedLucky7Number,secondLucky7Number, 'Second Lucky7Numbers should match')

    //     //Check if indexForLucky7Numbers was increased
    //     indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()

    //     //Check if indexForLucky7Array is 2 now
    //     assert.equal(indexForLucky7Array,2,'Index should be 2')
    // })
    
    // it("should sort the Lucky7Numbers when _generateLucky7Number is called for the eighth time", async() => {
    //     //Generating the Lucky7Numbers take time, a lot, even with a local network
    //     //That's why i'm using the insertCustomizedLucky7Number, insertCustomizedLucky7Ticket and
    //     //setIndexForLucky7Array of the Lucky7Ballot contract (at the bottom of the contract) to generate them virtually
    //     //without waiting


    //     //The mu and i paramaters value don't need to make sense at this point
    //     //This ticket value can be generated with the mbn.py of the python directory of this project

    //     const lucky7Ballot = await Lucky7Ballot.new({value: 100000000000000000})
    //     await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",99008528368191788285,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",23532579469038280293,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",69776513144870210205,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",42125129325443168719,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",88808972694141777419,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",55525851604563385589,0)
    //     await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",77880312560110550161,0)

    //     //Check if they were inserted, just by looking up two, the 1 and 4 for example

    //     let lucky7Number1 = await lucky7Ballot.lucky7Numbers(1)
    //     let lucky7Number4 = await lucky7Ballot.lucky7Numbers(4)
    //     lucky7Number1 = parseInt(lucky7Number1[2])
    //     lucky7Number4 = parseInt(lucky7Number4[2])
    //     assert.equal(lucky7Number1,23532579469038280293, 'Lucky7Numbers1 should match')
    //     assert.equal(lucky7Number4,88808972694141777419, 'Lucky7Numbers4 should match')

    //     //Now we can check if by calling _generateLucky7Number the numbers are going to be sorted
    //     //First, we have to set the indexForLucky7Array to 7, in this way the _generateLucky7Number function is going
    //     //to call the _orderLucky7Numbers function
    //     //Calling the _generateLucky7Number function in this case is the same as doing it for the eighth time
    //     //as showed on the first test function
        
    //     await lucky7Ballot.setIndexForLucky7Array(7)
    //     await lucky7Ballot._generateLucky7Number({from: owner})
        
    //     //Now lets check if they were sorted
    //     //I generated them purposely with the first digit different to easily see
    //     //which is bigger
    //     let lucky7Number0 = await lucky7Ballot.lucky7Numbers(0)
    //     lucky7Number1 = await lucky7Ballot.lucky7Numbers(1)
    //     let lucky7Number2 = await lucky7Ballot.lucky7Numbers(2)
    //     let lucky7Number3 = await lucky7Ballot.lucky7Numbers(3)
    //     lucky7Number4 = await lucky7Ballot.lucky7Numbers(4)
    //     let lucky7Number5 = await lucky7Ballot.lucky7Numbers(5)
    //     let lucky7Number6 = await lucky7Ballot.lucky7Numbers(6)
    //     lucky7Number0 = parseInt(lucky7Number0[2])
    //     lucky7Number1 = parseInt(lucky7Number1[2])
    //     lucky7Number2 = parseInt(lucky7Number2[2])
    //     lucky7Number3 = parseInt(lucky7Number3[2])
    //     lucky7Number4 = parseInt(lucky7Number4[2])
    //     lucky7Number5 = parseInt(lucky7Number5[2])
    //     lucky7Number6 = parseInt(lucky7Number6[2])
    //     assert.equal(lucky7Number0,23532579469038280293, 'Lucky7Numbers0 should match')
    //     assert.equal(lucky7Number1,42125129325443168719, 'Lucky7Numbers1 should match')
    //     assert.equal(lucky7Number2,55525851604563385589, 'Lucky7Numbers2 should match')
    //     assert.equal(lucky7Number3,69776513144870210205, 'Lucky7Numbers3 should match')
    //     assert.equal(lucky7Number4,77880312560110550161, 'Lucky7Numbers4 should match')
    //     assert.equal(lucky7Number5,88808972694141777419, 'Lucky7Numbers5 should match')
    //     assert.equal(lucky7Number6,99008528368191788285, 'Lucky7Numbers6 should match')
    // })
    
    it("should ask for a new ticket and check if it is a Lucky7Ticket", async() => {
        //For this test, i will set the Lucky7Numbers already sorted
        //Then, i will insert a ticket with a difference of 2 compared to a Lucky7Number
        //This will generate a Lucky7Ticket (because they're empty)
        //Then i will insert another ticket with a difference of 1 with the same number
        //Of the first Lucky7Number. This should replace the old Lucky7Ticket
        //I will insert another but close to another Lucky7Number and check if the difference are OK
        const lucky7Ballot = await Lucky7Ballot.new({value: 100000000000000000})
        await lucky7Ballot.insertCustomizedLucky7Number(0,"0","0",23532579469038280293,0)
        await lucky7Ballot.insertCustomizedLucky7Number(1,"0","0",42125129325443168719,0)
        await lucky7Ballot.insertCustomizedLucky7Number(2,"0","0",55525851604563385589,0)
        await lucky7Ballot.insertCustomizedLucky7Number(3,"0","0",69776513144870210205,0)
        await lucky7Ballot.insertCustomizedLucky7Number(4,"0","0",77880312560110550161,0)
        await lucky7Ballot.insertCustomizedLucky7Number(5,"0","0",88808972694141777419,0)
        await lucky7Ballot.insertCustomizedLucky7Number(6,"0","0",99008528368191788285,0)
        
        //This number has a difference of 2 with the first Lucky7Number
        let ticketID = await lucky7Ballot.insertCustomizedTicket("0","0",23532579469038280295,user1,0)
        console.log(ticketID)
        //Check if it was stored


        await lucky7Ballot.insertCustomizedTicket("0","0",23532579469038280295,user1,0)


        //     //Check if indexForLucky7Array is iniitialized on 0
        //     assert.equal(indexForLucky7Array,0,'Index not initialized on 0')
        
        //     //Generate a new Lucky7Number
        //     await lucky7Ballot._generateLucky7Number({from: owner})
        //     const eventWatcher = promisifyLogWatch(lucky7Ballot.NewLucky7Number({ fromBlock: 'latest' }))
        //     log = await eventWatcher
        //     assert.equal(log.event, 'NewLucky7Number', 'NewLucky7Number not emitted.')
        //     const generatedLucky7Number= parseInt(log.args.value)
        
        //     //Check if the first Lucky7Number is on the position 0
        //     let firstLucky7Number = await lucky7Ballot.lucky7Numbers(0)
        //     firstLucky7Number = parseInt(firstLucky7Number[2])
        //     assert.equal(generatedLucky7Number,firstLucky7Number, 'First Lucky7Numbers should match')
        
        //     //Check if indexForLucky7Numbers was increased
        //     indexForLucky7Array = await lucky7Ballot.indexForLucky7Array()
        
        //     //Check if indexForLucky7Array is iniitialized on 0
        //     assert.equal(indexForLucky7Array,1,'Index should be 1')
        
    })
});


// function insertCustomizedLucky7Number(uint _id, string _mu, string _i, uint _ticketValue,uint _drawNumber) public onlyOwner{
//     lucky7Numbers[_id] = Lucky7Number(_mu, _i, _ticketValue, _drawNumber);
// }


// function insertCustomizedTicket(string _mu, string _i, uint _ticketValue,address _ticketOwner, uint _drawNumber) 
//     public 
//     onlyOwner 
//     returns (uint){
//         uint id = tickets.push(Ticket(_mu,_i,_ticketValue,_ticketOwner,drawNumber)) - 1;
//         return id;
//     }

// function setIndexForLucky7Array(uint _newValue) public onlyOwner{
//     indexForLucky7Array = _newValue;
// }


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