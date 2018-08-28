## Design Pattern Requirements
### Circuit breakers
The project includes 2 circuit breakers. This are translated in two modifiers:

1. To stop selling tickets while the setting Lucky7Numbers phase is happening:
```
modifier sellingIsActive {
        require(settingLucky7Numbers==false);
        _;
    }
```
This modifier is in the Lucky7Store contract and is related to the sellRandomTicket, generateRandomTicket, and sellGeneratedTicket functions.

2. To stop the possible generation of Lucky7Numbers while a game is in curse:
```
modifier gameNotInCourse(){
        require(settingLucky7Numbers==true);
        _;
    }
```
This modifier is in the Lucky7Ballot contract and is related to the generateLuckyNumber which generates the Lucky7Numbers. The settingLucky7Numbers value is changed once the setNewGame of the Lucky7Ballot contract is called, i.e. when a new game is setted and is necessary to set the new Lucky7Numbers.

### Contract modularity and inheritances
The inheritances are as follow:
Lucky7Admin -> Lucky7TicketFactory -> Lucky7Ballot -> Lucky7Store -> Lucky7FrontEndFunctions

In the earlier stages of this project the contracts were pretty simple, but as the requirements were appearing, the code was getting more and more complex.
That's why i decided to divide the business logic in 4 modules:
1. Service Administration: Lucky7Admin

This contract contains the functions to change the selling and generating tickets prices, the oraclize gas limit and gas price and the wallet where the 30%
of the balance of the contract os going when a new game is setted.

2. Random numbers generation: Lucky7TicketFactory

This contract contains all the functions that generate random numbers, i.e. generates parame

### [Withdrawal from contracts](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts) and not sending ETH to 0
When the setNewGame function of the Lucky7Ballot is called, it then calls the deliverPrizes function, which deliver the prizes for the best Lucky7Tickets. It proceed to check that the owner of those Lucky7Tickets is not an address 0, and then store the prizes on the pendingWithdrawals mapping. This way we avoid a DoS with (Unexpected) revert attack; the winners have to claim for them prizes instead of being automatically delivered.

### Lucky7Admin functions
The Lucky7Admin contract contains all the parameters to control the game, and functions to modify them. With the time, the price of the ETHER is going to change, so the price have to be updated regularly. That's why there's functions to modify the prices for selling and generating ticket, and for the oraclize querys (gas limit and price).




### Feature Contracts

Ownable
Destructible

### Random Number Generator

### Prizes choice

### Lucky7Ticket and Tickets storage

### Deliver Prizes manually
