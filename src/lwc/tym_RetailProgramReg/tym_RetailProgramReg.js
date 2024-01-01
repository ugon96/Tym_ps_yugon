/*************************************************************
 * @author : th.kim
 * @date : 2023-11-03
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver       Date            Author            Modification
   1.0       2023-11-03      th.kim            Initial Version
**************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Status from '@salesforce/schema/RetailProgram__c.Status__c';
import IsPayToDealer from '@salesforce/schema/RetailProgram__c.IsPayToDealer__c';
import getRetailProgram from '@salesforce/apex/TYM_RetailProgramRegController.getRetailProgram';
import upsertRetailProgramItem from '@salesforce/apex/TYM_RetailProgramRegController.upsertRetailProgramItem';
import getProfileName from '@salesforce/apex/TYM_RetailProgramRegController.getProfileName';
import getSalesperson from '@salesforce/apex/TYM_RetailProgramRegController.getSalesperson';

const radioOptions = [
    { 'label': 'Issue Check', 'value': 'Issue Check' },
    { 'label': 'Issue Credit', 'value': 'Issue Credit' },
]

const statusOptions = [
    { 'label': '--None--', 'value': 'None' },
    { 'label': 'Approved', 'value': 'Approved' },
    { 'label': 'Need Approval', 'value': 'Need Approval' },
    { 'label': 'Declined', 'value': 'Declined' },
]

const FIELDS = [Status, IsPayToDealer];

export default class TymRetailProgramReg extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    rebateRadioOptions = radioOptions;
    volumeRadioOptions = radioOptions;
    bonusRadioOptions = radioOptions;
    statusOptions = statusOptions;
    activeSections = ['A', 'B', 'C'];
    @track salesPersonOptions;
    @track rebateList = [];
    @track volumeList = [];
    @track bonusList = [];
    @track programOptions = [];
    @track filteredOptions = [];
    @track optionLength = 0;
    @track volumeProgramOptions = [];
    @track volumeOptionLength = 0;
    @track volumeFilteredOptions = [];
    @track bonusProgramOptions = [];
    @track bonusOptionLength = 0;
    @track bonusFilteredOptions = [];
    @track fileData = [];
    @track totalAmount = 0;
    @track volumeTotalAmount = 0;
    @track bonusTotalAmount = 0;
    deleteList = [];
    deleteFileList = [];
    @track isPayToDealer;
    @track isBonusPayToDealer;
    volumeSalesPerson;
    bonusSalesPerson;
    rebateRadioValue = 'Issue Check';
    volumeRadioValue = 'Issue Check';
    bonusRadioValue = 'Issue Check';
    isAddButtonTrue = true;
    volumeIsAddButtonTrue = true;
    bonusIsAddButtonTrue = true
    isAdmin;
    isTymUser;
    isDealer;
    isAdjusted = true;
    isDealerCanEditClaimedAmount__c;
    isLoading;
    isLoadingData = true;
    isRebateData;
    isVolumeData;
    isBonusData;
    isSubmitButtom;
    isEditable;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    getRecordValue({ data, err }) {
        if (data) {
            setTimeout(() => {
                this.statusCheck(data.fields.Status__c.value);
                // this.isPayToDealer = data.fields.IsPayToDealer__c.value;
                // this.radioGroupFunc();
            }, 0);
        } else if (err) {
            console.log('err :: ', err);
        }
    }

    connectedCallback() {
        getProfileName().then(profile => {
            if (profile == 'System Administrator') this.isAdmin = true;
            else if (profile == 'TYM' || profile == 'TYM USA') this.isTymUser = true;
            else this.isDealer = true;
            this.recordId = this.pageRef.attributes.recordId;
            getSalesperson({ recordId: this.recordId }).then(res => {
                const picklistValue = [];
                res.forEach(el => {
                    picklistValue.push({ 'label': el.Name, 'value': el.Id });
                });
                this.salesPersonOptions = picklistValue;
            }).catch(err => {
                console.log('err :: ', err);
            });
            // this.recordId = this.pageRef.attributes.recordId;
            getRetailProgram({ recordId: this.recordId }).then(res => {
                console.log('res :: ',res);
                this.isLoadingData = false;
                const status = res.retailProgram.Status__c;
                // this.isDealerCanEditClaimedAmount__c = res.retailProgram.DealerCanEditClaimedAmount__c;
                if ((status == 'Created' || status == 'Submitted' || status == 'Received' || status == 'Under Review') && this.isDealer) {
                    this.isAdjusted = false;
                }
                this.statusCheck(status);

                const listRebate = JSON.parse(res.rebateMasterItemList);
                const listVolume = JSON.parse(res.volumeMasterItemList);
                const listBonus = JSON.parse(res.bonusMasterItemList);

                // Rebate 데이터
                listRebate.forEach(el => {
                    const MasterItem = el.objRPMasterItem;
                    const RPItem = el.objRPItem;
                    let contentDistribution = el.objCdb;
                    if (!contentDistribution) contentDistribution = { Id: null, Name: null };
                    if (!MasterItem.Amount__c) MasterItem.Amount__c = 0;
                    const invoiceAmt = MasterItem.RetailProgramID__r.PricingStructure__c == 'Flat Rate' ? MasterItem.Amount__c : 0;
                    const amount = MasterItem.RetailProgramID__r.PricingStructure__c == 'Flat Rate' ? 0 : MasterItem.Amount__c;
                    let claimed;
                    let adjusted;
                    if(RPItem) {
                        claimed = RPItem.Claimed__c;
                        adjusted = RPItem.Adjusted__c;
                    }
                    const issueType = RPItem.IssueType__c != null ? RPItem.IssueType__c : this.rebateRadioValue;
                    this.rebateList.push({
                        itemId: MasterItem.Id,
                        productId: MasterItem.ProductID__c,
                        programId: MasterItem.RetailProgramID__c,
                        programLabel: MasterItem.RetailProgramID__r.Name + ' - ' + MasterItem.ProductID__r.Name,
                        description: RPItem.Description__c,
                        invoiceAmt: invoiceAmt,
                        amount: claimed ? claimed : amount,
                        manager: adjusted ? adjusted : amount,
                        fileData: null,
                        attachment: contentDistribution.Name,
                        imgUrl: '/sfc/servlet.shepherd/version/download/' + contentDistribution.ContentVersionId,
                        status: RPItem.Status__c,
                        rpItemId: RPItem.Id,
                        requiredFile: MasterItem.RetailProgramID__r.IsFile__c,
                        issueType: issueType,
                        canEditClaimed: MasterItem.RetailProgramID__r.IsDealerCanEditClaimed__c
                    });
                });
                const programOptions = [];
                res.rebateAllList.forEach(el => {
                    if (!el.Amount__c) el.Amount__c = 0;
                    const invoiceAmt = el.RetailProgramID__r.PricingStructure__c == 'Flat Rate' ? el.Amount__c : 0;
                    const amount = el.RetailProgramID__r.PricingStructure__c == 'Flat Rate' ? 0 : el.Amount__c;
                    programOptions.push({
                        itemId: el.Id,
                        productId: el.ProductID__c,
                        programId: el.RetailProgramID__c,
                        label: el.RetailProgramID__r.Name + ' - ' + el.ProductID__r.Name,
                        value: el.Id,
                        invoiceAmt: invoiceAmt,
                        amount: amount,
                        manager: amount,
                        fileData: null,
                        attachment: null,
                        requiredFile: el.RetailProgramID__r.IsFile__c,
                        issueType: this.rebateRadioValue,
                        canEditClaimed: el.RetailProgramID__r.IsDealerCanEditClaimed__c
                    });
                });
                if (res.rebateAllList.length > 0) this.isRebateData = true;
                if (listRebate.length < 1) {
                    this.rebateList.push({
                        itemId: null,
                        productId: null,
                        programId: null,
                        programLabel: null,
                        amount: 0,
                        manager: 0,
                        fileData: null,
                        attachment: null,
                        issueType: this.rebateRadioValue
                    });
                }
                this.programOptions = programOptions;
                this.optionLength = this.programOptions.length;
                // this.filteredOptions = this.programOptions.slice();

                this.dropdownFiltering('rebate');
                this.calcTotalAmount('rebate');
                this.calcListLength('rebate');

                // Volume 데이터
                listVolume.forEach(el => {
                    const MasterItem = el.objRPMasterItem;
                    const RPItem = el.objRPItem;
                    const issueType = RPItem.IssueType__c != null ? RPItem.IssueType__c : this.volumeRadioValue;
                    let contentDistribution = el.objCdb;
                    if (!contentDistribution) contentDistribution = { Id: null, Name: null };
                    if (!MasterItem.Amount__c) MasterItem.Amount__c = 0;
                    setTimeout(() => {
                        this.isPayToDealer = RPItem.PayToDealer__c;
                        this.volumeSalesPerson = RPItem.SalespersonId__c;
                    },0);
                    let adjusted;
                    if(RPItem) adjusted = RPItem.Adjusted__c;
                    this.volumeList.push({
                        itemId: MasterItem.Id,
                        productId: MasterItem.ProductID__c,
                        programId: MasterItem.RetailProgramID__c,
                        programLabel: MasterItem.RetailProgramID__r.Name + ' - ' + MasterItem.ProductID__r.Name,
                        amount: MasterItem.Amount__c,
                        manager: adjusted ? adjusted : MasterItem.Amount__c,
                        unit: MasterItem.Unit__c,
                        fileData: null,
                        attachment: contentDistribution.Name,
                        imgUrl: '/sfc/servlet.shepherd/version/download/' + contentDistribution.ContentVersionId,
                        status: RPItem.Status__c,
                        rpItemId: RPItem.Id,
                        requiredFile: MasterItem.RetailProgramID__r.IsFile__c,
                        issueType: issueType,
                        salesperson: RPItem.SalespersonId__c
                    });
                });
                const volumeOptions = [];
                res.volumeAllList.forEach(el => {
                    if (!el.Amount__c) el.Amount__c = 0;
                    volumeOptions.push({
                        itemId: el.Id,
                        productId: el.ProductID__c,
                        programId: el.RetailProgramID__c,
                        label: el.RetailProgramID__r.Name + ' - ' + el.ProductID__r.Name,
                        value: el.Id,
                        amount: el.Amount__c,
                        manager: el.Amount__c,
                        unit: el.Unit__c,
                        fileData: null,
                        attachment: null,
                        requiredFile: el.RetailProgramID__r.IsFile__c,
                        issueType: this.volumeRadioValue
                    });
                });
                if (res.volumeAllList.length > 0) this.isVolumeData = true;
                if (listVolume.length < 1) {
                    this.volumeList.push({
                        itemId: null,
                        productId: null,
                        programId: null,
                        programLabel: null,
                        amount: 0,
                        manager: 0,
                        unit: null,
                        fileData: null,
                        attachment: null,
                        issueType: this.volumeRadioValue
                    });
                }
                this.volumeProgramOptions = volumeOptions;
                this.volumeOptionLength = this.volumeProgramOptions.length;
                // this.volumeFilteredOptions = this.volumeProgramOptions.slice();
                this.dropdownFiltering('volume');
                this.calcTotalAmount('volume');
                this.calcListLength('volume');

                // Bonus 데이터
                listBonus.forEach(el => {
                    const MasterItem = el.objRPMasterItem;
                    const RPItem = el.objRPItem;
                    const issueType = RPItem.IssueType__c != null ? RPItem.IssueType__c : this.rebateRadioValue;
                    let contentDistribution = el.objCdb;
                    if (!contentDistribution) contentDistribution = { Id: null, Name: null };
                    if (!MasterItem.Amount__c) MasterItem.Amount__c = 0;
                    setTimeout(() => {
                        this.isBonusPayToDealer = RPItem.PayToDealer__c;
                        this.bonusSalesPerson = RPItem.SalespersonId__c;
                    },0);
                    let adjusted;
                    if(RPItem) adjusted = RPItem.Adjusted__c;
                    this.bonusList.push({
                        itemId: MasterItem.Id,
                        productId: MasterItem.ProductID__c,
                        programId: MasterItem.RetailProgramID__c,
                        programLabel: MasterItem.RetailProgramID__r.Name + ' - ' + MasterItem.ProductID__r.Name,
                        amount: MasterItem.Amount__c,
                        manager: adjusted ? adjusted : MasterItem.Amount__c,
                        unit: MasterItem.Unit__c,
                        fileData: null,
                        attachment: contentDistribution.Name,
                        imgUrl: '/sfc/servlet.shepherd/version/download/' + contentDistribution.ContentVersionId,
                        status: RPItem.Status__c,
                        rpItemId: RPItem.Id,
                        requiredFile: MasterItem.RetailProgramID__r.IsFile__c,
                        payToDealer: RPItem.PayToDealer__c,
                        issueType: issueType,
                        salesperson: RPItem.SalespersonId__c
                    });
                });
                const bonusOptions = [];
                res.bonusAllList.forEach(el => {
                    if (!el.Amount__c) el.Amount__c = 0;
                    bonusOptions.push({
                        itemId: el.Id,
                        productId: el.ProductID__c,
                        programId: el.RetailProgramID__c,
                        label: el.RetailProgramID__r.Name + ' - ' + el.ProductID__r.Name,
                        value: el.Id,
                        amount: el.Amount__c,
                        manager: el.Amount__c,
                        unit: el.Unit__c,
                        fileData: null,
                        attachment: null,
                        requiredFile: el.RetailProgramID__r.IsFile__c,
                        issueType: this.bonusRadioValue
                    });
                });
                if (res.bonusAllList.length > 0) this.isBonusData = true;
                if (listBonus.length < 1) {
                    this.bonusList.push({
                        itemId: null,
                        productId: null,
                        programId: null,
                        programLabel: null,
                        amount: 0,
                        manager: 0,
                        unit: null,
                        fileData: null,
                        attachment: null,
                        issueType: this.bonusRadioValue
                    });
                }
                if (!this.isRebateData && !this.isVolumeData && !this.isBonusData) this.isSubmitButtom = false;

                this.bonusProgramOptions = bonusOptions;
                this.bonusOptionLength = this.bonusProgramOptions.length;
                // this.bonusFilteredOptions = this.bonusProgramOptions.slice();
                this.dropdownFiltering('bonus');
                this.calcTotalAmount('bonus');
                this.calcListLength('bonus');
                this.radioGroupFunc();
            }).catch(err => {
                console.log('err :: ', err);
                this.isLoadingData = false;
                this.isSubmitButtom = false;
            });
        }).catch(err => {
            console.log('err :: ', err);
        });
    }

    /** Eligible Program 드롭 다운 메뉴 생성 */
    toggleDropdown(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            if (!this.rebateList[idx].isDropdown && this.optionLength > 0) {
                if (this.isAddButtonTrue || !this.rebateList[idx].itemId) {
                    this.rebateList.forEach(el => {
                        el.isDropdown = false;
                    });
                    this.rebateList[idx].isDropdown = true;
                }
            } else {
                this.rebateList[idx].isDropdown = false;
            }
        } else if(type == 'volume') {
            if (!this.volumeList[idx].isDropdown && this.volumeOptionLength > 0) {
                if (/* this.volumeIsAddButtonTrue ||  */!this.volumeList[idx].itemId) {
                    this.volumeList.forEach(el => {
                        el.isDropdown = false;
                    });
                    this.volumeList[idx].isDropdown = true;
                }
            } else {
                this.volumeList[idx].isDropdown = false;
            }
        } else {
            if (!this.bonusList[idx].isDropdown && this.bonusOptionLength > 0) {
                if (/* this.bonusIsAddButtonTrue ||  */!this.bonusList[idx].itemId) {
                    this.bonusList.forEach(el => {
                        el.isDropdown = false;
                    });
                    this.bonusList[idx].isDropdown = true;
                }
            } else {
                this.bonusList[idx].isDropdown = false;
            }
        }
        document.addEventListener('click', this.handleDocumentClick);
        e.stopPropagation();
    }

    /** 다른 요소 클릭 시 드롭다운 없애는 함수 */
    handleDocumentClick = (e) => {
        const dropDownInput = this.template.querySelector('.dropdown-input');
        if (!dropDownInput.contains(e.target)) {
            this.rebateList.forEach(el => {
                el.isDropdown = false;
            });
            this.volumeList.forEach(el => {
                el.isDropdown = false;
            });
            document.removeEventListener('click', this.handleDocumentClick);
        }
    }

    /** Eligible Program 드롭 다운 옵션 클릭 */
    dropdownClick(e) {
        const idx = e.target.dataset.idx;
        const id = e.target.dataset.id;
        const type = e.target.dataset.type;
        const productId = e.target.dataset.productid;
        const programId = e.target.dataset.programid;
        const label = e.target.dataset.label;
        const amount = e.target.dataset.amount;
        const manager = e.target.dataset.manager;
        const unit = e.target.dataset.unit;
        const required = e.target.dataset.required === 'true' ? true : false;
        const invoiceAmt = e.target.dataset.invoiceamt;
        const canEditClaimed = e.target.dataset.caneditclaimed;
        this.deleteList = this.deleteList.filter(el => el.id != id);
        if (type == 'rebate') {
            this.rebateList[idx] = {
                isDropdown: false,
                itemId: id,
                productId: productId,
                programId: programId,
                programLabel: label,
                invoiceAmt: invoiceAmt,
                amount: amount,
                manager: manager,
                requiredFile: required,
                canEditClaimed: canEditClaimed
            };
        } else if(type == 'volume') {
            this.volumeList[idx] = {
                isDropdown: false,
                itemId: id,
                productId: productId,
                programId: programId,
                programLabel: label,
                amount: amount,
                manager: manager,
                unit: unit,
                requiredFile: required,
                payToDealer: this.isPayToDealer,
                salesperson: this.volumeSalesPerson
            };
        } else {
            this.bonusList[idx] = {
                isDropdown: false,
                itemId: id,
                productId: productId,
                programId: programId,
                programLabel: label,
                amount: amount,
                manager: manager,
                unit: unit,
                requiredFile: required,
                payToDealer: this.isBonusPayToDealer,
                salesperson: this.bonusSalesPerson
            };
        }
        this.dropdownFiltering(type);
        this.calcTotalAmount(type);
        this.calcListLength(type);
    }

    /** Description Input onchange() */
    onDescriptionChange(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            this.rebateList[idx].description = e.target.value;
        } else if(type == 'volume') {
            this.volumeList[idx].description = e.target.value;
        } else {
            this.bonusList[idx].description = e.target.value;
        }
    }

    /** Amount Input onChange() */
    onRebateAmountChange(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            this.rebateList[idx].amount = e.target.value;
            this.rebateList[idx].manager = e.target.value;
        } else if(type == 'volume') {
            this.volumeList[idx].amount = e.target.value;
        } else {
            this.bonusList[idx].amount = e.target.value;
        }
        this.calcTotalAmount(type);
    }

    /** Adjusted Input onChange() */
    onMangerAmountChange(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            this.rebateList[idx].manager = e.target.value;
        } else if(type == 'volume') {
            this.volumeList[idx].manager = e.target.value;
        } else {
            this.bonusList[idx].manager = e.target.value;
        }
    }

    /** File Input onchange() */
    onFileChange(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        const fileInput = e.target;
        if (fileInput.files.length > 0) {
            const file = fileInput.files[0];
            const reader = new FileReader();
            reader.onload = () => {
                let base64 = reader.result.split(',')[1];
                if (type == 'rebate') {
                    this.rebateList[idx].attachment = file.name;
                    this.rebateList[idx].fileData = { 'fileName': file.name, 'base64': base64, 'itemId': this.rebateList[idx].itemId, 'file': file };
                    this.fileData.push({ 'idx': idx, 'fileName': file.name, 'base64': base64, 'itemId': this.rebateList[idx].itemId, 'file': file });
                } else if(type == 'volume') {
                    this.volumeList[idx].attachment = file.name;
                    this.volumeList[idx].fileData = { 'fileName': file.name, 'base64': base64, 'itemId': this.volumeList[idx].itemId, 'file': file };
                    this.fileData.push({ 'idx': idx, 'fileName': file.name, 'base64': base64, 'itemId': this.volumeList[idx].itemId, 'file': file });
                } else {
                    this.bonusList[idx].attachment = file.name;
                    this.bonusList[idx].fileData = { 'fileName': file.name, 'base64': base64, 'itemId': this.bonusList[idx].itemId, 'file': file };
                    this.fileData.push({ 'idx': idx, 'fileName': file.name, 'base64': base64, 'itemId': this.bonusList[idx].itemId, 'file': file });
                }
            };
            reader.readAsDataURL(file);
        } else {
            let fileIdx;
            for (let i = 0; i < this.fileData.length; i++) {
                if (el.idx == idx) fileIdx = i;
            }
            this.fileData.splice(fileIdx, 1);
        }
    }

    /** 파일 다운로드 클릭 */
    onAttachmentDownload(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        let fileName;
        let path;
        if (type == 'rebate') {
            fileName = this.rebateList[idx].fileData.fileName;
            path = window.URL.createObjectURL(this.rebateList[idx].fileData.file);
        } else if(type == 'volume') {
            fileName = this.volumeList[idx].fileData.fileName;
            path = window.URL.createObjectURL(this.volumeList[idx].fileData.file);
        } else {
            fileName = this.bonusList[idx].fileData.fileName;
            path = window.URL.createObjectURL(this.bonusList[idx].fileData.file);
        }
        const link = document.createElement('a');
        link.href = path;
        link.download = fileName;
        link.click();
    }

    /** 파일 리스트 삭제 버튼 */
    onDeleteFileClcik(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            if (this.rebateList[idx].imgUrl) {
                const fileId = this.rebateList[idx].imgUrl.replace('/sfc/servlet.shepherd/version/download/', '');
                if (!this.deleteFileList.includes(fileId)) this.deleteFileList.push(fileId);
            }
            this.rebateList[idx].attachment = null;
            this.rebateList[idx].fileData = null;
            this.rebateList[idx].imgUrl = null;
        } else if(type == 'volume') {
            if (this.volumeList[idx].imgUrl) {
                const fileId = this.volumeList[idx].imgUrl.replace('/sfc/servlet.shepherd/version/download/', '');
                if (!this.deleteFileList.includes(fileId)) this.deleteFileList.push(fileId);
            }
            this.volumeList[idx].attachment = null;
            this.volumeList[idx].fileData = null;
            this.volumeList[idx].imgUrl = null;
        } else {
            if (this.bonusList[idx].imgUrl) {
                const fileId = this.bonusList[idx].imgUrl.replace('/sfc/servlet.shepherd/version/download/', '');
                if (!this.deleteFileList.includes(fileId)) this.deleteFileList.push(fileId);
            }
            this.bonusList[idx].attachment = null;
            this.bonusList[idx].fileData = null;
            this.bonusList[idx].imgUrl = null;
        }
        let fileIdx;
        for (let i = 0; i < this.fileData.length; i++) {
            if (el.idx == idx) fileIdx = i;
        }
        this.fileData.splice(fileIdx, 1);
    }

    /** Status 콤보 박스 선택 */
    onStatusChange(e) {
        const idx = e.target.dataset.idx;
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            if (e.target.value != 'None') this.rebateList[idx].status = e.target.value;
            else this.rebateList[idx].status = null;
        } else if(type == 'volume') {
            if (e.target.value != 'None') this.volumeList[idx].status = e.target.value;
            else this.volumeList[idx].status = null;
        } else {
            if (e.target.value != 'None') this.bonusList[idx].status = e.target.value;
            else this.bonusList[idx].status = null;
        }
    }

    /** Add Rebate/Volume 추가 버튼 */
    onAddRebateClick(e) {
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            if (this.rebateList.length > 0) {
                this.rebateList.push({ itemId: null, productId: null, programId: null, programLabel: null, description: null, amount: null, fileData: null, attachment: null });
            }
            this.rebateList.forEach(el => {
                el.isDropdown = false;
            });
        } else if(type == 'volume') {
            if (this.volumeList.length > 0) {
                this.volumeList.push({ itemId: null, productId: null, programId: null, programLabel: null, description: null, amount: 0, unit: null, fileData: null, attachment: null });
            }
            this.volumeList.forEach(el => {
                el.isDropdown = false;
            });
        } else {
            if (this.bonusList.length > 0) {
                this.bonusList.push({ itemId: null, productId: null, programId: null, programLabel: null, description: null, amount: 0, unit: null, fileData: null, attachment: null });
            }
            this.bonusList.forEach(el => {
                el.isDropdown = false;
            });
        }
        this.calcListLength(type);
    }

    /** 행 삭제 클릭 */
    onDeleteClick(e) {
        const idx = e.target.dataset.idx;
        const id = e.target.dataset.id;
        const programId = e.target.dataset.programid;
        const productId = e.target.dataset.productid;
        if (!this.deleteList.includes(id) || id) this.deleteList.push({ 'id': id, programId: programId, productId: productId });
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            if (this.rebateList.length > 1) {
                this.rebateList.splice(idx, 1);
                let fileIdx;
                for (let i = 0; i < this.fileData.length; i++) {
                    if (el.idx == idx) fileIdx = i;
                }
                this.fileData.splice(fileIdx, 1);
            } else {
                this.rebateList = [{ invoiceAmt: 0, amount: 0, manager: 0 }];
            }
            this.rebateList.forEach(el => {
                el.isDropdown = false;
            });
        } else if(type == 'volume') {
            if (this.volumeList.length > 1) {
                this.volumeList.splice(idx, 1);
                let fileIdx;
                for (let i = 0; i < this.fileData.length; i++) {
                    if (el.idx == idx) fileIdx = i;
                }
                this.fileData.splice(fileIdx, 1);
            } else {
                this.volumeList = [{ invoiceAmt: 0, amount: 0, manager: 0 }];
            }
            this.volumeList.forEach(el => {
                el.isDropdown = false;
            });
        } else {
            if (this.bonusList.length > 1) {
                this.bonusList.splice(idx, 1);
                let fileIdx;
                for (let i = 0; i < this.fileData.length; i++) {
                    if (el.idx == idx) fileIdx = i;
                }
                this.fileData.splice(fileIdx, 1);
            } else {
                this.bonusList = [{ invoiceAmt: 0, amount: 0, manager: 0 }];
            }
            this.bonusList.forEach(el => {
                el.isDropdown = false;
            });
        }
        this.dropdownFiltering(type);
        this.calcTotalAmount(type);
        this.calcListLength(type);
    }

    /** Volume Salesperson Combobox Change */
    onSalespersonChange(e) {
        this.volumeSalesPerson = e.target.value;
        this.volumeList.forEach(el => {
            el.salesperson = this.volumeSalesPerson;
        });
        console.log('volumeList :: ',JSON.stringify(this.volumeList));
    }

    /** Bonus Salesperson Combobox Change */
    onBonusSalespersonChange(e) {
        this.bonusSalesPerson = e.target.value;
        this.bonusList.forEach(el => {
            el.salesperson = this.bonusSalesPerson;
        });
    }

    /** Pay to Dealer 체크 박스 onchange() */
    onCheckboxChange(e) {
        const type = e.target.dataset.type;
        if(type == 'volume') {
            this.isPayToDealer = e.target.checked;
            this.volumeList[0].payToDealer = this.isPayToDealer;
            if(this.isPayToDealer && this.volumeList[0].salesperson) {
                this.volumeSalesPerson = null;
                this.volumeList[0].salesperson = null;
            }
        }
        else {
            this.isBonusPayToDealer = e.target.checked;
            this.bonusList[0].payToDealer = this.isBonusPayToDealer;
            if(this.isBonusPayToDealer && this.bonusList[0].salesperson) {
                this.bonusSalesPerson = null;
                this.bonusList[0].salesperson = null;
            }
        }
        this.radioGroupFunc();
    }

    /** Issue Type 라디오 버튼 onchange() */
    onRadioChange(e) {
        const type = e.target.dataset.type;
        if (type == 'rebate') {
            this.rebateRadioValue = e.target.value;
            this.rebateList.forEach(el => {
                el.issueType = this.rebateRadioValue;
            })
        } else if(type == 'volume') {
            this.volumeRadioValue = e.target.value;
            this.volumeList[0].issueType = this.volumeRadioValue;
        } else {
            this.bonusRadioValue = e.target.value;
            this.rebateList[0].issueType = this.bonusRadioValue;
        }
    }

    /** Submit 버튼 클릭 */
    onSubmitClick() {
        this.isLoading = true;
        const dataList = [];
        let isReturn = false;
        let isListNull = true;
        this.rebateList.forEach(el => {
            if (el.itemId) {
                dataList.push(el);
                isListNull = false;
                if (el.requiredFile && !el.attachment) {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message: el.programLabel + ' Attachment Is Required', variant: 'warning' })
                    );
                    isReturn = true;
                    return;
                }
            }
        });
        this.volumeList.forEach(el => {
            if (el.itemId) {
                dataList.push(el);
                if (el.requiredFile && !el.attachment) {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message: el.programLabel + ' Attachment Is Required', variant: 'warning' })
                    );
                    isReturn = true;
                    return;
                } else if(!this.isPayToDealer && !this.volumeSalesPerson) {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message:'You should choose \'Pay to Dealer\' or select salesperson on ' + el.programLabel, variant: 'warning' })
                    );
                    isReturn = true;
                    return;
                }
            }
        });
        this.bonusList.forEach(el => {
            if (el.itemId) {
                dataList.push(el);
                if (el.requiredFile && !el.attachment) {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message: el.programLabel + ' Attachment Is Required', variant: 'warning' })
                    );
                    isReturn = true;
                    return;
                } else if(!this.isBonusPayToDealer && !this.bonusSalesPerson) {
                    this.dispatchEvent(
                        new ShowToastEvent({ title: '', message:'You should choose \'Pay to Dealer\' or select salesperson on ' + el.programLabel, variant: 'warning' })
                    );
                    isReturn = true;
                    return;
                }
            }
        });

        if (isReturn || (dataList.length < 1 && this.deleteList.length < 1)) {
            this.isLoading = false;
            return;
        } else if(isListNull && !this.volumeList[0].itemId && !this.bonusList[0].itemId) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({ title: '', message: 'You should add one Retail Program for Submit', variant: 'warning' })
            );
            return;
        } else {
            const dataMap = {
                recordId: this.recordId,
                // payToDealer: this.isPayToDealer.toString(),
                rebateRadioValue: this.rebateRadioValue,
                volumeRadioValue: this.volumeRadioValue
            }
            upsertRetailProgramItem({
                dataMap: dataMap,
                jsonData: JSON.stringify(dataList),
                deleteList: JSON.stringify(this.deleteList),
                deleteFileList: this.deleteFileList
            }).then(res => {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({ title: '', message: 'Retail Program Submitted', variant: 'success' })
                );
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            }).catch(err => {
                console.log('err :: ', err);
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({ title: '', message: err.body.message, variant: 'warning' })
                );
            });
        }
    }

    handleSectionToggle() {

    }

    /** 상태 값 변경 시 Status 조건 적용 함수 */
    statusCheck(status) {
        setTimeout(() => {
            if ((status == 'Created' || status == 'Submitted' || status == 'Received' || status == 'Under Review') && this.isDealer) {
                this.isAdjusted = false;
            }
            const input = this.template.querySelectorAll('input');
            const lightningInput = this.template.querySelectorAll('lightning-input');
            const combobox = this.template.querySelectorAll('lightning-combobox');
            const radio = this.template.querySelectorAll('lightning-radio-group');
            if (((status == 'Created' || status == 'Submitted') && this.isDealer) || (status != 'Closed' && (this.isTymUser || this.isAdmin))) {
                console.log('true :: ',status, this.isTymUser);
                this.isSubmitButtom = true;
                this.isEditable = true;
                input.forEach(el => {
                    if (el.type == 'file') el.disabled = false;
                }); 
                lightningInput.forEach(el => {
                    if (el.type == 'checkbox') el.disabled = false;
                    else el.readOnly = false
                });
                combobox.forEach(el => el.disabled = false);
                radio.forEach(el => el.disabled = false);
            } else {
                this.rebateList = this.rebateList.filter(el => el.rpItemId != null);
                this.volumeList = this.volumeList.filter(el => el.rpItemId != null);
                this.bonusList = this.bonusList.filter(el => el.rpItemId != null);
                this.isSubmitButtom = false;
                this.isEditable = false;
                input.forEach(el => {
                    console.log('el :: ',el);
                    if (el.type == 'file') el.disabled = true;
                });
                console.log('lightningInput :: ', lightningInput);
                lightningInput.forEach(el => {
                    if(el.type == 'checkbox') el.disabled = true;
                    else el.readOnly = true;
                });
                combobox.forEach(el => el.disabled = true);
                radio.forEach(el => el.disabled = true);
            }
            if (this.rebateList.length < 1) {
                if (this.isRebateData) this.rebateList = [{ itemId: null, programId: null, programLabel: null, description: null, amount: 0, fileData: null, attachment: null }];
            }
            if (this.volumeList.length < 1) {
                if (this.isVolumeData) this.volumeList = [{ itemId: null, programId: null, programLabel: null, description: null, amount: 0, unit: null, fileData: null, attachment: null }];
            }
            if (this.bonusList.length < 1) {
                if (this.isBonusData) this.bonusList = [{ itemId: null, programId: null, programLabel: null, description: null, amount: 0, unit: null, fileData: null, attachment: null }];
            }
        }, 0);
    }

    /** Total Amount 계산 함수 */
    calcTotalAmount(type) {
        if (type == 'rebate') {
            this.totalAmount = 0;
            this.rebateList.forEach(el => {
                this.totalAmount += Number(el.amount);
            });
        } else if(type == 'volume') {
            this.volumeTotalAmount = 0;
            this.volumeList.forEach(el => {
                this.volumeTotalAmount += Number(el.amount);
            });
        } else {
            this.bonusTotalAmount = 0;
            this.bonusList.forEach(el => {
                this.bonusTotalAmount += Number(el.amount);
            });
        }
    }

    /** 드롭다운 옵션 길이 체크해서 버튼 Disabled or Active */
    calcListLength(type) {
        if (type == 'rebate') {
            if (this.filteredOptions.length < 1) {
                this.isAddButtonTrue = false;
            } else {
                this.isAddButtonTrue = true;
            }
        } else if(type == 'volume') {
            if (this.volumeFilteredOptions.length < 1) {
                this.volumeIsAddButtonTrue = false;
            } else {
                this.volumeIsAddButtonTrue = true;
            }
        } else {
            if (this.bonusFilteredOptions.length < 1) {
                this.bonusIsAddButtonTrue = false;
            } else {
                this.bonusIsAddButtonTrue = true;
            }
        }
    }

    /** 선택한 드롭다운 옵션은 현재 드롭다운 옵션에서 필터링 하는 함수 */
    dropdownFiltering(type) {
        const filterDataList = [];
        if (type == 'rebate') {
            this.rebateList.forEach(el => {
                filterDataList.push(el.itemId);
            });
            this.filteredOptions = this.programOptions.filter(option => !filterDataList.includes(option.itemId));
        } else if(type == 'volume') {
            this.volumeList.forEach(el => {
                filterDataList.push(el.itemId);
            });
            this.volumeFilteredOptions = this.volumeProgramOptions.filter(option => !filterDataList.includes(option.itemId));
        } else {
            this.bonusList.forEach(el => {
                filterDataList.push(el.itemId);
            });
            this.bonusFilteredOptions = this.bonusProgramOptions.filter(option => !filterDataList.includes(option.itemId));
        }
    }

    /** Pay to Dealer 선택 시 Issue Type 라디오 그룹 비활성화 함수 */
    radioGroupFunc() {
        setTimeout(() => {
            const radioGroup = this.template.querySelectorAll('lightning-radio-group[type="radio"]');
            if (!this.isPayToDealer) {
                this.volumeRadioValue = 'Issue Check';
                radioGroup.forEach(el => {
                    if(el.dataset.type == 'volume') el.disabled = true;
                });
            } else {
                radioGroup.forEach(el => {
                    if(el.dataset.type == 'volume') el.disabled = false;
                });
            }
            if(!this.isBonusPayToDealer) {
                this.bonusRadioValue = 'Issue Check';
                radioGroup.forEach(el => {
                    if(el.dataset.type == 'bonus') el.disabled = true;
                });
            } else {
                radioGroup.forEach(el => {
                    if(el.dataset.type == 'bonus') el.disabled = false;
                });
            }
        }, 0);
    }
}