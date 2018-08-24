import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Lucky7TicketFactory.sol";

contract TestLucky7TicketFactory{

  function testAskForMuParameter() {
    // Lucky7TicketFactory lucky7TicketFactory = Lucky7TicketFactory(DeployedAddresses.Lucky7TicketFactory());
    // address ticketOwner = address(0x22d491bde2303f2f43325b2108d26f1eaba1e32b);

    // //lucky7TicketFactory._askForMuParameter(ticketOwner);

    // Assert.isNotEmpty(lucky7TicketFactory.tickets[0].mu, "User mu parameter is empty");
  }
  // function modifyNumberOfLucky7Numbers(uint _newValue) public onlyOwner{
  //       uint oldValue = numberOfLucky7Numbers;
  //       numberOfLucky7Numbers = _newValue;
  //       numberModified("Sell ticket price changed", oldValue, _newValue);
  //   }
    
  //   function modifyNumberOfWinners(uint _newValue) public onlyOwner{
  //       uint oldValue = numberOfWinners;
  //       numberOfWinners = _newValue;
  //       numberModified("Number of winners changed", oldValue, _newValue);
  //   }
    
  //   function modifySellTicketPrice(uint _newValue) public onlyOwner{
  //       uint oldValue = sellTicketPrice;
  //       sellTicketPrice = _newValue;
  //       numberModified("Sell ticket price changed", oldValue, _newValue);
  //   }
    
  //   function modifyGenerateTicketPrice(uint _newValue) public onlyOwner{
  //       uint oldValue = generateTicketPrice;
  //       generateTicketPrice = _newValue;
  //       numberModified("Generate ticket price changed", oldValue, _newValue);
        
  //   }
    
  //   function modifyOraclizeGasLimit(uint _newValue) public onlyOwner{
  //       uint oldValue = oraclizeGasLimit;
  //       oraclizeGasLimit = _newValue;
  //       numberModified("Oraclize gas limit changed", oldValue, _newValue);
  //   }
    
  //   function modifyOraclizeCustomGasPrice(uint _newValue) public onlyOwner{
  //       uint oldValue = oraclizeCustomGasPrice;
  //       oraclizeCustomGasPrice = _newValue;
  //       numberModified("Oraclize custom gas price changed", oldValue, _newValue);
  //   }
    
  //   function modifyParameterB(string _newValue) public onlyOwner{
  //       string memory oldValue = b;
  //       b = _newValue;
  //       parameterModified("Parameter b modified", oldValue, _newValue);
  //   }
    
  //   function modifyParameterN(string _newValue) public onlyOwner{
  //       string memory oldValue = n;
  //       n = _newValue;
  //       parameterModified("Parameter n modified", oldValue, _newValue);
  //   }
    
  //   function modifyParameterP(string _newValue) public onlyOwner{
  //       string memory oldValue = p;
  //       p = _newValue;
  //       parameterModified("Parameter p modified", oldValue, _newValue);
  //   }
    
  //   function modifyParameterJ(string _newValue) public onlyOwner{
  //       string memory oldValue = j;
  //       j = _newValue;
  //       parameterModified("Parameter j modified", oldValue, _newValue);
  //   }
    
  //   function modifyEnterprisePrize(address _newAddress) public onlyOwner{
  //       address oldAddress = enterpriseWallet;
  //       enterpriseWallet = _newAddress;
  //       walletModified("Enterprise wallet changed", oldAddress, _newAddress);
  //   }
    
  //   function balance() public view onlyOwner returns(uint256){
  //       return address(this).balance;
  //   }
}
