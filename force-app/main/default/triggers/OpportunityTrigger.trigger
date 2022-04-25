trigger OpportunityTrigger on Opportunity (after update) {
    if( Trigger.isAfter && Trigger.isUpdate){
        System.debug('@@@ opps: ' + Trigger.newMap);
        OpportunityTriggerHelper.updateOpportunity(Trigger.newMap);
    }
}