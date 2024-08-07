public with sharing class BI_PSP_SymptomTrackerGraphCtrl {
    @AuraEnabled(cacheable=true)
    public static List<SymptomTracker> getSymptomTrackerDetails(
        String erolleId,
        Date firstDate,
        Date lastDate
    ) {
      
        
        if (!isValidInput(erolleId, firstDate, lastDate)) {
     
            return null;
        }
        	
        try {
            List<BI_PSP_Symptom_Tracker__c> recordSymptom = fetchSymptomRecords(erolleId, firstDate, lastDate);
        
            
            if (recordSymptom.isEmpty()) {
                return null;
            }

            List<SymptomTracker> symptomTrackers = processSymptomRecords(recordSymptom);
  
            
            return symptomTrackers.isEmpty() ? null : symptomTrackers;
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSP_SymptomTrackerConstantCtrl.symptomErrorMsg,
                BI_PSP_SymptomTrackerGraphCtrl.class.toString(),
                true,
                BI_PSP_SymptomTrackerConstantCtrl.LOG_SEVERITY_ERROR
            );
           
            return null;
        }
    }

    private static Boolean isValidInput(String erolleId, Date firstDate, Date lastDate) {
        Boolean isValid = !String.isBlank(erolleId) && firstDate != null && lastDate != null;
       
        return isValid;
    }

    private static List<BI_PSP_Symptom_Tracker__c> fetchSymptomRecords(String erolleId, Date firstDate, Date lastDate) {
        String firstDateEntryDateValue = String.valueOf(firstDate);
        	String lastDateEntryDateValue = String.valueOf(lastDate);

        String activeStatusValue = String.valueOf(BI_PSP_QuestionnaireConstant.symptomStatusInactive);
        String query = 
            'SELECT Id, LastModifiedDate, BI_PSP_Care_Program_Enrollee__c, BI_PSP_EditEntrydates__c, CreatedDate ' +
            'FROM BI_PSP_Symptom_Tracker__c ' +
            'WHERE BI_PSP_Care_Program_Enrollee__c = \'' + erolleId + '\' ' +
            'AND BI_PSP_EditEntrydates__c >  = ' +
			firstDateEntryDateValue +
			' ' +
            'AND BI_PSP_EditEntrydates__c < = ' +
			lastDateEntryDateValue +
			' ' +
            'AND BI_PSP_Symptom_Staus__c != \'' + activeStatusValue + '\' ' +
            'ORDER BY BI_PSP_EditEntrydates__c ASC';
    
       
       
            List<BI_PSP_Symptom_Tracker__c> symptomRecords = BI_PSP_CommonQueryUtility.executeComplexQuery(query, false);
        return symptomRecords;
    }

    private static List<SymptomTracker> processSymptomRecords(List<BI_PSP_Symptom_Tracker__c> recordSymptom) {
        List<SymptomTracker> symptomTrackers = new List<SymptomTracker>();
        Set<Id> symptomIds = extractSymptomIds(recordSymptom);
      
        
        if (!symptomIds.isEmpty()) {
            List<AllergyIntolerance> allergyTrack = fetchAllergyIntolerance(symptomIds);
           

            if (!allergyTrack.isEmpty()) {
                for (AllergyIntolerance allergy : allergyTrack) {
                    symptomTrackers.add(createSymptomTracker(allergy));
                }
            }
        }
        return symptomTrackers;
    }

    private static Set<Id> extractSymptomIds(List<BI_PSP_Symptom_Tracker__c> recordSymptom) {
        Set<Id> symptomIds = new Set<Id>();
        for (BI_PSP_Symptom_Tracker__c symp : recordSymptom) {
            if (symp.Id != null) { // Ensure Id is not null
                symptomIds.add(symp.Id);
            }
        }
      
        return symptomIds;
    }

    private static List<AllergyIntolerance> fetchAllergyIntolerance(Set<Id> symptomIds) {
            String symptomIdsString = '\'' + String.join(symptomIds, '\',\'') + '\'';
        String query = 
            'SELECT Id, BI_PSP_Graph_Symptom_Name__c, BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c, ' +
            'BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name ' +
            'FROM AllergyIntolerance ' +
            'WHERE BI_PSP_Symptom_Name__r.Id IN (' + symptomIdsString + ')' +
            'AND BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name != NULL ' +
            'AND BI_PSP_Symptoms__c != NULL ' +
            'ORDER BY BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c';
    
       

         List<AllergyIntolerance> allergyIntoleranceRecords = BI_PSP_CommonQueryUtility.executeComplexQuery(query, false);
        return allergyIntoleranceRecords;
    }
    
    private static SymptomTracker createSymptomTracker(AllergyIntolerance allergy) {
        SymptomTracker symp = new SymptomTracker();
        symp.symptom = allergy.BI_PSP_Graph_Symptom_Name__c;
        	symp.symptom = allergy.BI_PSP_Symptom_Name__c;
        symp.dates = allergy.BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c;
        symp.name = allergy.BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name;
       
        return symp;
    }

    /*
     * @description Inner class representing a symptom tracker record.
     */
    public class SymptomTracker {
        @AuraEnabled
        public Date dates; // Date of the symptom tracker record.

        @AuraEnabled
        public String name; // Name associated with the symptom.

        @AuraEnabled
        public String symptom; // Description of the symptom.
    }
}