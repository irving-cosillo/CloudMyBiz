import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, MessageContext } from 'lightning/messageService';
import refreshPageChannel from '@salesforce/messageChannel/refreshPage__c';
import getCommissionsByOpportunity from '@salesforce/apex/CommissionUtility.getCommissionsByOpportunity';
import updateCommissions from '@salesforce/apex/CommissionUtility.updateCommissions';
import deleteCommission from '@salesforce/apex/CommissionUtility.deleteCommission';

export default class CommissionsPanel extends LightningElement {
    @api recordId;

    loading;
    commissions;
    displayCommissions;
    displaySaveButtons;

    get title(){
        return `Commissions (${this.commissions?.length * 1})`;
    }
    
    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.refresh();
        subscribe(
            this.messageContext,
            refreshPageChannel, 
            () => {
                this.refresh();
            }
        );
    }
    
    refresh(){
        this.loading = true;
        this.commissions = [];
        this.displaySaveButtons = false;
        getCommissionsByOpportunity({ opportunityId : this.recordId}).then( commissions => {
            this.commissions = commissions;
            this.displayCommissions = commissions.length > 0;
        }).catch( error => {
            console.error(error);
            this.dispatchEvent( new ShowToastEvent({
                title: 'Error',
                message: error.body?.output?.errors ? error.body.output.errors[0].message : error.body.message,
                variant: 'error',
            }));
        }).finally(()=> {
            this.loading = false;
        })
    }

    handleChange(event){
        this.displaySaveButtons = true;
        const commissionChange = JSON.parse(JSON.stringify(event.detail.commission));
        this.commissions.find( commission => commission.Id === commissionChange.Id ).Rate__c = commissionChange.Rate__c;
    }

    handleDelete(event){
        deleteCommission({ commissionId : event.detail.Id }).then( ()=>{
            this.refresh();
            this.dispatchEvent( new ShowToastEvent({
                title: 'Success',
                message: 'Agent successfully deleted.',
                variant: 'success',
            }));
        }).catch( error => {
            console.error(error);
            this.dispatchEvent( new ShowToastEvent({
                title: 'Error',
                message: error.body?.output?.errors ? error.body.output.errors[0].message : error.body.message,
                variant: 'error',
            }));
        })
    }

    handleSave(){
        const commissions = JSON.parse(JSON.stringify(this.commissions));
        updateCommissions({ commissions }).then( ()=> {
            this.refresh();
            this.dispatchEvent( new ShowToastEvent({
                title: 'Success',
                message: 'Agents rate successfully updated.',
                variant: 'success',
            }));
        }).catch( error => {
            console.error(error);
            this.dispatchEvent( new ShowToastEvent({
                title: 'Error',
                message: error.body?.pageErrors ? error.body.pageErrors[0].message : error.body.message,
                variant: 'error',
            }));
        })
    }
}