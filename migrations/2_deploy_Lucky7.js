var Lucky7Admin= artifacts.require("Lucky7Admin");
var Lucky7TicketFactory= artifacts.require("Lucky7TicketFactory");
var Lucky7Storage= artifacts.require("Lucky7Storage");
var Lucky7Library= artifacts.require("Lucky7Library");
var Lucky7Store= artifacts.require("Lucky7Store");
// var Lucky7Ballot= artifacts.require("Lucky7Ballot");

//Contract addresses
var Lucky7AdminAddress;
var Lucky7StorageAddress;

module.exports = function(deployer) {
  deployer.deploy(Lucky7Library);
  deployer.link(Lucky7Library,Lucky7TicketFactory);
  deployer.link(Lucky7Library,Lucky7Store);
  deployer.deploy(Lucky7Storage).then(function() {
      return deployer.deploy(Lucky7Admin);
    }).then(function() {
    return deployer.deploy(Lucky7TicketFactory, Lucky7Admin.address, Lucky7Storage.address,{
      value: 7*2*300000*4000000000
      });
    }).then(function() {
      return deployer.deploy(Lucky7Store, Lucky7Admin.address, Lucky7Storage.address, Lucky7TicketFactory.address,{
      value: web3.toWei(1,"ether")
      });
    })
}
  // deployer.deploy(Lucky7Admin);
// 

// deployer.deploy(ArrayTes).then(function() {
//   return deployer.deploy(CallFunction, ArrayTes.address);})