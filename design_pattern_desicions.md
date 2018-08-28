# Design Pattern Requirements
## Circuit breakers
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

## Contract modularity and inheritances
The inheritances are as follow:
Lucky7Admin -> Lucky7TicketFactory -> Lucky7Ballot -> Lucky7Store -> Lucky7FrontEndFunctions

In the earlier stages of this project the contracts were pretty simple, but as the requirements were appearing, the code was getting more and more complex.
That's why i decided to divide the business logic in 4 modules:

1. Service Administration: Lucky7Admin

This contract contains the functions to change the selling and generating tickets prices, the oraclize gas limit and gas price and the wallet where the 30%
of the balance of the contract os going when a new game is setted.

2. Random numbers generation: Lucky7TicketFactory

This contract contains all the functions that generate random numbers, i.e. generates parameters, Tickets and Lucky7Numbers. This is the very essence of the game, the random numbers generated

3. Taking decisions to make the game work: Lucky7Ballot

This contract containts the function to know how and when to generate the Lucky7Numbers, when to Store the Lucky7Tickets in the lucky7TicketsArray of the Lucky7TicketFactory contract, how to order the Lucky7Numbers and Lucky7Tickets in ascending order, how to deliver the prizes, what parameters increment and what arrays to clean when a the setNewGame function is called.

4. The market: Lucky7Store

This contract contains the functions necessary to determine when to sell and generate tickets and when to stop to do it.

5. The frontend connection: Lucky7FrontEndFunctions

This contract contains the functions necessaries to extract the arrays with information of Tickets, Lucky7Numbers and Lucky7Tickets. This contract is not part of the business logic of the system.

## [Withdrawal from contracts](https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html#withdrawal-from-contracts) and not sending ETH to 0
When the setNewGame function of the Lucky7Ballot is called, it then calls the deliverPrizes function, which deliver the prizes for the best Lucky7Tickets. It proceed to check that the owner of those Lucky7Tickets is not an address 0, and then store the prizes on the pendingWithdrawals mapping. This way we avoid a DoS with (Unexpected) revert attack; the winners have to claim for them prizes instead of being automatically delivered.

## Lucky7Admin functions
The Lucky7Admin contract contains all the parameters to control the game, and functions to modify them. With the time, the price of the ETHER is going to change, so the price have to be updated regularly. That's why there's functions to modify the prices for selling and generating ticket, and for the oraclize querys (gas limit and price).

## Feature Contracts
Ownable: OpenZeppelin contract. There's a lot of functions which are necesarily stricted to the admins. It's used for the onlyOwner modifier.

Destructible: In case of emergency, to not lose the ETH of the contract. Is true that using this contracts makes the service "more centralized", but is a necessary precaution which should be evaluated in the future.

## Random Number Generator (Soon to be published)
Not presented yet, but is kind of a "numeric hash". While is true that Oraclize have a perfectly functional entropy source that could do the work, users needs a way to certificate that the game is not biased. That's why using this PRNG is important; since it acts as a "numeric hash", is unlikely to know the inputs that are going to produce certain output. It also works as a "watermark"; users can verify themselves that the tickets obtained corresponds to the paramaters purchased. Today, the parameters are 4 digits number, which means a space of (10000-1000)^2=81.000.000 distinct combinations, therefore that amount of numbers. The calculus comes from the idea that when asked for a 4 digit number, Wolfram responds with a number with the most significant digit distinct than 0, or strictly greater than 999 to be exact. 

Changing the query to 5 digits numbers, would result in a (100000-10000)^2 = 8.100.000.000 distinct numbers. This, asking for 2 parameters. Ask for 3 parameters would result in astronomics numbers. Future possibilities to ensure entropu of the game.

That said, the PRNG takes the mu and i parameter to generate Tickets and Lucky7Numbers.

## Prizes choice
The 60%, 30% and 10% corresponds to a sum that, the first value divided by 2, plus the second value divided by 3, sums up 100%. This way, the second place gains half of the prize of the first prize, and the third place gains the third part of the second place prize.

## Lucky7Ticket and Tickets storage
Lucky7Tickets and Tickets are stored permanently on the Blockchain to verify, in future gams and if a user wants to, that all the prices where delivered correctly. There have to be a work of "transparency", where users can claim they are the winner of certain past prize, and can demonstrate it through the values of the stored LuckyTickets and Tickets.

## Deliver Prizes manually
There were two options to deliver prizes. Depending on time and depending on contract balance:

1. First wasn't a good idea since miners can change the timestamp of the blocks and "finish" the game before if is good for them, e.g "is necessary to finish the game noew that i'm the first prize"
2. Second was even worst, because of the same reason but the "attack" can be even faster; if some user estimates that if he sends 20 ETH to the contract he is going to win 100 ETH, then is a good deal. Is necessary to avoid this attack, called Forcibly Sending Ether to a Contract.

That's why i decided to manually finish the games. Stop the ticket selling and generating is easy through the circuit breaker presented at the init of this document. Once the setNewGame is called, the selling is stopped. Again, this makes the service "more centralized" but the trade-off where too risky to make the game completely descentralized.
That's why is necessary to generate imagen of trust on the system, because at the end of the day, the way it works, an if it works at big scale, benefits a lot of people, making it a sustainable business model.

## Oraclize gas limit and gas price

OraclizeCustomGasPrice and OraclizeGasLimit where calculated in such way that the tickets weren't so expensive and the oraclize querys were to slow. This process was done on Rinkeby testnet through remix.

## ExactLucky7Ticket

An ExactLucky7Ticket is a Lucky7Ticket which difference is 0 with the Lucky7Number. Due to "high entropy" of the PRNG, is pretty unlikely to have two equal numbers without having the same parameters. Is such an improbable event that it have to be specially prized. On the other hand, the game is setted to, if a second ExactLucky7Number ocurs for the same Lucky7Number, the first ExactLucky7Ticket stays and the second is therefore not selected as Lucky7Ticket. Being the first ExactLucky7Ticket for a Lucky7Number is such a good thing, but being the second is horrible bad luck. 

That's way the ExactLucky7Tickets are going to be stored, to award them specially in the future, once the tokens are created, for example