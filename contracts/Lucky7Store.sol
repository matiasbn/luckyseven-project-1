pragma solidity ^0.4.20;
import "./Lucky7Ballot.sol";
import "./Destructible.sol";

contract Lucky7Store is Lucky7Ballot, Destructible{
    
    using SafeMath for uint256;
    
    function Lucky7Store() payable public{
        
    }
    
    modifier userBoughtTicket(address _ticketOwner){
        require(msg.value >= sellTicketPrice);
        userValues[_ticketOwner].userPaidTicket = true;
        _;
    }
    
    modifier userBoughtParameters(address _ticketOwner){
        require(msg.value >= generateTicketPrice);
        _;
    }
    
    
    modifier setParametersToReady(address _ticketOwner){
        userValues[_ticketOwner].muReady = false;
        userValues[_ticketOwner].iReady = false;
        _;
    }
    
    //Circuit breakers--------
    
    modifier sellingIsActive {
        require(settingLucky7Numbers==false);
        _;
    }
    //------------------------
    
    
    function sellRandomTicket() 
        public
        payable 
        userBoughtTicket(msg.sender)
        setParametersToReady(msg.sender)
        sellingIsActive
    {
        _generateTicket(msg.sender);
    }
    
    function generateRandomTicket() 
        public 
        payable 
        userBoughtParameters(msg.sender)
        setParametersToReady(msg.sender)
        sellingIsActive
    {
        _askForMuParameter(msg.sender);
        _askForIParameter(msg.sender);
    }
    
    function sellGeneratedTicket() 
        public 
        payable 
        userBoughtTicket(msg.sender)
        sellingIsActive
    {
        require(keccak256(userValues[msg.sender].mu)!=keccak256('') && keccak256(userValues[msg.sender].i)!=keccak256(''));
        _askForTicket(msg.sender);
    }
    
    function () public payable{
        
    }
}   
                                           
