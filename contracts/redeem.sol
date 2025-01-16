// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RegisterUsers.sol";
import "./PawsForHopeToken.sol";


contract Redeem is Ownable {
    // Counter for post IDs
    uint256 private postIdCounter = 0;

    // Struct to store post information
    struct Post {
        address creator;
        uint256 stock;            // Number of items in stock
        uint256 price;            // Price in PawsForHopeToken tokens
        string category;          // Category of the item or service (e.g., veterinary, food, adoption)
        string description;       // Description of the item or service
        string location;          // Location of the service or item
        string contactInfo;       // Contact information for further inquiries
        uint256 createdAt;        // Timestamp of post creation
        bool isOpen;
    }

    // Reference to other contracts
    RegisterUsers public registerUsers;
    PawsForHopeToken public tokenPawsForHopeToken;

    mapping(address => bool) private agents;     // Mapping to track authorized agents
    mapping(uint256 => Post) public posts;      // Mapping from post ID to Post struct

    // Events
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event PostCreated(uint256 indexed postId, address indexed creator, uint256 stock, uint256 price);
    event PostClosed(uint256 indexed postId);
    event ItemRedeemed(uint256 indexed postId, address indexed redeemer);

    /**
     * @dev Constructor initializes the contract with references to other contracts
     * @param _tokenPawsForHopeToken Address of the PawsForHopeToken contract
     */
    constructor(address _tokenPawsForHopeToken) Ownable(msg.sender) {
        // require(_registerUsers != address(0), "Invalid RegisterUsers address");
        require(_tokenPawsForHopeToken != address(0), "Invalid tokenPawsForHopeToken address");
        // registerUsers = RegisterUsers(_registerUsers);
        tokenPawsForHopeToken = PawsForHopeToken(_tokenPawsForHopeToken);
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
     * @param _price Price in PawsForHopeToken tokens
     */
    function createPost(uint256 _stock, uint256 _price, string memory _category, string memory _description, string memory _location, string memory _contactInfo) external {
        // require(registerUsers.isRegisteredEntity(msg.sender), "Only registered entities can create posts");
        require(_stock > 0, "Stock must be greater than 0");
        require(_price > 0, "Price must be greater than 0");
        require(bytes(_category).length > 0, "Category cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 postId = postIdCounter++;
        posts[postId] = Post({ creator: msg.sender, stock: _stock,
            price: _price, category: _category, description: _description,
            location: _location,
            contactInfo: _contactInfo,
            createdAt: block.timestamp,
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
        // require(registerUsers.isRegisteredUser(msg.sender) || registerUsers.isRegisteredEntity(msg.sender), "Only registered users or entities can redeem");

        Post storage post = posts[_postId];
        require(post.isOpen, "Post is closed");
        require(post.stock > 0, "No items left in stock");
        require(tokenPawsForHopeToken.balanceOf(msg.sender) >= post.price, "Insufficient token balance");

        post.stock--;
        tokenPawsForHopeToken.transferFrom(msg.sender, post.creator, post.price);
        
        emit ItemRedeemed(_postId, msg.sender);
    }
}