/**
  * @author Matias Barrios
  * @version 1.0.0
  */

/** @title Lucky7GetValues. 
  * This contract contains all the functions to generate get values between contracts.
*/

pragma solidity ^0.4.24;
import "./Lucky7Admin.sol";
import "./Lucky7Storage.sol";


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
  
  /** @dev Functions to store information into Lucky7Storage 
    */
} 