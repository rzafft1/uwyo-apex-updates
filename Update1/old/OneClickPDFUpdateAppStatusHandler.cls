public class OneClickPDFUpdateAppStatusHandler{
/*
  public class AttachmentPair implements Comparable{
    Id applicationId;
    Attachment attach;
    boolean appHasAttachments;
    
      public AttachmentPair(Id i, Attachment a){
        applicationId = i;
        attach = a;
        appHasAttachments = true;
      }
      
      public AttachmentPair(Id i){
        applicationId = i;
        appHasAttachments = false;
      }
      
      public Integer compareTo(Object compareTo){
        AttachmentPair compareToPair = (AttachmentPair)compareTo;
        if(applicationId == compareToPair.applicationId) return 0;
        if(applicationId > compareToPair.applicationId) return 1;
        return -1;
      }
  }
*/

  public class AttachmentPair implements Comparable{
    private Id applicationId;
    private Integer documentCount;
    private boolean noAttachments;
    private boolean multiAttach;
    private boolean nineDocuments;
    private boolean sevenMB;
    private String One_Click_PDF_status = '';
    private Integer totalDocumentCount = 0;
    private Integer recommendationAttCount = 0;
    private Long totalBodyLength = 0;
    private Set <Id> RecIdSet;
    
      public AttachmentPair(Id i){
        applicationId = i;
        multiAttach = false;
        noAttachments = true;
        documentCount = 0;
        nineDocuments = false;
        sevenMB = false;
        One_Click_PDF_status = '';
        totalDocumentCount = 0;
        recommendationAttCount = 0;
        totalBodyLength = 0;
        RecIdSet = new Set <Id> ();
      }
      
      public Integer compareTo(Object compareTo){
        AttachmentPair compareToPair = (AttachmentPair)compareTo;
        if(applicationId == compareToPair.applicationId) return 0;
        if(applicationId > compareToPair.applicationId) return 1;
        return -1;
      }
      
      public void addRecCount(List <Attachment> attachList){
        
        for(Attachment a : attachList){
          System.debug('OneClickPDFUpdateStatus Trigger debug: new rec id is ' +  a.parentId);
          System.debug('OneClickPDFUpdateStatus Trigger debug RecIdSet.contains (recId) = '+ RecIdSet.contains (a.parentId) );

          if(RecIdSet.contains (a.parentId) ){
            recommendationAttCount = recommendationAttCount + 1;
            multiAttach = true;
            break;
          }
          else{
            System.debug('OneClickPDFUpdateStatus Trigger debug: adding ' + a.parentId );
            RecIdSet.add(a.parentId);
          }
        }
    }
    
    public void addDocCount(Integer x){
        totalDocumentCount = totalDocumentCount + x;
        
        if(totalDocumentCount > 9 ){
          nineDocuments = true;
        }
    }
    
    public void addToTotalMB(List<Attachment> attList){
        
        if(attList.size() > 0){
          noAttachments = false;
        }
        
        for(Attachment a : attList){
          totalBodyLength = totalBodyLength + a.bodylength;
          
          if(totalBodyLength > 7000000){
            sevenMB = true;
          }
          
            System.debug('OneClickPDFUpdateStatus Trigger debug: totalBodyLength is ' + totalBodyLength);
        }
    }
    
    public boolean getMoreThanSevenMB(){
      return sevenMB;
    }
    
    public boolean getNineDocuments(){
      return nineDocuments;
    }
    
    public boolean getMultiAttach(){
      return multiAttach;
    }
    
    public boolean getNoAttachments(){
      return noAttachments;
    }
  }


  public static void handleAfterInsertUpdateandDelete(List <Attachment> attachList){ 
    
    //declare and initialize everything
    Map<String, String> application_status = new Map<String, String>();
    
    Map<String, AttachmentPair> testMap = new Map<String, AttachmentPair>();
    
    List<Attachment> attachmentList = new List<Attachment>();
    
    List<AttachmentPair> test = new List<AttachmentPair>();
    Set<Id> parentIdSet = new Set<Id>();
    Set<Id> AttparentIdSet = new Set<Id>();
    Id applicationId = null;
/*    
      Integer documentCount;
      Integer LoopIndex = 0;
      Id recommendationId;
      boolean noAttachments = true;
      boolean multiAttach = false;
      boolean nineDocuments = false;
      boolean sevenMB = false;
      String One_Click_PDF_status = '';
      Integer totalDocumentCount = 0;
      Integer recommendationAttCount = 0;
      Long totalBodyLength = 0;
*/      
      //Governor limits, we want to get the parentIds without querying every time for a new one
    for(Attachment a : attachList){
      attParentIdSet.add(a.parentId);
      System.debug('OneClickPDFUpdateStatus Trigger debug: attachmentId was ' + a.Id);
    }
      
    //Get objects and their children
      
//      Recommendation__c[] recWithAttList = [SELECT Name, ID, application__c, (SELECT Name, Id, bodylength, parentId FROM Attachments)
//    FROM Recommendation__c where Id IN: attParentIdSet order by application__c];
    
//    EnrollmentrxRx__Admissions_Document__c[] ADWithAttList = [SELECT Name, ID, EnrollmentrxRx__Enrollment_Opportunity__c, (SELECT Name, Id, bodylength, parentId FROM Attachments)
//    FROM EnrollmentrxRx__Admissions_Document__c where Id IN: attParentIdSet order by EnrollmentrxRx__Enrollment_Opportunity__c];
    
    List<ID> listAppParents = new List<ID>();
    for(Recommendation__c rec : [SELECT application__c FROM Recommendation__c where Id IN: attParentIdSet order by application__c]){
        listAppParents.add(rec.application__c);
    }

//    for(EnrollmentrxRx__Admissions_Document__c rec : [SELECT EnrollmentrxRx__Enrollment_Opportunity__c FROM EnrollmentrxRx__Admissions_Document__c where Id IN: attParentIdSet order by EnrollmentrxRx__Enrollment_Opportunity__c]){
    for(EnrollmentrxRx__Admissions_Document__c rec : [SELECT EnrollmentrxRx__Application__c FROM EnrollmentrxRx__Admissions_Document__c where Id IN: attParentIdSet order by EnrollmentrxRx__Application__c]){
//        listAppParents.add(rec.EnrollmentrxRx__Enrollment_Opportunity__c);
        listAppParents.add(rec.EnrollmentrxRx__Application__c);
    }

    Recommendation__c[] allRecs = [SELECT ID, application__c, (SELECT Name, Id, bodylength, parentId FROM Attachments) FROM Recommendation__c where application__c IN: listAppParents];
//    EnrollmentrxRx__Admissions_Document__c[] allAttach = [SELECT ID, EnrollmentrxRx__Enrollment_Opportunity__c, (SELECT Name, Id, bodylength, parentId FROM Attachments) FROM EnrollmentrxRx__Admissions_Document__c where EnrollmentrxRx__Enrollment_Opportunity__c IN: listAppParents];
    EnrollmentrxRx__Admissions_Document__c[] allAttach = [SELECT ID, EnrollmentrxRx__Application__c, (SELECT Name, Id, bodylength, parentId FROM Attachments) FROM EnrollmentrxRx__Admissions_Document__c where EnrollmentrxRx__Application__c IN: listAppParents];

//    Attachment aList = [SELECT Id, Name, bodyLength FROM Attachments where Attachment.parentId IN: recId or Attachment.parentId IN: adId ORDER BY parentId];
  
    for(Recommendation__c r : allRecs){
      if(r.application__c != null){
        
        System.debug('added ' + r.Id + ' ' + r.attachments + ' to the list of recommendations that were working with now');
        
        AttachmentPair p;
        
        if(! testMap.ContainsKey(r.application__c)){
          p = new AttachmentPair(r.application__c);
        }
        else{
          p = testMap.get(r.application__c);
        }
          p.addDocCount(r.attachments.size());
          p.addRecCount(r.attachments);
          p.addToTotalMB(r.attachments);
          testMap.put(r.application__c,p);
      }
    }
    
    for(EnrollmentrxRx__Admissions_Document__c ad : allAttach){
//      if(ad.EnrollmentrxRx__Enrollment_Opportunity__c != null){
      if(ad.EnrollmentrxRx__Application__c != null){
        
        AttachmentPair p;
        
//        if(! testMap.ContainsKey(ad.EnrollmentrxRx__Enrollment_Opportunity__c)){
        if(! testMap.ContainsKey(ad.EnrollmentrxRx__Application__c)){
//          p = new AttachmentPair(ad.EnrollmentrxRx__Enrollment_Opportunity__c);
          p = new AttachmentPair(ad.EnrollmentrxRx__Application__c);
        }
        else{
//          p = testMap.get(ad.EnrollmentrxRx__Enrollment_Opportunity__c);
          p = testMap.get(ad.EnrollmentrxRx__Application__c);
        }
          p.addDocCount(ad.attachments.size());
          p.addToTotalMB(ad.attachments);
//          testMap.put(ad.EnrollmentrxRx__Enrollment_Opportunity__c,p);
          testMap.put(ad.EnrollmentrxRx__Application__c,p);
      }
    }
    
    System.debug(testMap);
    
    for ( ID aID : testMap.keySet() ){
        
        AttachmentPair ap = testMap.get(aID);
        
        String result = calculateStatus( ap.getMultiAttach(), ap.getNineDocuments(), ap.getMoreThanSevenMB(), ap.getNoAttachments() );
        application_status.put(aID, result);  
    }
      
      commitResults(application_status);

  }

  
/*
    for(Attachment a : attachmentList){  
      System.debug('in the recommendation loop with ' + r.Name + ' ' + r.Id);
      
      if(r.Attachments.size() == 0){
        test.add(new AttachmentPair(r.application__c));
      }
      else{
        for(Attachment a : r.Attachments){
          System.debug('in the rec attachment loop with ' + a.Name + ' ' + a.Id);
          test.add(new AttachmentPair(r.application__c, a));
        }
      }
    }
    
    for(EnrollmentrxRx__Admissions_Document__c ad : ADWithAttList){  
      System.debug('in the ad loop with ' + ad.Name + ' ' + ad.Id);
      
      if(ad.Attachments.size() == 0){
        test.add(new AttachmentPair(ad.EnrollmentrxRx__Enrollment_Opportunity__c));
      }
      else{
        for(Attachment a : ad.Attachments){
          System.debug('in the ad attachment loop with ' + a.Name + ' ' + a.Id);
          test.add(new AttachmentPair(ad.EnrollmentrxRx__Enrollment_Opportunity__c, a));
        }
      }
    }
    
    System.debug('test before sort is ' + test);
    
    test.sort();
    
    System.debug('test after sort is ' + test);
    
    for (AttachmentPair attachmentPairInList : test){
      if(applicationId != attachmentPairInList.applicationId){
        if(applicationId == null){
              applicationId = attachmentPairInList.applicationId;
              System.debug('OneClickPDFUpdateStatus Trigger debug: Setting ID to ' + applicationId);  
            }
            else{
        
          One_Click_PDF_status  = calculateStatus(multiAttach, nineDocuments, sevenMB, noAttachments);
              
              System.debug('OneClickPDFUpdateStatus Trigger debug: Application ID is ' + applicationId + ' and status is ' + One_Click_PDF_status );
              
              application_status.put(applicationId, One_Click_PDF_status);
              applicationId = attachmentPairInList.applicationId;
              multiAttach = false;
            nineDocuments = false;
            sevenMB = false;
            One_Click_PDF_status = '';
            totalDocumentCount = 0;
            totalBodyLength = 0;
            recommendationAttCount = 0;
            noAttachments = true;
            System.debug('OneClickPDFUpdateStatus Trigger debug: Cleared out variables');        
            }
      }
      
      LoopIndex += 1;
      
      if(!attachmentPairInList.appHasAttachments && noAttachments == true){
        noAttachments = true;
        System.debug('made it to where the pair has no attachments');
        applicationId = attachmentPairInList.applicationId;
      }
      else{
        
        noAttachments = false;
        totalDocumentCount += 1;
      
        if(nineDocuments == false){
              System.debug('OneClickPDFUpdateStatus Trigger debug: totalDocumentCount is ' + totalDocumentCount);
              if(totalDocumentCount > 9){
                nineDocuments = true;
              }
            }
      
        totalBodyLength = totalBodyLength + attachmentPairInList.attach.bodyLength;
        System.debug('OneClickPDFUpdateStatus Trigger debug: totalBodyLength is ' + totalBodyLength);
        
        if(totalBodyLength > 7000000){
            System.debug('OneClickPDFUpdateStatus Trigger debug: we are over 7MB');
            sevenMB = true;
            }
          
            System.debug(String.valueOf( attachmentPairInList.attach.parentId.getSobjectType() ));
            
            if( String.valueOf( attachmentPairInList.attach.parentId.getSobjectType() ) == 'Recommendation__c'){
              if( recommendationId == null ){
                recommendationId = attachmentPairInList.attach.parentId;
                recommendationAttCount += 1;
              }
              else if(recommendationId == attachmentPairInList.attach.parentId){
                recommendationAttCount += 1;
              }
              else{
                recommendationAttCount = 0;
                recommendationId = attachmentPairInList.attach.parentId;
              }
            }
          
            if(recommendationAttCount > 1){
            multiAttach = true;
            }
             System.debug(String.valueOf( 'Recommendation Count is up to ' + recommendationAttCount));
    }
      
        if(loopIndex == test.size() ){
          
            System.debug('loop index == the size and variables are as follows multiattach' + multiAttach + ' nineDocuments ' + nineDocuments + ' sevenMB ' + ' noAttachments' + noAttachments);
              
              One_Click_PDF_status  = calculateStatus(multiAttach, nineDocuments, sevenMB, noAttachments);
              application_status.put(applicationId, One_Click_PDF_status);
              
              System.debug('OneClickPDFUpdateStatus Trigger debug: Application ID is ' + applicationId + ' and status is ' + One_Click_PDF_status );
              
              commitResults(application_status);
        }
  }    
 
}          
*/
/*    
    //Governor limits, we want to get the parentIds without querying every time for a new one
    for(Attachment a : attach){
      attParentIdSet.add(a.parentId);
      System.debug('OneClickPDFUpdateStatus Trigger debug: attachmentId was ' + a.Id);
    }
      
    //Get every recommendation that had an attachment added or updated, we want to know which app is the parent
      Recommendation__c[] recList = [SELECT Name, application__c, ID
              FROM Recommendation__c where ID IN: attparentIdSet order by application__c];
    
      EnrollmentrxRx__Admissions_Document__c[] ADList = [SELECT Name, EnrollmentrxRx__Applicant__c, ID
          FROM EnrollmentrxRx__Admissions_Document__c where ID IN: attParentIdSet order by EnrollmentrxRx__Enrollment_Opportunity__c];          
              
      for(Recommendation__c r : reclist){        
        if(r.application__c != null){
        parentIdSet.add(r.application__c);
      } 
      }
      
      for(EnrollmentrxRx__Admissions_Document__c ad : ADList){        
        if(ad.EnrollmentrxRx__Applicant__c != null){
        parentIdSet.add(ad.EnrollmentrxRx__Applicant__c);
        
      } 
      }

      //Get objects and their children  
      Recommendation__c[] recWithAttList = [SELECT Name, ID, application__c, (SELECT Name, Id, bodylength FROM Attachments)
    FROM Recommendation__c where application__c IN: parentIdSet order by application__c];
    
    EnrollmentrxRx__Admissions_Document__c[] ADWithAttList = [SELECT Name, ID, EnrollmentrxRx__Enrollment_Opportunity__c, (SELECT Name, Id, bodylength FROM Attachments)
    FROM EnrollmentrxRx__Admissions_Document__c where EnrollmentrxRx__Enrollment_Opportunity__c IN: parentIdSet order by EnrollmentrxRx__Enrollment_Opportunity__c];
     
     
     
     
                       
/*          for(Recommendation__c r : recWithAttList){         
          
          LoopIndex = loopIndex + 1;
             
            System.debug('OneClickPDFUpdateStatus Trigger debug: applicationID var is ' + applicationId + ' and the parent on rec is ' + r.application__c);
            if(applicationId != r.application__c){
              if(applicationId == null){
                applicationId = r.application__c;
                System.debug('OneClickPDFUpdateStatus Trigger debug: Setting ID to ' + applicationId);  
              }
              
              else{
          if(noAttachments == true ){
            One_Click_PDF_status = 'No recommendation attachments found on Application.';
          }
              application_status.put(applicationId, One_Click_PDF_status);
              applicationId = r.application__c;
              multiAttach = false;
            nineDocuments = false;
            noAttachments = true;
            sevenMB = false;
            One_Click_PDF_status = '';
            totalDocumentCount = 0;
            totalBodyLength = 0;
            System.debug('OneClickPDFUpdateStatus Trigger debug: Cleared out variables');        
              }
        }
        
        if(r.attachments.size() >= 1){
                 noAttachments = false;
                 if(r.attachments.size() > 1){
                   multiAttach = true;
                 }
                 if ( r.attachments.size() > 9 ) { 
              nineDocuments = true;   
            }
                   
            totalDocumentCount = totalDocumentCount + r.attachments.size();
          }
    
        if(nineDocuments == false){
              System.debug('OneClickPDFUpdateStatus Trigger debug: totalDocumentCount is ' + totalDocumentCount);
              if(totalDocumentCount > 9){
                nineDocuments = true;
              }
            }
            
            for(attachment a : r.attachments){              
              totalBodyLength = totalBodyLength + a.bodylength;
              System.debug('OneClickPDFUpdateStatus Trigger debug: totalBodyLength is ' + totalBodyLength);
              
              if(totalBodyLength > 7000000){
                System.debug('OneClickPDFUpdateStatus Trigger debug: we are over 7MB');
                sevenMB = true;
                break;    
              }
          }

              One_Click_PDF_status  = calculateStatus(multiAttach, nineDocuments, sevenMB, noAttachments); 
              
              if(loopIndex == recWithAttList.size() ){
                application_status.put(applicationId, One_Click_PDF_status);
                commitResults(application_status);
              }  
          }   
   }       
                  
*/    
  

  public static String calculateStatus(boolean  multiAttach, boolean nineDocuments, boolean sevenMB, boolean noAttachments){
    
    String status = '';
        
      if(multiAttach && sevenMB && nineDocuments){
            status = 'Recommendations exist with multiple attachments. Overall document count > 9. Sum of the documents to be merged > 7MB.';
        }           
        
        else if(multiAttach && nineDocuments){
            status = 'Recommendations exist with multiple attachments. Overall document count > 9.';
        }
        else if(sevenMB && nineDocuments){
            status = 'Sum of the documents to be merged > 7MB. Overall document count > 9.';
        }
        else if(multiAttach && sevenMB){
            status = 'Recommendations exist with multiple attachments. Sum of the documents to be merged > 7MB.';
        }
        else if(multiAttach){
            status = 'Recommendations exist with multiple attachments.';
        }
        else if(sevenMB){
            status = 'Sum of the documents to be merged > 7MB.';
        }
        else if(nineDocuments){
            status = 'Overall document count > 9.';
        }
        else if(noAttachments){
          status = 'No attachments found on Application.';
        } 
        else{
            status = 'Ready for 1-Click PDF.';
        }  
    
    
    System.debug('OneClickPDFUpdateStatus Trigger debug: status is ' + status);
    return status;
  }
  

  public static void commitResults( Map<String,String> appIdAndStatus) {
    System.debug('attempting to commit results ');
    
    List<EnrollmentrxRx__Enrollment_Opportunity__c> appList = new List<EnrollmentrxRx__Enrollment_Opportunity__c>();
    
    applist = [SELECT name, Id FROM EnrollmentrxRx__Enrollment_Opportunity__c WHERE Id IN : appIdAndStatus.keySet() ];
       
          System.debug('applist.size () is equal to ' + applist.size ());
          
          for(EnrollmentrxRx__Enrollment_Opportunity__c app : applist ){
            app.One_Click_PDF_status__c =  appIdAndStatus.get(app.Id);            
            System.debug('OneClickPDFUpdateStatus Trigger debug: we just inserted / updated ' + app.Id + ' to ' + app.One_Click_PDF_status__c);
      }

      update appList;
  }
}