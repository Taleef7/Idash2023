const { ethers } = require("hardhat");

async function testQueryForPatient() {
  const DynamicConsent = await ethers.getContractFactory("DynamicConsent");
  const dynamicConsent = await DynamicConsent.attach("0x5fbdb2315678afecb367f032d93f642f64180aa3"); // Replace with the actual contract address
  
  const patientID = 3448; // Replace with the desired patient ID
  const studyID = 3; // Replace with the desired study ID or use -1 for wildcard
  const startTime = 1631024390; // Replace with the desired start time
  const endTime = Math.floor(Date.now() / 1000); // Current Unix timestamp
  
  const result = await dynamicConsent.queryForPatient(patientID, studyID, startTime, endTime);
  console.log("Consent History:");
  console.log(result);
}

testQueryForPatient()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
