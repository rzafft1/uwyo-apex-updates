trigger DocumentStatus on Attachment (after delete, after insert, after undelete, after update) {
  
  // variable 'seeds' to store the reocrds which fire the trigger
  List<Attachment> seeds = new List<Attachment>();
  Set<Id> ids = new Set<Id>();
  
  //document, which status will be updated
  List<EnrollmentrxRx__Admissions_Document__c> updateDoc = new List<EnrollmentrxRx__Admissions_Document__c>();
  
  //assign the set to seeds
  if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete){
    seeds = Trigger.new;
  }else{
    seeds = Trigger.old;
  }  
  
  //get document's ID from attachment's parentID
  for(Attachment att : seeds){
    ids.add(att.parentId);
  }
  
  List<Attachment> attachments = [select Id, parentId from Attachment where parentId in : ids];
  
  //build map <document's Id, document's attachment>
  Map<Id,Attachment> attMap = new Map<Id,Attachment>();
  for(Attachment a : attachments){
    attMap.put(a.parentId,a);
  }
  
  //retrieve all the documents related to the attachment
  List<EnrollmentrxRx__Admissions_Document__c> docs = [select id,EnrollmentrxRx__Document_Status__c from EnrollmentrxRx__Admissions_Document__c where Id in : ids];
  
  
  //loop the map see if the document has attachment already. If yes, status = 'RFA', else status = 'requested'
  for(EnrollmentrxRx__Admissions_Document__c d : docs){
    if(attMap.containsKey(d.Id)){
      //if(d.EnrollmentrxRx__Document_Status__c == 'Required'){
        d.EnrollmentrxRx__Document_Status__c='Ready For Approval';
      //}
    }else{
      d.EnrollmentrxRx__Document_Status__c='Required';
    }
    updateDoc.add(d);
  }
  update(updateDoc);

}
