/**
  * @author Matias Barrios
  * @version 1.0
  */


/** @title Lucky7Admin. 
  * This contract contains all the functions to manage the game. 
  * All the functions inside this contract are setted with the onlyOwner modifier.
  */

pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Lucky7Admin is Ownable{

    /** @dev Whitelist to accept changes over all contracts
      */

    /** @dev event to register the change of a number */
    event numberModified(string describe, uint _oldValue, uint _newValue);

    /** @dev event to register the change of a parameter */
    event parameterModified(string describe, string _oldValue, string _newValue);

    /** @dev event to register the change of the enterprise wallet */
    event walletModified(string describe, address _oldValue, address _newValue);


    /** @param b Pseudo-random number generator parameter
      * @param n Pseudo-random number generator parameter
      * @param p Pseudo-random number generator parameter
      * @param j Pseudo-random number generator parameter
      */
    string public b = "1";
    string public n = "8";
    string public p = "10000"; 
    string public j = "20";
    
    /**
      * @dev This parameters control the prices of the system
      *    
      * The user can generate as many tickets as want, but none of them are going to be selectible
      * for prices if he don't buy it
      *
      * @param generateTicketPrice is the price that users pays to generate a ticket without buying it
      * @param sellTicketPrice is the price that users pays to actually buy a ticket to participate in the game
      * @param oraclizeGasLimit is the limit of gas for every oraclize query. Is important to have a good idea of the price of the query
      * because oraclize don't send back the remaining gas
      * @param oraclizeCustomGasPrice is the price of the gas for the oraclize querys
      */
    uint public generateTicketPrice = 0.005 ether;
    uint public sellTicketPrice = 0.012 ether;
    uint public oraclizeGasLimit = 300000 wei;
    uint public oraclizeCustomGasPrice = 4000000000 wei;

    /**
      * @param enterpriseWallet is the address of the wallet which will recieve 30% of the balance of this contract when the prizes are delivered
      */
    address public enterpriseWallet = owner;

    /**
      * @dev The next functions are self explanatory
      * Everyone emits an event to register changes, so there is a register of evolution of the game in the time
     */
    
    function modifySellTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = sellTicketPrice;
        sellTicketPrice = _newValue;
        emit numberModified("Sell ticket price changed", oldValue, _newValue);
    }
    
    function modifyGenerateTicketPrice(uint _newValue) public onlyOwner{
        uint oldValue = generateTicketPrice;
        generateTicketPrice = _newValue;
        emit numberModified("Generate ticket price changed", oldValue, _newValue);
    }
    
    function modifyOraclizeGasLimit(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeGasLimit;
        oraclizeGasLimit = _newValue;
        emit numberModified("Oraclize gas limit changed", oldValue, _newValue);
    }
    
    function modifyOraclizeCustomGasPrice(uint _newValue) public onlyOwner{
        uint oldValue = oraclizeCustomGasPrice;
        oraclizeCustomGasPrice = _newValue;
        emit numberModified("Oraclize custom gas price changed", oldValue, _newValue);
    }
    
    function modifyEnterpriseWallet(address _newAddress) public onlyOwner{
        address oldAddress = enterpriseWallet;
        enterpriseWallet = _newAddress;
        emit walletModified("Enterprise wallet changed", oldAddress, _newAddress);
    }
}   
                                           
