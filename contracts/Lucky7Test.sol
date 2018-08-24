pragma solidity ^0.4.20;

import "./Lucky7Store.sol";

contract Lucky7Test is Lucky7Store{

    function Lucky7Test() payable{
    }
    
    function insertTestLucky7Numbers() public{
        lucky7Numbers[0] = Lucky7Number("1","2",10651283657614267398,drawNumber);
        lucky7Numbers[1] = Lucky7Number("1","2",88052694543136051754,drawNumber);
        lucky7Numbers[2] = Lucky7Number("1","2",52398723847810031239,drawNumber);
        lucky7Numbers[3] = Lucky7Number("1","2",90527121997810111570,drawNumber);
        lucky7Numbers[4] = Lucky7Number("1","2",30481723712938712983,drawNumber);
        lucky7Numbers[5] = Lucky7Number("1","2",24342359080214091240,drawNumber);
        lucky7Numbers[6] = Lucky7Number("1","2",75126192741201932912,drawNumber);
    } 

    function() public payable{
    }
}
