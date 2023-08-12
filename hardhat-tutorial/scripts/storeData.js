const fs = require("fs");
const { ethers } = require("hardhat");

async function storeData() {
  const DynamicConsent = await ethers.getContractFactory("DynamicConsent");
  const dynamicConsent = await DynamicConsent.attach("0x5fbdb2315678afecb367f032d93f642f64180aa3"); // Replace with the actual contract address

  const jsonData = fs.readFileSync("../consents/1/training_data.json", "utf8");
  const consentRecords = JSON.parse(jsonData);

  var count = 0;

  for (const record of consentRecords) {
    await dynamicConsent.storeConsentFromJSON(
      record.patientID,
      record.studyID,
      record.timestamp,
      record.categorySharingChoices,
      record.elementSharingChoices
    );
    count = count + 1;
    console.log("Stored consent record number: ", count);
  }

  console.log("Consent records stored from JSON.");
}

storeData()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
