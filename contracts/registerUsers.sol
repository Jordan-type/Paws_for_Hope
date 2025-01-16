// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RegisterUsers is Ownable {

        // Counter for community IDs
    uint256 private communityIdCounter = 0;

    // Struct to store community information
    struct Community {
        string name;
        string description;
        address creator;
        uint256 createdAt;
        address[] members;
    }


    mapping(uint256 => Community) private communities;     // Mapping to track communities
    mapping(address => bool) private agents;              // Mapping to track authorized agents

    // Mappings to track registered users and entities
    mapping(address => bool) private registeredUsers;
    mapping(address => bool) private registeredEntities;

    // Events
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event UserRegistered(address indexed user, bool isEntity);
    event UserRemoved(address indexed user, bool isEntity);
    event CommunityCreated(uint256 indexed communityId, string name, address creator);
    event MemberAdded(uint256 indexed communityId, address member);

     /**
     * @dev Modifier to restrict functions to authorized agents only
     */
    modifier onlyAgent() {
        require(agents[msg.sender], "Only agents can perform this action");
        _;
    }

    /**
     * @dev Constructor initializes the contract with the deployer as owner
     */
    constructor() Ownable(msg.sender) {}


    /**
     * @dev Adds a new agent
     * @param _agent Address of the agent to add - pet vets
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
     * @dev Registers a normal user
     * @param _user Address of the user to register
     */
    function registerUser(address _user) external onlyAgent {
        require(_user != address(0), "Cannot register zero address");
        require(!registeredUsers[_user], "User already registered");
        require(!registeredEntities[_user], "Address already registered as entity");
        
        registeredUsers[_user] = true;
        emit UserRegistered(_user, false);
    }

    /**
     * @dev Registers an entity
     * @param _entity Address of the entity to register
     */
    function registerEntity(address _entity) external onlyAgent {
        require(_entity != address(0), "Cannot register zero address");
        require(!registeredEntities[_entity], "Entity already registered");
        require(!registeredUsers[_entity], "Address already registered as user");
        
        registeredEntities[_entity] = true;
        emit UserRegistered(_entity, true);
    }

    /**
     * @dev Creates a new community
     * @param _name Name of the community
     * @param _description Description of the community
     */
    function createCommunity(string calldata _name, string calldata _description) external {
        require(bytes(_name).length > 0, "Community name cannot be empty");
        require(bytes(_description).length > 0, "Community description cannot be empty");
        require(registeredUsers[msg.sender] || registeredEntities[msg.sender], "Only registered users or entities can create communities");

        uint256 communityId = communityIdCounter++;
        Community storage newCommunity = communities[communityId];
        newCommunity.name = _name;
        newCommunity.description = _description;
        newCommunity.creator = msg.sender;
        newCommunity.createdAt = block.timestamp;

        emit CommunityCreated(communityId, _name, msg.sender);
    }
    
    
    /**
     * @dev Adds a member to a community
     * @param _communityId ID of the community
     * @param _member Address of the member to add
     */
    function addMember(uint256 _communityId, address _member) external {
        require(_communityId < communityIdCounter, "Community does not exist");
        require(msg.sender == communities[_communityId].creator, "Only the creator can add members");
        require(registeredUsers[_member], "Member must be a registered user");

        communities[_communityId].members.push(_member);
        emit MemberAdded(_communityId, _member);
    }

    /**
     * @dev Retrieves community information
     * @param _communityId ID of the community
     */
    function getCommunity(uint256 _communityId) external view returns (Community memory) {
        require(_communityId < communityIdCounter, "Community does not exist");
        return communities[_communityId];
    }


    /**
     * @dev Removes a normal user
     * @param _user Address of the user to remove
     */
    function removeUser(address _user) external onlyAgent {
        require(_user != address(0), "Cannot remove zero address");
        require(registeredUsers[_user], "User not registered");
        
        registeredUsers[_user] = false;
        emit UserRemoved(_user, false);
    }

    /**
     * @dev Returns a list of all agents
     */
    function getAgents() external view returns (address[] memory) {
        uint256 agentCount = 0;
        for (uint256 i = 0; i < block.number; i++) {
            if (agents[address(uint160(i))]) {
                agentCount++;
            }
        }

        address[] memory agentList = new address[](agentCount);
        uint256 index = 0;
        for (uint256 i = 0; i < block.number; i++) {
            if (agents[address(uint160(i))]) {
                agentList[index++] = address(uint160(i));
            }
        }
        return agentList;
    }

    /**
     * @dev Removes an entity
     * @param _entity Address of the entity to remove
     */
    function removeEntity(address _entity) external onlyAgent {
        require(_entity != address(0), "Cannot remove zero address");
        require(registeredEntities[_entity], "Entity not registered");
        
        registeredEntities[_entity] = false;
        emit UserRemoved(_entity, true);
    }

    /**
     * @dev Checks if an address is a registered user
     * @param _address Address to check
     */
    function isRegisteredUser(address _address) external view returns (bool) {
        return registeredUsers[_address];
    }

    /**
     * @dev Checks if an address is a registered entity
     * @param _address Address to check
     */
    function isRegisteredEntity(address _address) external view returns (bool) {
        return registeredEntities[_address];
    }

    /**
     * @dev Checks if an address is an agent
     * @param _address Address to check
     */
    function isAgent(address _address) external view returns (bool) {
        return agents[_address];
    }

}