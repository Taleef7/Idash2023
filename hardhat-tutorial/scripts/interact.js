const { ethers } = require("hardhat");

async function interact() {
  const DynamicConsent = await ethers.getContractFactory("DynamicConsent");
  const dynamicConsent = await DynamicConsent.attach("0x5fbdb2315678afecb367f032d93f642f64180aa3"); // Replace with the actual contract address

  const studyID = 3;
  const endTime = 1661031638; // Replace with the desired end time
  const requestedCategoryChoices = ["03_Living Environment and Lifestyle"];
  const requestedElementChoices = ["01_02_Mental health disease or condition"];

  const result = await dynamicConsent.queryForResearcher(studyID, endTime, requestedCategoryChoices, requestedElementChoices);
  console.log("Result:", result);
}

interact()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
