/**
  * @author Matias Barrios
  * @version 1.0
  */

/** @title Lucky7Store. 
  * This contract contains all the functions to generate and sell tickets to the users.
  * The front end interacts with this functions to make the necessary transactions to play the game.
*/

pragma solidity ^0.4.20;
import "./Lucky7Library.sol";
import "./Lucky7Admin.sol";
import "./Lucky7Storage.sol";
import "./Lucky7TicketFactory.sol";
import "./Lucky7Ballot.sol";

contract Lucky7Store is Lucky7Ballot{
    /** @dev Library to read messages 
      */
    using Lucky7Library for *;

    /** @dev Address of the contracts to call functions
      */
    address lucky7AdminAddress;
    address lucky7StorageAddress;
    address lucky7TicketFactoryAddress;
    
    /** @dev Constructor to make the contract payable
      */
    function Lucky7Store(address _lucky7AdminAddress, address _lucky7StorageAddress, address _lucky7TicketFactoryAddress) public payable {
        lucky7AdminAddress = _lucky7AdminAddress;
        lucky7StorageAddress = _lucky7StorageAddress;
        lucky7TicketFactoryAddress = _lucky7TicketFactoryAddress;
    }
    /** @dev userBoughtTicket is a modifier to check if the user paid the necessary amount to buy a ticket.
      */
    modifier userBoughtTicket(address _ticketOwner){
        require(msg.value >= Lucky7Library.sellTicketPrice(lucky7AdminAddress));
        uint oraclizePrice = 2*Lucky7Library.oraclizeCustomGasPrice(lucky7AdminAddress)*Lucky7Library.oraclizeGasLimit(lucky7AdminAddress);
        lucky7TicketFactoryAddress.transfer(oraclizePrice);
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        lucky7TicketFactoryContract.paidTicketToTrue(_ticketOwner);
        _;
    }
    
    /** @dev userBoughtParameters is a modifier to check if the user paid the necessary amount to buy parameters, i.e. generate a ticket without buying it.
      */
    modifier userBoughtParameters(address _ticketOwner){
        require(msg.value >= Lucky7Library.generateTicketPrice(lucky7AdminAddress));
        uint oraclizePrice = 2*Lucky7Library.oraclizeCustomGasPrice(lucky7AdminAddress)*Lucky7Library.oraclizeGasLimit(lucky7AdminAddress);
        lucky7TicketFactoryAddress.transfer(oraclizePrice);
        _;
    }
    
    /** @dev setParametersToReady is a modifier to set the muReady and iReady booleans of the UserParametersValue of the Lucky7TicketFactory to false.
      * This way, the user can call for new parameters or buy ticket without being rejected by teh oraclize's callback function of the Lucky7TicketFactory contract.
      */
    modifier setParametersToReady(address _ticketOwner){
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        lucky7TicketFactoryContract.bothToFalse(_ticketOwner);
        _;
    }
    
    /** @dev sellingIsActive is a modifier which acts as a circuit breaker. If the settingLucky7Number is true, i.e. the game is in setting Lucky7Numbers phase, then
      * the users aren't allowed to buy tickets because the Lucky7Number are getting setted. Once the last Lucky7Number is setted and all them are ordered through the
      * _orderLucky7Numbers function of the Lucky7Ballot contract, the settingLucky7Numbers is setted to false, which means that users are then allowed to buy tickets.
      */
    modifier sellingIsActive {
        require(Lucky7Library.settingLucky7Numbers(lucky7TicketFactoryAddress)==false);
        _;
    }
    //------------------------
    
    /** @dev sellRandomTicket is a function used to sell a random ticket to the user. It checks if the user sent the correct amount and if the game is not
      * in the setting Lucky7Numbers phase. If so, then sets the user muReady and iReady of the UserParameters value of the Lucky7TicketFactory contract to false and 
      calls the _generateTicket function of the Lucky7TicketFactory contract with the msg.sender as the owner.
      */
    function sellRandomTicket() 
        public
        payable 
        userBoughtTicket(msg.sender)
        setParametersToReady(msg.sender)
        sellingIsActive
    {
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        lucky7TicketFactoryContract._generateTicket(msg.sender);
    }
    
    /** @dev generateRandomTicket is a function used to sell a parameters to the user without selling the ticket. It checks if the user sent the correct amount and 
      * if the game is not in the setting Lucky7Numbers phase. If so, then sets the user muReady and iReady of the UserParameters struct of the Lucky7TicketFactory 
      * contract to false and calls the _askForMuParameter and _askForIParamater functions of the Lucky7TicketFactory contract with the msg.sender as the owner.
      */
    function generateRandomTicket() 
        public 
        payable 
        userBoughtParameters(msg.sender)
        setParametersToReady(msg.sender)
        sellingIsActive
    {
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        lucky7TicketFactoryContract._generateTicket(msg.sender);
    }
    
    /** @dev sellGeneratedTicket is a function used to sell the ticket generated through the parameters the user already bought. 
      * It checks if the user sent the correct amount and if the game is not in the setting Lucky7Numbers phase. 
      * If so, then sets the user muReady and iReady of the UserParameters struct of the Lucky7TicketFactory contract to false 
      * and calls the _generateTicket function of the Lucky7TicketFactory contract with the msg.sender as the owner.
      */
    function sellGeneratedTicket() 
        public 
        payable 
        userBoughtTicket(msg.sender)
        sellingIsActive
    {
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        bool userParametersAreEmpty = lucky7TicketFactoryContract.userParametersEmpty(msg.sender);
        require(userParametersAreEmpty == false);
        lucky7TicketFactoryContract._askForTicket(msg.sender);
    }
    
    function multip() public view returns(uint){
        return Lucky7Library.oraclizeGasLimit(lucky7AdminAddress)*Lucky7Library.oraclizeCustomGasPrice(lucky7AdminAddress);
    }

    function () public payable{
        
    }
}   
                                           
