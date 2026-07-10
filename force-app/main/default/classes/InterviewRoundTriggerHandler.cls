public class InterviewRoundTriggerHandler {
    
    public static void updateApplicationStatus(List<Interview_Round__c> newRounds) {
        Set<Id> applicationIds = new Set<Id>();
        for (Interview_Round__c round : newRounds) {
            if (round.Application__c != null) {
                applicationIds.add(round.Application__c);
            }
        }
        
        if (applicationIds.isEmpty()) return;
        
        Map<Id, List<Interview_Round__c>> appToRoundsMap = new Map<Id, List<Interview_Round__c>>();
        for (Interview_Round__c r : [
            SELECT Id, Application__c, Result__c 
            FROM Interview_Round__c 
            WHERE Application__c IN :applicationIds
        ]) {
            if (!appToRoundsMap.containsKey(r.Application__c)) {
                appToRoundsMap.put(r.Application__c, new List<Interview_Round__c>());
            }
            appToRoundsMap.get(r.Application__c).add(r);
        }
        
        List<Application__c> applicationsToUpdate = new List<Application__c>();
        
        for (Id appId : appToRoundsMap.keySet()) {
            List<Interview_Round__c> rounds = appToRoundsMap.get(appId);
            Boolean allPassed = true;
            Boolean anyFailed = false;
            
            for (Interview_Round__c r : rounds) {
                if (r.Result__c == 'Fail') {
                    anyFailed = true;
                    allPassed = false;
                } else if (r.Result__c != 'Pass') {
                    allPassed = false;
                }
            }
            
            Application__c appToUpdate = new Application__c(Id = appId);
            if (anyFailed) {
                appToUpdate.Status__c = 'Rejected';
                applicationsToUpdate.add(appToUpdate);
            } else if (allPassed && !rounds.isEmpty()) {
                appToUpdate.Status__c = 'Offered';
                applicationsToUpdate.add(appToUpdate);
            }
        }
        
        if (!applicationsToUpdate.isEmpty()) {
            update applicationsToUpdate;
        }
    }
}