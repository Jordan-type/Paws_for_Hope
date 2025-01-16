import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  // Fetch named accounts
  const { deployer } = await getNamedAccounts();

  console.log("Deploying RegisterUsers...");
  const registerUsers = await deploy("RegisterUsers", {from: deployer, log: true,});
  console.log("RegisterUsers deployed to:", registerUsers.address);

  console.log("Deploying PawsForHopeToken..."); // args: ["Paws For Hope Token", "PAWS"]
  const pawsForHopeToken = await deploy("PawsForHopeToken", {from: deployer, log: true,});
  console.log("PawsForHopeToken deployed to:", pawsForHopeToken.address);

  console.log("Deploying USDCPaws...");
  const usdcPaws = await deploy("USDCPaws", {from: deployer, log: true,});
  console.log("USDCPaws deployed to:", usdcPaws.address);

  console.log("Deploying Donate...");
  const donate = await deploy("Donate", {from: deployer, args: [pawsForHopeToken.address, usdcPaws.address], log: true,});
  console.log("Donate deployed to:", donate.address);

  console.log("Deploying FindPet...");
  const findPet = await deploy("FindPet", {from: deployer, args: [registerUsers.address, pawsForHopeToken.address, usdcPaws.address], log: true,});
  console.log("FindPet deployed to:", findPet.address);

  console.log("Deploying Redeem...");
  const redeem = await deploy("Redeem", {from: deployer, args: [pawsForHopeToken.address], log: true,});
  console.log("Redeem deployed to:", redeem.address);

  console.log("\nDeployment completed successfully!");
};

export default func;
func.tags = ["all"];
