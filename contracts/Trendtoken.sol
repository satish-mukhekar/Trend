// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title MyToken
 * @dev ERC20 Token with role-based access control and blacklist functionality.
 */
contract Trend is ERC20, AccessControl, Pausable {
    bytes32 private  constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private  constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 private  constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(address => bool) public blacklist; // Mapping to track blacklisted addresses
    mapping(uint256 => bool) public usedNonces; // Mapping to track used nonces

    event Blacklisted(address indexed account); // Event emitted when an address is blacklisted
    event Unblacklisted(address indexed account); // Event emitted when an address is removed from the blacklist
    event Lock(address indexed from, uint256 amount, uint256 nonce); // Event emitted when tokens are locked
    event MintOnOtherChain(address indexed to, uint256 amount); // Event emitted when minting on another chain

    /**
     * @dev Sets the values for {name} and {symbol} of the token.
     * Grants roles to the deployer.
     * @param initialSupply The initial supply of tokens to mint for the deployer.
     */
    constructor(uint256 initialSupply) ERC20("Trend", "TRND") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, initialSupply); // Mint initial supply to deployer
    }

    modifier notBlacklisted() {
        require(!blacklist[msg.sender], "Caller is blacklisted");
        _;
    }

    /**
     * @dev Grants the MINTER_ROLE to an account.
     * @param account The address to grant the minter role.
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE.
     */
    function setMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    /**
     * @dev Grants the BURNER_ROLE to an account.
     * @param account The address to grant the burner role.
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE.
     */
    function setBurnerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BURNER_ROLE, account);
    }

    /**
     * @dev Grants the PAUSER_ROLE to an account.
     * @param account The address to grant the pauser role.
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE.
     */
    function setPauserRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PAUSER_ROLE, account);
    }

    /**
     * @dev Transfers tokens to a recipient.
     * Overrides the transfer function to include pause functionality.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating success or failure.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Transfers tokens from one address to another.
     * Overrides the transferFrom function to include pause functionality.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating success or failure.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Mints new tokens and assigns them to an account.
     * Can only be called by an account with MINTER_ROLE.
     * @param to The address receiving the new tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount)
        external
        whenNotPaused
        onlyRole(MINTER_ROLE)
    {
        _mint(to, amount);
    }

    /**
     * @dev Burns a specified amount of tokens from the caller's balance.
     * Can only be called by an account with BURNER_ROLE.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Adds an address to the blacklist.
     * Can only be called by an account with ADMIN_ROLE.
     * Emits a Blacklisted event upon success.
     * @param account The address to blacklist.
     */
    function addToBlacklist(address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        blacklist[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes an address from the blacklist.
     * Can only be called by an account with ADMIN_ROLE.
     * Emits an Unblacklisted event upon success.
     * @param account The address to remove from blacklist.
     */
    function removeFromBlacklist(address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        blacklist[account] = false;
        emit Unblacklisted(account);
    }

    /**
     * @dev Pauses all token transfers. 
     * Can only be called by an account with PAUSER_ROLE. 
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

   /**
   * @dev Unpauses all token transfers. 
   * Can only be called by an account with PAUSER_ROLE. 
   */
   function unpause() external onlyRole(PAUSER_ROLE) {
       _unpause();
   }

   /**
   * @dev Locks tokens on this contract and mints equivalent tokens for a recipient. 
   * Can be called by any non-blacklisted user when not paused. 
   *
   * Requirements:
   *
   * - `msg.sender` must have a sufficient balance for locking tokens. 
   * - `nonce` must be unique and not previously used. 
   *
   * Emits a Lock event and a MintOnOtherChain event upon success. 
   *
   * @param recipient The address receiving the minted tokens on another chain. 
   * @param amount The amount of tokens to lock and mint. 
   * @param nonce A unique identifier for this transaction. 
   */
   function lockAndMint(
       address recipient,
       uint256 amount,
       uint256 nonce
   ) external notBlacklisted whenNotPaused {
       require(balanceOf(msg.sender) >= amount, "Insufficient balance"); // Check sender's balance
       require(!usedNonces[nonce], "Nonce already used"); // Check nonce is unique

       _transfer(msg.sender, address(this), amount); // Locking tokens on this contract

       usedNonces[nonce] = true; // Mark nonce as used

       emit Lock(msg.sender, amount, nonce); // Emit lock event
       emit MintOnOtherChain(recipient, amount); // Emit mint event for bridge contract

       _mint(recipient, amount); // Mint tokens to recipient (for demonstration)
   }
}