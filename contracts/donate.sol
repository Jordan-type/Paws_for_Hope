// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./registerUsers.sol";
import "./tokenPawsForHopeToken.sol";


contract Donate is Ownable {
    
    // Counter for post IDs
    uint256 private postIdCounter = 0;

    // Base Mainnet USDC contract address
    //address constant public USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    // USDCPet contract address
    address constant public USDC = 0x1dfe0B41dDebe308B6096D32a0c404b2d835C6Ce;

    // Struct to store post information
    struct Post {
        address creator;
        uint256 targetAmount;
        uint256 currentAmount;
        bool isOpen;
        string description;
    }

    // Mapping from post ID to Post struct
    mapping(uint256 => Post) public posts;
    // Mapping to track authorized agents
    mapping(address => bool) private agents;

    // Events
    event PostCreated(uint256 indexed postId, address indexed creator, uint256 targetAmount, string description);
    event PostClosed(uint256 indexed postId);
    event DonationReceived(uint256 indexed postId, address indexed donor, uint256 amount);
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);

    // Reference to other contracts
    RegisterUsers public registerUsers;
    PawsForHopeToken public tokenPawsForHopeToken;
    IERC20 public usdc;

    /**
     * @dev Constructor initializes the contract with references to other contracts
     * @param _registerUsers Address of the RegisterUsers contract
     * @param _tokenPawsForHopeToken Address of the tokenPawsForHopeToken contract
     */
    constructor(address _registerUsers, address _tokenPawsForHopeToken) Ownable(msg.sender) {
        require(_registerUsers != address(0), "Invalid RegisterUsers address");
        require(_tokenPawsForHopeToken != address(0), "Invalid TokenHelPet address");
        registerUsers = RegisterUsers(_registerUsers);
        tokenPawsForHopeToken = PawsForHopeToken(_tokenPawsForHopeToken);
        usdc = IERC20(USDC);
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
     * @dev Creates a new donation post
     * @param _targetAmount Target amount for the donation in USDC
     * @param _description Description of the donation purpose
     */
    function createDonationPost(uint256 _targetAmount, string memory _description) external {
        require(registerUsers.isRegisteredEntity(msg.sender), "Only registered entities can create posts");
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 postId = postIdCounter++;
        posts[postId] = Post({
            creator: msg.sender,
            targetAmount: _targetAmount,
            currentAmount: 0,
            isOpen: true,
            description: _description
        });

        emit PostCreated(postId, msg.sender, _targetAmount, _description);
    }

    /**
     * @dev Closes a donation post
     * @param _postId ID of the post to close
     */
    function closePost(uint256 _postId) external {
        require(_postId < postIdCounter, "Post does not exist");
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is already closed");
        require(
            msg.sender == post.creator || agents[msg.sender],
            "Only creator or agent can close post"
        );

        post.isOpen = false;
        emit PostClosed(_postId);
    }

    /**
     * @dev Allows users to donate to a specific post
     * @param _postId ID of the post to donate to
     * @param _amount Amount to donate in USDC
     */
    function donateToPost(uint256 _postId, uint256 _amount) external {
        require(
            registerUsers.isRegisteredUser(msg.sender) || 
            registerUsers.isRegisteredEntity(msg.sender),
            "Must be registered user or entity"
        );
        require(_postId < postIdCounter, "Post does not exist");
        require(_amount > 0, "Amount must be greater than 0");
        
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is closed");

        uint256 creatorAmount = (_amount * 99) / 100;
        uint256 ownerAmount = _amount - creatorAmount;

        require(
            usdc.transferFrom(msg.sender, post.creator, creatorAmount),
            "Creator transfer failed"
        );
        require(
            usdc.transferFrom(msg.sender, owner(), ownerAmount),
            "Owner transfer failed"
        );

        post.currentAmount += _amount;
        
        // Mint HelPet tokens to donor
        tokenHelPet.mint(msg.sender, 50);
        
        emit DonationReceived(_postId, msg.sender, _amount);
    }

}