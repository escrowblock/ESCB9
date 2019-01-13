// Don't use this code, it can be not working or contain the vulnerability, for demonstration purpose only
pragma solidity ^0.4.21;

import "./ESCB9.sol";

/// @title p2pExchangeESCB9 - Allows exchanging any cryptocurrencies on fiat money and back, directly between users. The safe way to do deal for counterparties.
/// This example shows as exchange fiat money on BTC (forward flow)
/// @author ESCB development team - <support@escrowblock.net>
contract p2pExchangeESCB9 is ESCB9 {
  // in minimal decimals, for example, 500.000 rubles is equal 50000000 kopeks
  uint256 constant public inputAmount  = 50000000;
  // RUB in bytes
  bytes constant public inputCurrency  = "0x525542";
  // in minimal decimals, for example, 1 BTC is equal 100000000 satoshi
  uint256 constant public outputAmount = 100000000;
  // BTC in bytes
  bytes constant public outputCurrency = "0x425443";
  // Deposit can be place only before this time
  uint256 constant public closeTime    = 1526829900;
  // use "forward" way, when output currency will be deposited or "backward" if input currency will be deposited
  bytes constant public depositWay   = "forward";
  /**
   * Encrypted information, see https://github.com/ethereumjs/ethereumjs-wallet and
   * https://github.com/pubkey/eth-crypto/blob/master/tutorials/encrypted-message.md
  **/
  /**
   * Encrypted information for placing deposit, for example BTC address
  **/
  bytes private externalDepositAddress = "0x3139333978476346484d6f464b465845564754415761706b3537694e6a3579556b52";
  /**
   * Encrypted information for the amount of deposit, for example for BTC 8 decimals can be added 2-3 chars from 0-9 as pin-code for deal. See more in EscrowBlock WhitePaper
   * If output amount is equal 100000000, then deposited amount can be 100000123
  **/
  bytes private externalDepositAmount = "0x5f5e17b";
  /**
   * Encrypted information for sending amount to seller, for example credit card number or bank account, for example 4242424242424242
  **/
  bytes private externalIncomingAddress = "0xf12765df4c9b2";
  modifier only_before_close_time {
    require(getNow() < closeTime);
    _;
  }
  modifier only_after_close_time {
    require(getNow() > closeTime);
    _;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get address of apartment owner
   * @return Seller's address
  **/
  function seller() public returns(address) {
    return 0x0027a36731337cdee360d99b980b73e24f6e188618;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get custom type for ESCB9 smart contract
   * @return Type
  **/
  function typeContract() public returns(bytes) {
    return "0x65786368616e6765"; //exchange
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get address of renter
   * @return Buyer's address
  **/
  function buyer() public returns(address) {
    return 0x00b582baaF7e749d6aA98A22355A9d08B4c4d013C8;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get sum for deal
   * @return Sum of deal in minimal decimals
  **/
  function depositedSum() public returns(uint256) {
    return outputAmount;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get currency symbol for deal
   * @return Currency name in bytes
  **/
  //@TODO add in specification
  function depositedCurrency() public returns(bytes) {
    return "0x425443"; //BTC
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get arbitrage's address
   * @return Arbitrage's address
  **/
  function arbitrage() public returns(address) {
    return 0x00e91065d8bb2392121a8fbe6a81e79782fbc89dd4;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to approve escrow deal and confirm success
   * @param notice Some comment
   * @return Success of operation
  **/
  function confirm(bytes notice) public onlyArbitrage only_after_close_time returns(bool) {
    emit confirmed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to freeze escrow deal
   * @param notice Some comment
   * @return Success of operation
  **/
  function freeze(bytes notice) public onlyArbitrage only_after_close_time returns(bool) {
    emit frozen(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to dispute escrow deal
   * @return Success of operation
  **/
  function dispute(bytes notice) public onlyArbitrage only_after_close_time returns(bool) {
    emit disputed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to cancel escrow deal and confirm fail
   * @return Success of operation
  **/
  function cancel(bytes notice) public onlyArbitrage only_before_close_time returns(bool) {
    emit canceled(getNow(), notice);
  }
  /**
   * @notice Get current unix time stamp
  **/
  function getNow()
    constant
    public
    returns (uint) {
      return now;
  }
  /**
   * @notice Get private information for buyer when seller sent deposit
  **/
  function getExternalIncomingAddress()
    constant
    isDeposited
    public
    returns (bytes)
  {
      return externalIncomingAddress;
  }
  /**
   * @notice Get private information about amount for seller for sending deposit
  **/
  function getExternalDepositAmount()
    constant
    public
    returns (bytes)
  {
      return externalDepositAmount;
  }
  /**
   * @notice Get private information about address for seller for sending deposit
  **/
  function getExternalDepositAddress()
    constant
    public
    returns (bytes) {
      return externalDepositAddress;
  }
}
