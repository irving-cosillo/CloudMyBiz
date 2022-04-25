import { LightningElement, api } from 'lwc';

export default class CommissionsLine extends LightningElement {
    @api commission;
    rate;
    amount;

    get agentName(){
        return this.commission?.Sales_Agent__r?.Name;
    }

    get defaultRate(){
        return this.commission?.Sales_Agent__r?.Default_Rate__c / 100;
    }

    get opportunityRate(){
        this.rate = this.commission?.Rate__c / 100
        return this.rate;
    }

    get commissionAmount(){
        this.amount = this.rate * this.commission?.Opportunity__r?.Amount;
        return this.amount;
    }

    handleChange(event){
        this.rate = event.detail.value * 100;
        const commission = {...this.commission};
        commission.Rate__c = this.rate;
        this.dispatchEvent(new CustomEvent('commissionchange', { 
            detail: { 
                commission
            }
        }));
    }

    handleDelete(){
        this.dispatchEvent(new CustomEvent('commissiondelete', { 
            detail: { 
                Id : this.commission.Id
            }
        }));
    }
}