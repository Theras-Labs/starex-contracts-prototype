// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Gold Exchange Ledger for universal chain currency
/// @author 0xdellwatson
/// @dev Need to refactor and make it modular as it scales up, with upgradability option
/// @notice A version A ledger to manage balances, each tx will need approval for both parties (bank, client).
/// The tx is done in one-way, the function to view the list isn't implemented
/// as we can just see it from events off-chain unless we make contract provider requiring on-chain data
/// The currency here is only one for now. so it can be either points from the app or even USD depending on usage
contract PaymasterLedger is Ownable {
    /*------------------- ENUMS -------------------*/

    enum OperationType {
        Deposit,
        Transfer,
        PaymentRequest
    }
    enum OperationStatus {
        Pending,
        Rejected,
        BankApproved,
        Completed
    }

    /*------------------- STRUCTS -------------------*/

    /// @notice Struct to hold transaction information
    /// @dev - Need to differentiate the id for in and out later,
    /// @dev   so it would show on both related addresses as withdraw and deposit
    /// @dev - Need to add block timestamp for on-chain interaction
    /// @param id Id of tx from the address, and NOT global id
    /// @param amount Amount related in transaction using a single currency
    /// @param operationType Type of transaction Deposit | Transfer
    /// @param status Current status of transaction until completion
    /// @param isApprovedSender Does the client approve this?
    /// @param isApprovedBank Does the bank approve this?
    /// @param bankApprover The address of the bank who approves, in case of a change of bank-address
    /// @param initiator Address who is requesting this tx
    /// @param sender Address value account comes from
    /// @param recipient Address value account goes to
    struct Transaction {
        uint256 id;
        uint256 amount;
        OperationType operationType;
        OperationStatus status;
        bool isApprovedSender;
        bool isApprovedBank;
        address bankApprover;
        address initiator;
        address sender;
        address recipient;
    }

    /*------------------- STATE VARIABLES -------------------*/
    // Will record all tx per user
    mapping(address => Transaction[]) internal s_transactionHistory;
    // Balance of each user
    mapping(address => uint256) internal s_balances;
    address internal s_bank;
    address internal s_operator;
    uint256 public s_minAmount;
    uint256 public s_maxAmount;

    /*------------------- EVENTS -------------------*/

    event TransactionInitiated(
        OperationType operationType,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 transactionId
    );

    event TransactionProcessed(
        address indexed from,
        uint256 transactionId,
        bool approved
    );

    event BalanceMovement(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /*------------------- MODIFIERS -------------------*/

    modifier onlyBank() {
        require(msg.sender == s_bank, "Only the bank can call this function");
        _;
    }

    /// @dev The list of authorized operators, perhaps making this into list
    modifier onlyOperator() {
        require(
            msg.sender == s_operator,
            "Only authorized operator can call this function"
        );
        _;
    }

    /*------------------- CONSTRUCTOR -------------------*/

    /// @notice Constructor to initialize the PaymasterLedger contract.
    /// @param _bank The address of the bank.
    /// @param _minAmount Minimum amount to move the balance,
    ///      this is to avoid moving 0.001 points or something 0.00001 usd
    /// @param _maxAmount Maximum amount to receive the balance, in case the bank wants to limit this
    constructor(
        address _bank,
        address _operator,
        uint256 _minAmount,
        uint256 _maxAmount
    ) Ownable(msg.sender) {
        s_bank = _bank;
        s_operator = _operator;
        s_minAmount = _minAmount;
        s_maxAmount = _maxAmount;
    }

    /*------------------- EXTERNAL FUNCTIONS -------------------*/

    /// @notice Change the bank address.
    /// @param _newBank The new bank address.
    function changeBankAddress(address _newBank) external onlyOwner {
        s_bank = _newBank;
    }

    /// @notice Change the operator address.
    /// @param _newOperator The new operator address.
    function changeOperatorAddress(address _newOperator) external onlyOwner {
        s_operator = _newOperator;
    }

    /// @notice Get the balance of a user.
    /// @param _user The user's address.
    /// @return The user's balance.
    function balanceOf(address _user) external view returns (uint256) {
        return s_balances[_user];
    }

    /*------------------- PUBLIC FUNCTIONS -------------------*/

    /// @notice Get the all transactions history of a user.
    /// @param _user The user's address.
    /// @return An array of user's transactions.
    function getTransactionHistory(address _user)
        external
        view
        returns (Transaction[] memory)
    {
        return s_transactionHistory[_user];
    }

    /// @notice Get details of a specific transaction.
    /// @param _user The user's address.
    /// @param _id The transaction ID.
    /// @return Details of the transaction.
    function getTransactionDetail(address _user, uint256 _id)
        external
        view
        returns (Transaction memory)
    {
        require(
            _id > 0 && _id <= s_transactionHistory[_user].length,
            "Invalid transaction ID"
        );
        return s_transactionHistory[_user][_id - 1];
    }

    /// @notice Deposit funds to the ledger.
    /// @param _toAddress The recipient's address.
    /// @param _amount The amount to deposit.
    ///
    /// @notice The value of the currency won't be able to change.
    /// - Only self-account can deposit to himself or authority (bank or defi)
    ///
    function deposit(address _toAddress, uint256 _amount) public {
        // Checking the correct amount
        require(_amount > 0, "Amount must be greater than 0");
        // Avoid big amount, this is to increase security as well
        require(s_maxAmount > _amount, "Reduce the amount");
        // Only self-account can deposit to himself or authority (bank? or defi protocol)
        require(
            _toAddress == msg.sender || msg.sender == s_operator,
            "Invalid address"
        );

        Transaction memory newTransaction = Transaction({
            id: s_transactionHistory[_toAddress].length + 1, // Id will reflect to address of the receiver
            amount: _amount,
            operationType: OperationType.Deposit,
            status: OperationStatus.Pending,
            isApprovedSender: true, // If it's inactive/false require client approval
            isApprovedBank: false,
            bankApprover: address(0),
            initiator: msg.sender, // Initiator can be PROTOCOL | BANK | or self
            sender: msg.sender,
            recipient: _toAddress
        });

        // Store this into state;
        s_transactionHistory[_toAddress].push(newTransaction);

        // Notify the log
        emit TransactionInitiated(
            newTransaction.operationType,
            msg.sender,
            _toAddress,
            newTransaction.amount,
            s_transactionHistory[_toAddress].length + 1
        );
    }

    /// @notice Initiate a transfer between accounts.
    /// @param _fromAddress The sender's address.
    /// @param _toAddress The recipient's address.
    /// @param _amount The amount to transfer.
    /// @return The id of the transaction.
    /// Note _fromAddress isn't always a self-address; this will make
    /// the possibility to make a bill request or payment to another person
    function transferFrom(
        address _fromAddress,
        address _toAddress,
        uint256 _amount
    ) public virtual returns (uint256) {
        // cannot move self to self
        require(
            _fromAddress != _toAddress,
            "From and To cannot be same address"
        );

        // Restrict function to not accept small amounts like 0.001 usd; the amount is in 1e18
        require(
            _amount > s_minAmount,
            "Amount is lower than the minimum requirement"
        );

        // Prepare variable to store the state
        Transaction memory newTransaction;

        // Payment request doesn't need a balance check here
        // Bill request shouldn't be stopped even with zero balance; sender can deposit then pay it later
        OperationType operationType = OperationType.PaymentRequest;
        bool isApprovedSender = false;

        // If it's self-balance to move
        if (_fromAddress == msg.sender) {
            // Make this as msg.sender, as an operator can work on it too
            uint256 senderBalance = s_balances[msg.sender];
            require(senderBalance >= _amount, "Insufficient balance");
            // Self-balance move = TRANSFER
            operationType = OperationType.Transfer;
            // If it's self-balance, then should approve immediately
            // Since it's within the same contract and for this contract
            // If it's false -> it requires 1 step to
            isApprovedSender = false; // make it true if want auto approved from self
        }

        /// Note need to change this structure into nested_mapping + id++ structure later
        uint256 txHistoryLength = s_transactionHistory[_fromAddress].length;

        newTransaction = Transaction({
            id: txHistoryLength + 1,
            amount: _amount,
            operationType: operationType,
            status: OperationStatus.Pending,
            isApprovedSender: isApprovedSender,
            isApprovedBank: false,
            bankApprover: address(0),
            initiator: msg.sender,
            sender: _fromAddress,
            recipient: _toAddress
        });

        // Currently, this only records to the sender tx history
        /// @dev Should we store into both sender and recipient history?
        s_transactionHistory[_fromAddress].push(newTransaction);

        // Notify the log
        emit TransactionInitiated(
            newTransaction.operationType,
            _fromAddress,
            _toAddress,
            newTransaction.amount,
            txHistoryLength + 1
        );

        return txHistoryLength + 1;
    }

    /// @notice Work as the client's approval, work like Pay a bill or payment request
    /// @param transactionId The ID of the transaction to pay.
    /// Note approving tx is only work for self signature; cannot approve the other
    function approve(uint256 transactionId) external {
        // Since payment request will give the user
        require(
            transactionId > 0 &&
                transactionId <= s_transactionHistory[msg.sender].length,
            "Invalid transaction ID"
        );

        Transaction storage transaction = s_transactionHistory[msg.sender][
            transactionId - 1
        ];

        require(
            !transaction.isApprovedSender,
            "Transaction is already approved"
        );

        // Note this should open for all types of requests now
        // Require(
        //     transaction.operationType == OperationType.PaymentRequest,
        //     "Invalid operation type"
        // );

        require(
            s_balances[msg.sender] >= transaction.amount,
            "Insufficient balance"
        );

        transaction.isApprovedSender = true;

        // If the bank is already approved, execute immediately
        if (transaction.isApprovedBank) {
            // Move forward to update the balance
            _updateBalance(
                msg.sender,
                transaction.recipient,
                transaction.amount,
                transaction.id
            );
        }

        emit TransactionProcessed(msg.sender, transactionId, true);
    }

    /*------------------- ONLY BANK -------------------*/

    /// @notice Work as the bank's approval
    /// @param _user The address of the transaction to approve.
    /// @param _transactionId The ID from the address of tx
    /// @param _approved Bool whether is rejected or approved
    function bankApprove(
        address _user,
        uint256 _transactionId,
        bool _approved
    ) external onlyBank {
        require(
            _transactionId > 0 &&
                _transactionId <= s_transactionHistory[_user].length,
            "Invalid transaction ID"
        );
        Transaction storage transaction = s_transactionHistory[_user][
            _transactionId - 1
        ];

        // Move balance internally
        _internalBankApprove(transaction, _approved);
    }

    /// @notice Work as the bank's approval in batch
    /// @dev This function allows the bank to approve or reject multiple transactions for multiple users
    /// @param _users The addresses of the users whose transactions to approve or reject
    /// @param _transactionIds The ID(s) of the transaction(s) to approve or reject for each user
    /// @param _approvals Boolean array indicating whether each transaction is approved or rejected
    function batchBankApprove(
        address[] calldata _users,
        uint256[] calldata _transactionIds,
        bool[] calldata _approvals
    ) external onlyBank {
        require(
            _users.length == _transactionIds.length &&
                _transactionIds.length == _approvals.length,
            "Mismatched array lengths"
        );

        for (uint256 i = 0; i < _transactionIds.length; i++) {
            uint256 transactionId = _transactionIds[i];
            require(
                transactionId > 0 &&
                    transactionId <= s_transactionHistory[_users[i]].length,
                "Invalid transaction ID"
            );
            Transaction storage transaction = s_transactionHistory[_users[i]][
                transactionId - 1
            ];

            // Move balance internally
            _internalBankApprove(transaction, _approvals[i]);
        }
    }

    /*------------------- INTERNAL FUNCTIONS -------------------*/

    /// @dev Internal function to handle bank approval and balance adjustment.
    /// @param transaction The transaction to be approved or rejected.
    /// @param approved Whether to approve or reject the transaction.
    function _internalBankApprove(
        Transaction storage transaction,
        bool approved
    ) internal {
        // note: can do balance check here, but we would like to let the bank approve when the client hasn't approved yet too
        // require(s_balances[transaction.sender] > transaction.amount, "Transaction cannot proceed");

        // check if it's already approved; this is a one-way transaction, meaning it can't be returned
        require(
            !transaction.isApprovedBank,
            "Transaction is already bank approved"
        );

        // change the status of bank approval
        transaction.bankApprover = msg.sender;
        transaction.isApprovedBank = approved;

        // differentiate between APPROVE and REJECT conditions
        if (approved) {
            transaction.status = OperationStatus.BankApproved;

            // check if it's a deposit transaction, then do the second overload _updateBalance
            if (transaction.operationType == OperationType.Deposit) {
                // update balance in another internal function
                _updateBalance(transaction.recipient, transaction.amount);
            } else {
                // if it's not a deposit
                if (transaction.isApprovedSender) {
                    // update balance, carries ID for possible rejection later
                    _updateBalance(
                        transaction.sender,
                        transaction.recipient,
                        transaction.amount,
                        transaction.id
                    );
                }
            }
        } else {
            // if transaction is rejected, balance will not be moved out
            transaction.status = OperationStatus.Rejected;
        }

        emit TransactionProcessed(msg.sender, transaction.id, approved);
    }

    /// @dev Internal function to update user balances during a transfer.
    /// @param _from The sender's address.
    /// @param _to The recipient's address.
    /// @param _amount The amount to transfer.
    /// @param _id The identifier for the transaction.
    /// @notice This function is designed to control the balance update with extra steps and can be called from other functions.
    function _updateBalance(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _id
    ) internal virtual {
        // since the bank can take time on APPROVAL, there might be a consideration on the account
        // for example: it's a multiple tx, and the bank approves the higher amount, resulting in the sender's balance becoming empty
        if (s_balances[_from] > _amount) {
            // then move out the balance
            s_balances[_from] -= _amount;
            s_balances[_to] += _amount;

            emit BalanceMovement(_from, _to, _amount);
        } else {
            Transaction storage transaction = s_transactionHistory[_from][_id];
            transaction.status = OperationStatus.Rejected;

            // emit event reject
        }
    }

    /// @dev Internal function to update user balance for deposits.
    /// @param _to The recipient's address.
    /// @param _amount The amount to deposit.
    function _updateBalance(address _to, uint256 _amount) internal virtual {
        s_balances[_to] += _amount;

        emit BalanceMovement(address(0), _to, _amount);
    }
}
