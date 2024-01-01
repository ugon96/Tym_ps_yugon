/*************************************************************
 * @author : th.kim
 * @date : 2023-12-20
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-20      th.kim         Initial Version
**************************************************************/ 
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getNewsInfo from '@salesforce/apex/TYM_NewsDetailController.getNewsInfo';

export default class TymNewsDetail extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;
    recordId;
    @track news = [];
    @track formatDate;

    connectedCallback() {
        this.recordId = this.pageRef.state.recordId;
        getNewsInfo({recordId: this.recordId}).then(res => {
            console.log('res :: ',res);
            this.news = res.news;
            this.formatDate = res.formatDate;
        }).catch(err => {
            console.log('err :: ',err);
        });
    }

    onHomeClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    onNewsClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'TymNews__c'
            }
        });
    }
}