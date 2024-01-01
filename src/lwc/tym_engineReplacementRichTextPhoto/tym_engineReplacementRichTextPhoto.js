/*************************************************************
 * @author : th.kim
 * @date : 2023-10-26
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
import uploadFiles from '@salesforce/apex/TYM_EngineReplacementPhotoController.uploadFiles';
import getImageList from '@salesforce/apex/TYM_EngineReplacementPhotoController.getImageList';

export default class TymEngineReplacementRichTextPhoto extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;

    // Input File Datas
    @track engineOilFileData = [];
    @track coolantFileData = [];
    @track radiatorGrillFileData = [];
    @track airFilterFileData = [];
    @track airHoseClampsFileData = [];
    @track meterPanelFileData = [];
    @track etcFileData = [];

    // return Datas
    @track returnEengineOilData = [];
    @track returnCoolantData = [];
    @track returnRadiatorGrillData = [];
    @track returnAirFilterData = [];
    @track returnAirHoseClampsData = [];
    @track returnMeterPanelData = [];
    @track returnEtcData = [];

    fileSize1 = 0;
    fileSize2 = 0;
    fileSize3 = 0;
    fileSize4 = 0;
    fileSize5 = 0;
    fileSize6 = 0;
    fileSize7 = 0;
    successLength = 0;
    fileAcceptType = ['.jpg', '.jpeg', '.png']; // 파일 형식
    isLoading = false;
    errMessage;

    connectedCallback() {
        this.recordId = this.pageRef.attributes.recordId;
        getImageList({ recordId: this.recordId }).then(res => {
            console.log('res :: ', res);
            const basicUrl = '/sfc/servlet.shepherd/version/download/';
            if (res.QuantityofEngineOil__c) {
                res.QuantityofEngineOil__c.forEach(el => {
                    this.returnEengineOilData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.QuantityofCoolant__c) {
                res.QuantityofCoolant__c.forEach(el => {
                    this.returnCoolantData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.RadiatorGrill__c) {
                res.RadiatorGrill__c.forEach(el => {
                    this.returnRadiatorGrillData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.AirFilter__c) {
                res.AirFilter__c.forEach(el => {
                    this.returnAirFilterData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.AirHoseClamps__c) {
                res.AirHoseClamps__c.forEach(el => {
                    this.returnAirHoseClampsData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.MeterPanel__c) {
                res.MeterPanel__c.forEach(el => {
                    this.returnMeterPanelData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
            if (res.ETC__c) {
                res.ETC__c.forEach(el => {
                    this.returnEtcData.push({ name: el.ContentVersion.Title, url: /* basicUrl +  */el.ContentDownloadUrl });
                });
            }
        }).catch(err => {
            console.log('err :: ', err);
        });
    }

    /** Upload Files */
    onFileUpload(e) {
        const label = e.target.label;
        switch (label) {
            case 'Quantity of Engine Oil':
                this.engineOilFileData = [];
                break;
            case 'Quantity of Coolant':
                this.coolantFileData = [];
                break;
            case 'Radiator Grill':
                this.radiatorGrillFileData = [];
                break;
            case 'Air Filter':
                this.airFilterFileData = [];
                break;
            case 'Air Hose & Clamps':
                this.airHoseClampsFileData = [];
                break;
            case 'Meter Panel':
                this.meterPanelFileData = [];
                break;
            case 'ETC':
                this.etcFileData = [];
                break;
        }
        const fileMaxSize = 3000000;
        let fileSize = 0;
        let files = e.target.files;
        for (let i = 0; i < files.length; i++) {
            let file = files[i];
            fileSize += file.size;
            if (fileSize > fileMaxSize) {
                this.dispatchEvent(
                    new ShowToastEvent({ title: '', message: '파일 사이즈 체크 메시지', variant: 'warning' })
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
                            case 'Quantity of Engine Oil':
                                this.fileSize1 = fileSize;
                                this.engineOilFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Quantity of Coolant':
                                this.fileSize2 = fileSize;
                                this.coolantFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Radiator Grill':
                                this.fileSize3 = fileSize;
                                this.radiatorGrillFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Air Filter':
                                this.fileSize4 = fileSize;
                                this.airFilterFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Air Hose & Clamps':
                                this.fileSize5 = fileSize;
                                this.airHoseClampsFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'Meter Panel':
                                this.fileSize6 = fileSize;
                                this.meterPanelFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                            case 'ETC':
                                this.fileSize7 = fileSize;
                                this.etcFileData.push({ 'fileName': file.name, 'base64': base64, 'fieldLabel': label, 'fileSize': file.size });
                                break;
                        }
                    }
                    fileReader.readAsDataURL(file);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message: '확장자명 체크 메시지', variant: 'warning' })
                    );
                }
            }
        }
    }

    /** 파일 리스트 삭제 버튼 */
    onDeleteFileClcik(e) {
        const idx = e.target.dataset.idx;
        const label = e.target.dataset.label;
        const size = e.target.dataset.size;
        switch (label) {
            case 'Quantity of Engine Oil':
                this.engineOilFileData.splice(idx, 1);
                this.fileSize1 -= size;
                break;
            case 'Quantity of Coolant':
                this.coolantFileData.splice(idx, 1);
                this.fileSize2 -= size;
                break;
            case 'Radiator Grill':
                this.radiatorGrillFileData.splice(idx, 1);
                this.fileSize3 -= size;
                break;
            case 'Air Filter':
                this.airFilterFileData.splice(idx, 1);
                this.fileSize4 -= size;
                break;
            case 'Air Hose & Clamps':
                this.airHoseClampsFileData.splice(idx, 1);
                this.fileSize5 -= size;
                break;
            case 'Meter Panel':
                this.meterPanelFileData.splice(idx, 1);
                this.fileSize6 -= size;
                break;
            case 'ETC':
                this.etcFileData.splice(idx, 1);
                this.fileSize7 -= size;
                break;
        }
    }

    /** Rich Text 이미지 파일 생성하는 Save 버튼 */
    async onUploadClick() {
        this.isLoading = true;
        const totalFileSize = this.fileSize1 + this.fileSize2 + this.fileSize3 + this.fileSize4 + this.fileSize5 + this.fileSize6 + this.fileSize7;
        const fileMaxSize = 3000000; // limit 3000000
        let totalLength = 0;
        this.successLength = 0;
        if ((this.engineOilFileData == [] || this.engineOilFileData.length == 0)
            && (this.coolantFileData == [] || this.coolantFileData.length == 0)
            && (this.radiatorGrillFileData == [] || this.radiatorGrillFileData.length == 0)
            && (this.airFilterFileData == [] || this.airFilterFileData.length == 0)
            && (this.airHoseClampsFileData == [] || this.airHoseClampsFileData.length == 0)
            && (this.meterPanelFileData == [] || this.meterPanelFileData.length == 0)
            && (this.etcFileData == [] || this.etcFileData.length == 0)) {
            this.dispatchEvent(
                new ShowToastEvent({ title: '', message: '파일을 선택해주세요.', variant: 'warning' })
            );
            this.isLoading = false;
        } else {
            const fileData = [];
            if (this.engineOilFileData.length != 0) {
                totalLength += this.engineOilFileData.length;
                await this.insertFiles(this.engineOilFileData, this.engineOilFileData.length);
            }
            if (this.coolantFileData.length != 0) {
                totalLength += this.coolantFileData.length;
                await this.insertFiles(this.coolantFileData, this.coolantFileData.length);
            }
            if (this.radiatorGrillFileData.length != 0) {
                totalLength += this.radiatorGrillFileData.length;
                await this.insertFiles(this.radiatorGrillFileData, this.radiatorGrillFileData.length);
            }
            if (this.airFilterFileData.length != 0) {
                totalLength += this.airFilterFileData.length;
                await this.insertFiles(this.airFilterFileData, this.airFilterFileData.length);
            }
            if (this.airHoseClampsFileData.length != 0) {
                totalLength += this.airHoseClampsFileData.length;
                await this.insertFiles(this.airHoseClampsFileData, this.airHoseClampsFileData.length);
            }
            if (this.meterPanelFileData.length != 0) {
                totalLength += this.meterPanelFileData.length;
                await this.insertFiles(this.meterPanelFileData, this.meterPanelFileData.length);
            }
            if (this.etcFileData.length != 0) {
                totalLength += this.etcFileData.length;
                await this.insertFiles(this.etcFileData, this.etcFileData.length);
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