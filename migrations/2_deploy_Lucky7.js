var Lucky7Admin= artifacts.require("Lucky7Admin");
var Lucky7TicketFactory= artifacts.require("Lucky7TicketFactory");
var Lucky7Ballot= artifacts.require("Lucky7Ballot");
var Lucky7Store= artifacts.require("Lucky7Store");
var Lucky7FrontEndFunctions= artifacts.require("Lucky7FrontEndFunctions");

// const owner = web3.eth.accounts[0]

module.exports = function(deployer) {
  // deployer.deploy(Lucky7Admin,{
  //   //gas: 13000000,
  //   //value: 1000000000000000000
  //   });
  // deployer.deploy(Lucky7TicketFactory,{
  //   //gas: 13000000,
  //   // from: owner,
  //   // value: 1000000000000000000
  //   });
  // deployer.deploy(Lucky7Ballot,{
  //   // gas: 4000000000,
  //   // value: 1000000000000000000
  //   });
  // deployer.deploy(Lucky7Store,{
  //   // gas: 400000000,
  //   value: web3.toWei(1,"ether")
  //   });
  deployer.deploy(Lucky7FrontEndFunctions,{
    // gas: 400000000,
    value: web3.toWei(1,"ether")
    });
};
