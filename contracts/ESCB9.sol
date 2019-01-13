pragma solidity ^0.4.21;

/// @title ESCB9 protocol interface.
/// @author ESCB development team - <support@escrowblock.net>
contract ESCB9 {
  /**
  * Modificator for arbitrage
  */
  modifier onlyArbitrage() {
    require(msg.sender == arbitrage());
    _;
  }

  /**
  * Modificator for checking deposit status
  */
  modifier isDeposited {
    uint i;
    bytes4 _funcName = bytes4(keccak256("ESCB9SmartContractIsDeposited(address)"));
    bytes memory _concat = new bytes(_funcName.length + 32);
    for(i=0; i < _funcName.length; i++) {
      _concat[i] = _funcName[i];
    }
    bytes20 contractAddress = bytes20(address(this));
    for(i=0; i < contractAddress.length; i++) {
      _concat[_funcName.length+i] = contractAddress[i];
    }
    require(arbitrage().call.value(0)(_concat));
    _;
  }

  event confirmed(uint256 unixtimestamp, bytes notice);
  event frozen(uint256 unixtimestamp, bytes notice);
  event disputed(uint256 unixtimestamp, bytes notice);
  event canceled(uint256 unixtimestamp, bytes notice);
  /**
  * @notice Function to approve escrow deal and confirm success
  * @return Success of operation
  **/
  function confirm(bytes notice) public onlyArbitrage returns(bool);
  /**
  * @notice Function to freeze escrow deal
  * @return Success of operation
  **/
  function freeze(bytes notice) public onlyArbitrage returns(bool);
  /**
  * @notice Function to dispute escrow deal
  * @return Success of operation
  **/
  function dispute(bytes notice) public onlyArbitrage returns(bool);
  /**
  * @notice Function to cancel escrow deal and confirm fail
  * @return Success of operation
  **/
  function cancel(bytes notice) public onlyArbitrage returns(bool);
  /**
  * @notice Function to get seller's address
  * @return Seller's address
  **/
  function seller() public returns(address);
  /**
  * @notice Function to get custom type for ESCB9 smart contract
  * @return Type
  **/
  function typeContract() public returns(bytes);
  /**
  * @notice Function to get buyer's address
  * @return Buyer's address
  **/
  function buyer() public returns(address);
  /**
  * @notice Function to get sum for deal
  * @return Sum of deal in minimal decimal for currency
  **/
  function depositedSum() public returns(uint256);
  /**
   * @notice Function to get currency symbol for deal
   * @return Currency name in bytes
  **/
  function depositedCurrency() public returns(bytes);
  /**
  * @notice Function to get arbitrage's address
  * @return Arbitrage's address
  **/
  function arbitrage() public returns(address);
}
