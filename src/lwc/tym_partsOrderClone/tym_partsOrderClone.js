import { LightningElement, api, track } from 'lwc';
import partOrderClone from '@salesforce/apex/TYM_PartsOrderCloneController.partsOrderClone';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Tym_partsOrderClone extends NavigationMixin(LightningElement) {

    @api recordId;
    error;
    @track inputPONum;
    @track isLoading = false;
    

    
    onSubmitSave(e) {
        this.isLoading = true;
        
        const inputNumField = this.template.querySelector('[data-num]').value;

        this.inputPONum = inputNumField;

        console.log('this.inputPONum:::::', this.inputPONum);


        const partsOrderMap = {
            'poNum' : this.inputPONum
        }

        partOrderClone({recordId : this.recordId, partsOrderMap : partsOrderMap})
            .then(result => {
                console.log('result:::: ', result);
                this.isLoading = false;
                this.ShowToast('Success', 'This is an success message', 'success', 'dismissable');

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.Id,
                        actionName: 'view',
                    },
                });

            }).catch(error=> {
                this.error = error;
                this.isLoading = false;
                this.ShowToast('Error', 'Error!!!', 'error', 'dismissable');

            })

    };


    handleInputNumberChange(e) {
        this.inputPONum = e.target.value;
        console.log('this.inputPONum::', this.inputPONum);
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