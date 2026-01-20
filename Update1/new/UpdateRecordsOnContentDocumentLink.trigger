trigger UpdateRecordsOnContentDocumentLink on ContentDocumentLink (after insert, before delete) {

    List<ContentDocumentLink> links;
    if (Trigger.isDelete) {
        links = Trigger.old;
    } 
    else {
        links = Trigger.new;
    }

    // Get the parent record(s) of the deleted Attachment
    // NOTE: Only get parent record(s) with type admissions document or recommendation
    Set<Id> deletedContentDocumentIds = new Set<Id>();
    Set<Id> docIds = new Set<Id>();
    Set<Id> recIds = new Set<Id>();
    for (ContentDocumentLink link : links){
        if (link.LinkedEntityId == null) continue;
        Schema.SObjectType parentType = link.LinkedEntityId.getSObjectType();

        if (parentType == EnrollmentrxRx__Admissions_Document__c.SObjectType) {
            docIds.add(link.LinkedEntityId);
        }
        else if (parentType == Recommendation__c.SObjectType) {
            recIds.add(link.LinkedEntityId);
        }

        if (Trigger.isDelete){
            deletedContentDocumentIds.add(link.ContentDocumentId);
        }
    }
    if (docIds.isEmpty() && recIds.isEmpty()) {
        return; 
    }

    // If the file was inserted/deleted on an Admissions Document, update the docs status
    if (!docIds.isEmpty()){
        DocumentStatusHandler.updateDocumentStatus(docIds, deletedContentDocumentIds);
    }

    // If the file was inserted/deleted on a rec or doc, get the parent app and update the one click pdf status
    if (!docIds.isEmpty() || !recIds.isEmpty()) {
        Set<Id> appIds = new Set<Id>();
        for (Recommendation__c rec : [SELECT Application__c FROM Recommendation__c WHERE Id IN :recIds]){
            if (rec.Application__c != null) appIds.add(rec.Application__c);
        }
        for(EnrollmentrxRx__Admissions_Document__c doc : [SELECT EnrollmentrxRx__Application__c FROM EnrollmentrxRx__Admissions_Document__c WHERE Id IN :docIds]){
            if (doc.EnrollmentrxRx__Application__c != null) appIds.add(doc.EnrollmentrxRx__Application__c);
        }
        if (!appIds.isEmpty()) {
            OneClickPdfStatusHandler.updateOneClickPdfStatus(appIds, deletedContentDocumentIds);
        }
    }

}