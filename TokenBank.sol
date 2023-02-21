// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A smartcontract where user can deposit EUROe tokens, and the app's backend will release them to the recipient when credentials are verified
/// @notice This contract assumes that the owner is an honest player
contract TokenBank is Ownable {

    IERC20 public immutable EUROe;
    
    mapping (address => uint) public claims;

    event Deposit(address recipient, uint amount);
    event Release(address recipient, uint amount);

    constructor(address _tokenAddress) {
        EUROe = IERC20(_tokenAddress);
    }

    function deposit(address recipient, uint amount) external {
        require(recipient != address(0));
        claims[recipient] = amount;
        EUROe.transferFrom(msg.sender, address(this), amount);
        emit Deposit(recipient, amount);
    }

    function release(address recipient) external onlyOwner {
        require(recipient != address(0));
        require(claims[recipient] > 0, "no claimable money");
        uint claimable = claims[recipient];
        claims[recipient] = 0;
        EUROe.transfer(recipient, claimable);
        emit Release(recipient, claimable);
    }

    /// emergency function in case recipient address is compromised
    function emergencyWithdraw(address user) external onlyOwner {
        require(user != address(0));
        uint balance = EUROe.balanceOf(user);
        claims[user] = 0;
        EUROe.transfer(msg.sender, balance);
    }

    /// emergency function in case 
    function emergencyWithdrawAll() external onlyOwner {
        uint balance = EUROe.balanceOf(address(this));
        EUROe.transfer(msg.sender, balance);
    }
}