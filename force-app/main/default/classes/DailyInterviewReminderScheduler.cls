public class DailyInterviewReminderScheduler implements Schedulable {
    
    public void execute(SchedulableContext context) {
        System.enqueueJob(new InterviewReminderQueueable());
    }
}