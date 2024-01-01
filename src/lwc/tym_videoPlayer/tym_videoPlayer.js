/*************************************************************
 * @author : th.kim
 * @date : 2023-11-29
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-29      th.kim         Initial Version
**************************************************************/
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getUrl from '@salesforce/apex/TYM_VideoPlayerController.getUrl';

export default class TymVideoPlayer extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    recordId;
    url;

    connectedCallback() {
        this.recordId = this.pageRef.attributes.recordId;
        getUrl({recordId: this.recordId}).then(res => {
            console.log('res :: ',res);
            this.url = res;
        }).catch(err => {
            console.log('err :: ',err);
        });
    }
}