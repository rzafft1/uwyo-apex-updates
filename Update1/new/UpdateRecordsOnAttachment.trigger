trigger UpdateRecordsOnAttachment on Attachment (after insert, before delete) {

    List<Attachment> attachments;
    if (Trigger.isDelete) {
        attachments = Trigger.old;   
    } 
    else {
        attachments = Trigger.new;
    }

    // Get the parent record(s) of the deleted Attachment
    // NOTE: Only get parent record(s) with type admissions document or recommendation
    Set<Id> deletedAttachmentIds = new Set<Id>();
    Set<Id> docIds = new Set<Id>();
    Set<Id> recIds = new Set<Id>();
    for (Attachment a : attachments){
        if (a.ParentId == null) continue;
        Schema.SObjectType parentType = a.ParentId.getSObjectType();

        if (parentType == EnrollmentrxRx__Admissions_Document__c.SObjectType) {
            docIds.add(a.ParentId);
        }
        else if (parentType == Recommendation__c.SObjectType) {
            recIds.add(a.ParentId);
        }

        if (Trigger.isDelete){
            deletedAttachmentIds.add(a.Id);
        }
    }
    if (docIds.isEmpty() && recIds.isEmpty()) {
        return; 
    }

    // If the attachment was inserted/deleted on an Admissions Document, update the docs status
    if (!docIds.isEmpty()){
        DocumentStatusHandler.updateDocumentStatusOnDelete(docIds, deletedAttachmentIds);
    }

    // If the attachment was inserted/deleted on a rec or doc, get the parent app and update the one click pdf status
    if (!docIds.isEmpty() || !recIds.isEmpty()) {
        Set<Id> appIds = new Set<Id>();
        for (Recommendation__c rec : [SELECT Application__c FROM Recommendation__c WHERE Id IN :recIds]){
            if (rec.Application__c != null) appIds.add(rec.Application__c);
        }
        for(EnrollmentrxRx__Admissions_Document__c doc : [SELECT EnrollmentrxRx__Application__c FROM EnrollmentrxRx__Admissions_Document__c WHERE Id IN :docIds]){
            if (doc.EnrollmentrxRx__Application__c != null) appIds.add(doc.EnrollmentrxRx__Application__c);
        }
        if (!appIds.isEmpty()) {
            OneClickPdfStatusHandler.updateOneClickPdfStatus(appIds, deletedAttachmentIds);
        }
    }


}