/**
 * @description To send email when a post is being created.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public without sharing class BI_PSPB_DashboardNotification {
	/**
	 * @description This method is used for general insite notification checking for sending symptomtracker, challenges,
	 * and community SMS, Email, and Insite Notification.
	 * @param cpeId The list of Task records being inserted.
     * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Task> getEvents() {
		List<Task> taskList = new List<Task>();
        List<Task> listOfTasks = new List<Task>(); 
        List<Task> matchingTasks = new List<Task>();
		try {
            //List<CareProgramEnrollee> enrolleeRecords = BI_PSP_CurrentUser.getEnrolleeRecords();
            Id cpeId = '0Ww9V0000000PJNSA2';
                //enrolleeRecords[0].Id;
              String fields = 'Id, Subject, CreatedDate, Status, BI_PSP_Category__c, BI_PSP_Notification_Type__c,WhatId';
        			String conditions = 'WhatId = \'' + cpeId + '\' AND (BI_PSP_Notification_Type__c = \'' +
                            BI_PSPB_NotificatinRmdConstantsCtrl.actionTypeAction +
                    		'\' AND Status = \''+BI_PSPB_NotificatinRmdConstantsCtrl.actionTypeNotificatonTypeAction+'\')';
                	listOfTasks = BI_PSP_CommonQueryUtility.executeQuery(
                    'Task',
                    fields,
                    conditions,
                    false
                );
            system.debug('sdfghj'+listOfTasks);
            List<BI_PSPB_Treatment_Reminder__c> treatementRemiderRecords = BI_PSPB_MessageCenterCtrl.getTreatmentReminders(cpeId);
            system.debug('treate'+treatementRemiderRecords);
            Set<Id> careProgramEnrolleeIds = new Set<Id>();
            for (BI_PSPB_Treatment_Reminder__c reminder : treatementRemiderRecords) {
                careProgramEnrolleeIds.add(reminder.BI_PSPB_Care_Program_Enrollee__r.Id);
            }
            
            // Query tasks related to the collected care program enrollees
            if (!careProgramEnrolleeIds.isEmpty()) {
                String fields1 = 'SELECT Id, Subject, CreatedDate, Status, BI_PSP_Category__c, BI_PSP_Notification_Type__c,WhatId ';
                  String conditions1 = 'WhatId IN: \''+ careProgramEnrolleeIds;
                   List<Task> totalListOfTasks = BI_PSP_CommonQueryUtility.executeQuery(
                            'Task',
                            fields,
                            conditions,
                            false
                        );
                // Add the related tasks to the listOfTasks
                listOfTasks.addAll(totalListOfTasks);
            }
			//Set<Id> relatedIds = new Set<Id>();
			//relatedIds.add(cpeId);
			/**if (!String.isBlank(cpeId)) {
				List<BI_PSPB_Treatment_Reminder__c> treatmentList = BI_PSPB_TreatmentReminderRecords.getTreatmentReminders(
					relatedIds
				);
				if (treatmentList != null) {
					relatedIds.add(cpeId);
					for (
						BI_PSPB_Treatment_Reminder__c treatment : treatmentList
					) {
						relatedIds.add(treatment.Id);
					}
					String fields = 'Id, Subject, CreatedDate, Status, BI_PSP_Category__c, BI_PSP_Notification_Type__c';
        			String conditions = 'WhatId = \'' + cpeId + '\' AND (BI_PSP_Notification_Type__c = \'' +
                            BI_PSPB_NotificatinRmdConstantsCtrl.actionTypeAction +
                    		'\' AND (Status = \''+BI_PSPB_NotificatinRmdConstantsCtrl.actionTypeNotificatonTypeAction+'\')';
                	listOfTasks = BI_PSP_CommonQueryUtility.executeQuery(
                    'Task',
                    fields,
                    conditions,
                    false
                );
					taskList.addAll(listOfTasks);
				} else {
					BI_PSP_LogMessagesUtility.logError(
						BI_PSPB_NotificatinRmdConstantsCtrl.errorMsgRecordNotFound,
						BI_PSPB_DashboardNotification.class.toString(),
						false,
						BI_PSPB_NotificatinRmdConstantsCtrl.severityError
					);
				}
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificatinRmdConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_DashboardNotification.class.toString(),
					false,
					BI_PSPB_NotificatinRmdConstantsCtrl.severityError
				);
			}*/
		} catch (Exception ex) {
			BI_PSPB_LogUtilities.exceptionLogMessage(
				BI_PSPB_CommunityConstantCtrl.errorWhileFetchingPost,
				BI_PSPB_DashboardNotification.class.toString(),
				ex
			);
		}
		return listOfTasks;
	}
}