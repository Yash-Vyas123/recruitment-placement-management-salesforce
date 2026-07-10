trigger InterviewRoundTrigger on Interview_Round__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            InterviewRoundTriggerHandler.updateApplicationStatus(Trigger.new);
        }
    }
}