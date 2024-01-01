/*************************************************************
 * @author : th.kim
 * @date : 2023-11-20
 * @group : 
 * @group-content :
 * @description : 
==============================================================
  * Ver       Date            Author            Modification
    1.0       2023-11-20      th.kim            Initial Version
**************************************************************/ 
import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import callBatch from '@salesforce/apex/TYM_RetailProgramBatchController.callBatch';

export default class TymRetailProgramBatchCall extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    isLoading = false;
    
    connectedCallback() {
        this.recordId = this.pageRef.state.recordId;
        console.log('recordId :: ',this.recordId);
    }
    
    handleBatchCall() {
        this.isLoading = true;
        callBatch({recordId : this.recordId}).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({title: '', message: 'Closed', variant: 'success'})
            );
            this.dispatchEvent(new CloseActionScreenEvent());
            this.isLoading = false;
        }).catch(err => {
            console.log('err :: ',err);
            this.dispatchEvent(
                new ShowToastEvent({title: '', message: err.body.message, variant: 'warning'})
            );
            this.isLoading = false;
        });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}