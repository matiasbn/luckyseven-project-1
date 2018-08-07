pragma solidity ^0.4.20;
import "./Lucky7TicketFactory.sol";

contract Lucky7Store is Lucky7TicketFactory{
    
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
    
    function generateParameters(address _ticketOwner) 
        public 
        payable 
        userBoughtParameters(_ticketOwner)
        setParametersToReady(_ticketOwner)
        sellingIsActive
    {
        _askForMuParameter(_ticketOwner);
        _askForIParameter(_ticketOwner);
    }
    
    function sellTicket(address _ticketOwner) 
        public 
        payable 
        userBoughtTicket(_ticketOwner)
        sellingIsActive
    {
        require(keccak256(userValues[_ticketOwner].mu)!=keccak256('') && keccak256(userValues[_ticketOwner].i)!=keccak256(''));
        _askForTicket(_ticketOwner);
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
        //Deliver lot for the project
        //Generate Lucky7Numbers
        _startLucky7NumbersGeneration();
        //Set off Lucky7NumbersSetting
    }
    
    function who() public returns (address){
        return msg.sender;
    }
}   
                                           
