// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GovernanceToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("GovernanceToken", "GT") {
        _mint(msg.sender, initialSupply * 10**uint(decimals()));
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount * 10**uint(decimals()));
    }
}