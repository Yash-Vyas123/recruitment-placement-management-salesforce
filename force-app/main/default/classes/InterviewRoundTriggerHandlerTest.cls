@isTest
public class InterviewRoundTriggerHandlerTest {
    
    private static Application__c createTestApplication() {
        Candidate__c cand = new Candidate__c(
            Name = 'Test Candidate',
            Email_c__c = 'test@example.com',
            College_c__c = 'Test College',
            CGPA_c__c = 8.0
        );
        insert cand;
        
        Job_Opening__c job = new Job_Opening__c(
            Job_Title_c__c = 'Test Role',
            Department_c__c = 'IT',
            Status_c__c = 'Open',
            Openings_c__c = 1
        );
        insert job;
        
        Application__c app = new Application__c(
            Candidate__c = cand.Id,
            Job_Opening__c = job.Id,
            Status__c = 'Interviewing'
        );
        insert app;
        
        return app;
    }
    
    @isTest
    static void testAllRoundsPass_StatusBecomesOffered() {
        Application__c app = createTestApplication();
        
        Interview_Round__c round1 = new Interview_Round__c(
            Application__c = app.Id,
            Round_Name__c = 'Aptitude',
            Result__c = 'Pending'
        );
        insert round1;
        
        Test.startTest();
        round1.Result__c = 'Pass';
        update round1;
        Test.stopTest();
        
        Application__c updatedApp = [SELECT Status__c FROM Application__c WHERE Id = :app.Id];
        System.assertEquals('Offered', updatedApp.Status__c, 'Application should be Offered when round passes');
    }
    
    @isTest
    static void testOneRoundFails_StatusBecomesRejected() {
        Application__c app = createTestApplication();
        
        Interview_Round__c round1 = new Interview_Round__c(
            Application__c = app.Id,
            Round_Name__c = 'Aptitude',
            Result__c = 'Pass'
        );
        insert round1;
        
        Interview_Round__c round2 = new Interview_Round__c(
            Application__c = app.Id,
            Round_Name__c = 'Technical',
            Result__c = 'Pending'
        );
        insert round2;
        
        Test.startTest();
        round2.Result__c = 'Fail';
        update round2;
        Test.stopTest();
        
        Application__c updatedApp = [SELECT Status__c FROM Application__c WHERE Id = :app.Id];
        System.assertEquals('Rejected', updatedApp.Status__c, 'Application should be Rejected when any round fails');
    }
    
    @isTest
    static void testPendingRound_StatusUnchanged() {
        Application__c app = createTestApplication();
        
        Interview_Round__c round1 = new Interview_Round__c(
            Application__c = app.Id,
            Round_Name__c = 'Aptitude',
            Result__c = 'Pending'
        );
        
        Test.startTest();
        insert round1;
        Test.stopTest();
        
        Application__c updatedApp = [SELECT Status__c FROM Application__c WHERE Id = :app.Id];
        System.assertEquals('Interviewing', updatedApp.Status__c, 'Application status should remain unchanged while round is Pending');
    }
    
    @isTest
    static void testBulkInsert_200Records() {
        List<Candidate__c> candidates = new List<Candidate__c>();
        for (Integer i = 0; i < 200; i++) {
            candidates.add(new Candidate__c(
                Name = 'Bulk Candidate ' + i,
                Email_c__c = 'bulk' + i + '@example.com',
                CGPA_c__c = 7.5
            ));
        }
        insert candidates;
        
        Job_Opening__c job = new Job_Opening__c(
            Job_Title_c__c = 'Bulk Test Role',
            Department_c__c = 'IT',
            Status_c__c = 'Open',
            Openings_c__c = 200
        );
        insert job;
        
        List<Application__c> applications = new List<Application__c>();
        for (Candidate__c c : candidates) {
            applications.add(new Application__c(
                Candidate__c = c.Id,
                Job_Opening__c = job.Id,
                Status__c = 'Interviewing'
            ));
        }
        insert applications;
        
        List<Interview_Round__c> rounds = new List<Interview_Round__c>();
        for (Application__c a : applications) {
            rounds.add(new Interview_Round__c(
                Application__c = a.Id,
                Round_Name__c = 'Aptitude',
                Result__c = 'Pending'
            ));
        }
        insert rounds;
        
        Test.startTest();
        for (Interview_Round__c r : rounds) {
            r.Result__c = 'Pass';
        }
        update rounds;
        Test.stopTest();
        
        List<Application__c> updatedApps = [SELECT Status__c FROM Application__c WHERE Id IN :applications];
        for (Application__c a : updatedApps) {
            System.assertEquals('Offered', a.Status__c, 'All 200 applications should be Offered');
        }
    }
}