// Don't use this code, it can be not working or contain the vulnerability, for demonstration purpose only
pragma solidity ^0.4.21;

import "./ESCB9.sol";

/// @title rentESCB9 - Allows rent object on market with escrow service. The safe way to do deal for counterparties.
/// @author ESCB development team - <support@escrowblock.net>
contract rentMyApartmentESCB9 is ESCB9 {
  // 2018-05-10 18:25 in unix timestamp
  uint256 constant public checkInTime  = 1525965900;
  // 2018-05-20 18:25 in unix timestamp
  uint256 constant public checkOutTime = 1526829900;
  // Coordinates in bytes format. For example 56.865129,35.881540
  bytes constant public coordinates    = '0x35362e3836353132392c33352e383831353430';
  // Google maps link, as example, but better add Url to landing page
  bytes constant public externalUrl    = '0x68747470733a2f2f676f6f2e676c2f6d6170732f6e783563396b6737384170';
  /**
   * Encrypted information, see https://github.com/ethereumjs/ethereumjs-wallet and
   * https://github.com/pubkey/eth-crypto/blob/master/tutorials/encrypted-message.md
   * For example you can leave here information about pin-code for smart lock
  **/
  bytes constant private privateInformation = '0x0dfef623523483245687234';
  modifier only_before_check_in {
    require(getNow() < checkInTime);
    _;
  }
  modifier only_after_check_out {
    require(getNow() > checkOutTime);
    _;
  }
  modifier only_during_renting {
    require(getNow() > checkInTime && getNow() < checkOutTime);
    _;
  }
  modifier only_not_in_during_renting {
    require(getNow() < checkInTime && getNow() > checkOutTime);
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
    return '0x72656e74';
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
   * @return Sum of deal in wei
  **/
  function depositedSum() public returns(uint256) {
    return 1000000000000000000; //1 ETH in weis
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
  function confirm(bytes notice) public onlyArbitrage only_after_check_out returns(bool) {
    emit confirmed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to freeze escrow deal
   * @param notice Some comment
   * @return Success of operation
  **/
  function freeze(bytes notice) public onlyArbitrage only_during_renting returns(bool) {
    emit frozen(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to dispute escrow deal
   * @return Success of operation
  **/
  function dispute(bytes notice) public onlyArbitrage only_after_check_out returns(bool) {
    emit disputed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to cancel escrow deal and confirm fail
   * @return Success of operation
  **/
  function cancel(bytes notice) public onlyArbitrage only_not_in_during_renting returns(bool) {
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
   * @notice Get private information when renter will pay deposit
  **/
  function getPrivateInformation()
    constant
    isDeposited
    public
    returns (bytes) {
      return privateInformation;
  }
}
