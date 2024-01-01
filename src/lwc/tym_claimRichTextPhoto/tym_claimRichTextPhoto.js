/*************************************************************
 * @author : th.kim
 * @date : 2023-10-11
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver Date Author Modification
 1.0    Initial Version
**************************************************************/

import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFiles from '@salesforce/apex/TYM_ClaimRichTextPhotoController.uploadFiles';
import getImageList from '@salesforce/apex/TYM_ClaimRichTextPhotoController.getImageList';

export default class TymClaimRichTextPhoto extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    @track fileData1 = [];
    @track fileData2 = [];
    @track fileData3 = [];
    @track fileData4 = [];
    @track Photo_of_Hour_Meter = [];
    @track Photo_of_Serial_Number = [];
    @track Photo_of_Tractor_during_repair = [];
    @track Photo_of_failure_part = [];
    fileSize1 = 0;
    fileSize2 = 0;
    fileSize3 = 0;
    successLength = 0;
    fileAcceptType = ['.jpg', '.jpeg', '.png']; // 파일 형식
    isLoading = false;
    isEditable = true;
    errMessage;

    connectedCallback() {
        this.recordId = this.pageRef.attributes.recordId;
        getImageList({ recordId: this.recordId }).then(res => {
            console.log('res :: ', res);
            const status = res.case[0].Status;
            if (status != 'Created' && status != 'Submitted') {
                this.isEditable = false;
            }
            const basicUrl = '/sfc/servlet.shepherd/version/download/';
            if (res.PhotOf0HourMeter__c) this.Photo_of_Hour_Meter = { name: res.PhotOf0HourMeter__c[0].ContentVersion.Title, url: /* basicUrl +  */res.PhotOf0HourMeter__c[0].ContentDownloadUrl };
            if (res.PhotoOfSerialNumber__c) this.Photo_of_Serial_Number = { name: res.PhotoOfSerialNumber__c[0].ContentVersion.Title, url: /* basicUrl +  */res.PhotoOfSerialNumber__c[0].ContentDownloadUrl };
            if (res.PhotoTractoDuringRepair__c) {
                res.PhotoTractoDuringRepair__c.forEach(el => {
                    this.Photo_of_Tractor_during_repair.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.PhotoFailurePart__c) {
                res.PhotoFailurePart__c.forEach(el => {
                    this.Photo_of_failure_part.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
        }).catch(err => {
            console.log('err :: ', err);
        });
    }

    /** Upload Files onChange() 함수 */
    onFileUpload(e) {
        const label = e.target.label;
        if (label == 'Photo of Tractor during repair') this.fileData3 = [];
        if (label == 'Photo of failure part') this.fileData4 = [];
        const fileMaxSize = 3000000;
        let fileSize = 0;
        let files = e.target.files;
        for (let i = 0; i < files.length; i++) {
            let file = files[i];
            fileSize += file.size;
            if (fileSize > fileMaxSize) {
                this.dispatchEvent(
                    new ShowToastEvent({ title: '', message: 'Check File Size', variant: 'warning' })
                );
            } else {
                let fileLength = file.name.length;
                let fileNameExt = file.name.lastIndexOf(".");
                let fileExtType = '.' + file.name.substring(fileNameExt + 1, fileLength).toLowerCase(); // 파일 확장자 가져오기
                if (this.fileAcceptType.includes(fileExtType)) {
                    let fileReader = new FileReader();
                    fileReader.onload = (reader) => {
                        let base64 = reader.target.result.split(',')[1];
                        switch (label) {
                            case 'Photo of Hour Meter':
                                this.fileData1 = [{ 'fileName': file.name, 'base64': base64, 'fieldLabel': label }];
                                break;
                            case 'Photo of Serial Number':
                                this.fileData2 = [{ 'fileName': file.name, 'base64': base64, 'fieldLabel': label }];
                                break;
                            case 'Photo of Tractor during repair':
                                this.fileData3.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Photo of failure part':
                                this.fileData4.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                        }
                    }
                    fileReader.readAsDataURL(file);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message: 'Please Upload Image File Only', variant: 'warning' })
                    );
                }
            }
        }
    }

    /** 파일 삭제 버튼 */
    onDeleteFileClcik(e) {
        const label = e.target.dataset.label;
        const idx = Number(e.target.dataset.idx);
        const size = e.target.dataset.size;
        switch (label) {
            case 'Photo of Hour Meter':
                this.fileData1 = [];
                break;
            case 'Photo of Serial Number':
                this.fileData2 = [];
                break;
            case 'Photo of Tractor during repair':
                this.fileData3.splice(idx, 1);
                break;
            case 'Photo of failure part':
                this.fileData4.splice(idx, 1);
                break;
        }
    }

    /** Save 버튼 */
    async onUploadClick() {
        this.isLoading = true;
        const totalFileSize = this.fileSize1 + this.fileSize2 + this.fileSize3;
        const fileMaxSize = 3000000;
        let totalLength = 0;
        if ((this.fileData1 == [] || this.fileData1.length == 0)
            && (this.fileData2 == [] || this.fileData2.length == 0)
            && (this.fileData3 == [] || this.fileData3.length == 0)
            && (this.fileData4 == [] || this.fileData4.length == 0)) {
            this.dispatchEvent(
                new ShowToastEvent({ title: '', message: 'Please Upload Files', variant: 'warning' })
            );
            this.isLoading = false;
        } else {
            if (this.fileData1.length != 0) {
                totalLength += this.fileData1.length;
                await this.insertFiles(this.fileData1, this.fileData1.length);
            }
            if (this.fileData2.length != 0) {
                totalLength += this.fileData2.length;
                await this.insertFiles(this.fileData2, this.fileData2.length);
            }
            if (this.fileData3.length != 0) {
                totalLength += this.fileData3.length;
                await this.insertFiles(this.fileData3, this.fileData3.length);
            }
            if (this.fileData4.length != 0) {
                totalLength += this.fileData4.length;
                await this.insertFiles(this.fileData4, this.fileData4.length);
            }
            this.isLoading = false;
            if (this.successLength > 0) {
                this.dispatchEvent(
                    new ShowToastEvent({ title: '', message: 'Successful ' + this.successLength + ' out of ' + totalLength + 'uploads', variant: 'success' })
                );
                setTimeout(() => {
                    window.location.reload();
                }, 2000);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Upload Failed', message: this.errMessage, variant: 'warning' })
                );
            }
        }
    }

    /** Insert Files */
    async insertFiles(data, length) {
        await uploadFiles({ fileData: JSON.stringify(data), recordId: this.recordId })
            .then(res => {
                console.log('res :: ', res);
                this.successLength += length;
            }).catch(err => {
                console.log('err :: ', err);
                this.errMessage = err.body.message;
            });
    }
}