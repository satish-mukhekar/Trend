// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Bridging is CCIPReceiver, OwnerIsCreator, ERC20 {
    
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error NothingToWithdraw(); 
    error FailedToWithdrawEth(address owner, address target, uint256 value); 
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); 
    error SourceChainNotAllowlisted(uint64 sourceChainSelector); 
    error SenderNotAllowlisted(address sender); 

    bytes32 public constant MINT = "MINT";

    event MessageSent(
        bytes32 indexed messageId, 
        uint64 indexed destinationChainSelector, 
        address receiver, 
        bytes32 message,
        address _recipient, 
        address feeToken, 
        uint256 fees 
    );

    event MessageReceived(
        bytes32 indexed messageId, 
        uint64 indexed sourceChainSelector,
        address sender,
        bytes32 text, 
        address recipient
    );

    event MintOnOtherChain(address indexed to, uint256 amount);
    event Lock(address to,uint256 amount,uint256 nonce);

    bytes32 private s_lastReceivedMessageId; 
    bytes32 private s_lastReceivedText;

    mapping(uint64 => bool) public allowlistedDestinationChains;
    mapping(uint64 => bool) public allowlistedSourceChains;
    mapping(address => bool) public allowlistedSenders;
    mapping(uint256 => bool) private usedNonces;

    IERC20 private s_linkToken;

    event msgRecieved(uint64 chainSelector, address sender);

    constructor(address _router, address _link) CCIPReceiver(_router) ERC20("WebDevSoultions", "WDS") {
        s_linkToken = IERC20(_link);
    }

    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector])
            revert DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }

    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        emit msgRecieved(_sourceChainSelector, _sender);
        if (!allowlistedSourceChains[_sourceChainSelector])
            revert SourceChainNotAllowlisted(_sourceChainSelector);
        if (!allowlistedSenders[_sender]) revert SenderNotAllowlisted(_sender);
        _;
    }

    /**
     * @notice Allowlist a destination chain for cross-chain operations.
     * @param _destinationChainSelector The selector of the destination chain.
     * @param allowed Boolean indicating whether the chain is allowed.
     */
    function allowlistDestinationChain(uint64 _destinationChainSelector, bool allowed) external onlyOwner {
        allowlistedDestinationChains[_destinationChainSelector] = allowed;
    }

    /**
     * @notice Allowlist a source chain for cross-chain operations.
     * @param _sourceChainSelector The selector of the source chain.
     * @param allowed Boolean indicating whether the chain is allowed.
     */
    function allowlistSourceChain(uint64 _sourceChainSelector, bool allowed) external onlyOwner {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    /**
     * @notice Allowlist a sender for cross-chain operations.
     * @param _sender The address of the sender.
     * @param allowed Boolean indicating whether the sender is allowed.
     */
    function allowlistSender(address _sender, bool allowed) external onlyOwner {
        allowlistedSenders[_sender] = allowed;
    }

    /**
     * @notice Transfer tokens to a receiver on a different chain.
     * @param _destinationChainSelector The selector of the destination chain.
     * @param _receiver The address of the receiver on the destination chain.
     * @param message The message to send with the transfer.
     * @param _recipient The recipient of the tokens on the destination chain.
     * @return messageId The ID of the sent message.
     */
    function transferToken(
        uint64 _destinationChainSelector,
        address _receiver,
        bytes32 message,
        address _recipient
    )
        external
        onlyOwner
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            message,
            _recipient,
            address(s_linkToken)
        );

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        s_linkToken.approve(address(router), fees);

        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            message,
            _recipient,
            address(s_linkToken),
            fees
        );

        return messageId;
    }

    /**
     * @notice Handle receiving messages from other chains.
     * @param any2EvmMessage The received message data structure.
     */
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage)
        internal
        override
        onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)))
    {
        address user;
        s_lastReceivedMessageId = any2EvmMessage.messageId; 
        (s_lastReceivedText, user) = abi.decode(any2EvmMessage.data, (bytes32, address)); 

        if(s_lastReceivedText == MINT){
            super._mint(user, 1e18);
            emit MintOnOtherChain(user, 1e18);
        }

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)), 
            s_lastReceivedText,
            user
        );
    }

   /**
     * @notice Build a CCIP message for sending across chains.
     * @param _receiver The receiver's address on the destination chain.
     * @param message The message to send.
     * @param _recipient The recipient's address on the destination chain.
     * @param _feeTokenAddress The token used to pay fees for sending the message.
     * @return evm2AnyMessage The constructed EVM to Any Message structure.
     */
   function _buildCCIPMessage(
       address _receiver,
       bytes32 message,
       address _recipient,
       address _feeTokenAddress
   ) internal pure returns (Client.EVM2AnyMessage memory) {
       return Client.EVM2AnyMessage({
           receiver: abi.encode(_receiver), 
           data: abi.encode(message, _recipient), 
           tokenAmounts: new Client.EVMTokenAmount[](0), 
           extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200_000_0})),
           feeToken: _feeTokenAddress
       });
   }

   /**
   * @notice Get details of the last received message.
   * @return messageId The ID of the last received message.
   * @return text The text of the last received message.
   */
   function getLastReceivedMessageDetails() external view returns (bytes32 messageId, bytes32 text) {
       return (s_lastReceivedMessageId, s_lastReceivedText);
   }

   receive() external payable {}

   /**
   * @notice Withdraw native Ether from the contract to a beneficiary's address.
   * @param _beneficiary The address to withdraw Ether to.
   */
   function withdraw(address _beneficiary) public onlyOwner {
       uint256 amount = address(this).balance;

       if (amount == 0) revert NothingToWithdraw();

       (bool sent,) = _beneficiary.call{value: amount}("");
       if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
   }

   /**
   * @notice Withdraw ERC20 tokens from the contract to a beneficiary's address.
   * @param _beneficiary The address to withdraw tokens to.
   * @param _token The token contract to withdraw from.
   */
   function withdrawToken(address _beneficiary, address _token) public onlyOwner {
       uint256 amount = IERC20(_token).balanceOf(address(this));

       if (amount == 0) revert NothingToWithdraw();

       IERC20(_token).transfer(_beneficiary, amount);
   }
}


// avax: 0x31b103D1B0144a4B2630A26602BA6aeCFF0aa47f
// chain selector: 14767482510784806043
// router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
// link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846

// sepolia: 0x6aDC717a47fC1Fce89d6897886333547Df80217D
// chain selector: 10344971235874465080
// router: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93
// link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410