public with sharing class CommissionTriggerHelper {

    private static Set<Id> getOpportunitiesId(List<Commission__c> commissions){
        Set<Id> opportunitiesId = new Set<Id>();
        for(Commission__c commission : commissions){
            opportunitiesId.add(commission.Opportunity__c);
        }
        return opportunitiesId;
    }

    public static void validateTotalRateAmount(List<Commission__c> commissions){
        Set<Id> opportunitiesId = getOpportunitiesId(commissions);
    
        List<aggregateResult> results = [
            SELECT 
                SUM(Rate__c) totalRate, 
                Opportunity__c
            FROM Commission__c 
            WHERE Opportunity__c IN : opportunitiesId
            GROUP BY Opportunity__c
            HAVING SUM(Rate__c) > 100
        ];

        for (aggregateResult result : results){
            for (Commission__c commission : commissions){
                if (result.get('Opportunity__c') == commission.Opportunity__c){
                    commission.addError('The sum of all rates from this opportunity exceeds 100%');
                }
            }
        }
    }

    public static void validateDuplicates(List<Commission__c> commissions){
        Set<Id> opportunitiesId = getOpportunitiesId(commissions);
    
        List<aggregateResult> results = [
            SELECT 
                COUNT(Id),
                Opportunity__c,
                Sales_Agent__c
            FROM Commission__c
            WHERE Opportunity__c IN : opportunitiesId
            GROUP BY Opportunity__c, Sales_Agent__c
            HAVING COUNT(Id) > 1
        ];

        for (aggregateResult result : results){
            for (Commission__c commission : commissions){
                if (result.get('Opportunity__c') == commission.Opportunity__c && result.get('Sales_Agent__c') == commission.Sales_Agent__c){
                    commission.addError('Agent can\'t be added twice on the same opportunity');
                }
            }
        }
    }

    public static void updateAgentsCommission(List<Commission__c> commissions){
        OpportunityTriggerHelper.OpportunityTriggerHelper(getOpportunitiesId(commissions));
    }
}
