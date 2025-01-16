// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RegisterUsers.sol";
import "./PawsForHopeToken.sol";


contract FindPet is Ownable {
    
    // Counter for post IDs
    uint256 private postIdCounter = 0;

    // Sepolia Mainnet USDC contract address
    //address constant public USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    // USDCPaws contract address
    // address constant public USDC = 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47;

    // Struct to store post a lost pet  information
    struct Post {
        address creator;
        uint256 amount;
        string imgUrl;
        string petName;           // Name of the lost pet
        string description;       // Description of the pet (e.g., color, breed)
        string location;          // Location where the pet was last seen
        string contactInfo;       // Contact information for the creator
        uint256 timestamp;
        bool isOpen;
    }

    // Mapping from post ID to Post struct
    mapping(uint256 => Post) public posts;
    // Mapping to track authorized agents
    mapping(address => bool) private agents;

    // Events
    event PostCreated(uint256 indexed postId, address indexed creator, uint256 amount);
    event PostClosed(uint256 indexed postId, address indexed beneficiary, uint256 amount);
    
    // Reference to other contracts
    RegisterUsers public registerUsers;
    PawsForHopeToken public tokenPawsForHopeToken;
    IERC20 public usdc;

    // Events
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event DonationReceived(address indexed donor, uint256 amount);
    event DonationProcessed(address indexed donor, uint256 amount, uint256 tokens);

    /**
     * @dev Modifier to restrict functions to authorized agents only
     */
    modifier onlyAgent() {
        require(agents[msg.sender], "Only agents can perform this action");
        _;
    }

    
     // @dev Constructor initializes the contract with references to other contracts
     // @param _registerUsers Address of the RegisterUsers contract
     // @param tokenPawsForHopeToken Address of the tokenPawsForHopeToken contract
     constructor(address _registerUsers, address _tokenPawsForHopeToken, address _USDCpaws) Ownable(msg.sender) {
        require(_registerUsers != address(0), "Invalid RegisterUsers address");
        require(_tokenPawsForHopeToken != address(0), "Invalid tokenPawsForHopeToken address");

        registerUsers = RegisterUsers(_registerUsers);
        tokenPawsForHopeToken = PawsForHopeToken(_tokenPawsForHopeToken);
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
     * @dev Creates a new post with a reward amount
     * @param _amount Amount of USDC for the reward
     */
    function createPost(uint256 _amount, string memory _imgUrl, string memory _petName, string memory _description, string memory _location, string memory _contactInfo) external {
        // check if sender is registered user or entity
        require( registerUsers.isRegisteredUser(msg.sender) || registerUsers.isRegisteredEntity(msg.sender), "Must be registered user or entity");
        require(_amount > 0, "Amount must be greater than 0");

        // Transfer USDC from sender to contract
        require(usdc.transferFrom(msg.sender, address(this), _amount), "USDC transfer failed");

        // Create new post
        uint256 postId = postIdCounter++;
        posts[postId] = Post({ creator: msg.sender, amount: _amount, imgUrl: _imgUrl, petName: _petName, description: _description, location: _location, contactInfo: _contactInfo, timestamp: block.timestamp, isOpen: true});

        emit PostCreated(postId, msg.sender, _amount);
    }

    /**
     * @dev Closes a post and distributes the reward
     * @param _postId ID of the post to close
     * @param _beneficiary Address to receive the reward
     */
    function closePost(uint256 _postId, address _beneficiary) external {
        require(_postId < postIdCounter, "Post does not exist");
        Post storage post = posts[_postId];
        require(post.isOpen, "Post is already closed");
        require(msg.sender == post.creator || agents[msg.sender], "Only creator or agent can close post");
        require(_beneficiary != address(0), "Invalid beneficiary address");

        post.isOpen = false;

        // Calculate amounts
        uint256 beneficiaryAmount = (post.amount * 97) / 100;
        uint256 ownerAmount = post.amount - beneficiaryAmount;

        // Transfer rewards in USDC from this contract
        require(usdc.transferFrom(address(this), _beneficiary, beneficiaryAmount), "Beneficiary USDC transfer failed");
        require(usdc.transferFrom(address(this), owner(), ownerAmount), "Owner USDC transfer failed");

        // Mint HelPet tokens to beneficiary
        tokenPawsForHopeToken.mint(_beneficiary, 50);

        emit PostClosed(_postId, _beneficiary, post.amount);
    }

    /**
     * @dev Returns post information
     * @param _postId ID of the post
     */
    function getPost(uint256 _postId) external view returns (address creator, uint256 amount, bool isOpen) {
        require(_postId < postIdCounter, "Post does not exist");
        Post storage post = posts[_postId];
        return (post.creator, post.amount, post.isOpen);
    }
    
    /**
    * @dev Returns all posts.
    * @return allPosts An array of Post structs containing all the posts.
    */
    function getAllPosts() external view returns (Post[] memory) {
        Post[] memory allPosts = new Post[](postIdCounter);
        
        for (uint256 i = 0; i < postIdCounter; i++) {
            allPosts[i] = posts[i];
        }
        
        return allPosts;
    }

}