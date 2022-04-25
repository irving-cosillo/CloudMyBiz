public with sharing class OpportunityTriggerHelper {
    public static void updateOpportunity(Map<Id, Opportunity> opportunities){
        updateAgentsCommission(opportunities.keySet());
    }

    public static void updateAgentsCommission(Set<Id> opportunitiesId){
        List<Sales_Agent__c> agents = [
            SELECT 
                Name, 
                (SELECT 
                    Rate__c,
                    Opportunity__r.Amount, 
                    Opportunity__r.StageName
                FROM Commissions__r) 
            FROM Sales_Agent__c
        ];

        Decimal totalPendingCommission;
        Decimal totalCompletedCommission;

        for(Sales_Agent__c agent : agents){
            totalPendingCommission = 0;
            totalCompletedCommission = 0;
            for(Commission__c commission : agent.Commissions__r){
                if(commission.Opportunity__r.StageName == 'Pending'){
                    totalPendingCommission += commission.Rate__c/100 * commission.Opportunity__r.Amount;
                } else if(commission.Opportunity__r.StageName == 'Completed Won'){
                    totalCompletedCommission += commission.Rate__c/100 * commission.Opportunity__r.Amount;
                }
            }
            agent.Pending_Commission_Amount__c = totalPendingCommission;
            agent.Completed_Commission_Amount__c = totalCompletedCommission;
        }

        update agents;
    }
}
