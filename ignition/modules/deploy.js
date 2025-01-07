// https://hardhat.org/hardhat-runner/docs/advanced/migrating-from-hardhat-waffle (Migrating away from hardhat-waffle)
const hre = require("hardhat");

async function main() {
  
  // compile the contract to get the latest bytecode and ABI - Optional
  await hre.run('compile');

  // step one get the DadaNFT 
  const dadaNFT = await hre.ethers.getContractFactory("DadaNFT");
  // step two deploy the DadaNFT 
  const deployedNFT = await dadaNFT.deploy();
  await deployedNFT.waitForDeployment()   
  console.log("dadaNFT deployed to address this:", await deployedNFT.getAddress()) // .address); depreciated
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exit(1);
});

