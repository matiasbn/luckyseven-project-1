pragma solidity ^0.4.20;
import "./Lucky7Ballot.sol";

contract Lucky7Store is Lucky7Ballot{
    
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
    
    function insertNewLucky7Number(uint _index,string _mu,string _i, uint _ticketValue, uint _drawID) public{
        lucky7Numbers[_index]=Lucky7Number(_mu,_i,_ticketValue,_drawID);
    }
    
    function test ()public payable{
        lucky7Numbers[0] = Lucky7Number("1","2",1067651283657614267398,0);
        lucky7Numbers[1] = Lucky7Number("1","2",4331546272812712317382,0);
        lucky7Numbers[2] = Lucky7Number("1","2",4552398723847810031239,0);
        lucky7Numbers[3] = Lucky7Number("1","2",3311248712094819028091,0);
        lucky7Numbers[4] = Lucky7Number("1","2",3041381723712938712983,0);
        lucky7Numbers[5] = Lucky7Number("1","2",2422342359080214091240,0);
        lucky7Numbers[6] = Lucky7Number("1","2",7512876192741201932912,0);
    }
    function () public payable{
        
    }
}   
                                           
