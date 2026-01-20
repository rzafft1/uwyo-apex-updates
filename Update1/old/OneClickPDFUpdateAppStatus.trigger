trigger OneClickPDFUpdateAppStatus on Attachment (after update, after insert, after delete) {
    
    if(Trigger.isAfter && Trigger.isInsert || Trigger.isUpdate){
        OneClickPDFUpdateAppStatusHandler.handleAfterInsertUpdateandDelete(Trigger.new);
    }
    else if (Trigger.isAfter && Trigger.isDelete){
        System.debug(' trigger is after and trigger is delete ');
        OneClickPDFUpdateAppStatusHandler.handleAfterInsertUpdateandDelete(Trigger.old);
    }
}