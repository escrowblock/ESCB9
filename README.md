# NOT READY FOR PRODUCTION
Proof of conception implementation for the Hierarchy Multisignature Wallets (HMW)

# Todo

* [ ] Add tests
* [ ] Optimization
* [ ] Using library storage
* [ ] New using examples

# Hierarchy multisignature wallets (HMW, Trust system)

`Viktorov Konstantin CEO / CTO Escrowblock Foundation`

`Version 0.0.1`

`2019`

```
Contents

Introduction

1 Description multisignature wallet

2 Ways of constructing hierarchy wallets

3 Interface hierarchy multisignature wallets

Flows interactions

4.1 Standard interaction flow

4.2 Protected interaction flow

4.3 Disputed flow interaction

5 Protocol ESCB9

6 Integration trust system and smart contracts ESCB9 implementing protocols

7 Examples of contracts that are implemented ESCB9

7.1 Smart contract for the rental market of private real estate, following the example of AirBnb

7.2 Smart contract for the exchange of any cryptocurrency for fiat money and back, in decentralized mode

8 Arbitration nodes

9 Developing your own network for the trust system

10 Glossary
```

### Introduction

The main problem for escrow services is to create a relationship of trust between all parties. In this case, the participants need not be known to each other. To summarize all the cases we will assume that they are all anonymous. For a trust system it is important to adjust the ratio of new participants to the existing ones. Existing participants who already have a rating on our system of transactions are thus treated more trustworthy. Since no one knows anyone in the trust system - this causes a problem verifying the previous rating. This paper presents the description of a trust-based systems multisignature cryptowallets. Such a system can be programmed in a smart contract. In full view of the Ethereum platform, this platform is used to describe all smart contracts in this document.

#### 1 Description multisignature wallet

Abstraction which allows to confirm or cancel the transaction only if the consensus among authorized parties for the decision referred to the multisignature wallet. Transaction in this context is an automatic operation programmed to perform the method in a different or the same smart contract. Interface for Smart contract such abstraction can be represented as the constructor accepts the addresses of the founding participants and the number of mandatory minimum confirmations for the execution of transactions

`
constructor(address[]:members, uint256:requiredConfirmationCount)
`

for interface with authorized parties

2.1 getting a list of participants

`static getMembers() -> address[]:address`

2.2 view address of participant

`static getMember(uint256:indexNumber) -> address:address`

2.3 checking the address for belonging to the participant

`static isMember(address:address) -> bool:value`

2.4 obtaining the maximum number of participants for the wallet

`static  getMaxMemberCount() -> uint256:value`

2.5 obtaining the minimum number of confirmations for consensus

`static getRequiredConfirmationCount() -> uint256:value`

2.6 new member event

`event MemberAddition() -> address:member`

2.7 event to delete a member

`event MemberRemoval() -> address:member`

2.8 event of a change in the mandatory number of confirmations to be performed

`event RequiredConfirmationCountChange() -> uint256:count`

2.9 add participant

`execute addMember(address:member) -> void:value`

2.10 removal of participant

`execute removeMember(address:member) -> void:value`

2.11 replacement participants

`execute replaceMember(address:currentMember, address:newMember) -> void:value`

2.12 change the number of mandatory confirmations to be performed

`execute changeRequiredConfirmationCount(uint256:count) -> void:value`

interface for working with transactions

3.1 verification of transaction confirmation at the participant's address

`static getConfirmationByAddress(uint256:indexNumber, address:addressMember) -> bool:value`

3.2 obtaining information from a transaction

`static getTransactionInfo(uint256:indexNumber)  -> [address:destination, uint256:value, bytes:data, bool:executed]`

3.3 obtaining total number of transactions in this wallet

`static getTransactionCount() -> uint256:value`

3.4 receiving the status of transaction confirmation

`static isConfirmed(uint256:transactionId) -> bool:value`

3.5 obtaining the number of confirmations

`static getConfirmationCount(uint256:transactionId) -> uint256:count`

3.6 obtaining the number of transactions by type

`static getTransactionCount(bool:pending, bool:executed) -> uint256:count`

3.7 receiving a list of participants who confirmed the transaction

`static getConfirmations(uint256:transactionId) -> address[]:confirmations`

3.8 receiving a list of transaction ids by type in a certain period of time

`static getTransactionIds(uint256:from, uint256:to, bool:pending, bool:executed) -> uint256[]:transactionIds`

3.9 event for transaction confirmation by a participant

`event confirmation() -> [address:sender, uint256:transactionId, uint256:timeStamp]`

3.10 event of confirmation of a participant's confirmation prior to the execution of a transaction

`event revocation() -> [address:sender, uint256:transactionId, uint256:timeStamp]`

3.11 event of adding a transaction to the queue

`event submission() -> [uint256:transactionId]`

3.12 transaction execution event

`event execution() ->  [uint256:transactionId]`

3.13 error event when the transaction is executed

`event executionFailure -> [uint256:transactionId]`

3.14 charge event

`event deposit -> [address:sender, uint256:amount]``

3.15 adding a transaction to a member

`execute submitTransaction(address:destination, uint256:value, bytes:data) -> uint256:transactionId`

3.16 transaction confirmation by the participant

`execute confirmTransaction(uint256:transactionId) -> void:value`

3.17 confirmation of the participant's confirmation

`execute revokeConfirmation(uint256:transactionId) -> void:value`

3.18 manual transaction execution

`execute executeTransaction(uint256:transactionId) -> void:value`

#### 2 Ways of constructing hierarchy wallets
There are two main ways of building a trust system. Vertical and horizontal. The Horizontal way of construction involves the creation of one main subsidiaries parent wallets list. The Vertical way of building implies a chain consisting of subsidiaries wallets with reference to the parent wallet. In this case, the parent wallet can be the child to the other parent wallet.

As we see the horizontal path of constructing may be a subspecies of the vertical way of building. Therefore, drop this approach without attention.

#### 3 Interface hierarchy multisignature wallets

To build the confidence necessary to expand the systems simple interface multisignature wallet, as described above, adding the hierarchy of mechanisms of regulation and automatic execution confirmations, as well as the possibility of deferred execution.

The constructor takes the address of the parent wallet, the addresses of the founding members, the number of mandatory minimum confirmations for the transactions, the standard time for automatic acknowledgments in seconds

`constructor(address:parent, address[]:members, uint256:requiredConfirmationCount, uint256:standardTimeAutoConfirmation)`

##### Interface for working with participants

2.1 getting a list of participants

`static getMembers() -> address[]:address`

2.2 function for viewing the address of the participant

`static getMember(uint256:indexNumber) -> address:address`

2.3 checking the address for belonging to the participant

`static isMember(address:address) -> bool:value`

2.4 obtaining the maximum number of participants in the wallet

`static  getMaxMemberCount() -> uint256:value`

2.5 obtaining the minimum number of confirmations for consensus

`static getRequiredConfirmationCount() -> uint256:value`

2.6 event of adding a new participant

`event MemberAddition() -> address:member`

2.7 event of removing a member

`event MemberRemoval() -> address:member`

2.8 event of changing in the mandatory number of confirmations to be performed

`event requiredConfirmationCountChange() -> uint256:count`

2.9 adding a participant

`execute addMember(address:member) -> void:value`

2.10 removal a participant

`execute removeMember(address:member) -> void:value`

2.11 replacement a participant

`execute replaceMember(address:currentMember, address:newMember) -> void:value`

2.12 change the number of mandatory confirmations to be performed

`execute changeRequiredConfirmationCount(uint256:count) -> void:value`

##### Interface to work with the hierarchy

3.1 getting a list of child wallets

`static getChildren() -> address[]:wallets`

3.2 checking whether the wallet address is a child of the current

`static isChild(address:address) -> bool:value`

3.3 check whether the wallet address is parental to the current one through isChild by opposing.

3.4 child wallet attachment event

`event childAttachment() -> [address:address,uint256:timeStamp]`

3.5 event removing the child wallet

`event childRemoval() -> [address:address,uint256:timeStamp]`

3.6 creating a child wallet

`execute attachChild(addres:child) -> void:value`

3.7 removal of the child wallet

`execute removeChildren(address:address) -> void:value`

3.8 change one child wallet to another

`execute replaceChild(address:newAddress) -> void:value`

##### Interface for transactions

4.1 checking the status of the transaction for compliance

`static getTransactionStatus(uint256:transactionId) -> enum:{submitted,completed,frozen,disputed,reverted}`

4.2 transaction status checking for compliance with

`static isTransactionStatus(uint256:transactionId, uint256:enumStatusNumber) -> bool:value`

4.3 verification of transaction confirmation at the participant's address

`static getConfirmationByAddress(uint256:transactionId, address:addressMember) -> bool:value`

4.4 receiving information from a transaction

`static getTransactionInfo(uint256:transactionId)  -> [address:destination, uint256:value, bytes:data, bool:executed]`

4.5 obtaining the total number of transactions in a wallet

`static getTransactionCount() -> uint256:value`

4.6 receiving the status of transaction confirmation

`static isConfirmed(uint256:transactionId) -> bool:value`

4.7 obtaining the number of confirmations

`static getConfirmationCount(uint256:transactionId) -> uint256:count`

4.8 obtaining the number of transactions by type

`static getTransactionCount(bool:pending, bool:executed) -> uint256:count`

4.9 receiving a list of participants who confirmed the transaction

`static getConfirmations(uint256:transactionId) -> address[]:confirmations`

4.10 receiving time for auto-confirmation

`static getTimeAutoConfirmation(uint256:transactionId) -> uint256:timestamp`

4.11 receiving a list of transaction ids by type in a certain period of time

`static getTransactionIds(uint256:from, uint256:to, bool:pending, bool:executed) -> uint256[]:transactionIds`

4.12 transaction confirmation of a participant

`event Confirmation() -> [address:sender, uint256:transactionId, uint256:timeStamp]`

4.13 automatic transaction confirmation event

`event AutoConfirmation() -> [uint256:transactionId, uint256:timeStamp]`

4.14 event of confirmation of a participant's confirmation prior to the execution of a transaction

`event Revocation() -> [address:sender, uint256:transactionId, uint256:timeStamp]`

4.15 event of adding a transaction to the queue

`event Submission() -> [uint256:transactionId]`

4.16 transaction execution event

`event Execution() -> [uint256:transactionId]`

4.17 event of an error during the transaction

`event ExecutionFailure -> [uint256:transactionId]`

4.18 change event transaction status to frozen

`event TransactionFrozen -> [uint256:transactionId]`

4.19 transaction status change event to the disputed

`event TransactionDisputed -> [uint256:transactionId]`

4.20 transaction status change event on the returned

`event TransactionReverted -> [uint256:transactionId]`

4.21 wallet replenishment event

`event Deposit -> [address:sender, uint256:amount]`

4.22 adding a transaction for execution

`execute submitTransaction(address:destination, uint256:value, uint256:TimeAutoConfirmation, bytes:data) -> uint256:transactionId`

4.23 confirmation transaction

`execute confirmTransaction(uint256:transactionId) -> void:value`

4.24 revoke confirmation

`execute revokeConfirmation(uint256:transactionId) -> void:value`

4.25 change the transaction status to frozen

`execute setTransactionStatus(uint256:transactionId, uint256:enumStatusNumber) -> void:value`

4.26 manual execution transaction

`execute executeTransaction(uint256:transactionId) -> void:value`

##### Rating management

5.1 getting a rating by address

`static getRatingByAddress(address:agent) -> [uint256:negativeRating, uint256:positiveRating, uint256:countRatingRecords]`

5.2 getting the history of the rating by address and serial number

`static getRatingRecordForAddress(address:agent, uint256:indexNumber) -> void:value`

5.3 event of adding an entry to the rating by address

`event RatingRecordAdded -> [address:author, address:agent, bytes32:smartContractAddress, bool:positiveOrNegative, uin256:ratingNumber, bytes:comment, uint256:indexNumber]`

5.4 adding an entry to the rating by address

`execute AddRatingRecord(address:agent, bytes32:smartContractAddress, bool:positiveOrNegative, uin256:ratingNumber, bytes:comment) -> void:value`

##### Integration with ESCB9 protocol

6.1 checking at the address whether the smart contract is attached to this wallet with a smart contract with ESCB9 implementation

`static isAttachedESCB9SmartContract(address:smartContract) -> bool:result`

6.2 checking the status of the deposit for a smart contract with ESCB9 attached to this wallet

`static getDepositStatusForESCB9SmartContract(address:smartContract) -> enum:{awaiting,founded,returned}`

6.3 event of attaching a smart contract with ESCB9 implementation to a wallet

`event AttachingESCB9SmartContract -> [address:smartContract]`

6.4 event of making a deposit for a smart contract with ESCB9 implementation attached to a wallet

`event ConfirmationForDepositESCB9SmartContract -> [address:smartContract, uint256:sum, bytes:notice]`

6.5 attachment a smart contract with the implementation of ESCB9 to the wallet

`execute attachESCB9SmartContract(address:smartContract) -> void:value`

6.6 confirmation of deposit for a smart contract with the implementation of ESCB9. If the deposit is in the external system, then in notice there will be a mark. If the deposit is in ETH, the deposit amount is sent when the method is executed.

`execute fundDepositForESCB9SmartContract(address:smartContract, uint256:sum, bytes:notice) -> void:value`

#### Flows interactions

Any smart contract can be integrated in the system hierarchy multisignature wallets. This integration will have a flow of interactions. In general terms, we distinguish several kinds of flows:

Standard. This kind of transaction takes place automatically. Without the participation of authorized participants wallets hierarchy.

Protected. In this form, the transaction may be increased from the standard time for automatic acknowledgment to the time necessary. In this case, the participation of authorized participants wallets hierarchy in the process is mandatory.

Controversial. In this kind of transaction a participant may freeze a transaction. In this case, the participation of authorized participants wallets hierarchy wallets for consensus building is mandatory.
Each wallet in a trust system has a number of authorized participants, and they decree a verdict. For simple reasoning unite all authorized participants wallet in one concept - the arbitrator.

##### 4.1 Standard interaction flow

For the sake of simplicity, we present the concept of goods and services to the concept of transfer of the object (object), and the concept fiat money, cryptocurrency to the concept of the transfer of the fund (fund).

Counterparty, the owner of the object enters into a transaction with the counterparty, the owner of the funds, in order to exchange. In this case, the object owner creates an intelligent escrow contract by sending a standardized transaction to one of the commissioners of wallets in the hierarchy multisignature wallets. In this case the registration of a third party to the transaction as a confidential system. On each transaction is determined by the standard time to carry it out. Counterparty, the owner of the fund makes a deposit transaction by transferring fund to the trust system. After that, the owner of the object passes an object owner fund. Owner fund checks the quality of the object. If before the end of time for carrying out the transaction, he/she did not confirm the quality, the funds are transferred to the owner of the object in the transaction. Both exhibit counterparty ratings of comfort to each other. Thus, the owner can change the flow means prior to closure of the transaction interaction. After the transfer of funds the owner of the object, the owner of the fund may seek a higher level of the hierarchy of the wallet to resolve disputes within the time limit specified time. After this time the ratings for the transaction are applied to both sides of the deal and it becomes irrecoverable.

##### 4.2 Protected interaction flow

If for some reason beyond the control of counterparties for the period of the transaction should be extended, by agreement between the parties wallet multisignature hierarchy (the arbitrator) may change the time allotted to the deal. After changing the time allowed for interaction transaction flow returns to the level of standard logic flow.

##### 4.3 Disputed flow interaction

If the quality of the object during the transaction counterparty is not satisfied, the owner of fund, that does deposit to the system hierarchy of multisignature wallets, the transaction can be frozen. In this case, the deposit is not transmitted to the counterpart, the owner of the object till the verdict of the transaction. Party owning funds should provide strong evidence of the transaction to the arbitrator and after that, the arbitrator shall issue a verdict in favor of one of the counterparties. If any party is not satisfied with the transaction verdict, it appeals to a superior wallet in order to follow the hierarchy multisignature wallets. Having passed all instances of hierarchy which either party may request a public vote. This exceptional measure can only be assigned to a wallet with absolute authority.

#### 5 Protocol ESCB9

Example of ESCB9 protocol on Solidity language as abstract smart contract (the protocol is under construction and can be changed)

```solidity
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
       bytes memory _funcName = bytes4(keccak256("getDepositStatusForESCB9SmartContract(address)"));
       bytes memory _concat = new bytes(_funcName.length + 32);
       for(i=0; i < address(this).length; i++) {
           _concat[i] = address(this)[i];
       }
       require(arbitrage().call.value(0)(_concat) == 1); // “founded” for enum
       _;
  }
  event confirmed(uint256 unixtimestamp, bytes32 notice);
  event frozen(uint256 unixtimestamp, bytes32 notice);
  event disputed(uint256 unixtimestamp, bytes32 notice);
  event canceled(uint256 unixtimestamp, bytes32 notice);
  /**
   * @notice Function to approve escrow deal and confirm success
   * @return Success of operation
  **/
  function confirm(notice) public onlyArbitrage returns(bool);
  /**
   * @notice Function to freeze escrow deal
   * @return Success of operation
  **/
  function freeze(notice) public onlyArbitrage returns(bool);
  /**
   * @notice Function to dispute escrow deal
   * @return Success of operation
  **/
  function dispute(notice) public onlyArbitrage returns(bool);
  /**
   * @notice Function to cancel escrow deal and confirm fail
   * @return Success of operation
  **/
  function cancel(notice) public onlyArbitrage returns(bool);
  /**
   * @notice Function to get seller's address
   * @return Seller's address
  **/
  function seller() public returns(address);
  /**
   * @notice Function to get custom type for ESCB9 smart contract
   * @return Type
  **/
  function type() public returns(bytes);
  /**
   * @notice Function to get buyer's address
   * @return Buyer's address
  **/
  function buyer() public returns(address);
 /**
   * @notice Function to get sum for deal
   * @return Sum of deal in wei
  **/
  function depositedSum() public returns(uint256);
  /**
   * @notice Function to get arbitrage's address
   * @return Arbitrage's address
  **/
  function arbitrage() public returns(address);
}
```

#### 6 Integration trust system and smart contracts ESCB9 implementing protocols

For the use of a trust system hierarchy multisignature wallets in your own project, you create a smart contract that implements the standard ESCB9 and attach this smart contract to one of the wallets, who does not have a child wallet. Such wallets in multisignature hierarchy are called "input nodes". All higher multisignature wallets known as "arbitrage nodes".

#### 7 Examples of contracts that are implemented ESCB9

##### 7.1 Smart contract for the rental market of private real estate, following the example of AirBnb

```solidity
// Don't use this code, it can be not working or contain the vulnerability, for demonstration purpose only
pragma solidity ^0.4.21;
/// @title rentMyApartmentESCB9 - Allows rent object on market with escrow service. The safe way to do deal for counterparties.
/// @author Konstantin Viktorov - <ceo@escrowblock.net>
contract rentMyApartmentESCB9 is ESCB9 {
  // 2018-05-10 18:25 in unix timestamp
  uint256 constant public checkInTime  = 1525965900;
  // 2018-05-20 18:25 in unix timestamp
  uint256 constant public checkOutTime = 1526829900;
  // Coordinates in bytes format. For example 56.865129,35.881540
  bytes constant public coordinates    = "0x35362e3836353132392c33352e383831353430";
  // Google maps link, as example, but better add Url to landing page
  bytes constant public externalUrl    = "0x68747470733a2f2f676f6f2e676c2f6d6170732f6e783563396b6737384170";
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
    return "0x27a36731337cdee360d99b980b73e24f6e188618";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get custom type for ESCB9 smart contract
   * @return Type
  **/
  function type() public returns(bytes) {
    return "rent";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get address of renter
   * @return Buyer's address
  **/
  function buyer() public returns(address) {
    return "0xb582baaF7e749d6aA98A22355A9d08B4c4d013C8";
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
    return "0xe91065d8bb2392121a8fbe6a81e79782fbc89dd4";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to approve escrow deal and confirm success
   * @param Some comment
   * @return Success of operation
  **/
  function confirm(notice) public onlyArbitrage only_after_check_out returns(bool) {
    confirmed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to freeze escrow deal
   * @param Some comment
   * @return Success of operation
  **/
  function freeze(notice) public onlyArbitrage only_during_renting returns(bool) {
    frozen(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to dispute escrow deal
   * @return Success of operation
  **/
  function dispute() public onlyArbitrage only_after_check_out returns(bool) {
    disputed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to cancel escrow deal and confirm fail
   * @return Success of operation
  **/
  function cancel() public onlyArbitrage only_not_in_during_renting returns(bool) {
    canceled(getNow(), notice);
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
```

#### 7.2 Smart contract for the exchange of any cryptocurrency for fiat money and back, in decentralized mode

The following example of a smart contract allows you to exchange BTC for fiat money directly, without the participation of exchangers and third-party services. The seller of BTC transfers to the deposit in the BTC blockchain the amount of money put into the smart contract. The buyer, after confirming the deposit by the arbitrator in automatic mode, transfers the amount pledged in the contract to the account or number of the plastic card stipulated in the contract. The arbitrator may intervene in the transaction process after the appeal of one of the participants. Initially, the deposit will be frozen and if the parties do not agree by consensus, such a contract will pass into disputable status with further permission on the flow of disputable interaction.

```solidity
// Don't use this code, it can be not working or contain the vulnerability, for demonstration purpose only
pragma solidity ^0.4.21;
/// @title p2pExchangeESCB9 - Allows exchanging any cryptocurrencies on fiat money and back, directly between users. The safe way to do deal for counterparties.
/// @desc  This example shows as exchange fiat money on BTC (forward flow)
/// @author Konstantin Viktorov - <ceo@escrowblock.net>
contract p2pExchangeESCB9 is ESCB9 {
  // in minimal decimals, for example, 500.000 rubles is equal 50000000 kopeks
  uint256 constant public inputAmount  = 50000000;
  // RUR in bytes
  bytes constant public inputCurrency  = "0x525552";
  // in minimal decimals, for example, 1 BTC is equal 100000000 satoshi
  uint256 constant public outputAmount = "100000000";   
  // BTC in bytes
  bytes constant public outputCurrency = "0x425443";
  // Deposit can be place only before this time
  const bytes public closeTime              = "1526829900";
  // use "forward" way, when output currency will be deposited or "backward" if input currency will be deposited
  uint256 constant public depositWay   = "forward";   
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
    return "0x27a36731337cdee360d99b980b73e24f6e188618";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get custom type for ESCB9 smart contract
   * @return Type
  **/
  function type() public returns(bytes) {
    return "exchange";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get address of renter
   * @return Buyer's address
  **/
  function buyer() public returns(address) {
    return "0xb582baaF7e749d6aA98A22355A9d08B4c4d013C8";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get sum for deal
   * @return Sum of deal in minimal decimals
  **/
  function depositedSum() public returns(uint256) {
    rerurn outputAmount;
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to get arbitrage's address
   * @return Arbitrage's address
  **/
  function arbitrage() public returns(address) {
    return "0xe91065d8bb2392121a8fbe6a81e79782fbc89dd4";
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to approve escrow deal and confirm success
   * @param Some comment
   * @return Success of operation
  **/
  function confirm(notice) public onlyArbitrage only_after_close_time returns(bool) {
    confirmed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to freeze escrow deal
   * @param Some comment
   * @return Success of operation
  **/
  function freeze(notice) public onlyArbitrage only_after_close_time returns(bool) {
    frozen(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to dispute escrow deal
   * @return Success of operation
  **/
  function dispute() public onlyArbitrage only_after_close_time returns(bool) {
    disputed(getNow(), notice);
  }
  /**
   * @notice ESCB9 interface
   * @notice Function to cancel escrow deal and confirm fail
   * @return Success of operation
  **/
  function cancel() public onlyArbitrage only_before_close_time returns(bool) {
    canceled(getNow(), notice);
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
    returns (bytes) {
      return externalIncomingAddress;
  }
  /**
   * @notice Get private information about amount for seller for sending deposit
  **/
  function getExternalDepositAmount()
    constant
    public
    returns (bytes) {
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
```

#### 8 Arbitration nodes

To support the work of the trust system, a hierarchy of multi-signature wallets is introduced. Arbitration nodes, that is, wallets in the hierarchy, which have a subsidiary wallet, act as guarantors of dispute resolution. Plenipotentiaries for such nodes can only be assigned to a higher-level arbitrator. Each authorized participant receives a reward by dividing, as described in EscrowBlock WhitePaper and bonuses for dealing with disputed interaction flows. The size of bonuses is determined by consensus.

To obtain the status of an authorized member of the arbitration unit, it is necessary to have a certain amount of tokens determined by consensus at the address of the authorized participant. Thus, it is guaranteed stable receipt of dividends by all participants of arbitration nodes. The higher the multi-signature wallet is in the hierarchy, the more required tokens should be present at the authorized member's address.

#### 9 Developing your own network for the trust system

At a certain stage of the development of the system, it is planned to develop its own block platform with smart contracts based on the Paxos consensus protocol family https://en.wikipedia.org/wiki/Paxos_(computer_science), the fractal dimension of the subnets of the blockchain. The lua VM is to be used as the programming language for smart contracts. The generation of internal cryptocurrency will be tied to the reward for using the computing resources of users of the system. Thus, the more computing resources of your computer for maintaining a network consensus or calculating the necessary conditions for smart contracts will be used, the more internal currency will be accrued to this user. The economic model of determining remuneration will be based on the principle of world inflation based on the basket of the maximum number of fiat currencies. In the time intervals determined by the consensus of the hierarchy of multi-signature wallets, it is proposed to adjust the basic remuneration in the form of an internal currency. Thus, it is proposed to remove the problem of large volatility of the domestic cryptocurrency by fixing on the basis of a consensus on the amount of remuneration. As in any economic models, the amount of reward can disperse inflation or reduce it. Reduction of inflation can mean negative compensation. That is, the user needs to spend the domestic currency on maintaining the network. More details about the blockchain will be outlined in further publications.

#### 10 Glossary

Ethereum - is an open source technology that allows you to create a decentralized, unchanging chain of transactions. Each transaction can be executed with certain conditions recorded in a smart contract.

Smart contract - written in the language of Solidity, the logic that runs in the virtual machine Ethereum, which allows you to extend the logic of transactions.

A multi-signature wallet (arbitrator) - is a special smart contract controlled by a group of authorized participants who can confirm or cancel transactions. Using the mechanism of multi-signature wallets, you can create a chain of gateways for transactions and timely control the execution or return of funds.

The owner of the object - is the lessor, the supplier, the developer of the software product, etc. That is, the person who implements the object and ultimately receives the deposit as a reward.

The owner of the funds - is the tenant, the buyer, the customer of the software product, etc. That is, the person who places the deposit on the object to purchase the product or service.
