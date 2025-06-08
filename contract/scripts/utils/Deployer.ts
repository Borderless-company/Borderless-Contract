import hre from "hardhat";

export const getDeployerAddress = async () => {
  const deployerWallet = new hre.ethers.Wallet(
    process.env.DEPLOYER_PRIVATE_KEY!,
    hre.ethers.provider
  );
  const deployer =
    (await deployerWallet.getAddress()) ||
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  console.log(`deployer: ${deployer}`);
  return { deployer, deployerWallet };
};

export const getAdminAddresses = async () => {
  const adminAddresses = process.env.ADMIN_ADDRESSES?.split(",") || [];
  if (adminAddresses.length === 0) {
    console.log("No admin addresses found in .env file");
  } else {
    console.log(`Admin addresses: ${adminAddresses.join(", ")}`);
  }
  return adminAddresses;
};

export const getFounderAddresses = async () => {
  const founderAddresses = process.env.FOUNDER_ADDRESSES?.split(",") || [];
  if (founderAddresses.length === 0) {
    console.log("No founder addresses found in .env file");
  } else {
    console.log(`Founder addresses: ${founderAddresses.join(", ")}`);
  }
  return founderAddresses;
};

export const getMinterAddresses = async () => {
  const minterAddresses = process.env.MINTER_ADDRESSES?.split(",") || [];
  if (minterAddresses.length === 0) {
    console.log("No minter addresses found in .env file");
  } else {
    console.log(`Minter addresses: ${minterAddresses.join(", ")}`);
  }
  return minterAddresses;
};