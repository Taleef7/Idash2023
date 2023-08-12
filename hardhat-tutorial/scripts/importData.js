const fs = require('fs');
const ethers = require('ethers');
const contractABI = require('./artifacts/contracts/DynamicConsent.sol/DynamicConsent.json').abi;

async function importData() {
  const provider = new ethers.providers.JsonRpcProvider(); // Connect to your local network
  const signer = provider.getSigner();

  const contractAddress = 'CONTRACT_ADDRESS'; // Replace with actual contract address
  const contract = new ethers.Contract(contractAddress, contractABI, signer);

  const consentData = JSON.parse(fs.readFileSync('../consents/1/training_data.json', 'utf8'));// Use the consentData in your script


  for (const record of consentData) {
    await contract.storeRecord(
      record.patientID,
      record.studyID,
      record.timestamp,
      record.categorySharingChoices,
      record.elementSharingChoices
    );
  }
}

importData();
