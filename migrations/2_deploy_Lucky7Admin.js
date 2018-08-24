var Lucky7Admin= artifacts.require("Lucky7Admin");
var Lucky7TicketFactory= artifacts.require("Lucky7TicketFactory");
var Lucky7Store= artifacts.require("Lucky7Store");
var Lucky7Ballot= artifacts.require("Lucky7Ballot");

// const owner = web3.eth.accounts[0]

module.exports = function(deployer) {
  deployer.deploy(Lucky7Admin,{
    //gas: 13000000,
    //value: 1000000000000000000
    });
  deployer.deploy(Lucky7TicketFactory,{
    //gas: 13000000,
    // from: owner,
    value: 1000000000000000000
    });
  deployer.deploy(Lucky7Ballot,{
    //gas: 13000000,
    // value: 1000000000000000000
    });
  deployer.deploy(Lucky7Store,{
    //gas: 13000000,
    value: 1000000000000000000
    });
};
