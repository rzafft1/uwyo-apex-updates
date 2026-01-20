# The Old/Current System

When an Attachment is inserted on an Admissions Document or Recommendation, the **OneClickPDFUpdateAppStatus** Apex Trigger calls the **OneClickPDFUpdateAppStatusHandler** Apex Class. This code retreives the Admissions Document or Recommendations parent Application, then gets all the attachments stored in ALL of the application's related Admissions Documents and Recommendations. It then makes the following update:

* Case 1: If the total size of attachments on all the application's recs and docs is > 7MB, update One_Click_PDF_status__c field to "Sum of the documents to be merged > 7MB".
* Case 2: If the total count of attachments on all recs and docs is > 9, update One_Click_PDF_status__c to "Overall document count > 9". 
* Case 3: If the total count of attachments on all the recs and docs is == 0, update One_Click_PDF_status__c to "No attachments found on Application". 
* Case 4: If the application has a recommendation with more than one attachment, update One_Click_PDF_status__c to "Recommendations exist with multiple attachments". 
* Case 5: If cases 1-4 were false, update One_Click_PDF_status__c field to 'Ready for 1-Click PDF'. 

Current System: When an attachment is inserted, updated, deleted, or undeleted from an Admissiosn Document, the **DocumentStatus** Apex Trigger runs and updates the Admissions Document's EnrollmentrxRx__Document_Status__c to 'Ready for Approval' (if the attachment was inserted, updated, or undeleted) or 'Required' (if the attachment was deleted and there are no other attachmentes on the admissions document)

# The Problem

1. If an attachment is removed from a doc or rec, and there no remaining attachments on any other docs or recs, the One_Click_PDF_status__c "No attachments found on Application". This error message is both misleading and unecessary. For example, if there are no attachments in the docs or recs, but are there are attachments on the attachments itself, the field is still updated to "No attachments found on Application". Therefore, it would be better to simply reset the One_Click_PDF_status__c to null whenever there are no attachments (or files) on any of the docs or recs. 

2. The code only accounts for attachments (should account for attachments AND files/contentDocumentLinks)

3. The error messages; "Sum of the documents to be merged > 7MB", "Overall document count > 9", and "Recommendations exist with multiple attachments" are all unecessary. (1) "Sum of the documents to be merged > 7MB" and "Overall document count > 9" were only used for the conga pdf composer tool, which could not merge more than 9 files, or pdfs with a combined size > 7MB. The conga pdf composer tool has been replaced by Ryan's custom pdf composer api that is currently hosted by UW integrations, and has neither of those limitations. (2) "Recommendations exist with multiple attachments" is simply unecessary. It is okay if a recommendation has more than 1 attachment. 



