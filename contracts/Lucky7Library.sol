/**
  * @author Matias Barrios
  * @version 1.0.0
  */

/** @title Lucky7GetValues. 
  * This contract contains all the functions to get values between contracts.
*/

pragma solidity ^0.4.24;
import "./Lucky7Admin.sol";
import "./Lucky7Storage.sol";
import "./Lucky7TicketFactory.sol";


library Lucky7Library{  
    
  /** @dev Functions to get values from Lucky7Admin
    */
  function oraclizeCustomGasPrice(address _lucky7AdminAddress) public returns (uint){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    return lucky7AdminContract.oraclizeCustomGasPrice();
  }

  function oraclizeGasLimit(address _lucky7AdminAddress) public returns (uint){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    return lucky7AdminContract.oraclizeGasLimit();
  }
  
  function sellTicketPrice(address _lucky7AdminAddress) public returns (uint){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    return lucky7AdminContract.sellTicketPrice();
  }

  function generateTicketPrice(address _lucky7AdminAddress) public returns (uint){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    return lucky7AdminContract.generateTicketPrice();
  }

  function enterpriseWallet(address _lucky7AdminAddress) public returns (address){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    return lucky7AdminContract.enterpriseWallet();
  }

  function getParameters(address _lucky7AdminAddress) public returns (string,string,string,string){
    Lucky7Admin lucky7AdminContract = Lucky7Admin(_lucky7AdminAddress);
    string memory b = lucky7AdminContract.b();
    string memory n = lucky7AdminContract.n();
    string memory p = lucky7AdminContract.p();
    string memory j = lucky7AdminContract.j();
    return (b,n,p,j);
  }


  /** @dev Functions to get values from Lucky7Storage
    */
  function indexForLucky7Array(address _lucky7StorageAddress) public returns (uint){
    Lucky7Storage lucky7StorageContract = Lucky7Storage(_lucky7StorageAddress);
    return lucky7StorageContract.indexForLucky7Array();
  } 

  function numberOfLucky7Numbers(address _lucky7StorageAddress) public returns (uint){
    Lucky7Storage lucky7StorageContract = Lucky7Storage(_lucky7StorageAddress);
    return lucky7StorageContract.numberOfLucky7Numbers();
  } 
  
  /** @dev Functions to get values from Lucky7TicketFactory 
    */

  function settingLucky7Numbers(address _lucky7TicketFactoryAddress) public returns (bool){
    Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(_lucky7TicketFactoryAddress);
    return lucky7TicketFactoryContract.settingLucky7Numbers();
  }

} 