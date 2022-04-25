trigger CommissionTrigger on Commission__c (after update, after insert, after delete) 
{
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            CommissionTriggerHelper.validateTotalRateAmount(Trigger.new);
        }
        if(Trigger.isInsert){
            CommissionTriggerHelper.validateDuplicates(Trigger.new);
        }
        
        if (Trigger.isDelete){
            CommissionTriggerHelper.updateAgentsCommission(Trigger.old);
        } else {
            CommissionTriggerHelper.updateAgentsCommission(Trigger.new);
        }
    }
}