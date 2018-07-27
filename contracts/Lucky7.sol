pragma solidity ^0.4.20;
import "./usingOraclize.sol";

contract Lucky7 is usingOraclize{
    address public contractOwner;
    string constant b = "1";
    string constant n = "8";
    string constant p = "1000"; 
    string constant j = "20";
        
    struct userParametersValue{
        string mu;
        string i;
        string ticketValue;
    }
    
    mapping (address => userParametersValue) public userValues;
    mapping (bytes32 => address) muParameterID;
    mapping (bytes32 => address) iParameterID;
    mapping (bytes32 => address) ticketID;
    
    event newOraclizeQuery(string description);
    event newResponse(string currentParameter,string parameterValue);
    
    constructor () public payable{
        contractOwner = msg.sender;
    }

    function askForMuParameter() public payable{
        // newOraclizeQuery("Asking for a new mu parameter...");
        // bytes32 muID = oraclize_query("WolframAlpha","3 random number");
        // muParameterID[muID] = _parametersOwner;
        //muParameterID[muID] = msg.sender;
        userValues[msg.sender].mu = "8";
    }

    function askForIParameter() public payable{
        // newOraclizeQuery("Asking for a new i parameter...");
        // bytes32 iID = oraclize_query("WolframAlpha","3 random number");
        // //iParameterID[iID] = _parametersOwner;
        // iParameterID[iID] = msg.sender;
        userValues[msg.sender].i = "2";
    }
    
    function askForBothParameters() public payable{
        // newOraclizeQuery("Asking for a i and mu parameter...");
        // bytes32 muID = oraclize_query("WolframAlpha","3 random number");
        // //muParameterID[muID] = _parametersOwner;
        // muParameterID[muID] = msg.sender;
        // bytes32 iID = oraclize_query("WolframAlpha","3 random number");
        // iParameterID[iID] = msg.sender;
        userValues[msg.sender].mu = "3";
        userValues[msg.sender].i = "4";
    }
    
    function askForTicket() public payable {
        // newOraclizeQuery("Asking for a new ticket...");
        // bytes32 userTicketID = oraclize_query("WolframAlpha",setTicketQuery(_parametersOwner));
        // ticketID[userTicketID] = _parametersOwner;
        userValues[msg.sender].ticketValue = userValues[msg.sender].mu;
    }
    
    /*function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        if(muParameterID[myid]!=0 && keccak256(userValues[muParameterID[myid]].mu)==keccak256("")){
            userValues[muParameterID[myid]].mu=result;
        }
        else if (iParameterID[myid]!=0 && keccak256(userValues[iParameterID[myid]].i)==keccak256("")){
            userValues[iParameterID[myid]].i=result;
        }
        else if (ticketID[myid]!=0){
            userValues[ticketID[myid]].ticketValue=result;
        }
    }
    
    function setTicketQuery(address _parametersOwner) returns (string){
        string memory queryWolframA;
        string memory queryWolframB;
        //This line => mod((1/(10^n-mu))*10^217,10^(    
        queryWolframA = strConcat("mod((1/(10^",n,"-",userValues[_parametersOwner].mu,"))*10^1000,10^(");
        //This line => mod((1/(10^n-mu))*10^1000,10^(j+i))
        queryWolframB = strConcat(queryWolframA,j,"+",userValues[_parametersOwner].i,"))");
        //This line => mod((1/(10^n-mu))*10^1000,10^(j+i))-mod((1/(10^n-mu))*10^1000,10^(i))
        queryWolframB = strConcat(queryWolframB,"-",queryWolframA,userValues[_parametersOwner].i,"))");
        //This line => (mod((1/(10^n-mu))*10^1000,10^(j+i))-mod((1/(10^n-mu))*10^1000,10^(i)))/10^i
        return strConcat("(",queryWolframB,")/10^",userValues[_parametersOwner].i);
    }*/
}   
                                           
