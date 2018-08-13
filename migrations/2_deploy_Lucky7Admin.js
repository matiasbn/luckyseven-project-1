var Lucky7TicketFactory = artifacts.require("Lucky7Store");

module.exports = function(deployer) {
  deployer.deploy(Lucky7TicketFactory,{
    gas: 7000000
    });
};
