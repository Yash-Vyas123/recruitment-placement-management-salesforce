public class InterviewReminderQueueable implements Queueable {
    
    public void execute(QueueableContext context) {
        Date tomorrow = Date.today().addDays(1);
        
        List<Interview_Round__c> upcomingRounds = [
            SELECT Id, Round_Name__c, Round_Date__c, Interviewer__c,
                   Application__r.Candidate__r.Name, 
                   Application__r.Candidate__r.Email_c__c,
                   Application__r.Job_Opening__r.Job_Title_c__c
            FROM Interview_Round__c
            WHERE Round_Date__c = :tomorrow
            AND Result__c = 'Pending'
        ];
        
        if (upcomingRounds.isEmpty()) {
            System.debug('No interviews scheduled for tomorrow.');
            return;
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Interview_Round__c round : upcomingRounds) {
            if (round.Application__r.Candidate__r.Email_c__c != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { round.Application__r.Candidate__r.Email_c__c });
                email.setSubject('Interview Reminder: ' + round.Round_Name__c + ' Round Tomorrow');
                email.setPlainTextBody(
                    'Dear ' + round.Application__r.Candidate__r.Name + ',\n\n' +
                    'This is a reminder that your ' + round.Round_Name__c + ' interview round for the ' +
                    round.Application__r.Job_Opening__r.Job_Title_c__c + ' position is scheduled for tomorrow (' +
                    round.Round_Date__c.format() + ').\n\n' +
                    'Best of luck!\n\nRecruitment Team'
                );
                emailsToSend.add(email);
            }
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}