// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Interface for contracts conforming to ERC-20
 */

interface ERC20Interface {
  function transferFrom(address from, address to, uint tokens) external returns (bool success);
  function approve(address spender, uint amount) external returns (bool success);
}
