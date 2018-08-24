pragma solidity ^0.4.20;
import "./usingOraclize.sol";
//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./Lucky7Admin.sol";


contract Lucky7TicketFactory is Lucky7Admin, usingOraclize{
    
    function Lucky7TicketFactory() payable{
        OAR = OraclizeAddrResolverI(0xc7d22a8737a85391928b09f1a0116bed0d44a56f);
    }
    
    using SafeMath for uint256;
    
    event NewOraclizeQuery(string description);
    event NewMuReceived(string muParameter);
    event NewIReceived(string iParameter);
    event NewTicketReceived(string newTicket);
    event NewWolframQuery(string description);

    
    modifier oraclizeGasPriceCustomized{
        oraclize_setCustomGasPrice(oraclizeCustomGasPrice);
        _;
    }
    
    uint public drawNumber = 0;
    uint public indexForLucky7Array = 0;
    
    //Circuit breakers
    bool public settingLucky7Numbers = true;
    
    function toggleLucky7Setting() public onlyOwner{
        settingLucky7Numbers = !settingLucky7Numbers;
    }
    
    struct UserParametersValue{
        string mu;
        string i;
        uint ticketValue;
        bool muReady;
        bool iReady;
        bool userPaidTicket;
    }
    
    struct Ticket{
        string mu;
        string i;
        uint ticketValue;
        address owner;
        uint drawID;
    }
    
    struct Lucky7Number{
        string mu;
        string i;
        uint ticketValue;
        uint drawID;
    }
    
    struct Lucky7Ticket{
        uint difference;
        address owner;
        uint ticketID;
        uint ticketValue;
        uint lucky7Number;
        uint lucky7NumberID;
        uint drawID;
    }
    
    Lucky7Ticket[] public lucky7Tickets;
    Ticket[] public tickets;    
    Lucky7Number[7] public lucky7Numbers;

    mapping (address => UserParametersValue) public userValues;
    mapping (bytes32 => address) muParameterID;
    mapping (bytes32 => address) iParameterID;
    mapping (bytes32 => address) ticketID;
    mapping (uint => uint) public lucky7TicketDifference;
    mapping (uint => address) public lucky7TicketOwner;
    mapping (uint => uint) public lucky7TicketID;

    function _askForMuParameter(address _ticketOwner) payable oraclizeGasPriceCustomized{
        NewOraclizeQuery("Asking for a new mu parameter...");
        bytes32 muID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        muParameterID[muID] = _ticketOwner;
    }

    function _askForIParameter(address _ticketOwner) oraclizeGasPriceCustomized{
        NewOraclizeQuery("Asking for a new i parameter...");
        bytes32 iID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        iParameterID[iID] = _ticketOwner;
    }
    
    function _askForTicket(address _ticketOwner) oraclizeGasPriceCustomized{
        NewOraclizeQuery("Asking for a new ticket...");
        bytes32 userTicketID = oraclize_query("WolframAlpha", _setTicketQuery(_ticketOwner), oraclizeGasLimit);
        ticketID[userTicketID] = _ticketOwner;
    }
    
    function _generateTicket(address _ticketOwner) {
        _askForMuParameter(_ticketOwner);
        _askForIParameter(_ticketOwner);
    }
    
    function _insertTicket(address _ticketOwner) internal {
        uint id = tickets.push(Ticket(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,_ticketOwner,drawNumber)) - 1;
        _checkForLucky7Ticket(id);
    }
    
    function _insertLucky7Number(address _ticketOwner) internal {
        lucky7Numbers[indexForLucky7Array] = Lucky7Number(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,drawNumber);
        indexForLucky7Array++;
    }
    //SafeMath
    function _checkForLucky7Ticket(uint _ticketID) public/*internal*/{
        uint i;
        uint difference;
        
        if(tickets[_ticketID].ticketValue>lucky7Numbers[numberOfLucky7Numbers-1].ticketValue){
            i=numberOfLucky7Numbers-1;
            difference = tickets[_ticketID].ticketValue.sub(lucky7Numbers[i].ticketValue);
            
        }
        else if (tickets[_ticketID].ticketValue<lucky7Numbers[0].ticketValue){
            i=0;
            difference = lucky7Numbers[i].ticketValue.sub(tickets[_ticketID].ticketValue);
        }
        else{
            while(tickets[_ticketID].ticketValue>lucky7Numbers[i].ticketValue){
                i++;
            }
            
            uint lowerLucky7NumberDifference = tickets[_ticketID].ticketValue.sub(lucky7Numbers[i-1].ticketValue);
            uint upperLucky7NumberDifference = lucky7Numbers[i].ticketValue.sub(tickets[_ticketID].ticketValue);
            
            if(upperLucky7NumberDifference>lowerLucky7NumberDifference){
                i=i-1;
                difference = lowerLucky7NumberDifference;
            }
            else{
                difference = upperLucky7NumberDifference;
            }
        }
        
        if(lucky7TicketOwner[i] == address(0x0) || difference<lucky7TicketDifference[i]){
            lucky7TicketOwner[i] = tickets[_ticketID].owner;
            lucky7TicketDifference[i] = difference;
            lucky7TicketID[i] = _ticketID;
        }
    }
    
    function _setTicketQuery(address _parametersOwner) internal returns (string){
        string memory queryWolfram;
        //This line => (mod((1/(10^n-mu))*10^    
        queryWolfram = strConcat("(mod((1/(10^",n,"-",userValues[_parametersOwner].mu,"))*10^");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+
        queryWolfram = strConcat(queryWolfram,p,",10^(",j,"+");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-
        queryWolfram = strConcat(queryWolfram,userValues[_parametersOwner].i,"))-mod((1/(10^",n,"-");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^
        queryWolfram = strConcat(queryWolfram,userValues[_parametersOwner].mu,"))*10^",p,",10^");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^(i)))/10^i
        queryWolfram = strConcat(queryWolfram,"(",userValues[_parametersOwner].i,")))/10^",userValues[_parametersOwner].i);
        NewWolframQuery(queryWolfram);
        return queryWolfram;
    }
    
    function __callback(bytes32 myid, string result) public{
        require(msg.sender == oraclize_cbAddress());
        if(muParameterID[myid]!=0 && userValues[muParameterID[myid]].muReady==false){
            userValues[muParameterID[myid]].mu=result;
            NewMuReceived(result);
            userValues[muParameterID[myid]].muReady=true;
            if(userValues[muParameterID[myid]].iReady == true && (userValues[muParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(muParameterID[myid]);
            }
        }
        else if (iParameterID[myid]!=0 && userValues[iParameterID[myid]].iReady==false){
            userValues[iParameterID[myid]].i=result;
            NewIReceived(result);
            userValues[iParameterID[myid]].iReady=true;
            if(userValues[iParameterID[myid]].muReady == true && (userValues[iParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(iParameterID[myid]);
            }
        }
        else if (ticketID[myid]!=0 &&  (userValues[ticketID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
            userValues[ticketID[myid]].ticketValue=parseInt(result);
            NewTicketReceived(result);
            userValues[ticketID[myid]].userPaidTicket=false;
            if(settingLucky7Numbers==true){
                _insertLucky7Number(ticketID[myid]);
            }
            else{
                _insertTicket(ticketID[myid]);
            }
        }
    }

    function() public payable{}
} 