// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./registerUsers.sol";
import "./tokenHelPet.sol";

/**
 * @dev Contract deployed on Base Sepolia
 * @notice You can view the deployed contract at:
 * https://sepolia.basescan.org/address/0x8D94F785E28657400d31b2cc3a68404Cd8557B6A#code
*/

contract Redeem is Ownable {
    // Counter for post IDs
    uint256 private postIdCounter = 0;

    // Struct to store post information
    struct Post {
        address creator;
        uint256 stock;
        uint256 price;
        bool isOpen;
    }

    // Reference to other contracts
    RegisterUsers public registerUsers;
    HelPetToken public tokenHelPet;

    // Mapping to track authorized agents
    mapping(address => bool) private agents;
    // Mapping from post ID to Post struct
    mapping(uint256 => Post) public posts;

    // Events
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event PostCreated(uint256 indexed postId, address indexed creator, uint256 stock, uint256 price);
    event PostClosed(uint256 indexed postId);
    event ItemRedeemed(uint256 indexed postId, address indexed redeemer);

    /**
     * @dev Constructor initializes the contract with references to other contracts
     * @param _registerUsers Address of the RegisterUsers contract
     * @param _tokenHelPet Address of the HelPetToken contract
     */
    constructor(address _registerUsers, address _tokenHelPet) Ownable(msg.sender) {
        require(_registerUsers != address(0), "Invalid RegisterUsers address");
        require(_tokenHelPet != address(0), "Invalid TokenHelPet address");
        registerUsers = RegisterUsers(_registerUsers);
        tokenHelPet = HelPetToken(_tokenHelPet);
    }

    /**
     * @dev Modifier to restrict functions to authorized agents only
     */
    modifier onlyAgent() {
        require(agents[msg.sender], "Only agents can perform this action");
        _;
    }

    /**
     * @dev Adds a new agent
     * @param _agent Address of the agent to add
     */
    function addAgent(address _agent) external onlyOwner {
        require(_agent != address(0), "Cannot add zero address as agent");
        require(!agents[_agent], "Address is already an agent");
        agents[_agent] = true;
        emit AgentAdded(_agent);
    }

    /**
     * @dev Removes an agent
     * @param _agent Address of the agent to remove
     */
    function removeAgent(address _agent) external onlyOwner {
        require(agents[_agent], "Address is not an agent");
        agents[_agent] = false;
        emit AgentRemoved(_agent);
    }

    /**
     * @dev Checks if an address is an agent
     * @param _address Address to check
     */
    function isAgent(address _address) external view returns (bool) {
        return agents[_address];
    }

    /**
     * @dev Creates a new post for an item
     * @param _stock Number of items in stock
     * @param _price Price in TokenHelPet tokens
     */
    function createPost(uint256 _stock, uint256 _price) external {
        require(registerUsers.isRegisteredEntity(msg.sender), "Only registered entities can create posts");
        require(_stock > 0, "Stock must be greater than 0");
        require(_price > 0, "Price must be greater than 0");

        uint256 postId = postIdCounter++;
        posts[postId] = Post({
            creator: msg.sender,
            stock: _stock,
            price: _price,
            isOpen: true
        });

        emit PostCreated(postId, msg.sender, _stock, _price);
    }

    /**
     * @dev Closes an existing post
     * @param _postId ID of the post to close
     */
    function closePost(uint256 _postId) external {
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is already closed");
        require(post.creator == msg.sender || agents[msg.sender], "Only creator or agents can close posts");

        post.isOpen = false;
        emit PostClosed(_postId);
    }

    /**
     * @dev Redeems an item from a post using tokens
     * @param _postId ID of the post to redeem from
     */
    function redeemItem(uint256 _postId) external {
        require(
            registerUsers.isRegisteredUser(msg.sender) || registerUsers.isRegisteredEntity(msg.sender),
            "Only registered users or entities can redeem"
        );

        Post storage post = posts[_postId];
        require(post.isOpen, "Post is closed");
        require(post.stock > 0, "No items left in stock");
        require(
            tokenHelPet.balanceOf(msg.sender) >= post.price,
            "Insufficient token balance"
        );

        post.stock--;
        tokenHelPet.transferFrom(msg.sender, post.creator, post.price);
        
        emit ItemRedeemed(_postId, msg.sender);
    }
}