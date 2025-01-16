// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RegisterUsers.sol";
import "./PawsForHopeToken.sol";

contract Donate is Ownable {
    
    // Counter for post IDs
    uint256 private postIdCounter = 0;

    // Base Mainnet USDC contract address
    //address constant public USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    // USDCPaws contract address
    // address constant public USDC = 0xDA07165D4f7c84EEEfa7a4Ff439e039B7925d3dF;

    // Struct to store post information
    struct Post {
        address creator;
        uint256 targetAmount;
        uint256 currentAmount;
        string category;          // Category of the donation
        string description;       // Purpose of the donation
        uint256 deadline;         // Deadline for the campaign
        string beneficiary;       // Beneficiary organization or cause
        bool isOpen;
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
    // RegisterUsers public registerUsers;
    PawsForHopeToken public tokenPawsForHopeToken;
    IERC20 public usdc; // USDCPaws contract address

    /**
     * @dev Constructor initializes the contract with references to other contracts
     * @param _pawsForHopeToken Address of the tokenPawsForHopeToken contract
     */
    constructor(address _pawsForHopeToken, address _USDCpaws) Ownable(msg.sender) {
        // require(_registerUsers != address(0), "Invalid RegisterUsers address");
        require(_pawsForHopeToken != address(0), "Invalid TokenPawsForHope address");
        require(_USDCpaws != address(0), "Invalid USDCPaws address");
        
        // registerUsers = RegisterUsers(_registerUsers);
        tokenPawsForHopeToken = PawsForHopeToken(_pawsForHopeToken);
        usdc = IERC20(_USDCpaws);
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
    function createDonationPost(uint256 _targetAmount, string memory _category, string memory _description, uint256 _deadline, string memory _beneficiary) external {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 postId = postIdCounter++;
        posts[postId] = Post({creator: msg.sender, targetAmount: _targetAmount, currentAmount: 0, category: _category, description: _description, deadline: _deadline, beneficiary: _beneficiary, isOpen: true});

        emit PostCreated(postId, msg.sender, _targetAmount, _description);
    }

    function getAllPosts() external view returns (Post[] memory) {
        Post[] memory allPosts = new Post[](postIdCounter);
        for (uint256 i = 0; i < postIdCounter; i++) {
            allPosts[i] = posts[i];
            }
        return allPosts;
    }

    function getPostsByCategory(string memory _category) external view returns (Post[] memory) {
        uint256 count = 0;
        
        for (uint256 i = 0; i < postIdCounter; i++) {
            if (keccak256(abi.encodePacked(posts[i].category)) == keccak256(abi.encodePacked(_category))) {
                count++;
            }
        }
        
        Post[] memory categoryPosts = new Post[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < postIdCounter; i++) {
            if (keccak256(abi.encodePacked(posts[i].category)) == keccak256(abi.encodePacked(_category))) {
                categoryPosts[index] = posts[i];
                index++;
            }
        }
        
        return categoryPosts;
    }
    
    /**
    * @dev Returns the total donations made across all posts.
    * @return totalDonations The total amount of donations in USDC.
    */
    function getTotalDonations() external view returns (uint256 totalDonations) {
        for (uint256 i = 0; i < postIdCounter; i++) {
            totalDonations += posts[i].currentAmount;
        }
    }


    /**
     * @dev Closes a donation post
     * @param _postId ID of the post to close
     */
    function closePost(uint256 _postId) external {
        require(_postId < postIdCounter, "Post does not exist");
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is already closed");
        require(msg.sender == post.creator || agents[msg.sender], "Only creator or agent can close post");

        post.isOpen = false;
        emit PostClosed(_postId);
    }

    /**
     * @dev Allows users to donate to a specific post
     * @param _postId ID of the post to donate to
     * @param _amount Amount to donate in USDC
     */
    function donateToPost(uint256 _postId, uint256 _amount) external payable {
        require(_postId < postIdCounter, "Post does not exist");
        require(_amount > 0, "Amount must be greater than 0");
        
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is closed");

        require(usdc.balanceOf(msg.sender) >= _amount, "Insufficient USDC balance");
        require(usdc.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");

        uint256 creatorAmount = (_amount * 99) / 100;
        uint256 ownerAmount = _amount - creatorAmount;

        require(usdc.transferFrom(msg.sender, post.creator, creatorAmount), "Creator transfer failed");
        require(usdc.transferFrom(msg.sender, owner(), ownerAmount), "Owner transfer failed");

        post.currentAmount += _amount;
        
        // Mint PawsForHope tokens to donors
        tokenPawsForHopeToken.mint(msg.sender, 100);
        
        emit DonationReceived(_postId, msg.sender, _amount);
    }

}