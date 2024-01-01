/*************************************************************
 * @author : th.kim
 * @date : 2023-11-24
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver        Date        Author        Modification
   1.0                    Initial Version
**************************************************************/
import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPathStatus from '@salesforce/apex/TYM_CustomPathController.getPathStatus';

export default class TymCustomPath extends LightningElement {

    @wire(CurrentPageReference) pageRef;
    recordId;
    objectName;
    @track statusList = [];
    statusValue;
    isClaim;
    isSubmitted;
    isAccordion;
    isPhotoHourMeter__c;
    isPhotoSerialNo__c;
    isPhotoRepair__c;
    isPhotoFailurePart__c;

    connectedCallback() {
        console.log(this.pageRef);
        this.recordId = this.pageRef.attributes.recordId;
        getPathStatus({ recordId: this.recordId }).then(res => {
            console.log('res :: ', res);
            this.statusList = JSON.parse(res.pickList);
            this.statusValue = res.status;
            this.statusList.forEach(el => {
                if ((this.statusValue == 'Rejected' && el.value == 'Closed') || (this.statusValue == 'Canceled' && el.value == 'Closed')) {
                    el.isView = false;
                } else if ((this.statusValue == 'Rejected' && el.value == 'Rejected') || (this.statusValue == 'Canceled' && el.value == 'Canceled')) {
                    el.isView = true;
                } else if (el.value == 'Rejected' || el.value == 'Canceled') {
                    el.isView = false;
                } else {
                    el.isView = true;
                }
            });
            const claim = res.case;
            if(claim.Id) {
                this.isClaim = true;
                this.isPhotoHourMeter__c = claim.IsPhotoHourMeter__c;
                this.isPhotoSerialNo__c = claim.IsPhotoSerialNo__c;
                this.isPhotoRepair__c = claim.IsPhotoRepair__c;;
                this.isPhotoFailurePart__c = claim.IsPhotoFailurePart__c;
            }

            // 렌더링 후 처리하기 위한 비동기 처리
            setTimeout(() => {
                let active = this.template.querySelectorAll('lightning-progress-step');
                active.forEach(el => {
                    if (el.value == this.statusValue) {
                        el.classList.remove('slds-is-current');
                        el.classList.add('slds-is-active');
                    }
                });
            }, 0);
        }).catch(err => {
            console.log('err :: ', err);
        });
    }

    /** Claim일 때 Key Field 보기 버튼 */
    handleShowMore(e) {
        console.log(e.currentTarget.classList);
        if(this.isAccordion) {
            this.isAccordion = false;
            e.currentTarget.classList.add('non-active');
        }
        else {
            this.isAccordion = true;
            e.currentTarget.classList.remove('non-active');
        }
    }

    /** Path 클릭 시 Submitted일 때 아코디언 활성화 */
    handlePathClick(e) {
        if(e.target.value == 'Submitted') {
            this.isSubmitted = true;
        } else {
            this.isSubmitted = false;
            this.isAccordion = false;
        }
    }
}