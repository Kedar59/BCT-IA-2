pragma solidity 0.8.19;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract Victim{
    using SafeMath for uint256;
    mapping(address => uint256) private balances;
    mapping(address => bool) private mutex;
    event SumCompleted(address indexed user, uint256 result);
    event MutexLocked(address indexed user);
    event MutexUnlocked(address indexed user);
    event AttackAttempted(address indexed attacker);
    event Notification(address indexed user, string message);
    modifier noReentrancy(){
        require(!mutex[msg.sender],"Reentrancy attack in progress");
        mutex[msg.sender] = true;
        emit MutexLocked(msg.sender);
        _;
        mutex[msg.sender] = false;
        emit MutexUnlocked(msg.sender);
    }
    function deposit() public payable {
        require(msg.value > 0, "Please deposit some ether");
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    function withdraw() public noReentrancy {
        require(balances[msg.sender] > 0, "Insufficient balance");
        uint256 amount = balances[msg.sender];
        balances[msg.sender]=0;
        if(!_safeTransfer(msg.sender, amount)){
            emit AttackAttempted(msg.sender);
            emit Notification(msg.sender, "An attack has been attempted on your account");
        }
    }
    function sum(uint256 a, uint256 b) public noReentrancy returns (uint256) {
        require(balances[msg.sender] >= a && balances[msg.sender] >= b, "Insufficient balance for sum operation");
        uint256 result = a.add(b);
        balances[msg.sender] = balances[msg.sender].sub(a).sub(b); // Subtract amounts used in sum operation
        emit SumCompleted(msg.sender, result);
        return result;
    }
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    function notifyUser(string memory message) public {
        emit Notification(msg.sender, message);
    }
    function _safeTransfer(address to, uint amount) private returns (bool) {
        (bool success, ) = payable(to).call{value : amount}("");
        return success;
    }
}