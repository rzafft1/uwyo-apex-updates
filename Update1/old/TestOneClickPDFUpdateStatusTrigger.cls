@isTest
private class TestOneClickPDFUpdateStatusTrigger {
      
      static String multiAttach = 'Recommendations exist with multiple attachments.';
      static String nineDocuments = 'Overall document count > 9.';
      static String sevenMB = 'Sum of the documents to be merged > 7MB.';
      static String noAttachments = 'No attachments found on Application.';
      static String ready = 'Ready for 1-Click PDF.';
    
      Private static void populateCustomSetting(){
            ERx_Events__Event_Registration_Settings__c eventSetObj = new ERx_Events__Event_Registration_Settings__c();
            eventSetObj.Name = 'DEFAULTS';
            eventSetObj.ERx_Events__Group_Name__c = 'ERxCampusGroup';
            eventSetObj.ERx_Events__Contact_Email_Address__c = 'eventstest@test.com';
            eventSetObj.ERx_Events__Default_Template_Name__c = 'Test';
            eventSetObj.ERx_Events__Event_Full_Message__c = 'Registration is Full';
            eventSetObj.ERx_Events__Invalid_Date_Message__c = 'Invalid Date';
            eventSetObj.ERx_Events__Is_DatePicker_Required__c = true;
            eventSetObj.ERx_Events__New_Contact_Lead_Source__c = 'Web';
            eventSetObj.ERx_Events__Thank_You_Message__c = 'Thanks';
            eventSetObj.ERx_Events__Is_Send_Email__c = true;
            eventSetObj.ERx_Events__is_Send_QR_Code__c = true;
            eventSetObj.ERx_Events__Campus_Campaign_Recurrence__c = 15;
            eventSetObj.ERx_Events__Time_Zone__c = 'GMT-06 : 00 Central Standard Time (America/Chicago)';
            eventSetObj.ERx_Events__Sender_Email__c = 'developer@test.com';
            eventSetObj.ERx_Events__Deactivate_random_string_for_contact__c = false;
            insert eventSetObj;        
        }
    
      public static String[] createTestContactAndApp(){
            populateCustomSetting();
        String[] idArray = new List<string>();
        List<Contact> contactList = new List<Contact>();
        List<EnrollmentrxRx__Enrollment_Opportunity__c> appList = new List<EnrollmentrxRx__Enrollment_Opportunity__c>();
        
        Contact contact1 = new Contact();
          contact1.FirstName = 'BobFirstName';
          contact1.LastName = 'JonesLastName';
          contact1.Email = 'Bobtestemail@example.com';
          contact1.birthdate = date.today();
                   
        Contact contact2 = new Contact();
          contact2.FirstName = 'SallyFirstName';
          contact2.LastName = 'MayLastName';
          contact2.Email = 'Sallytestemail@example.com';
          contact2.birthdate = (date.today() - 900);
          
          Contact contact3 = new Contact();
          contact3.FirstName = 'GaryFirstName';
          contact3.LastName = 'AldersLastName';
          contact3.Email = 'Garytestemail@example.com';
          contact3.birthdate = (date.today() - 1024);
          
          Contact contact4 = new Contact();
          contact4.FirstName = 'JoanneFirstName';
          contact4.LastName = 'FarmerLastName';
          contact4.Email = 'Joannetestemail@example.com';
          contact4.birthdate = (date.today() - 1024);
          
          contactList.add(contact1);
          contactList.add(contact2);
          contactList.add(contact3);
          contactList.add(contact4);
          insert contactList;
          
          EnrollmentrxRx__Enrollment_Opportunity__c app1 = new EnrollmentrxRx__Enrollment_Opportunity__c();
          app1.EnrollmentrxRx__Applicant__c = contact1.Id;
          appList.add(app1);

          EnrollmentrxRx__Enrollment_Opportunity__c app2 = new EnrollmentrxRx__Enrollment_Opportunity__c();
          app2.EnrollmentrxRx__Applicant__c = contact2.Id;  
          appList.add(app2);

          
      //Giving one person many apps          
          for(Integer i = 0; i < 17; i++){
            EnrollmentrxRx__Enrollment_Opportunity__c app = new EnrollmentrxRx__Enrollment_Opportunity__c();
            app.EnrollmentrxRx__Applicant__c = contact3.Id;
            appList.add(app);
          }
          insert appList;
          
          for(EnrollmentrxRx__Enrollment_Opportunity__c x: appList){
            idArray.add(x.id);
          }
          
          return idArray;
      }
    
    @istest static void testCreateAndDelete(){
        Test.startTest();
        //create contact and application        
        String[] appIdArray = createTestContactAndApp();
        
        //Then create recommendation and attachment
        Recommendation__c Rec1 = new Recommendation__c();
        
        List<Attachment> attachmentList = new List<Attachment>();
        
        System.debug('OneClickPDF App testUpdate(): App ID is ' + appIdArray[0]); 
        Rec1.application__c = appIdArray[0];
        System.debug('OneClickPDF App testUpdate(): Rec1.application__c ' + Rec1.application__c );
        //insert Rec1;
        insert(Rec1);

        System.debug('OneClickPDF App testUpdate(): Recommendation applicant is ' + Rec1.application__c);            
            
        Recommendation__c[] recList = 
            [SELECT Id FROM Recommendation__c WHERE application__c =: Rec1.application__c];     
            
        Blob blobA = Blob.valueOf('abcd');
        Attachment att = new Attachment();
        att.Name='Test1.doc';
        att.Body = blobA;   
        att.ParentId = Rec1.Id;
        attachmentList.add(att);
        
        EnrollmentrxRx__Admissions_Document__c ad = new EnrollmentrxRx__Admissions_Document__c();
        //ad.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[0];
        ad.EnrollmentrxRx__Document_Name__c = 'Admissions Document Test 1';
        insert ad;
        
        Attachment att2 = new Attachment();
        att2.Name='Test2.doc';
        att2.Body = blobA;   
        att2.ParentId = ad.Id;
        attachmentList.add(att2);
        
        insert attachmentList;

        String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[0]].One_Click_PDF_status__c;
        
        System.Assert(testResult == ready, 'The testResult for testCreateAndDelete() was ' + testResult + ' when it was supposed to be ' + ready);
        DELETE [select Id from Attachment where Id =: att.Id OR Id =: att2.Id];
        
        testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[0]].One_Click_PDF_status__c;
        
        System.Assert(testResult == noAttachments, 'The testResult for testCreateAndDelete()\'s deletion was ' + testResult + ' when it was supposed to be ' + noAttachments);
        System.debug('testResult was ' +  testResult);
        
        Test.stopTest();
    }
       
    @istest static void testWithMoreThanNineAttachments(){
      Test.startTest();
      
      //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    Blob blobB = Blob.valueOf('abcdefghijk');

        for(Integer i = 0; i <= 11; i++){
        Recommendation__c newRecordOnApp = new Recommendation__c();
        newRecordOnApp.application__c = appIdArray[3];
        recommendationList.add(newRecordOnApp);
        }
        
        insert recommendationList;
        
        for(Integer i = 0; i <= 11; i++){
          Attachment newAttOnRec = new Attachment();
          newAttOnRec.Name='TestAppsWithManyAttachments' + i + '.doc';
          newAttOnRec.Body = blobB;
          newAttOnRec.parentId = recommendationList[i].Id;
          attachmentList.add(newAttOnRec);
          System.debug('OneClickPDF App testUpdateWithMoreThanNineAttachments(): added attachment  on recommendation ID' + recommendationList[i].Id + ' named '+ recommendationList[i].Name);
    }

    insert attachmentList;
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[3]].One_Click_PDF_status__c;
    System.debug('OneClickPDF App testUpdateWithMoreThanNineAttachments(): testResult was ' + testResult);

    System.assert(testResult == nineDocuments, 'OneClickPDF App, testWithMoreThanNineAttachments(): The testResult for testWithMoreThanNineAttachments() was ' + testResult + ' when it was supposed to be ' + nineDocuments);
    
    //Now, test deletion and re-calculation
    for(Integer i = 0; i <= 4; i++){
      attachmentsToDelete.add(attachmentList[i]);
      attachmentList.remove(i);
    }
    
    System.debug(attachmentsToDelete);
    DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[3]].One_Click_PDF_status__c;
    
    //System.assert(testResult == ready, 'OneClickPDF App, testWithMoreThanNineAttachments(): The testResult for the testUpdateWithMoreThanNineAttachments deletion was ' + testResult + ' when it was supposed to be ' + ready);

    //Add some Admissions Documents to this
    attachmentsToDelete.clear();
    
    for(Integer i = 0; i <= 4; i++){
      attachmentsToDelete.add(attachmentList[i]);
      System.debug(attachmentsToDelete);
    }
    
    attachmentList.clear();
    
    for(Integer i = 0; i <= 4; i++){
        EnrollmentrxRx__Admissions_Document__c newAdmissionsDoc = new EnrollmentrxRx__Admissions_Document__c();
        //newAdmissionsDoc.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[3];
        admissionDocList.add(newAdmissionsDoc);
        }
        
        insert admissionDocList;
        
        for(Integer i = 0; i <= 4; i++){
          Attachment newAttOnAd = new Attachment();
          newAttOnAd.Name='TestAppsWithManyAttachmentsAD' + i + '.doc';
          newAttOnAd.Body = blobB;
          newAttOnAd.parentId = admissionDocList[i].Id;
          attachmentList.add(newAttOnAd);
          System.debug('OneClickPDF App testUpdateWithMoreThanNineAttachments(): added attachment  on recommendation ID' + recommendationList[i].Id + ' named '+ recommendationList[i].Name);
    }
        
        insert attachmentList;
    
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[3]].One_Click_PDF_status__c;
    //System.assert(testResult == nineDocuments, 'OneClickPDF App, testWithMoreThanNineAttachments(): The testResult for the testUpdateWithMoreThanNineAttachments deletion was ' + testResult + ' when it was supposed to be ' + nineDocuments);
    
    DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[3]].One_Click_PDF_status__c;
    
    System.assert(testResult == ready, 'OneClickPDF App, testWithMoreThanNineAttachments(): The testResult for the testUpdateWithMoreThanNineAttachments deletion was ' + testResult + ' when it was supposed to be ' + ready);
    Test.stopTest();
    }
    
    @isTest static void testWith7MBRec(){
      Test.startTest();
      
      Blob hugeText = blob.valueOf('');
      
      System.debug(createTestString(1000000));
      hugeText = blob.valueOf(createTestString(1000000));
      
      
      //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    
    for(Integer i = 0; i <= 8; i++){
        Recommendation__c newRecordOnApp = new Recommendation__c();
        newRecordOnApp.application__c = appIdArray[1];
        recommendationList.add(newRecordOnApp);
        }
 
        insert recommendationList;
        
        for(Integer i = 0; i <= 8; i++){
          Attachment newAttOnRec = new Attachment();
          newAttOnRec.Name='TestAppWithLargeAttachment' + i + '.doc';
          newAttOnRec.Body = hugeText;
          newAttOnRec.parentId = recommendationList[i].Id;
          
          attachmentList.add(newAttOnRec);
                 
        System.debug('OneClickPDF App testUpdateWith7MBRec(): Attachment '+  newAttOnRec.Name + ' was added to  ' + recommendationList[i].Id + ' with parent ' + recommendationList[i].application__c + ' and size ' + (String.valueOf(hugeText)));    
        //Heap size too  small to create and insert everything at once
        if(math.mod(i,10) == 0){
          System.debug('OneClickPDF App testUpdateWith7MBRec(): List of Attachments was inserted');
          insert attachmentList ;
          attachmentList = new List <Attachment>();
        }  
    }

    if(!attachmentList.isEmpty() ) {
      insert attachmentList;
    }
    
    System.debug('ID array value is ' + appIdArray[1]);
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    System.debug('OneClickPDF App testUpdateWith7MBRec(): testResult was ' + testResult);
    System.assert(testResult == sevenMB, 'OneClickPDF App, testWith7MBRec(): The test result for testUpdateWith7MBRec(): was ' + testResult + ' when it was supposed to be ' + sevenMB);
    
    //Now test deletion
    for(Integer i = 0; i <= 3; i++){
      attachmentsToDelete.add(attachmentList[i]);
      attachmentList.remove(i);
      }
    
    System.debug(attachmentsToDelete);
    DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    System.assert(testResult == ready, 'OneClickPDF App, testWith7MBRec(): The testWith7MBRec deletion result was ' + testResult + ' when it was supposed to be ' + ready);
    
    
    Test.stopTest();
    }
    
    @isTest static void testWith7MBAD(){
  Test.startTest();
  
  Blob hugeText = blob.valueOf('');
  
  System.debug(createTestString(1000000));
  hugeText = blob.valueOf(createTestString(1000000));
  
  
  //create contact and application
  String[] appIdArray = createTestContactAndApp();
  List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
  List<Attachment> attachmentList = new List<Attachment>();
  List<Attachment> attachmentsToDelete = new List<Attachment>();
  List<Recommendation__c> recommendationList = new List <Recommendation__c>();
        //Add some Admissions Documents
    for(Integer i = 0; i <= 9; i++){
        EnrollmentrxRx__Admissions_Document__c newAdmissionsDoc = new EnrollmentrxRx__Admissions_Document__c();
        //newAdmissionsDoc.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[1];
        admissionDocList.add(newAdmissionsDoc);
        }
        
        insert admissionDocList;
        
        //And some attachments
        attachmentsToDelete.clear();
        attachmentList.clear();
        for(Integer i = 0; i < 8; i++){
          Attachment newAttOnAD = new Attachment();
          newAttOnAD.Name='TestAppWithLargeAttachmentAD' + i + '.doc';
          newAttOnAD.Body = hugeText;
          newAttOnAD.parentId = admissionDocList[i].Id;
          attachmentList.add(newAttOnAD);
          
          if(Math.mod(i,2) == 0){
            attachmentsToDelete.add(newAttOnAD);
          }
        }

    insert attachmentList;
    
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    //System.assert(testResult ==  sevenMB, 'OneClickPDF App, testWith7MBAD(): The testWith7MBAD deletion result was ' + testResult + ' when it was supposed to be ' +  sevenMB);
    
    DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    //System.assert(testResult == ready, 'OneClickPDF App, testWith7MBAD(): The testWith7MBAD deletion result was ' + testResult + ' when it was supposed to be ' + ready);
    
    }
    
    
   @isTest static void testRecWithMultiAtt(){ 
       Test.startTest();
    //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    
    Recommendation__c recordWithManyAtt = new Recommendation__c();
    recordWithManyAtt.application__c = appIdArray[0];
    recommendationList.add(recordWithManyAtt);
    insert recommendationList;
    
    EnrollmentrxRx__Admissions_Document__c admissionsDocWithManyAtt = new EnrollmentrxRx__Admissions_Document__c();
    //admissionsDocWithManyAtt.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[0];
    admissionDocList.add(admissionsDocWithManyAtt);
    insert admissionDocList;
    
    Blob blobC = Blob.valueOf('abcdefghijk');
    
    for(Integer i = 0; i <= 5; i++){
       Attachment newAttOnRec = new Attachment();
         newAttOnRec.Name='TestManyAttachments' + i + '.doc';
         newAttOnRec.parentId = recommendationList[0].Id;
         newAttOnRec.Body =  blobC;
         attachmentList.add(newAttOnRec); 
         
         if(i < 3){
           //Add one to the Admissions Document as well. Those CAN have multiple attachments so we might as well test that case while we're here.
           Attachment newAttOnRec2 = new Attachment();
           newAttOnRec2.Name='TestManyAttachmentsAD' + i + '.doc';
           newAttOnRec2.parentId = admissionDocList[0].Id;
           newAttOnRec2.Body =  blobC;
           attachmentList.add(newAttOnRec2);
         }
    }
     
    insert attachmentList;
       
     String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[0]].One_Click_PDF_status__c;
    System.assert(testResult == multiAttach, 'OneClickPDF App testRecWithMultiAtt(): testResult before delete was ' + testResult + ' when it was supposed to be ' + multiAttach);
       
       //test deletion
      for(Integer i = 1; i <= 8; i++){
         attachmentsToDelete.add(attachmentList[i]);
      }
      
      
      
      DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
      testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[0]].One_Click_PDF_status__c;
      System.assert(testResult == ready, 'OneClickPDF App testRecWithMultiAtt(): testResult after delete was ' + testResult + ' when it was supposed to be ' + ready);

       Test.stopTest();
   }
    
   @isTest static void test9DocsAndMultiAttachments(){ 
       Test.startTest();
    //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    
    Recommendation__c recordWithManyAtt = new Recommendation__c();
    recordWithManyAtt.application__c = appIdArray[0];
    recommendationList.add(recordWithManyAtt);
    insert recommendationList;
    
    EnrollmentrxRx__Admissions_Document__c admissionsDocWithManyAtt = new EnrollmentrxRx__Admissions_Document__c();
    //admissionsDocWithManyAtt.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[0];
    admissionDocList.add(admissionsDocWithManyAtt);
    insert admissionDocList;
    
    
    Blob blobD = Blob.valueOf('abcdefghijk');
    
    for(Integer i = 0; i <= 5; i++){
       Attachment newAttOnRec = new Attachment();
         newAttOnRec.Name='TestManyAttachments' + i + '.doc';
         newAttOnRec.parentId = recommendationList[0].Id;
         newAttOnRec.Body =  blobD;
         attachmentList.add(newAttOnRec); 
    }
    
    for(Integer i = 0; i <= 4; i++){
       Attachment newAttOnRec = new Attachment();
         newAttOnRec.Name='TestManyAttachmentsAD' + i + '.doc';
         newAttOnRec.parentId = admissionDocList[0].Id;
         newAttOnRec.Body =  blobD;
         attachmentList.add(newAttOnRec); 
    }
       insert attachmentList;

     String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[0]].One_Click_PDF_status__c;
    //System.assert(testResult == (multiAttach + ' ' + nineDocuments), 'OneClickPDF App test9DocsAndMultiAttachments(): testResult was ' + testResult + ' when it was supposed to be ' + multiAttach + ' ' + nineDocuments);
       
       Test.stopTest();
   }
   
    @isTest static void test7MBand9Docs(){ 
       Test.startTest();
    //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    
    Blob hugeText = blob.valueOf('');
      System.debug(createTestString(1000000));
      hugeText = blob.valueOf(createTestString(1000000));
    
    for(Integer i = 0; i <= 10; i++){
        Recommendation__c newRecordOnApp = new Recommendation__c();
        newRecordOnApp.application__c = appIdArray[1];
        recommendationList.add(newRecordOnApp);
        }
 
        insert recommendationList;
        
        for(Integer i = 0; i <= 10; i++){
          Attachment newAttOnRec = new Attachment();
          newAttOnRec.Name='TestManyLargeAttachments' + i + '.doc';
          newAttOnRec.Body = hugeText;
          newAttOnRec.parentId = recommendationList[i].Id;
          attachmentList.add(newAttOnRec);
                 
        System.debug('OneClickPDF App test7MBand9Docs(): Attachment '+  newAttOnRec.Name + ' was added to  ' + recommendationList[i].Id + ' with parent ' + recommendationList[i].application__c + ' and size ' + (String.valueOf(hugeText)));    
        //Heap size too large to create and insert everything at once
        if(math.mod(i,10) == 0){
          System.debug('OneClickPDF App test7MBand9Docs(): List of Attachments was inserted');
          insert attachmentList ;
          attachmentList = new List <Attachment>();  
        }  
          System.debug('OneClickPDF App testUpdateWith7MB(): added attachment  on recommendation ID' + recommendationList[i].Id);
    }

    if(!attachmentList.isEmpty() ) {
      insert attachmentList;
    }
    
    System.debug('ID array value is ' + appIdArray[1]);
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    System.debug('OneClickPDF App test7MBand9Docs(): testResult was ' + testResult);
    System.assert(testResult == sevenMB + ' ' + nineDocuments);
    
    Test.stopTest();
   }
   
   
  @isTest static void test7MBandMultiAttachments(){ 
    Test.startTest();
    //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    
    Blob hugeText = blob.valueOf('');
      System.debug(createTestString(1000000));
      hugeText = blob.valueOf(createTestString(1000000));
      
      Recommendation__c newRecordOnApp = new Recommendation__c();
    newRecordOnApp.application__c = appIdArray[2];
    recommendationList.add(newRecordOnApp);
        insert recommendationList;
        
        EnrollmentrxRx__Admissions_Document__c newAdmissionDocOnApp = new EnrollmentrxRx__Admissions_Document__c();
    //newAdmissionDocOnApp.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[2];
    admissionDocList.add(newAdmissionDocOnApp);
        insert admissionDocList;
        
        for(Integer i = 0; i <= 3; i++){
          Attachment newAttOnRec = new Attachment();
          newAttOnRec.Name='TestManyLargeAttachments' + i + '.doc';
          newAttOnRec.Body = hugeText;
          newAttOnRec.parentId = newRecordOnApp.Id;
          attachmentList.add(newAttOnRec);
          
          Attachment newAttOnRec2 = new Attachment();
          newAttOnRec2.Name='TestManyLargeAttachmentsDocument' + i + '.doc';
          newAttOnRec2.Body = hugeText;
          newAttOnRec2.parentId = newAdmissionDocOnApp.Id;
        attachmentList.add(newAttOnRec2);       
              
        if(math.mod(i,10) == 0){
          System.debug('OneClickPDF App test7MBandMultiAttachments(): List of Attachments was inserted');
          
          insert attachmentList ;
          attachmentList = new List <Attachment>();  
        }
    }

    if(!attachmentList.isEmpty() ) {
      insert attachmentList;
    }
    
    System.debug('ID array value is ' + appIdArray[1]);
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[2]].One_Click_PDF_status__c;
    //System.assert(testResult == multiAttach + ' ' + sevenMB, 'The result for test7MBandMultiAttachments() is ' + testResult + ' when it was supposed to be ' + multiAttach + ' ' + sevenMB);
        System.debug('OneClickPDF App test7MBandMultiAttachments(): testResult was ' + testResult);
  
    Test.stopTest();
   }
   
  @isTest static void test7MBandMultiAttachand9Docs(){ 
    Test.startTest();
    //create contact and application
    String[] appIdArray = createTestContactAndApp();
    List<Attachment> attachmentList = new List<Attachment>();
    List<Attachment> attachmentsToDelete = new List<Attachment>();
    List<Attachment> attachmentsToDelete2 = new List<Attachment>();
    List<Recommendation__c> recommendationList = new List <Recommendation__c>();
    List<EnrollmentrxRx__Admissions_Document__c> admissionDocList = new List <EnrollmentrxRx__Admissions_Document__c>();
    
    Blob hugeText = blob.valueOf('');
      System.debug(createTestString(1000000));
      hugeText = blob.valueOf(createTestString(1000000));
    
    for(Integer i = 0; i <= 8; i++){
        Recommendation__c newRecordOnApp = new Recommendation__c();
        newRecordOnApp.application__c = appIdArray[1];
        recommendationList.add(newRecordOnApp);
        }
        insert recommendationList;
        
        for(Integer i = 0; i <= 6; i++){
        EnrollmentrxRx__Admissions_Document__c newAdmissionsDocOnApp = new EnrollmentrxRx__Admissions_Document__c();
        //newAdmissionsDocOnApp.EnrollmentrxRx__Enrollment_Opportunity__c = appIdArray[1];
        admissionDocList.add(newAdmissionsDocOnApp);
        }
        insert admissionDocList;
        
    Integer j = 0;
        Integer k = 0;
        Integer l = 0;
        integer m = 0;
        for(Integer i = 0; i <= 8; i++){
          Attachment newAtt1 = new Attachment();         
          newAtt1.Name='TestManyLargeAttachments' + i + '.doc';
          newAtt1.Body = hugeText;

          //place two attachments on some records, one on others
          if( math.mod(i,2) == 0 ){

            Attachment newAtt2 = new Attachment();
            newAtt2.Name='TestManyLargeAttachments' + i + '.doc';
            newAtt2.Body = hugeText;
            
            if(Math.mod(l,2) == 0 && admissionDocList.size() > k){
              newAtt1.parentId = admissionDocList[k].Id;
              newAtt2.parentId = admissionDocList[k].Id;
              k++;             
            }
            else{
          newAtt1.parentId = recommendationList[j].Id;
              newAtt2.parentId = recommendationList[j].Id;
              j++;
            }
            l++;
            attachmentList.add(newAtt1);
            attachmentList.add(newAtt2);
            
            //Set this up for the deletion test later
            attachmentsToDelete.add(newAtt2);
          }
          else{
            
            if(Math.mod(m,2) == 0 && admissionDocList.size() > k){
              newAtt1.parentId = admissionDocList[k].Id;
              k++;
            }
            else{
          newAtt1.parentId = recommendationList[j].Id;
              j++;
            }
            m++;
            attachmentList.add(newAtt1);
            
            //Set this up for the deletion test later
            attachmentsToDelete.add(newAtt1);
          }       
        if(math.mod(i,10) == 0){
          System.debug('OneClickPDF App test7MBandMultiAttachments(): List of Attachments was inserted');
          insert attachmentList ;
          attachmentList = new List <Attachment>();  
        }  
    }

    if(!attachmentList.isEmpty() ) {
      insert attachmentList;
    }
    
    System.debug('ID array value is ' + appIdArray[1]);
    String testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
    //System.assert(testResult == (multiAttach + ' ' + nineDocuments + ' ' + sevenMB), 'The deletion result for test7MBandMultiAttachand9Docs is ' + testResult + ' when it was supposed to be ' + multiAttach + ' ' + nineDocuments + ' ' + sevenMB);
    //Test deleting attachments that are on records with multiple attachments per object
    DELETE [select Id from Attachment where Id IN: attachmentsToDelete];
    testResult = [SELECT One_Click_PDF_status__c from EnrollmentrxRx__Enrollment_Opportunity__c where Id =: appIdArray[1]].One_Click_PDF_status__c;
      System.assert(testResult == ready, 'The second deletion result for test7MBandMultiAttachand9Docs is ' + testResult + ' when it was supposed to be ' + ready);
      
    Test.stopTest();
  } 

   private static String createTestString(Integer length){
    String s = 'abcdefghijk';
      
      for (Integer i = 10; i <= 1000000; i = i * 10) {
        if (length <= i) {
          return s.substring(0, length);  
        }
        
        else{
          String newString = '';
          for (Integer j = 0; j < 10; j ++) {
                newString += s;
          }
          s = newString;
        }
      }
      return null; 
    }   
}