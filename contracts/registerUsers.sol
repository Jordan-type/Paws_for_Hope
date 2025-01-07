// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Contract deployed on Base Sepolia
 * @notice You can view the deployed contract at:
 * https://sepolia.basescan.org/address/0x3D832fF79eab5783D933d348CB5C6e54bf41c600#code
*/

contract RegisterUsers is Ownable {
    // Mapping to track authorized agents
    mapping(address => bool) private agents;
    
    // Mappings to track registered users and entities
    mapping(address => bool) private registeredUsers;
    mapping(address => bool) private registeredEntities;

    // Events
    event AgentAdded(address indexed agent);
    event AgentRemoved(address indexed agent);
    event UserRegistered(address indexed user, bool isEntity);
    event UserRemoved(address indexed user, bool isEntity);

    /**
     * @dev Constructor initializes the contract with the deployer as owner
     */
    constructor() Ownable(msg.sender) {}

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