/*************************************************************
 * @author : th.kim
 * @date : 2023-12-27
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-27      th.kim         Initial Version
**************************************************************/ 
import { LightningElement, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getNews from '@salesforce/apex/TYM_NewsHomeController.getNews';

export default class TymNewsHome extends NavigationMixin(LightningElement) {

    @track listReturn = [];

    connectedCallback() {
        getNews().then(res => {
            console.log('res :: ',res);
            this.listReturn = JSON.parse(res);
        }).catch(err => {
            console.log('err :: ',err);
        });
    }

    onContentsClick(e) {
        const id = e.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'tymNewsDetail__c'
            },
            state: {
                recordId: id
            }
        });
    }

    onShowMoreButton() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'TymNews__c'
            }
        });
    }
}