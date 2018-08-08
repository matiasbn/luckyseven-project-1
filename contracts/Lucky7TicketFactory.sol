pragma solidity ^0.4.20;
//import "./usingOraclize.sol";
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./SafeMath.sol";
import "./Lucky7Admin.sol";


contract Lucky7TicketFactory is usingOraclize, Lucky7Admin{
    
    using SafeMath for uint256;
    
    event newOraclizeQuery(string description);
    event newMuReceived(address parameterOwner, string muParameter);
    event newIReceived(address parameterOwner, string iParameter);
    event newTicketReceived(address parameterOwner, string newTicket);
    
    modifier oraclizeGasPriceCustomized{
        oraclize_setCustomGasPrice(oraclizeCustomGasPrice);
        _;
    }
    
    uint drawNumber = 0;
    uint indexForLucky7Array = 0;
    
    //Circuit breakers
    bool internal settingLucky7Numbers = true;
    
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
    }
    
    Ticket[] public tickets;    
    Lucky7Number[7] public lucky7Numbers;
    Lucky7Ticket[7] public lucky7Tickets;
    //checkfordoublewinner
    
    mapping (uint => address) public ticketToOwner;
    mapping (address => uint) ownerTicketCount;
    mapping (address => UserParametersValue) public userValues;
    mapping (bytes32 => address) muParameterID;
    mapping (bytes32 => address) iParameterID;
    mapping (bytes32 => address) ticketID;
    mapping (uint => uint) public lucky7TicketDifference;
    mapping (uint => address) public lucky7TicketOwner;
    mapping (uint => uint) public lucky7TicketID;
    mapping (uint => address) public ExactLucky7TicketOwner;
    
    function _askForMuParameter(address _ticketOwner) oraclizeGasPriceCustomized{
        newOraclizeQuery("Asking for a new mu parameter...");
        bytes32 muID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        muParameterID[muID] = _ticketOwner;
    }

    function _askForIParameter(address _ticketOwner) oraclizeGasPriceCustomized{
        newOraclizeQuery("Asking for a new i parameter...");
        bytes32 iID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        iParameterID[iID] = _ticketOwner;
    }
    
    function _askForTicket(address _ticketOwner) oraclizeGasPriceCustomized{
        newOraclizeQuery("Asking for a new ticket...");
        string memory query = _setTicketQuery(_ticketOwner);
        bytes32 userTicketID = oraclize_query("WolframAlpha", query, oraclizeGasLimit);
        ticketID[userTicketID] = _ticketOwner;
    }
    
    function _generateTicket(address _ticketOwner) {
        _askForMuParameter(_ticketOwner);
        _askForIParameter(_ticketOwner);
    }
    
    function _insertTicket(address _ticketOwner) internal {
        uint id = tickets.push(Ticket(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,_ticketOwner,drawNumber)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        _checkForLucky7Ticket(id);
    }
    
    function _insertLucky7Number(address _ticketOwner) internal {
        lucky7Numbers[indexForLucky7Array] = Lucky7Number(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,drawNumber);
        indexForLucky7Array++;
    }
    
    function _checkForLucky7Ticket(uint _ticketID) public/*internal*/ returns (uint256){
        uint256 i;
        uint difference;
        uint lowerLucky7NumberDifference;
        uint upperLucky7NumberDifference;
        
        if(tickets[_ticketID].ticketValue>lucky7Numbers[numberOfLucky7Numbers-1].ticketValue){
            i=numberOfLucky7Numbers-1;
            difference = tickets[_ticketID].ticketValue.sub(lucky7Numbers[i].ticketValue);
            if(lucky7TicketOwner[i] == address(0x0) || difference<lucky7TicketDifference[i]){
                _updateLucky7Ticket(i,ticketToOwner[_ticketID],difference,_ticketID);
            }
        }
        else if (tickets[_ticketID].ticketValue<lucky7Numbers[0].ticketValue){
            i=0;
            difference = lucky7Numbers[i].ticketValue.sub(tickets[_ticketID].ticketValue);
            if(lucky7TicketOwner[i] == address(0x0) || difference<lucky7TicketDifference[i]){
                _updateLucky7Ticket(i,ticketToOwner[_ticketID],difference,_ticketID);
            }
        }
        else{
            while(tickets[_ticketID].ticketValue>lucky7Numbers[i].ticketValue){
                i++;
            }
            
            lowerLucky7NumberDifference = tickets[_ticketID].ticketValue.sub(lucky7Numbers[i-1].ticketValue);
            upperLucky7NumberDifference = lucky7Numbers[i].ticketValue.sub(tickets[_ticketID].ticketValue);
            
            if(upperLucky7NumberDifference>lowerLucky7NumberDifference){
                i=i-1;
                difference = lowerLucky7NumberDifference;
            }
            else{
                difference = upperLucky7NumberDifference;
            }
            
            if(lucky7TicketOwner[i] == address(0x0) || difference<lucky7TicketDifference[i]){
                _updateLucky7Ticket(i,ticketToOwner[_ticketID],difference,_ticketID);
            }
        }
        return i;
    }
    
    function _updateLucky7Ticket(uint _i, address _ticketOwner, uint _difference, uint _ticketID) 
        internal{
        lucky7TicketOwner[_i] = _ticketOwner;
        lucky7TicketDifference[_i] = _difference;
        lucky7TicketID[_i] = _ticketID;
    }g
    
    function _setTicketQuery(address _parametersOwner) internal returns (string){
        string memory queryWolframA;
        string memory queryWolframB;
        //This line => mod((1/(10^n-mu))*10^217,10^(    
        queryWolframA = strConcat("mod((1/(10^",n,"-",userValues[_parametersOwner].mu,"))*10^10000,10^(");
        //This line => mod((1/(10^n-mu))*10^10000,10^(j+i))
        queryWolframB = strConcat(queryWolframA,j,"+",userValues[_parametersOwner].i,"))");
        //This line => mod((1/(10^n-mu))*10^10000,10^(j+i))-mod((1/(10^n-mu))*10^10000,10^(i))
        queryWolframB = strConcat(queryWolframB,"-",queryWolframA,userValues[_parametersOwner].i,"))");
        //This line => (mod((1/(10^n-mu))*10^10000,10^(j+i))-mod((1/(10^n-mu))*10^10000,10^(i)))/10^i
        return strConcat("(",queryWolframB,")/10^",userValues[_parametersOwner].i);
    }
    
    function __callback(bytes32 myid, string result) public{
        require(msg.sender == oraclize_cbAddress());
        if(muParameterID[myid]!=0 && userValues[muParameterID[myid]].muReady==false){
            userValues[muParameterID[myid]].mu=result;
            newMuReceived(muParameterID[myid], result);
            userValues[muParameterID[myid]].muReady=true;
            if(userValues[muParameterID[myid]].iReady == true && (userValues[muParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(muParameterID[myid]);
            }
        }
        else if (iParameterID[myid]!=0 && userValues[iParameterID[myid]].iReady==false){
            userValues[iParameterID[myid]].i=result;
            newIReceived(iParameterID[myid], result);
            userValues[iParameterID[myid]].iReady=true;
            if(userValues[iParameterID[myid]].muReady == true && (userValues[iParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(iParameterID[myid]);
            }
        }
        else if (ticketID[myid]!=0 &&  (userValues[ticketID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
            userValues[ticketID[myid]].ticketValue=parseInt(result);
            newTicketReceived(ticketID[myid], result);
            userValues[ticketID[myid]].userPaidTicket=false;
            if(settingLucky7Numbers==true){
                _insertLucky7Number(ticketID[myid]);
            }
            else{
                _insertTicket(ticketID[myid]);
            }
        }
    }
}   
                                           
