# Smart Contract Documentation: PawsForHope token and Related Contracts

## Overview
This project implements a decentralized platform for pet-related use cases, leveraging blockchain technology. The system incorporates a token (USDCPet), donation management, a pet search mechanism, and user registration.

---

## Key Components and Functionality

### 1. **USDCPet Token Contract**
- **Purpose:** Provides a fungible token used within the platform.
- **Core Functions:**
  - `mint(address to, uint256 amount)`: Mints new tokens for a specified address.
  - `transfer(address to, uint256 amount)`: Transfers tokens between users.
- **Use Case:** Serves as the primary token for transactions, including rewards and donations.

---

### 2. **Donation Management Contract (`Donate`)**
- **Purpose:** Manages donation posts for pet-related causes.
- **Core Functions:**
  - `createDonationPost(uint256 targetAmount, string description)`: Allows registered entities to create donation campaigns.
  - `donateToPost(uint256 postId, uint256 amount)`: Allows users to donate USDC tokens to campaigns.
  - `closePost(uint256 postId)`: Closes donation campaigns and allocates the collected funds.
- **Reward Mechanism:** Donors receive "PawsForHope" tokens as a reward for contributions.

---

### 3. **Pet Search Contract (`FindPet`)**
- **Purpose:** Enables users to create and manage posts for finding lost pets.
- **Core Functions:**
  - `createPost(uint256 amount)`: Posts a reward for finding a lost pet.
  - `closePost(uint256 postId, address beneficiary)`: Closes the search and rewards the finder.
- **Reward Mechanism:** The finder is rewarded with USDC tokens and additional PawsForHope tokens.

---

### 4. **Redemption Contract (`Redeem`)**
- **Purpose:** Allows users to redeem tokens for goods or services.
- **Core Functions:**
  - `createPost(uint256 stock, uint256 price)`: Creates redeemable offers.
  - `redeemItem(uint256 postId)`: Facilitates token redemption for items.
- **Stock Management:** Tracks item availability and deducts redeemed items.

---

### 5. **User Registration Contract (`RegisterUsers`)**
- **Purpose:** Handles the registration of users and entities.
- **Core Functions:**
  - `registerUser(address user)`: Registers individual users.
  - `registerEntity(address entity)`: Registers organizations or entities.
- **Agent Management:** Restricts certain functions to authorized agents.

---

### 6. **PawsForHopeToken Contract**
- **Purpose:** Implements an ERC20 token with additional features for the platform.
- **Core Functions:**
  - **Token Minting and Burning:** Agents can mint or burn tokens.
  - **Account Freezing:** Freeze specific accounts or globally restrict transfers.
  - **Forced Transfers:** Agents can reallocate tokens if necessary.
- **Use Case:** Rewards and utility token across the platform.

---

## Entity Relationship Diagram

Below is the **Entity Relationship Diagram** that illustrates the relationships between the contracts:

```plaintext
+-------------------+      +---------------------+
|   RegisterUsers   |<---->|      Donate         |
+-------------------+      +---------------------+
           ^                       ^
           |                       |
           v                       v
+-------------------+      +---------------------+
|     USDCPet       |<---->|     FindPet         |
+-------------------+      +---------------------+
           ^                       ^
           |                       |
           v                       v
+-------------------+      +---------------------+
|  PawsForHopeToken |      |      Redeem         |
+-------------------+      +---------------------+



# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/deploy.js || npx hardhat run ./ignition/modules/deploy.js --network lisk-sepolia
npx hardhat verify --network lisk-sepolia <deployed address>

```
