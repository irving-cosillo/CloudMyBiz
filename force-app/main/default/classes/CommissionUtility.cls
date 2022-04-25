public with sharing class CommissionUtility {
    @AuraEnabled
    public static List<Commission__c> getCommissionsByOpportunity(Id opportunityId){
        return [
            SELECT
                Rate__c,
                Sales_Agent__c,
                Sales_Agent__r.Name,
                Sales_Agent__r.Default_Rate__c,
                Opportunity__r.Amount,
                Opportunity__r.StageName
            FROM Commission__c
            WHERE Opportunity__c =: opportunityId
        ];
    }

    @AuraEnabled
    public static void deleteCommission(Id commissionId){
        Commission__c commission = [SELECT Id FROM Commission__c WHERE Id =: commissionId];
        delete commission;
    }

    @AuraEnabled
    public static void updateCommissions(List<Commission__c> commissions){
        update commissions;
    }
}
