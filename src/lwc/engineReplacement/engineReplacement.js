import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin} from 'lightning/navigation';
import selectEngine  from '@salesforce/apex/EngineReplacementsController.SelectengineReplaceAsset';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';


export default class EngineReplacement extends NavigationMixin(LightningElement) {

    // @api recordId;
    // @track fieldMapping = [];



    // @wire(getObjectInfo, { objectApiName: 'EngineReplacement__c' })
    // getObjectInfo({ error, data }) {

    //     if (data) {
    //         const engineFieldNames = Object.keys(data.fields);
    //         console.log('engineFieldNames :::', JSON.stringify(engineFieldNames));
    //         // this.fieldNames는 엔진 관련
    //         createRecord(recordInput)
    //         selectEngine({recordId:this.recordId})
    //         .then((assets) => {
    //             if (assets) {
    //                 const asset = assets[0];
    //                 const assetId = asset.Id;
    //                 const assetDealership = asset.AccountId;
    //                 const assetEngineSerialNumber = asset.EngineSerialNumber__c;
    //                 const assetSerialNumber = asset.SerialNumber;

    //                 const excludedFields = [
    //                     'CreatedById',
    //                     'CreatedDate',
    //                     'RecordTypeId',
    //                     'Deleted',
    //                     'LastActivityDate',
    //                     'LastModifiedById',
    //                     'LastModifiedDate',
    //                     'LastReferencedDate',
    //                     'LastViewedDate',
    //                     'EngineReplacementNo__c',
    //                     'OwnerId',
    //                     'SystemModstamp',
    //                     'Record ID',
    //                     'IsDeleted',
    //                     'Engine Replacement No.',
    //                     'Id',
    //                     'Name'
    //                 ];

    //                 this.fieldMapping = engineFieldNames
    //                 .filter(engineField => !excludedFields.includes(engineField))
    //                 .map(engineField => {
    //                     if (engineField === 'AssetId__c') {
    //                         return { fieldName: engineField, value: assetId};
    //                     } else if (engineField === 'DealershipID__c') {
    //                         return { fieldName: engineField, value: assetDealership};
    //                     } else if (engineField === 'EngineSerialNumber__c') {
    //                         return { fieldName: engineField, value: assetEngineSerialNumber};
    //                     } else if (engineField === 'Machine_Serial_Number__c') {
    //                         return { fieldName: engineField, value: assetSerialNumber};

    //                     } else {
    //                         return { fieldName: engineField, value: null }; // 다른 필드의 경우, null 또는 적절한 기본값으로 설정
    //                     }
    //                 });

    //                 console.log('Field Mapping:', JSON.stringify(this.fieldMapping));
    //             }
    //         })
    //         .catch((error) => {
    //             this.error = error;
    //             console.log('에러 :: ', JSON.stringify(error));
    //         });

    //     } else if (error) {
    //         console.error('Error fetching object info', JSON.stringify(error));
    //     }

    // }

    // handleSuccess(event){
    //     console.log('버튼 눌림');
    //     const evt = new ShowToastEvent({
    //         title: 'Success Message',
    //         message: 'Record Created successfully ',
    //         variant: 'success'
    //     });
    //     this.dispatchEvent(evt);
    //     window.location.reload();
    // }



    


}