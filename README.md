Recruitment & Placement Management System (Salesforce)

A custom Salesforce application that automates the candidate recruitment pipeline — from job posting to interview scheduling to final offer/rejection decisions — built to demonstrate Apex trigger design, asynchronous processing, and clean data modeling on the Salesforce Platform.

Overview

This project models a real-world campus/corporate recruitment workflow using custom objects, automated Apex triggers, and scheduled/asynchronous jobs. It was built as a hands-on application of Salesforce Platform Developer I (PD-1) concepts.

Data Model

| Object | Purpose |
|---|---|
| `Job_Opening__c` | Represents an open position (title, department, location, number of openings) |
| `Candidate__c` | Stores candidate profile information (skills, CGPA, contact details) |
| `Application__c` | Links a Candidate to a Job Opening; tracks overall application status |
| `Interview_Round__c` | Represents individual interview rounds (Aptitude, Technical, HR, Managerial) tied to an Application |

Relationships:
- Candidate → Application (1:many)
- Job Opening → Application (1:many)
- Application → Interview Round (1:many)
Key Features

1. Automated Status Updates (Apex Trigger)
`InterviewRoundTrigger` + `InterviewRoundTriggerHandler` automatically updates an Application's status based on its related Interview Round outcomes:
- If any round is marked `Fail` → Application status becomes `Rejected`
- If all rounds are marked `Pass` → Application status becomes `Offered`
- If rounds are still `Pending` → status remains unchanged

The handler is fully bulkified — it collects Application Ids into a Set, runs a single SOQL query outside any loop, and performs a single bulk DML update, so it safely handles batches of any size without hitting governor limits.

2. Automated Interview Reminders (Queueable + Scheduled Apex)
`InterviewReminderQueueable` queries for interview rounds scheduled for the next day and sends reminder emails to candidates. `DailyInterviewReminderScheduler` implements the `Schedulable` interface to trigger this job automatically on a daily cron schedule.

3. Test Coverage
`InterviewRoundTriggerHandlerTest` includes:
- Positive case — all rounds pass → Offered
- Negative case — one round fails → Rejected
- Edge case — round still pending → status unchanged
- Bulk case — 200 records inserted/updated in a single transaction to verify bulkification

Achieves 100% code coverage on both the trigger and handler class.

Tech Stack
- Apex (Triggers, Classes, Queueable, Schedulable)
- SOQL
- Salesforce Custom Objects & Relationships
- Lightning Web Components (LWC) — pipeline dashboard

What I Learned
Building this project surfaced a real debugging scenario: interview round records were initially linked to the wrong parent Application due to a lookup field not being explicitly reselected during manual data entry. This was diagnosed using Salesforce Debug Logs and Trace Flags, and resolved by auditing each record's lookup relationships — a good reminder that data integrity issues can silently break automation even when the underlying Apex logic is correct.

Author
Yash Vyas — B.Tech CSE (AIML), Salesforce Certified Platform Developer I (PD-1)
