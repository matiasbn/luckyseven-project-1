pragma solidity ^0.4.20;
import "./Ownable.sol";
import "./SafeMath.sol";


contract Lucky7Admin is Ownable{
    using SafeMath for uint256;
    
    event numberModified(string feeType, uint _oldValue, uint _newValue);
    event parameterModified(string parameter, string _oldValue, string _newValue);
    event walletModified(string parameter, address _oldValue, address _newValue);

    
    string public b = "1";
    string public n = "8";
    string public p = "10000"; 
    string public j = "20";
    
    uint public numberOfLucky7Numbers = 7;
    
    uint public generateTicketPrice = 0.005 ether;
    uint public sellTicketPrice = 0.012 ether;
    uint public oraclizeGasLimit = 300000 wei;
    uint public oraclizeCustomGasPrice = 4000000000 wei;
    address public enterpriseWallet = owner;
    
    function modifyNumberOfLucky7Numbers(uint _newValue) public onlyOwner{
        uint oldValue = numberOfLucky7Numbers;
        numberOfLucky7Numbers = _newValue;
        numberModified("Sell ticket price changed", oldValue, _newValue);
    }
        
    function modifySellTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = sellTicketPrice;
        sellTicketPrice = _newValue;
        numberModified("Sell ticket price changed", oldValue, _newValue);
    }
    
    function modifyGenerateTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = generateTicketPrice;
        generateTicketPrice = _newValue;
        numberModified("Generate ticket price changed", oldValue, _newValue);
        
    }
    
    function modifyOraclizeGasLimit(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeGasLimit;
        oraclizeGasLimit = _newValue;
        numberModified("Oraclize gas limit changed", oldValue, _newValue);
    }
    
    function modifyOraclizeCustomGasPrice(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeCustomGasPrice;
        oraclizeCustomGasPrice = _newValue;
        numberModified("Oraclize custom gas price changed", oldValue, _newValue);
    }
    
    function modifyParameterB(string _newValue) public onlyOwner{
        string memory oldValue = b;
        b = _newValue;
        parameterModified("Parameter b modified", oldValue, _newValue);
    }
    
    function modifyParameterN(string _newValue) public onlyOwner{
        string memory oldValue = n;
        n = _newValue;
        parameterModified("Parameter n modified", oldValue, _newValue);
    }
    
    function modifyParameterP(string _newValue) public onlyOwner{
        string memory oldValue = p;
        p = _newValue;
        parameterModified("Parameter p modified", oldValue, _newValue);
    }
    
    function modifyParameterJ(string _newValue) public onlyOwner{
        string memory oldValue = j;
        j = _newValue;
        parameterModified("Parameter j modified", oldValue, _newValue);
    }
    
    function modifyEnterpriseWallet(address _newAddress) public onlyOwner{
        address oldAddress = enterpriseWallet;
        enterpriseWallet = _newAddress;
        walletModified("Enterprise wallet changed", oldAddress, _newAddress);
    }
    
    function balance() public view onlyOwner returns(uint256){
        return address(this).balance;
    }
}   
                                           
