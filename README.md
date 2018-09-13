# Lucky7 Lottery

Decentralized lottery-based crowdfunding system on Ethereum Blockchain.

## About the project

This development is the first part of the Lucky7 Lottery project.
Lucky7 Lottery is a descentralized lottery-based crowdfounding system on blockchain.
More details of it can be found in the [White Paper](https://ipfs.infura.io/ipfs/QmaKdc6feSgeEoxvJgqRJ1GzGFxkBTezbBmqM48PzKyUDt).


It uses Oraclize to ask for random numbers which operates as paramaters of a Pseudo-Random Number Generator (PRNG), and to execute the PRNG offchain and store the result on chain.


Lucky7 Lottery is simple. There are going to be 7 numbers, which are the Lucky7Numbers. Once they're setted, the players have two options; to buy a random Ticket or to generate a random Ticket. 


Buying a random Ticket means the user accepts the result whatever it is, paying for it a fee of 0.012 ETH, but registering the ticket as purchased. 

Generate a random Ticket means the user generates the parameters of the PRNG but without registering the Ticket as purchased, paying 0.005 ETH for this action. Advantage of this is that players can "choose" them tickets, and once they're decided, they can pay the 0.012 ETH fee to register the Ticket as purchased. 

Anyway, in both cases the result is going to be random, but the user can choose spending less money with the trade-off of having to pay extra to mark the Ticket as purchased.

Once a Ticket is marked as Purchased, the contracts compares the value of the Ticket with the Lucky7Numbers, i.e. obtains the difference in absolut value between the Ticket and the closest Lucky7Number to it, and if this Ticket is the closest to that  Lucky7Number amongst all existing Tickets, then the Ticket is now a Lucky7Ticket.


The 3 better Lucky7Tickets earns 60%, 30% and 10% of the 70% of the balance of the contract, respectively, i.e. first place (closest Lucky7Ticket to it Lucky7Number) obtains 60% * 70% = 42% of the balance, second place obtains 30% * 70% = 21% and third place obtains 10% * 70% = 7% of the balance of the contract.

Once a week (sundays, for example) the prizes are going to be delivered, the Lucky7Numbers are going to be generated again and the Lucky7Tickets are going to be setted to 0 (saving the values for future references) and the game starts over!.


The balance of the contract is going to increase in the way more players purchase/generates tickets.

The other 30% is the profit of the "company" in charge of the Lucky7 Lottery.

All the above empowered by Blockchain, to make a "fair play" contract and transparent draw.

Lucky7 Lottery is planned to be a win-win crowdfounding system. Once it gains traction and active players, part of the contract balance is going to be dedicated to fund projects postuled by people and voted through tokens.
The tokens are going to be delivered to players according to "how close was the ticket you purchased to a Lucky7Number".
The prizes for ALL projects are going to be proportional to how many tokens were delivered in a certain game and how many tokens they earned, i.e. the prize of a certain project is (amount of tokens gained for that the project)/(amount of tokens delivered to all projects in game N)* (x% of the contract balance). That's what's going to give value to the tokens. More details in the [White Paper](https://ipfs.infura.io/ipfs/QmaKdc6feSgeEoxvJgqRJ1GzGFxkBTezbBmqM48PzKyUDt).

Don't like any project? sell your token, for ETH for example, and buy another Ticket (or ice cream, you decide).

Have an AWESOME idea and need money to fund it? tell people to buy Tickets and vote for your project.

Everybody wins!

Thanks Blockchain!

### Prerequisites

[NPM](https://github.com/npm/cli), to install the next packages.

[Ethereum-bridge](https://github.com/oraclize/ethereum-bridge), for testing Oraclize on local net.

[Truffle Framework](https://github.com/trufflesuite/truffle), for, well, everything related with Ethereum development, and

[NodeJS](https://github.com/nodejs/node) to run some scripts that will help you work easier.

[Ganache-CLI](https://github.com/trufflesuite/ganache-cli) to generate a local blockchain to complete the sandbox. I've been using it with Ganache-GUI but gave me some troubles with Metamask.
 
[Metamask](https://metamask.io/) to have interact with the dApp.

### Installing
Install the prerequisites:
```
npm install -g ethereum-bridge
npm install -g ganache-cli
npm install -g truffle
```
Remember to "sudo" if necessary.

Once that's done, proceed to clone the repository:

```
git clone https://github.com/matiasbn/luckyseven/
```

### Running the project

First, start by running ganache-cli. Use it with the -d parameter to set it "deterministic".
```
ganache-cli -d
```

This way, everytime you run it, it will create the same accounts with the same mnemonic phrase to not lose the connection between Metamask and ganache-cli. Keep using this line for subsequents ganache-cli callings.

Once is running, is time to run ethereum-bridge. The next command will call the ethereum-bridge on localhost, port 8545, using the account 1 (your second account of ganache). The result should be something like this:
```
ethereum-bridge -H localhost -p 8545 -a 1
Please wait...
[2018-08-27T21:19:29.650Z] INFO you are running ethereum-bridge -version: 0.6.1
[2018-08-27T21:19:29.654Z] INFO saving logs to: ./bridge.log
[2018-08-27T21:19:29.656Z] INFO using active mode
[2018-08-27T21:19:29.656Z] INFO Connecting to eth node http://localhost:8545
[2018-08-27T21:19:31.241Z] INFO connected to node type EthereumJSTestRPC/v2.2.0/ethereum-js
[2018-08-27T21:19:32.048Z] WARN Using 0xffcf8fdee72ac11b5c542428b35eef5769c409f0 to query contracts on your blockchain, make sure it is unlocked and do not use the same address to deploy your contracts
[2018-08-27T21:19:32.282Z] INFO deploying the oraclize connector contract...
[2018-08-27T21:19:42.982Z] INFO connector deployed to: 0xd3aa556287afe63102e5797bfddd2a1e8dbb3ea5
[2018-08-27T21:19:43.181Z] INFO deploying the address resolver with a deterministic address...
[2018-08-27T21:20:05.272Z] INFO address resolver (OAR) deployed to: 0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475
[2018-08-27T21:20:05.273Z] INFO updating connector pricing...
[2018-08-27T21:20:16.736Z] INFO successfully deployed all contracts
[2018-08-27T21:20:16.750Z] INFO instance configuration file savedto /Users/matiasbarrios/Desktop/Proyecto Consensys/luckyseven/ethereum-bridge/config/instance/oracle_instance_20180827T182016.json

Please add this line to your contract constructor:

OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

[2018-08-27T21:20:16.765Z] WARN re-org block listen is disabled while using TestRPC
[2018-08-27T21:20:16.766Z] WARN if you are running a test suit with Truffle and TestRPC or your chain is reset often please use the--dev mode
[2018-08-27T21:20:16.766Z] INFO Listening @ 0xd3aa556287afe63102e5797bfddd2a1e8dbb3ea5 (Oraclize Connector)

```

As told, copy the next line:
```
OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
```
To the Lucky7TicketFactory.sol constructor . Just by copying the address inside the OraclizeAddrResolverI() is sufficient.
The contract is in the contracts directory. Save the file.

At this point you should be running 2 consoles windows. Don't close them. Neither run them as daemon because you need the information they give you. I recommend you to use Visual Studio Code (or any code editor you like) to edit files while looking the console the code editor gives you.

Go to a command line (again, you see, 3 consoles, that's why is good to use an integrated code editor-console view), go to luckyseven directory and run:
```
truffle console
```
It will connect to ganache-cli. Then run:

```
truffle(development)> migrate
```
Which will give you something like this:
```
Using network 'development'.

Running migration: 1_initial_migration.js
  Deploying Migrations...
  ... 0x1b990fe6a71e4ed7430dbfdac0ca754b81aab9a199ec2a797c749546f3c9e0ab
  Migrations: 0xe78a0f7e598cc8b0bb87894b0f60dd2a88d6a8ab
Saving artifacts...
Running migration: 2_deploy_Lucky7.js
  Deploying Lucky7FrontEndFunctions...
  ... 0x589eb050818c073db7a0a803e0f1b64c6044e829a481d16121381eaa2e0d22b6
  Lucky7FrontEndFunctions: 0x5b1869d9a4c187f2eaa108f3062412ecf0526b24
Saving artifacts...
```

Copy the address of the Lucky7FrontEndFunctions (0x5b1869d9a4c187f2eaa108f3062412ecf0526b24 in this case), go to a different console and run the next on the luckyseven directory:

```
node auxiliaryScript.js 0x5b1869d9a4c187f2eaa108f3062412ecf0526b24
```
Replacing my address by your contract address. It should prompt something like this:
```
var contract = Lucky7FrontEndFunctions.at('0x5b1869d9a4c187f2eaa108f3062412ecf0526b24')
```
Copy it an paste it in the truffle console window and hit enter:
```
truffle(development)> var contract = Lucky7FrontEndFunctions.at('0x5b1869d9a4c187f2eaa108f3062412ecf0526b24')
```

Now you can access easy to the contract functions, which will save you a lot of time typing. You'll have to call auxiliaryScript.js EVERYTIME you migrate a new contract.
You can as well do it manually, but i think this way is faster. You choose.

Open (another) console windows, go to the luckyseven directory and run:
```
npm run dev
```

It will open your browser and redirect you directly to the dApp page.
You should see something like this:
![dApp front end](https://ipfs.infura.io/ipfs/QmZmRBM66VWGerrsE9XkdPadsNcopdWrfibxtwoNAp2UPN) 

Among other (for now) cryptic fields.

If the "Your account" field is equal to your Metamask current account, congrats! you're ready to start using and testing the dApp. You'll realize that clicking any button will advert "revert" in Metamask; it is because the game is in the "setting Lucky7Numbers" phase, which means users (you in this case) can't buy tickets because the Lucky7Numbers are getting setted.
This state is the same the contract acquires when the prizes are delivered; the Lucky7Numbers are empty and need to be determined to let players buy Tickets.

To set the Lucky7Numbers, go back to your truffle console and type:
```
truffle(development)> contract._generateLucky7Number()
```

(Quickly) go to your ethereum-bridge console. You'll see a lot of ~~garbage~~ interesting information, running to finally show something like this:

```
contract 0xc89ce4735882c9f0f0fe26686c53074e09b0d550 __callback tx sent, transaction hash: 0x04dcf34c51a12e98079c24baeba317ba860eed989231a65e933ebbb82699fe26
        {
    "myid": "0x80e0bd2215f53cc097074b4a2eb052c0c824bf84978411bb4cd7af5aacb4f58a",
    "result": "34324321383748026376",
    "proof": null,
    "proof_type": "0x00",
    "contract_address": "0xc89ce4735882c9f0f0fe26686c53074e09b0d550",
    "gas_limit": 300000,
    "gas_price": 4000000000
}
```

Go to the dApp webpage and check if it is true:
[dApp updated with Lucky7Number](https://ipfs.infura.io/ipfs/QmYrERs3MuVtSKCUA3GjijatqAuhQjsPd15snhfjKQHWAE)

WARNING: the contracts are not prepared to handle more than one process of setting Lucky7Numbers at the same time,i.e. wait for the Lucky7Number to be generated before calling the function again.

It take some time to get a Lucky7Number, so for testing purposes i inserted functions to generate them artificially:
```
truffle(development)> contract.insertCustomizedLucky7Number(2,"mu","i",12345678901234567890,0)
```
Beeing the 2 the position (counting from 0, off course) to put the Lucky7Number. In this case it would be the third Lucky7Number. Values of "mu" and "i" are not important if you are defining the Lucky7Number. 12345678901234567890 is the value of the Lucky7Number, and 0 is the "drawID", i.e. the id of the game we are playing now. The contracts are setted to generate 20 digits long Tickets and Lucky7Numbers, so it would be a good idea to choose 20 digits long determined if you want to insert them artificially.

After you inserted them artificially, you should set the "indexForLucky7Array" to 7:
```
truffle(development)> contract.setIndexForLucky7Array(7)
```
This way, you emulate the behavior of generate the Lucky7Numbers not-artificially. This is not necessary if you generated the tickets through the generateLucky7Number.


Once you done that, call the generateLucky7Numbers again to order them.

```
truffle(development)> contract._generateLucky7Number()
```

Now the Lucky7Numbers should appear in ascending order, and you'll have to be capable of generating and buying random Tickets!
WARNING: this function should be erased in production. It will be a HUGE mistake to have the capability of choosing the Lucky7Numbers. Nobody will trust a contract this deterministic as a Lottery.

Once you finished buying tickets (with different accounts for extra fun!) you are ready to deliver the prizes. Be careful of, as with the Lucky7Numbers, not calling the "I'm feeling lucky!" button before receiving your ticket. It is a bug and is going to be fixed in the future. 

Go back to the truffle console and type:
```
truffle(development)> contract.setNewGame
```
This will erase the current, well, all. Take a look at all the boxes, they should be saying "Still vacant".

Now look the last box. This contains the winners, the differences and the prices. Check for every address with Metamask and claim your prizes.

Now you are ready to start a new game. 

If you try this:
```
truffle(development)> contract._generateLucky7Number()
```

You'll have a revert exception. This is because the generateLucky7Number() does a Oraclize query which requires that the contract have enough ETH to do the querys. When the contract was deployed, it was funded with 1 ETH so it was more than enough to generate the Lucky7Numbers and deliver proper prizes.

You have to fund the contract by sending it some ether, e.g. by sending ETH with Metamask to the contract address.

That's it!

### The project-running cycle
1. Ganache-cli with -d parameter.

2. Ethereum-bridge on the ethereum-bridge directory. Copy and paste the OAR on the constructor of the Lucky7TicketFactory contract.

3. Truffle console, then migrate the contract.

4. Use the auxiliaryScript to generate the var for the truffle console.

5. npm run dev.

6. Check the address. You can't buy tickets yet.

7. Generate the Lucky7Numbers. If not by the generateLucky7Numbers, by the insertCustomizedLucky7Number function. Remember to call the setIndexForLucky7Array(7) function and then the generateLucky7Number function to order them.

8. Now you can buy tickets. Buy a lot with different users to check consistency of the contract.

9. Start a new game by calling the setNewGame function.

10. Fund the contract with ETH to be capable of calling the generateLucky7Numbers again.

11. Generate the Lucky7Numbers and start the game again.

## Running the tests

To properly run the tests, is necessary some considerations:

1. Exagerate the block gas limit and Ether fund for the accounts. This is because the tests have several storages due to avoid waiting for the Lucky7Numbers and the Tickets by inserting them with . This two actions are tested when is proper to, but not in every test.
```
ganache-cli -d -l 40000000 -e 10000
```

2. Test every contract ONE BY ONE, i.e. in the luckyseven main directory:
```
truffle test ./test/lucky7Admin.test.js
```
Then:
```
truffle test ./test/lucky7TicketFactory.test.js
```
Then:
```
truffle test ./test/lucky7Ballot.test.js 
```
Then:
```
truffle test ./test/lucky7Store.test.js
```

This will run just the Lucky7TicketFactory. This is important because in some ocassions, ethereum-bridge behaves strange and stop doing queries.

3. The tests take a lot of time. This is because the waiting for the oraclize querys to be resolved. Please be patient.

4. run the ethereum-bridge un dev mode
```
ethereum-bridge ./ethereum-bridge -H localhost -p 8545 -a 1 --dev 
```

All the tests were tested and all they are passing.

The explanation for every test is written inside every test file, in the test directory of the project.

Again, __DO __NOT __TRY:
```
truffle test
```

because is likely to get stuck. Test every contract by separate.

## Libraries

The contracts use the SafeMath contract of the OpenZeppelin project to avoid Integer Underflow/Overflow problems. Particularly, it is used on the checkForLucky7Ticket function of the Lucky7TicketFactory contract to add and substract values. It was a good way to check if the difference was 0, to check if the Ticket was a ExactLucky7Number.

## mbn.py

In later deployments, the PRNG is going to be presented. By noew, the file mbn.py of the directory python contains a function where mu and i can be replaced. If you ran a generateLucky7Number or a sellRandomTicket function, you can take the parameters and replace them in the file, then run :
```
python mbn.py
```
and the result is (and should) be the same as the Ticket or Lucky7Number generated. Due to complications of implementing Big Numbers on Javascript, this was not implemented n the front end. Therefore it is absolutely necessary to implement this function when the project gets in production, because people NEEDS to know the result of them new purchased parameters before purchasing the ticket, and telling them to run a python file is not the better idea. Either way, the PRNG is easily implementable; three code lines for the case of python, which manage the Big Numbers internally.

This file can be used as a PRNG itself for various purposes, e.g. to generate Lucky7Numbers and insert them artificially through the insertCustomizedLucky7Number function of the Lucky7Ballot contract.

## Testnet

The project can be recently found deployed to Rinkeby testnet. 

You can get Rinkeby ETH from [The Rinkeby faucet](https://faucet.rinkeby.io/).

Front end is deployed and working at IPFS in [this link](https://ipfs.infura.io/ipfs/QmXoKWUoE5f6dZK8st3a7QiLDB1E8sJ9y4p1QgSq8vSkjo/src/).

## The story behind the PRNG

I wrote an article on [Medium](https://medium.com/@matias.barriosn/how-i-realized-as-an-adult-that-ive-been-studying-number-theory-since-i-was-a-kid-a8b49ea57a87) about how i get to the PRNG. Read it and give me some claps.

## Authors

* **Matías Barrios** 

