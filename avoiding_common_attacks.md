## Security tools/Common attacks
### Withdrawal from contract
As told, choosing a Withdrawal from contract pattern let me avoid the DoS with (Unexpected) revert attack. If i weren't aware of it, everytime  i setted a new game by using the setNewGame of the Lucky7Ballot contract, and if my contract were victim of this attack, probably the game would be stucked, because when the deliverPrizes function of the Lucky7Ballot were called, the transaction would be reverted and the prizes wouldn't be delivered. 

### Cleaning the previous winners
This design pattern is better illustrated with an example.

Case: 10 ETH for the winners, Player1 prize is 6 ETH, Player2 is 3 ETH and Player 1 is ETH.
Until the players don't claim they're prizes, the ETH is going to be on the balance of the contract. Let's suppose none of them claimed them prizes.

Next game, the accumulated prize was 90 ETH, so added to the first lot, are 100 ETH.

The prizes are calculated over the balance of the contract, so now the balance is 100 and Player4 prize is 60 ETH, Player5 prize is 30 ETH and Player6 prize is 10 ETH.

Player1 claims it prize (6 ETH, 94 ETH in the balance), Player2 too (3 ETH, 91 ETH),then Player3 (1 ETH, 90 ETH), then Player5 (30 ETH, 60 ETH) and then Player6 (10 ETH, 50 ETH)). 

Now, when Player4 tries to claim it prize, it would be unfeasibleand and would be reverted (because, Player4 prize is 60 ETH and balance is 50 ETH). 

That's why i choose to set to 0 the pendingWithdrawals everytime a new game is setted, because the games are going to be resetted every 1 week, more than enogh time to claim the prizes. (and be honest, 30 ETH!!!, GIVE ME THAT RIGHT NOW!!!)

### Integer Underflow or Overflow

The contracts of this project are oriented basically to ask for random numbers and compare them. Asking for the numbers is not a problem, but to "compare" them is. Due to Solidity language 