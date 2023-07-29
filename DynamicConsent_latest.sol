// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.12;

/**
* Team Name:
*
*   Team Member 1:
*       { Name: , Email:  }
*   Team Member 2:
*       { Name: , Email:  }
*   Team Member 3:
*       { Name: , Email:  }
*	...
*   Team Member n:
*       { Name: , Email:  }
*
* Declaration of cross-team collaboration:
*	We DO/DO NOT collaborate with (list teams).
*
* REMINDER
*	No change to function declarations is allowed.
*/

contract DynamicConsent {

    struct Consent {
        uint256 patientID;
        uint256 studyID;
        uint256 recordTime;
    }

    mapping(uint256 => mapping(uint256 => Consent)) public patientStudyConsents;
    mapping(uint256 => mapping(uint256 => mapping(string => bool))) public patientStudyCategories;
    mapping(uint256 => mapping(uint256 => mapping(string => bool))) public patientStudyElements;

    mapping(uint256 => mapping(uint256 => string[])) private patientStudyCategoriesArray;
    mapping(uint256 => mapping(uint256 => string[])) private patientStudyElementsArray;

    uint256[] public patientIDs;
    uint256[] public studyIDs;
    /**
    *   If a WILDCARD (-1) is received as function parameter, it means any value is accepted.
    *   For example, if _studyID = -1 in queryForPatient,
    *	then we expected all consents made by the patient within the appropriate time frame
    *	regardless of studyID.
    */
    int256 private constant WILDCARD = -1;

    // Consent[] public patientConsents;

    /**
    *   Function Description:
    *	Given a patientID, studyID, recordTime, consented category choices, and consented element choices,
    *   store a patient's consent record on-chain.
    *   Parameters:
    *       _patientID: uint256
    *       _studyID: uint256
    *       _recordTime: uint256
    *       _patientCategoryChoices: string[] calldata
    *       _patientElementChoices: string[] calldata
    */
    function storeRecord(uint256 _patientID, uint256 _studyID, uint256 _recordTime, string[] calldata _patientCategoryChoices, string[] calldata _patientElementChoices) public {
        Consent storage existingConsent = patientStudyConsents[_patientID][_studyID];
        if (_recordTime > existingConsent.recordTime) {
            existingConsent.patientID = _patientID;
            existingConsent.studyID = _studyID;
            existingConsent.recordTime = _recordTime;

            // Clear existing choices for the patient and study
            clearCategoriesAndElements(_patientID, _studyID);

            // Add patientID to patientIDs array if not already present
            bool patientIDFound = false;
            for (uint256 i = 0; i < patientIDs.length; i++) {
                if (patientIDs[i] == _patientID) {
                    patientIDFound = true;
                    break;
                }
            }
            if (!patientIDFound) {
                patientIDs.push(_patientID);
            }

            // Add studyID to studyIDs array if not already present
            bool studyIDFound = false;
            for (uint256 i = 0; i < studyIDs.length; i++) {
                if (studyIDs[i] == _studyID) {
                    studyIDFound = true;
                    break;
                }
            }
            if (!studyIDFound) {
                studyIDs.push(_studyID);
            }

            // Store the new category
            for (uint256 i = 0; i < _patientCategoryChoices.length; i++) {
                string memory categoryChoice = _patientCategoryChoices[i];
                patientStudyCategories[_patientID][_studyID][categoryChoice] = true;
                patientStudyCategoriesArray[_patientID][_studyID].push(categoryChoice);
            }

            // Store the new element
            for (uint256 i = 0; i < _patientElementChoices.length; i++) {
                string memory elementChoice = _patientElementChoices[i];
                patientStudyElements[_patientID][_studyID][elementChoice] = true;
                patientStudyElementsArray[_patientID][_studyID].push(elementChoice);
            }
        }
    }

    function clearCategoriesAndElements(uint256 _patientID, uint256 _studyID) private {
        string[] storage categories = patientStudyCategoriesArray[_patientID][_studyID];
        for (uint256 i = 0; i < categories.length; i++) {
            delete patientStudyCategories[_patientID][_studyID][categories[i]];
        }

        string[] storage elements = patientStudyElementsArray[_patientID][_studyID];
        for (uint256 i = 0; i < elements.length; i++) {
            delete patientStudyElements[_patientID][_studyID][elements[i]];
        }
    }

    /**
    *   Function Description:
    *	Given a studyID, endTime, requested category choices, and requested element choices,
    *	return a list of patientIDs that have consented to share with the study
    *	at least the requested categories and elements,
    *	and such consent was timestamped at or before _endTime.
    *	If there are several consents from the same patient for the same studyID
    *	made within the indicated timeframe
    *	then only the most recent one should be considered.
    *   Parameters:
    *      _studyID: uint256
    *      _endTime: int256
    *      _requestedCategoryChoices: string[] calldata
    *      _requestedElementChoices: string[] calldata
    *   Return:
    *       Array of consenting patientIDs: uint256[] memory
    */

    // uint256[] public matchingPatientIDs;

    function queryForResearcher(uint256 _studyID, int256 _endTime, string[] calldata _requestedCategoryChoices, string[] calldata _requestedElementChoices) public view returns(uint256[] memory) {
        uint256[] memory result;

        // Handle the wildcard value (-1) for _endTime
        uint256 endTime;
        if (_endTime == -1) {
            endTime = type(uint256).max;
        } else {
            require(_endTime >= 0, "Invalid _endTime");
            endTime = uint256(_endTime);
        }

        // Loop through the known patient IDs
        for (uint256 i = 0; i < patientIDs.length; i++) {
            uint256 patientID = patientIDs[i];

            // Loop through study IDs for the current patient
            for (uint256 j = 0; j < studyIDs.length; j++) {
                uint256 studyID = _studyID;

                Consent storage consent = patientStudyConsents[patientID][studyID]; // Check if consent has all the requested categories and elements
                if (consent.recordTime <= endTime) {
                    
                    bool hasAllCategoriesAndElements = true;

                   
                    for (uint256 k = 0; k < _requestedCategoryChoices.length; k++) {  // Check if consent has all the requested categories and elements
                        bool foundCategory = false;
                        for (uint256 l = 0; l < patientStudyCategoriesArray[patientID][studyID].length; l++) {
                            if (keccak256(bytes(patientStudyCategoriesArray[patientID][studyID][l])) == keccak256(bytes(_requestedCategoryChoices[k]))) {
                                foundCategory = true;
                                break;
                            }
                        }
                        if (!foundCategory) {
                            hasAllCategoriesAndElements = false;
                            break;
                        }
                    }

                    for (uint256 k = 0; k < _requestedElementChoices.length; k++) {
                        bool foundElement = false;
                        for (uint256 l = 0; l < patientStudyElementsArray[patientID][studyID].length; l++) {
                            if (keccak256(bytes(patientStudyElementsArray[patientID][studyID][l])) == keccak256(bytes(_requestedElementChoices[k]))) {
                                foundElement = true;
                                break;
                            }
                        }
                        if (!foundElement) {
                            hasAllCategoriesAndElements = false;
                            break;
                        }
                    }

                    
                    if (hasAllCategoriesAndElements) { // Add patientID to result ONLY if it has all requested categories and elements
                        if (result.length == 0) {
                            result = new uint256[](1);
                            result[0] = patientID;
                        } else {
                            uint256 newLength = result.length + 1;
                            uint256[] memory tempResult = new uint256[](newLength);
                            for (uint256 k = 0; k < result.length; k++) {
                                tempResult[k] = result[k];
                            }
                            tempResult[result.length] = patientID;
                            result = tempResult;
                        }
                    }
                }
            }
        }
        return result;
    }
        
    
    

    /**
    *   Function Description:
    *	Given a patientID, studyID, search start time, and search end time,
    *	return a concatenated string of the patient's consent history.
    *	The expected format of the returned string:
    *		Within the same consent: fields separated by comma.
    *		More than one consent returned: consents separated by newline character.
    *   For e.g:
    *		"studyID1,timestamp1,categorySharingChoices1,elementSharingChoices1\nstudyID2,timestamp2,categorySharingChoices2,elementSharingChoices2\n"
    *   Parameters:
    *       _patientID: uint256
    *       _studyID: int256
    *       _startTime: int256
    *       _endTime: int256
    *   Return:
    *       String of concatenated consent history: string memory
    */

    function queryForPatient(uint256 _patientID, int256 _studyID, int256 _startTime, int256 _endTime) public view returns(string memory) {
        string[] memory consentRecords;
        uint256 recordCount = 0;

        // Loop through patient IDs
        for (uint256 i = 0; i < patientIDs.length; i++) {
            uint256 patientID = patientIDs[i];

            
            if (patientID == _patientID) { // Check if the current patientID matches the requested _patientID

                
                for (uint256 j = 0; j < studyIDs.length; j++) { // Loop through the study IDs
                    uint256 studyID = studyIDs[j];

                    
                    if (_studyID == WILDCARD || studyID == uint256(_studyID)) { // Check if studyID matches the requested _studyID

                        Consent storage consent = patientStudyConsents[patientID][studyID];
                        uint256 recordTime = consent.recordTime;

                        
                        if (recordTime >= uint256(_startTime) && recordTime <= uint256(_endTime)) { // Check if consent is within the time

                            
                            string memory categoryChoices = categoryChoicesToString(patientID, studyID);
                            string memory elementChoices = elementChoicesToString(patientID, studyID); // Convert category and element choices to comma-separated strings (problem)

                            
                            string memory consentRecord = string(abi.encodePacked(studyID, ",", recordTime, ",", categoryChoices, ",", elementChoices));
                            consentRecords = appendToStringArray(consentRecords, consentRecord); // Concatenate the consent details to the consent record string
                            recordCount++;
                        }
                    }
                }
            }
        }

        
        string[] memory finalConsentRecords = new string[](recordCount); // Copyconsent records to a new array with the correct size
        for (uint256 i = 0; i < recordCount; i++) {
            finalConsentRecords[i] = consentRecords[i];
        }

        string memory concatenatedRecords = concatenateStrings(consentRecords);

        return concatenatedRecords;
    }

    // Helper: converts category choices to a comma-separated string (problem)
    function categoryChoicesToString(uint256 _patientID, uint256 _studyID) private view returns (string memory) {
        string[] storage categoryChoicesArray = patientStudyCategoriesArray[_patientID][_studyID];
        string memory categoryChoicesStr = "[";

        for (uint256 i = 0; i < categoryChoicesArray.length; i++) {
            if (i > 0) {
                categoryChoicesStr = string(abi.encodePacked(categoryChoicesStr, ","));
            }
            categoryChoicesStr = string(abi.encodePacked(categoryChoicesStr, categoryChoicesArray[i]));
        }

        categoryChoicesStr = string(abi.encodePacked(categoryChoicesStr, "]"));
        return categoryChoicesStr;
    }

    // Helper: converts element choices to a comma-separated string (problem)
    function elementChoicesToString(uint256 _patientID, uint256 _studyID) private view returns (string memory) {
        string[] storage elementChoicesArray = patientStudyElementsArray[_patientID][_studyID];
        string memory elementChoicesStr = "[";

        for (uint256 i = 0; i < elementChoicesArray.length; i++) {
            if (i > 0) {
                elementChoicesStr = string(abi.encodePacked(elementChoicesStr, ","));
            }
            elementChoicesStr = string(abi.encodePacked(elementChoicesStr, elementChoicesArray[i]));
        }

        elementChoicesStr = string(abi.encodePacked(elementChoicesStr, "]"));
        return elementChoicesStr;
    }

    // Helper: appends a string to a string array
    function appendToStringArray(string[] memory array, string memory element) private pure returns (string[] memory) {
        string[] memory newArray = new string[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = element;
        return newArray;
    }

    // Helper: just concats the strings in the array
    function concatenateStrings(string[] memory _strings) private pure returns (string memory) {
        uint256 totalLength = 0;
        for (uint256 i = 0; i < _strings.length; i++) {
            totalLength += bytes(_strings[i]).length;
        }

        string memory result = new string(totalLength);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < _strings.length; i++) {
            string memory currentString = _strings[i];
            uint256 currentLength = bytes(currentString).length;
            for (uint256 j = 0; j < currentLength; j++) {
                bytes(result)[currentIndex] = bytes(currentString)[j];
                currentIndex++;
            }
        }

        return result;
    }
}
