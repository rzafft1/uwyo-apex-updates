public class OneClickPdfStatusHandler {

    /**
     * Updates the One_Click_PDF_status__c of EnrollmentrxRx__Enrollment_Opportunity__c records 
     * to 'Ready for 1-Click PDF' (if at least one upload exists in the apps recs and docs) or 
     * to null (if no uploads exist in the apps recs and docs). 
     * 
     * @param appIds : Set of Application Ids to update
     * @param deletedIds : Set of Attachment or ContentDocument ids that were deleted (we exclude these from the count)
    */
    public static void updateOneClickPdfStatus(Set<Id> appIds, Set<Id> deletedIds) {

        // Get all of docs and recs related to the application(s)
        Map<Id, Id> docOrRecToApplication = new Map<Id, Id>();
        for(Recommendation__c rec : [SELECT Id, Application__c FROM Recommendation__c WHERE Application__c IN :appIds]){
            if(rec.Application__c != null) {
                docOrRecToApplication.put(rec.Id, rec.Application__c);
            }
        }
        for(EnrollmentrxRx__Admissions_Document__c doc : [SELECT Id, EnrollmentrxRx__Application__c FROM EnrollmentrxRx__Admissions_Document__c WHERE EnrollmentrxRx__Application__c IN :appIds]){
            if(doc.EnrollmentrxRx__Application__c != null) {
                docOrRecToApplication.put(doc.Id, doc.EnrollmentrxRx__Application__c);
            }
        }

        // Count the number of uploads on the application(s) excluding the deleted file/attachment
        Map<Id, List<Id>> appUploads = new Map<Id, List<Id>>();
        for (Id appId : appIds){
            appUploads.put(appId, new List<Id>());
        }

        // Count attachments (exclude deleted)
        for (Attachment a : [SELECT Id, ParentId FROM Attachment WHERE ParentId IN :docOrRecToApplication.keySet()]){
            if (deletedIds.contains(a.Id)) continue;

            Id appId = docOrRecToApplication.get(a.ParentId); 
            if (appId == null) continue; 

            appUploads.get(appId).add(a.Id); 
        }

        // Count ContentDocuments (exclude deleted)
        for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :docOrRecToApplication.keySet()]){
            if (deletedIds.contains(link.ContentDocumentId)) continue;

            Id appId = docOrRecToApplication.get(link.LinkedEntityId); 
            if (appId == null) continue; 

            appUploads.get(appId).add(link.Id); 
        }


        // Get the application records
        List<EnrollmentrxRx__Enrollment_Opportunity__c> apps = [SELECT Id, One_Click_PDF_status__c FROM EnrollmentrxRx__Enrollment_Opportunity__c WHERE Id IN :appUploads.keySet()];

        // Update the one click pdf status of each application
        List<EnrollmentrxRx__Enrollment_Opportunity__c> updates = new List<EnrollmentrxRx__Enrollment_Opportunity__c>();
        for (EnrollmentrxRx__Enrollment_Opportunity__c app : apps){
            Integer uploadCount = appUploads.get(app.Id).size();

            if (uploadCount == 0 && app.One_Click_PDF_status__c != null){
                app.One_Click_PDF_status__c = null;
                updates.add(app);
            }
            else if (uploadCount > 0){
                app.One_Click_PDF_status__c = 'Ready for 1-Click PDF.';
                updates.add(app);
            }
        }
        if (!updates.isEmpty()) {
            update updates;
        }


    }

}