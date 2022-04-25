@IsTest
public with sharing class OpportunityTriggerHelperTest {
    @TestSetup 
    static void setup(){
        Account account = new Account(Name='Jhon Doe');
        insert account;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Jhon Doe';
        opportunity.AccountId = account.Id;
        opportunity.StageName = 'New';
        opportunity.Amount = 1000;
        opportunity.CloseDate = System.today()+10;
        insert opportunity;

        Sales_Agent__c agent = new Sales_Agent__c();
        agent.Default_Rate__c = 5;
        agent.Name = 'Will Smith';
        insert agent;

        Commission__c commission = new Commission__c();
        commission.Opportunity__c = opportunity.Id;
        commission.Sales_Agent__c = agent.Id;
        commission.Rate__c = 7;
        insert commission;
    }

    @IsTest 
    static void testUpdateOpportunity() {
        Test.startTest();
        Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Jhon Doe' LIMIT 1];
        opportunity.StageName = 'Completed Won';
        update opportunity;
        Sales_Agent__c agent = [SELECT Completed_Commission_Amount__c FROM Sales_Agent__c WHERE Name = 'Will Smith'];
        System.assertEquals(70, agent.Completed_Commission_Amount__c, 'Agent does not have the correct commission.');
        Test.stopTest();
    }
}
