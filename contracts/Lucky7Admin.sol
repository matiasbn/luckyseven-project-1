pragma solidity ^0.4.20;
//import "./usingOraclize.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


contract Lucky7Admin is Ownable{
    
    using SafeMath for uint256;
    
    event priceModified(string feeType, uint _oldValue, uint _newValue);
    event parameterModified(string parameter, string _oldValue, string _newValue);
    
    string b = "1";
    string n = "8";
    string p = "1000"; 
    string j = "20";
    
    uint numberOfLucky7Numbers = 7;
    
    uint generateTicketPrice = 0.0003 ether;
    uint sellTicketPrice = 0.003 ether;
    uint oraclizeGasLimit = 5000000 wei;
    uint oraclizeCustomGasPrice = 4000000000 wei;
    
    function modifyNumberOfLucky7Numbers(uint _newValue) public onlyOwner{
        uint oldValue = sellTicketPrice;
        sellTicketPrice = _newValue;
        priceModified("Sell ticket price changed", oldValue, _newValue);
    }
    
    function modifySellTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = sellTicketPrice;
        sellTicketPrice = _newValue;
        priceModified("Sell ticket price changed", oldValue, _newValue);
    }
    
    function modifyGenerateTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = generateTicketPrice;
        generateTicketPrice = _newValue;
        priceModified("Generate ticket price changed", oldValue, _newValue);
        
    }
    
    function modifyOraclizeGasLimit(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeGasLimit;
        oraclizeGasLimit = _newValue;
        priceModified("Oraclize gas limit changed", oldValue, _newValue);
    }
    
    function modifyOraclizeCustomGasPrice(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeCustomGasPrice;
        oraclizeCustomGasPrice = _newValue;
        priceModified("Oraclize custom gas price changed", oldValue, _newValue);
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
}   
                                           
