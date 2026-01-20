public class DocumentStatusHandler {

    /**
     * Updates the EnrollmentrxRx__Document_Status__c of EnrollmentrxRx__Admissions_Document__c records to
     * Required (if no uploads exist) or Ready For Approval (if at least one upload exists). 
     * 
     * @param docIds : Set of Admissions Document Ids to update
     * @param deletedIds : Set of Attachment or ContentDocument ids that were deleted (we exclude these from the count)
    */
    public static void updateDocumentStatus(Set<Id> docIds, Set<Id> deletedIds) {

        // Count the number of uploads on the admissions doc(s) excluding the deleted file/attachment
        Map<Id, List<Id>> docUploads = new Map<Id, List<Id>>();
        for (Id docId : docIds){
            docUploads.put(docId, new List<Id>());
        }

        // Count attachments (exclude deleted)
        for (Attachment a : [SELECT Id, ParentId FROM Attachment WHERE ParentId IN :docIds]){
            if (deletedIds.contains(a.Id)) continue;
            docUploads.get(a.ParentId).add(a.Id); 
        }

        // Count ContentDocuments (exclude deleted)
        for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :docIds]){
            if (deletedIds.contains(link.ContentDocumentId)) continue;
            docUploads.get(link.LinkedEntityId).add(link.Id); 
        }

        // Get the admissions document records
        List<EnrollmentrxRx__Admissions_Document__c> docs = [SELECT Id, EnrollmentrxRx__Document_Status__c FROM EnrollmentrxRx__Admissions_Document__c WHERE Id IN :docUploads.keySet()];

        // Update the status of each doc
        List<EnrollmentrxRx__Admissions_Document__c> updates = new List<EnrollmentrxRx__Admissions_Document__c>();
        for (EnrollmentrxRx__Admissions_Document__c doc : docs){
            Integer uploadCount = docUploads.get(doc.Id).size();

            // Set the status to 'Required' if the document has no uploads
            Set<String> excludedStatuses = new Set<String>{'Required', 'Resubmit', 'Currently Not Needed'};
            if (uploadCount == 0 && !excludedStatuses.contains(doc.EnrollmentrxRx__Document_Status__c)){
                doc.EnrollmentrxRx__Document_Status__c = 'Required';
                updates.add(doc);
            }
            else if (uploadCount > 0 && doc.EnrollmentrxRx__Document_Status__c != 'Ready For Approval'){
                doc.EnrollmentrxRx__Document_Status__c = 'Ready For Approval';
                updates.add(doc);
            }
        }
        if (!updates.isEmpty()) {
            update updates;
        }
    }
}