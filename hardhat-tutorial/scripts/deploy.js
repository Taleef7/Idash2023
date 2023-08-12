const { ethers } = require("hardhat");

async function main() {
  const DynamicConsent = await ethers.getContractFactory("DynamicConsent");
  const dynamicConsent = await DynamicConsent.deploy();

  await dynamicConsent.deployed();

  console.log("DynamicConsent deployed to:", dynamicConsent.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
