pragma solidity ^0.4.21;

import "./ESCB9.sol";

/// @title Hierarchy multisignature wallets - Allows build governance structure in trust system format on Ethereum blockchain.
/// @author ESCB development team - <support@escrowblock.net>
contract HMW {

    /**
     * Constants
    **/
    uint public maxMemberCount = 50;

    /**
     * Storage for members
    **/
    address[] public members;
    mapping (address => bool) public isMember;

    /**
     * Storage for agents
    **/
    address[] public agents;
    mapping (address => bool) public isAgent;

    /**
     * Storage for children
    **/
    address[] public children;
    mapping (address => bool) public isChild;

    enum Status { Submitted, Completed, Frozen, Disputed, Reverted }

    /**
     * Storage for transactions
    **/
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
        Status status;
        uint256 timeAutoConfirmation;
    }

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;

    uint public requiredConfirmationCount;
    uint public transactionCount;
    uint public standardTimeAutoConfirmation;

    /**
     * Storage for ratings
    **/
    struct Rating {
        address agent;
        uint256 negativeRating;
        uint256 positiveRating;
        uint256 countRatingRecords;
    }

    mapping (address => Rating) public ratings;

    /**
     * Storage for ratings records
    **/
    struct RatingRecord {
        address agent;
        address author;
        bytes32 smartContractAddress;
        bool positiveOrNegative;
        uint256 ratingNumber;
        bytes comment;
    }

    mapping (address => RatingRecord[]) public ratingRecords;

    /**
     * Storage for ESCB9 smart contracts
    **/
    address[] public ESCB9smartContracts;
    mapping (address => bool) public isESCB9smartContract;

    /**
     * Storage for ESCB9 smart contracts deposits
    **/
    enum DepositStatus { Awaiting, Checking, Founded, Returned }

    struct DepositRecord {
        DepositStatus status;
        uint256 sum;
        bytes notice;
        uint256 transactionId;
    }

    mapping (address => DepositRecord) public depositESCB9smartContract;

    /**
     * Modifiers
    **/
    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier memberDoesNotExist(address member) {
        require(!isMember[member]);
        _;
    }

    modifier memberExists(address member) {
        require(isMember[member]);
        _;
    }

    modifier childDoesNotExist(address child) {
        require(!isChild[child]);
        _;
    }

    modifier childExists(address child) {
        require(isChild[child]);
        _;
    }

    modifier agentExists(address agent) {
        require(isAgent[agent]);
        _;
    }

    modifier ECB9smartContractExists(address smartContract) {
        require(isESCB9smartContract[smartContract]);
        _;
    }

    modifier depositStatusECB9smartContractAwaiting(address smartContract) {
        require(depositESCB9smartContract[smartContract].status == DepositStatus.Awaiting);
        _;
    }

    modifier depositStatusECB9smartContractFounded(address smartContract) {
        require(depositESCB9smartContract[smartContract].status == DepositStatus.Founded);
        _;
    }

    modifier depositStatusECB9smartContractReturned(address smartContract) {
        require(depositESCB9smartContract[smartContract].status == DepositStatus.Returned);
        _;
    }

    modifier ECB9smartContractDoesNotExist(address smartContract) {
        require(!isESCB9smartContract[smartContract]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier afterTimeAutoConfirmation(uint transactionId) {
        require(transactions[transactionId].timeAutoConfirmation > getNow());
        _;
    }

    modifier confirmed(uint transactionId, address member) {
        require(confirmations[transactionId][member]);
        _;
    }

    modifier notConfirmed(uint transactionId, address member) {
        require(!confirmations[transactionId][member]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier rightTransactionStatus(uint transactionId, Status _enumStatus) {
        require(transactions[transactionId].status == _enumStatus);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint memberCount, uint _requiredConfirmationCount) {
        require(memberCount <= maxMemberCount && _requiredConfirmationCount <= memberCount && _requiredConfirmationCount != 0 && memberCount != 0);
        _;
    }

    /**
     * Constructor
    **/

    /// @dev Contract constructor sets initial members and required number of confirmations.
    /// @param _members List of initial members.
    /// @param _requiredConfirmationCount Number of required confirmations.
    /// @param _standardTimeAutoConfirmation Number of seconds after which transaction can be confirmed in auto mode.
    constructor (address[] _members, uint _requiredConfirmationCount, uint _standardTimeAutoConfirmation)
        public
        validRequirement(_members.length, _requiredConfirmationCount)
     {
        require(_standardTimeAutoConfirmation > 0);

        for (uint i = 0; i < _members.length; i++) {
            require(!isMember[_members[i]] && _members[i] != 0);
            isMember[_members[i]] = true;
        }

        members = _members;
        requiredConfirmationCount = _requiredConfirmationCount;
        standardTimeAutoConfirmation = _standardTimeAutoConfirmation;
    }

    /**
     * Public functions for member management
    **/

    /// @dev Returns list of members.
    /// @return List of member addresses.
    function getMembers()
        public
        constant
        returns (address[])
    {
        return members;
    }

    /// @dev Returns member from member list by index number.
    /// @return member address.
    function getMember(uint256 indexNumber)
        public
        constant
        returns (address)
    {
        require(indexNumber > 0 && members.length >= indexNumber);
        return members[indexNumber];
    }

    /**
     * Events for member management
    **/
    event MemberAddition(address indexed member);
    event MemberRemoval(address indexed member);
    event RequiredConfirmationCountChange(uint requiredConfirmationCount);

    /**
     * Execution functions for member management
    **/
    /// @dev Allows to add a new member. Transaction has to be sent by wallet.
    /// @param member Address of new member.
    function addMember(address member)
        public
        onlyWallet
        memberDoesNotExist(member)
        notNull(member)
        validRequirement(members.length + 1, requiredConfirmationCount)
    {
        isMember[member] = true;
        members.push(member);
        emit MemberAddition(member);
    }

    /// @dev Allows to remove an member. Transaction has to be sent by wallet.
    /// @param member Address of member.
    function removeMember(address member)
        public
        onlyWallet
        memberExists(member)
    {
        isMember[member] = false;
        for (uint i = 0; i < members.length - 1; i++) {
            if (members[i] == member) {
                members[i] = members[members.length - 1];
                break;
            }
        }
        members.length -= 1;
        if (requiredConfirmationCount > members.length) {
            changeRequiredConfirmationCount(members.length);
        }
        emit MemberRemoval(member);
    }

    /// @dev Allows to replace an member with a new member. Transaction has to be sent by wallet.
    /// @param member Address of member to be replaced.
    /// @param newMember Address of new member.
    function replaceMember(address member, address newMember)
        public
        onlyWallet
        memberExists(member)
        memberDoesNotExist(newMember)
    {
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == member) {
                members[i] = newMember;
                break;
            }
        }
        isMember[member] = false;
        isMember[newMember] = true;
        emit MemberRemoval(member);
        emit MemberAddition(newMember);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _requiredConfirmationCount Number of required confirmations.
    function changeRequiredConfirmationCount(uint _requiredConfirmationCount)
        public
        onlyWallet
        validRequirement(members.length, _requiredConfirmationCount)
    {
        requiredConfirmationCount = _requiredConfirmationCount;
        emit RequiredConfirmationCountChange(_requiredConfirmationCount);
    }

    /**
     * Public functions for hierarchy management
    **/

    /// @dev Returns list of children wallets.
    /// @return List of children wallet addresses.
    function getChildren()
        public
        constant
        returns (address[])
    {
        return children;
    }

    /**
     * Events for hierarchy management
    **/
    event ChildAttachment(address childAddress, uint256 timeStamp);
    event ChildRemoval(address childAddress, uint256 timeStamp);

    /**
     * Execution functions for hierarchy management
    **/

    /// @dev Allows to add a new child. Transaction has to be sent by wallet.
    /// @param child Address of new child.
    function attachChild(address child)
      public
      onlyWallet
      childDoesNotExist(child)
      notNull(child)
    {
      isChild[child] = true;
      children.push(child);
      emit ChildAttachment(child, getNow());
    }

    /// @dev Allows to remove a child. Transaction has to be sent by wallet.
    /// @param child Address of child.
    function removeChild(address child)
        public
        onlyWallet
        childExists(child)
    {
        isChild[child] = false;
        for (uint i = 0; i < children.length - 1; i++) {
            if (children[i] == child) {
                children[i] = children[children.length - 1];
                break;
            }
        }
        children.length -= 1;
        emit ChildRemoval(child, getNow());
    }

    /// @dev Allows to replace an child with a new child. Transaction has to be sent by wallet.
    /// @param child Address of child to be replaced.
    /// @param newChild Address of new child.
    function replaceChild(address child, address newChild)
        public
        onlyWallet
        childExists(child)
        childDoesNotExist(newChild)
    {
        for (uint i = 0; i < children.length; i++) {
            if (children[i] == child) {
                children[i] = newChild;
                break;
            }
        }
        isChild[child] = false;
        isChild[newChild] = true;
        emit ChildRemoval(child, getNow());
        emit ChildAttachment(newChild, getNow());
    }

    /**
     * Public functions for transaction management
    **/

    function getTransactionStatus(uint256 transactionId)
      public
      constant
      returns (Status status)
    {
       status = transactions[transactionId].status;
    }

    function isTransactionStatus(uint256 transactionId, Status enumStatusNumber)
      public
      constant
      returns (bool result)
    {
      return transactions[transactionId].status == enumStatusNumber;
    }

    function getConfirmationByAddress(uint256 transactionId, address addressMember)
        public
        constant
        returns (bool result)
    {
      return confirmations[transactionId][addressMember];
    }

    //@TODO remove from doc, we can directly get informaton from transactions

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++) {
            if ((pending && !transactions[i].executed) || (executed && transactions[i].executed)) {
                count += 1;
            }
        }
    }

    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        constant
        returns (uint count)
    {
        for (uint i = 0; i < members.length; i++) {
            if (confirmations[transactionId][members[i]]) {
                count += 1;
            }
        }
    }

    /// @dev Returns array with member addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of member addresses.
    function getConfirmations(uint transactionId)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](members.length);
        uint count = 0;
        uint i;
        for (i = 0; i < members.length; i++) {
            if (confirmations[transactionId][members[i]]) {
                confirmationsTemp[count] = members[i];
                count += 1;
            }
        }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
    }

    /// @dev Returns array with member addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of member addresses.
    function getTimeAutoConfirmation(uint transactionId)
        public
        constant
        returns (uint256 timeStamp)
    {
        timeStamp = transactions[transactionId].timeAutoConfirmation;
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    /// @dev Returns list of transaction IDs in defined range.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionIds)
    {
        require(from <= to || to < transactionCount);
        uint[] memory transactionIdsTemp = new uint[](to - from + 1);
        uint count = 0;
        uint i;
        for (i = from; i <= to; i++) {
            if ((pending && !transactions[i].executed) || (executed && transactions[i].executed)) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        }
        _transactionIds = new uint[](count);
        for (i = 0; i < count; i++) {
            _transactionIds[i] = transactionIdsTemp[i];
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i < members.length; i++) {
            if (confirmations[transactionId][members[i]]) {
                count += 1;
            }
            if (count == requiredConfirmationCount) {
                return true;
            }
        }
    }

    /**
     * Events for transaction management
    **/
    event Confirmation(address indexed sender, uint indexed transactionId, uint timeStamp);
    event Revocation(address indexed sender, uint indexed transactionId, uint timeStamp);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event TransactionFrozen(uint indexed transactionId);
    event TransactionDisputed(uint indexed transactionId);
    event TransactionReverted(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);

    /**
     * Execution functions for transaction management
    **/

    /// @dev Allows an member to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, uint256 _timeAutoConfirmation, bytes data)
        public
        notNull(destination)
        returns (uint transactionId)
    {
        uint256 timeAutoConfirmation;

        if(_timeAutoConfirmation > getNow()) {
          timeAutoConfirmation = _timeAutoConfirmation;
        } else {
          timeAutoConfirmation = getNow() + standardTimeAutoConfirmation;
        }

        transactionId = addTransaction(destination, value, data, timeAutoConfirmation);
        confirmTransaction(transactionId);
    }

    //@TODO add to specification

    /// @dev Allows an child to submit transaction to the parent.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function delegateTransaction(address destination, uint value, uint256 _timeAutoConfirmation, bytes data)
        public
        notNull(destination)
        returns (uint transactionId)
    {
        // only the child can delegate this transaction to the parent
        require(isChild[address(msg.sender)]);

        uint256 timeAutoConfirmation;
        if(_timeAutoConfirmation > getNow()) {
          timeAutoConfirmation = _timeAutoConfirmation;
        } else {
          timeAutoConfirmation = getNow() + standardTimeAutoConfirmation;
        }

        transactionId = addTransaction(destination, value, data, timeAutoConfirmation);
    }

    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data, uint256 timeAutoConfirmation)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false,
            status: Status.Submitted,
            timeAutoConfirmation: timeAutoConfirmation
        });

        transactionCount += 1;
        emit Submission(transactionId);
    }

    /// @dev Allows an member to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        memberExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId, getNow());
        executeTransaction(transactionId);
    }

    /// @dev Allows an member to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        memberExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId, getNow());
    }

    /// @dev Allows the wallet set the new transaction status
    /// @param transactionId Transaction ID.
    /// @param enumStatusNumber Status number.
    function setTransactionStatus(uint256 transactionId, Status enumStatusNumber)
        public
        onlyWallet
    {
      if(Status.Frozen == enumStatusNumber) {
        emit TransactionFrozen(transactionId);
      } else {
        if(Status.Disputed == enumStatusNumber) {
          emit TransactionDisputed(transactionId);
        } else {
          if(Status.Reverted == enumStatusNumber) {
            emit TransactionReverted(transactionId);
          } else {
            revert();
          }
        }
      }
      transactions[transactionId].status = enumStatusNumber;
    }

    /// @dev Allows anyone from members to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        memberExists(msg.sender)
        rightTransactionStatus(transactionId, Status.Submitted)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (txn.destination.call.value(txn.value)(txn.data)) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    /// @dev Allows anyone to execute transaction in autoconfirmation mode
    /// @param transactionId Transaction ID.
    function autoExecuteTransaction(uint transactionId)
        public
        afterTimeAutoConfirmation(transactionId)
        rightTransactionStatus(transactionId, Status.Submitted)
        notExecuted(transactionId)
    {
        Transaction storage txn = transactions[transactionId];
        txn.executed = true;
        if (txn.destination.call.value(txn.value)(txn.data)) {
            emit Execution(transactionId);
        } else {
            emit ExecutionFailure(transactionId);
            txn.executed = false;
        }
    }

    /**
     * Public functions for rating management
     *
    **/
    //@TODO remove from doc, we can explicitly get from ratings
    /*
     function getRatingByAddress(address agent)
         constant
         public
         agentExists(agent)
         returns(Rating rating)
     {
       rating = ratings[agent];
     }
    */

    /**
     * Events for rating management
    **/
    event RatingRecordAdded(address indexed author, address indexed agent, bytes32 smartContractAddress, bool positiveOrNegative, uint256 ratingNumber, bytes comment);

    /**
     * Execution functions for rating management
     * Only attached ESCB9 smartcontract can add rating to HMW
    **/
    function addRatingRecord(address author,
                             address agent,
                             bytes32 smartContractAddress,
                             bool positiveOrNegative,
                             uint256 ratingNumber,
                             bytes comment)
        public
        agentExists(agent)
        ECB9smartContractExists(msg.sender)
        returns(bool)
    {
      RatingRecord storage newRecord = ratingRecords[agent][ratingRecords[agent].length++];
      newRecord.agent = agent;
      newRecord.author = author;
      newRecord.smartContractAddress = smartContractAddress;
      newRecord.positiveOrNegative = positiveOrNegative;
      newRecord.ratingNumber = ratingNumber;
      newRecord.comment = comment;
      emit RatingRecordAdded(author, agent, smartContractAddress, positiveOrNegative, ratingNumber, comment);
      return true;
    }

    /**
     * Public functions for ESCB9 protocol management
    **/
    function isAttachedESCB9SmartContract(address smartContract)
        public
        view
        returns(bool result)
    {
      result = isESCB9smartContract[smartContract];
    }

    function getDepositStatusForESCB9SmartContract(address smartContract)
        public
        view
        returns(DepositStatus result)
    {
      return depositESCB9smartContract[smartContract].status;
    }

    function ESCB9SmartContractIsDeposited(address smartContract)
        public
        view
        returns(bool result)
    {
      return depositESCB9smartContract[smartContract].status == DepositStatus.Founded;
    }

    /**
     * Events for ESCB9 protocol management
    **/
    event AttachingESCB9SmartContract(address smartContract);

    //@TODO add to specification
    event ChangeDepositStatusForESCB9SmartContract(address smartContract, DepositStatus status);
    event ConfirmationForDepositESCB9SmartContract(address smartContract, uint256 sum, bytes notice);
    event CheckingForDepositESCB9SmartContract(address smartContract, uint256 sum, bytes notice);

    //@TODO add to specification
    event SendDepositToSeller(address smartContract, uint256 sum, bytes notice);

    /**
     * Execution functions for ESCB9 protocol management
    **/
    function attachESCB9SmartContract(address smartContract)
        notNull(smartContract)
        ECB9smartContractDoesNotExist(smartContract)
        public
    {
      isESCB9smartContract[smartContract] = true;
      ESCB9smartContracts.push(smartContract);
      bytes4 _funcName = bytes4(keccak256("confirmESCB9SmartContract(address, notice)"));
      bytes memory notice = "0x6175746f"; //auto
      bytes memory _data = new bytes(_funcName.length + 32 + notice.length);
      uint i;
      for(i=0; i < _funcName.length; i++) {
        _data[i] = _funcName[i];
      }
      bytes20 contractAddress = bytes20(address(this));
      for(i=0; i < contractAddress.length; i++) {
        _data[_funcName.length+i] = contractAddress[i];
      }
      for(i=0; i < notice.length; i++) {
        _data[_funcName.length+32+i] = notice[i];
      }
      //@TODO add this function to specification
      //@NOTICE After an attaching Smart contract we add in the queue the transaction
      //for confirmation deal by the contract in a standart time for the autoconfirmation
      uint256 transactionId = addTransaction(address(this), 0, _data, standardTimeAutoConfirmation);
      depositESCB9smartContract[smartContract].status = DepositStatus.Awaiting;
      depositESCB9smartContract[smartContract].transactionId = transactionId;
      emit AttachingESCB9SmartContract(smartContract);
    }

    /**
     * This is a function to there the buyer sends an agreement sum or publish
     * encrypted data with an external transactional information
    **/
    function fundDepositForESCB9SmartContract(address smartContract, uint256 sum, bytes notice)
        notNull(smartContract)
        ECB9smartContractExists(smartContract)
        depositStatusECB9smartContractAwaiting(smartContract)
        payable
        public
    {
      // here we check the case with funding in ETH amount
      if (msg.value > 0 && keccak256(ESCB9(smartContract).depositedCurrency()) == keccak256("0x455448")) {
        uint256 sumEth = msg.value;
        if(sumEth == ESCB9(smartContract).depositedSum()) {
          depositESCB9smartContract[smartContract].status = DepositStatus.Founded;
          emit ConfirmationForDepositESCB9SmartContract(smartContract, sum, notice);
        } else {
          revert();
        }
      } else {
        // In this case arbitrage must confirm deposit via the Oracle contract.
        // For this aim we need to write for each supported methods own checking function
        // in an external blockchain, system, or check by manually. All data will be confirmed via the Oracle.
        if(sum == ESCB9(smartContract).depositedSum()) {
          depositESCB9smartContract[smartContract].status = DepositStatus.Checking;
          depositESCB9smartContract[smartContract].sum = sum;
          depositESCB9smartContract[smartContract].notice = notice;
          emit ChangeDepositStatusForESCB9SmartContract(smartContract, DepositStatus.Checking);
        }
      }
    }

    /**
     * This method uses when a deposit from a counterparty is in an external blockchain, system
    **/
    //@TODO add to specification
    function setDepositForESCB9SmartContractStatus(address smartContract, DepositStatus enumStatusNumber)
        public
        onlyWallet
    {
      if(DepositStatus.Awaiting == enumStatusNumber) {
        emit ChangeDepositStatusForESCB9SmartContract(smartContract, DepositStatus.Awaiting);
      } else {
        if(DepositStatus.Founded == enumStatusNumber) {
          emit ChangeDepositStatusForESCB9SmartContract(smartContract, DepositStatus.Founded);
          emit ConfirmationForDepositESCB9SmartContract(smartContract, depositESCB9smartContract[smartContract].sum, depositESCB9smartContract[smartContract].notice);
        } else {
          if(DepositStatus.Returned == enumStatusNumber) {
            emit ChangeDepositStatusForESCB9SmartContract(smartContract, DepositStatus.Returned);
          } else {
            revert();
          }
        }
      }
      depositESCB9smartContract[smartContract].status = enumStatusNumber;
    }

    /**
     * The buyer or the current wallet can confirm deal before it
     * will be made by autoconfirmation process
    **/
    function confirmESCB9SmartContract(address smartContract, bytes notice)
        ECB9smartContractExists(smartContract)
        public
    {
      // Confirmation must be called by buyer or by current wallet
      address buyer = ESCB9(smartContract).buyer();
      require(msg.sender == address(this) || msg.sender == buyer);
      require(depositESCB9smartContract[smartContract].status == DepositStatus.Founded);

      // here we check the case when a funding was in ETH amount
      if (keccak256(ESCB9(smartContract).depositedCurrency()) == keccak256("0x455448")) {
        address seller = ESCB9(smartContract).seller();
        uint depositedSum = ESCB9(smartContract).depositedSum();
        address(seller).transfer(depositedSum);
      } else {
        //@TODO here we emit an event with instruction for the arbitrage to send a deposit for a seller
        emit SendDepositToSeller(smartContract, depositESCB9smartContract[smartContract].sum, depositESCB9smartContract[smartContract].notice);
      }

      ESCB9(smartContract).confirm(notice);
    }

    /**
     * The buyer or the current wallet can cancel deal before it will be founded
     * then nothing will happen, if they will to try cancel after the deal is deposited,
     * then the deal will become in dispute status
    **/
    function cancelESCB9SmartContract(address smartContract, bytes notice)
        ECB9smartContractExists(smartContract)
        public
    {
      // Cancel must be called by buyer or by current wallet
      address buyer = ESCB9(smartContract).buyer();
      require(msg.sender == address(this) || msg.sender == buyer);

      if (depositESCB9smartContract[smartContract].status == DepositStatus.Awaiting) {
        ESCB9(smartContract).cancel(notice);
      } else {
        if (depositESCB9smartContract[smartContract].status == DepositStatus.Checking) {
          setTransactionStatus(depositESCB9smartContract[smartContract].transactionId, Status.Frozen);
          //here we set a status for the transaction in disputed to avoid autoconfirmation
          ESCB9(smartContract).freeze(notice);
        } else {
          if (depositESCB9smartContract[smartContract].status == DepositStatus.Founded) {
            ESCB9(smartContract).dispute(notice);
            //here we set a status for the transaction in disputed to avoid autoconfirmation
            setTransactionStatus(depositESCB9smartContract[smartContract].transactionId, Status.Disputed);
          }
        }
      }
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

    /// @dev Fallback function allows to deposit ether.
    function() public payable {
      if (msg.value > 0) {
        emit Deposit(msg.sender, msg.value);
      }
    }
}
