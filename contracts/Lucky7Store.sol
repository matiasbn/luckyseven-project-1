pragma solidity ^0.4.20;
import "./Lucky7Ballot.sol";

contract Lucky7Store is Lucky7Ballot{
    
    using SafeMath for uint256;
    
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
    
    function generateTicket() 
        public 
        payable 
        userBoughtParameters(msg.sender)
        setParametersToReady(msg.sender)
        sellingIsActive
    {
        _askForMuParameter(msg.sender);
        _askForIParameter(msg.sender);
    }
    
    function sellTicket() 
        public 
        payable 
        userBoughtTicket(msg.sender)
        sellingIsActive
    {
        require(keccak256(userValues[msg.sender].mu)!=keccak256('') && keccak256(userValues[msg.sender].i)!=keccak256(''));
        _askForTicket(msg.sender);
    }
    
    function setNewLucky7Numbers()                                      
        public 
        payable 
        onlyOwner 
    {
        //Increase drawNumber
        drawNumber++;
        //Set on Lucky7NumbersSetting
        toggleLucky7Setting();
        //Deliver Prizes
        //Deliver lot for enterprise
        _deliverPrizes();
        //Generate Lucky7Numbers
        _startLucky7NumbersGeneration();
        //Set off Lucky7NumbersSetting
    }
    
}   
                                           
