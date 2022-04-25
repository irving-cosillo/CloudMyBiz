import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { publish, MessageContext } from 'lightning/messageService';
import refreshPageChannel from '@salesforce/messageChannel/refreshPage__c';
import COMMISSION_OBJECT from '@salesforce/schema/Commission__c';

export default class AddSalesAgent extends LightningElement {
    @api recordId; 
    fields = {};
    
    @wire(MessageContext)
    messageContext;
    
    handleSubmit(event) {
        event.preventDefault();
    }

    handleChange(event){
        const { fieldName, value } = event.target;
        const fields = {...this.fields};
        fields[fieldName] = value;
        this.fields = fields;
    }

    add(){
        const fields = {...this.fields};
        fields.Opportunity__c = this.recordId;
        this.template.querySelectorAll('lightning-input-field').forEach(field => { 
            if( field.fieldName === 'Default_Rate__c') {
                fields.Rate__c = field.value * 1;
            }
        });

        if(fields.Sales_Agent__c && fields.Rate__c != undefined){
            createRecord({ apiName: COMMISSION_OBJECT.objectApiName, fields })
                .then(() => {
                    this.cancel();
                    publish(this.messageContext, refreshPageChannel);
                    this.dispatchEvent( new ShowToastEvent({
                        title: 'Success',
                        message: 'Agent successfully added.',
                        variant: 'success',
                    }));
                })
                .catch(error => {
                    console.error(error);
                    this.dispatchEvent( new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.output?.errors ? error.body.output.errors[0].message : error.body.message,
                        variant: 'error',
                    }));
                });
        } else {
            this.dispatchEvent( new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Missing required fields.',
            }));
        }
    }

    cancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}