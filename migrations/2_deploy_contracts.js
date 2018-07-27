var Lucky7 = artifacts.require("Lucky7");
var Oraclize = artifacts.require("usingOraclize");

module.exports = function(deployer) {
  deployer.deploy(Lucky7);
  deployer.deploy(Oraclize);
};
