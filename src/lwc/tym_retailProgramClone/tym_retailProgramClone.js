import { LightningElement, api, track } from 'lwc';
import retailProgramClone from '@salesforce/apex/TYM_retailProgramCloneController.retailProgramClone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Tym_retailProgramClone extends NavigationMixin(LightningElement) {

    @api recordId;
    @track inputName;
    @track inputStartDate;
    @track inputEndDate;
    @track isLoading = false;

    onSubmitSave(e) {

        this.isLoading = true;

        const inputNameField = this.template.querySelector('[data-name]').value;
        const startDateField = this.template.querySelector('[data-start]').value;
        const endDateField = this.template.querySelector('[data-end]').value;
        console.log('inputNameFieldinputNameFieldinputNameField::', inputNameField);
        console.log('inputNameFieldinputNameFieldinputNameField::', startDateField);
        console.log('inputNameFieldinputNameFieldinputNameField::', endDateField);


        this.inputName = inputNameField;
        this.inputStartDate = startDateField;
        this.inputEndDate = endDateField;

        // console.log('11111111this.inputName :::' , this.inputName);
        // console.log('11111111this.inputName :::' , this.inputStartDate);
        // console.log('11111111this.inputName :::' , this.inputEndDate);

        const retailData = {
            'name' : this.inputName,
            'startDate' : this.inputStartDate, 
            'endDate' : this.inputEndDate
        };

        retailProgramClone({recordId:this.recordId, retailMap : retailData})
            .then(result => {
                // console.log('t3est:::::::::', e.detail);
                // const fields = e.detail.fields;
                // console.log('t3est:::::::::', fields);

                console.log('result::::', result);
                this.isLoading = false;
                this.ShowToast('Success', 'This is an success message', 'success', 'dismissable');

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.Id,
                        actionName: 'view',
                    },
                });

            }).catch((error) => {
                this.error = error;
                console.log('error :::::' , error , '::::::::'  , error.message);
                this.isLoading = false;
                this.ShowToast('Error', 'Set the Start Date and End Date not to overlap when the program type is volume incentive and the Pricing Structure is dynamic', 'error', 'dismissable');

            });

    }

    handleInputNameChange(e) {
        this.inputName = e.target.value;
        console.log('this.inputName::::::', this.inputName);
    }
    
    handleInputStartDateChange(e) {
        this.inputStartDate = e.target.value;
        console.log('this.inputStartDate::::::', this.inputStartDate);
    }
    
    handleInputEndDateChange(e) {
        this.inputEndDate = e.target.value;
        console.log('this.inputEndDat::::::', this.inputEndDate);
    }

    handleCancel(e){
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
        }
    

}