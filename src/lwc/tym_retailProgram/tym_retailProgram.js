import { LightningElement, track, api, wire } from 'lwc';
import getItemGroupCodes from '@salesforce/apex/Tym_RetailProgramController.getItemGroupCodes';
import selectRetailMasterItemInfo from '@salesforce/apex/Tym_RetailProgramController.selectRetailMasterItemInfo';
import selectpayoutStructure from '@salesforce/apex/Tym_RetailProgramController.selectpayoutStructure';
import insertRetailMasterItemInfo from '@salesforce/apex/Tym_RetailProgramController.insertRetailProgramMasterItem';
import insertPayoutItems from '@salesforce/apex/Tym_RetailProgramController.insertPayoutItems';
import deleteRow from '@salesforce/apex/Tym_RetailProgramController.deleteRow';
import deletePayRow from '@salesforce/apex/Tym_RetailProgramController.deletePayRow';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import PROGRAM_TYPE_FIELD from '@salesforce/schema/RetailProgramMaster__c.ProgramType__c';
import PricingStructure from '@salesforce/schema/RetailProgramMaster__c.PricingStructure__c';
import { getRecord } from 'lightning/uiRecordApi';

export default class Tym_retailProgram extends NavigationMixin(LightningElement) {

    @api recordId;
    isSelectedRebate;
    isSelectedVolume;
    isShowAmountAndUnit;
    isFlatRate;
    isDynamic;
    isVariableAmount;
    isPayoutStructure;
    isSelectVolumeInfo;
    isPayoutDynamic;

    @track programType;
    @track pricingStructure;
    @track selectedItem;
    @track selectedItemValue;
    @track AllItems = [];
    @track selectedModelValue;
    @track returnList = [];
    @track payoutList = [];
    @track deleteList = [];
    @track deletePayoutList = [];
    @track allItemsList = [];
    @track itemGroupCodes = [];
    isSelectedItems;
    @track itemId;
    @track numberValue;
    @track idKey;
    @track payIdkey;
    error;
    @track initialNumberValue = [];
    @track payoutListValue = [];
    @track isLoading = false;
    @track optionList = [];
    @track optionSelectList = [];
    @track initListRetailpro = {"Discount__c": 0, "Amount__c": 0, "Unit__c": 0};
    @track initListVolumeRetailpro = {"Unit__c": 1, "Payout__c": 1};
    @track newValue;
    @track newPointsVal;
    @track newDiscountVal;
    @track newAmountVal;
    @track isDropdownOpen = false;
    @track isNonPick = false;


    @wire(getRecord, { recordId: '$recordId', fields: [PROGRAM_TYPE_FIELD, PricingStructure] })
    wiredRecord({ error, data }) {
        if (data) {
            this.selectedItemValue = 'All';
            this.programType = data.fields.ProgramType__c.value;
            this.pricingStructure = data.fields.PricingStructure__c.value;

            if (this.programType == 'Rebate') {
                this.isSelectedRebate = true;
                this.isSelectedVolume = false;
            } else if (this.programType == 'Volume Incentive') {
                this.isSelectedRebate = false;
                this.isSelectedVolume = true;
            } else {
                this.isSelectedRebate = true;
                this.isSelectedVolume = false;
            }
            if(this.pricingStructure == 'Dynamic' && this.programType == 'Volume Incentive') {
                this.isPayoutDynamic = true;
                this.isSelectedItems = true;
                this.isSelectVolumeInfo = true;
                this.isFlatRate = false;
                this.isDynamic = true;
                this.isVariableAmount = false;
                this.loadPayout();
            } else if (this.pricingStructure == 'Variable Amount') {
                this.isFlatRate = false;
                this.isDynamic = false;
                this.isVariableAmount = true;
                this.isSelectedItems = true;
                this.isSelectVolumeInfo = false;
            } else if(this.pricingStructure == 'Flat Rate') {
                this.isFlatRate = true;
                this.isDynamic = false;
                this.isVariableAmount = false;
                this.isSelectedItems = true;
                this.isSelectVolumeInfo = false;
            } 
            else {
                this.isFlatRate = false;
                this.isDynamic = false;
                this.isVariableAmount = false;
                this.isSelectedItems = false;
                this.isSelectVolumeInfo = false;
                this.isSelectedRebate = false;
            }
            this.loadRetailItems();
        }
    }
    connectedCallback() {
        this.fetchItemGroupCodes();
    }

    fetchItemGroupCodes(e) {
        getItemGroupCodes()
            .then((result) => {
                const labelList = result.label;
                const valueList = result.value;

                this.itemGroupCodes = [];
                this.itemGroupCodes.push({
                    label : 'All',
                    value : 'All'
                });

                for (let i = 0; i < labelList.length; i++) {
                    const newItem = {
                        label: labelList[i],
                        value: valueList[i]
                    };
                    if(valueList[i] == '112' || valueList[i] == '113' || valueList[i] == '114' || valueList[i] == '117') {
                        this.itemGroupCodes.push(newItem);
                        this.AllItems.push(valueList[i]);
                    }
                }
            }).catch((error) => {
                this.error = error;
            })
    }

    handleItemGroupChange(e) {
        this.selectedItemValue = e.detail.value;
        this.loadRetailItems();
    }

    comboboxAct(e) {
        this.isDropdownOpen = !this.isDropdownOpen;
        let sldsCombobox = this.template.querySelector('.slds-combobox');

        if (this.isDropdownOpen) {
            sldsCombobox.classList.add('slds-is-open');
            document.addEventListener('click', this.handleDocumentClick);
        } 
        e.stopPropagation();
    }
    
    handleDocumentClick = (e) => {
        const dropdownContainer = this.template.querySelector('.slds-combobox');
    
        if (!dropdownContainer.contains(e.target)) {
            this.isDropdownOpen = false;
            dropdownContainer.classList.remove('slds-is-open');
            document.removeEventListener('click', this.handleDocumentClick);
        }
    }
    
    selectItem(e) {
        const idx = e.target.dataset.idx;
        const id = e.target.dataset.id;
        
        this.returnList.push({
            name: this.optionList[idx].label,
            productId: this.optionList[idx].value,
            rpmitemList: this.optionList[idx].rpmitemList
        });

        this.deleteList = this.deleteList.filter(item => item != id);
        this.updateOptions();
        this.isNonPick = this.returnList.length === 0;
        this.isDropdownOpen = true;
    }

    handleNumberChange(e) {
        const idx = e.target.dataset.idx;
        const name = e.target.name;
        try {
            if(name === 'Discount') this.returnList[idx].rpmitemList.Discount__c = e.target.value;
            if(name === 'Amount') this.returnList[idx].rpmitemList.Amount__c = e.target.value;
            if(name === 'Unit') this.returnList[idx].rpmitemList.Unit__c = e.target.value;
            if(name === 'Payout') this.returnList[idx].rpmitemList.Payout__c = e.target.value;

        } catch (error) {
            this.error = error;
        }
    }

    updateOptions() {
        const selectIdList = [];
        this.returnList.forEach(el => {
            selectIdList.push(el.productId);
        });
        const allOte = this.allItemsList.filter(item => !selectIdList.includes(item.productId));
        this.optionList = allOte.map(item => {
            return {
                label: item.name,
                value: item.productId,
                rpmitemList: item.rpmitemList
            };
        });
    }

    loadRetailItems() {
        setTimeout(() => {
            this.isLoading = true;
            if(this.selectedItemValue) {
                let selectValue = [];
                if (this.selectedItemValue == 'All') {
                    selectValue = this.AllItems;
                } else {
                    selectValue.push(this.selectedItemValue);
                }
                selectRetailMasterItemInfo({itemValue:selectValue, recordId: this.recordId})
                .then(result => {
                    if(result) {
                        this.allItemsList = JSON.parse(result.allOptions);
                        if(result.allOptions) {
                            this.allItemsList = this.allItemsList.filter(item => item.name !== 'Implements/Tires');
                            const options = this.allItemsList.map(item => ({
                                label: item.name,
                                value: item.productId,
                                rpmitemList : item.rpmitemList
                            }));
                            this.optionList = options;
                        }
                        if(result.products) {
                            this.isSelectedItems = true;
                            this.returnList = JSON.parse(result.products);
                            this.initialNumberValue = this.returnList;
                        } else {
                            this.returnList = []
                        }
                        if (this.returnList.length === 0 ) {
                            this.isNonPick = true;
                            this.isLoading = false;
                        } else {
                            this.isNonPick = false;
                            this.isLoading = false;
                        }  
                    } 
                    this.updateOptions(); 
                }).catch((error) => {
                    this.error = error;
                    this.isLoading = false;
                });
            }
        }, 1000);
    }

    loadPayout(){
        selectpayoutStructure({retailId : this.recordId})
        .then(result => {
            this.payoutList = result;
            this.payoutListValue = JSON.parse(JSON.stringify(this.payoutList));
            
        }).catch(error=> {
            this.error = error;
        });
    }

    onClickSave(e) {
        this.isLoading = true;
        try{
            insertRetailMasterItemInfo({productWrapperJSON : JSON.stringify(this.returnList)}) 
            .then(result => {
                if(result) {
                    if(result.products) {
                        this.isSelectedItems = true;
                        this.returnList = JSON.parse(result.products);
                        this.initialNumberValue = this.returnList;
                    } 

                    if(result.allOptions) {
                        this.allItemsList = JSON.parse(result.allOptions);
                        const options = this.allItemsList.map(item => ({

                            label: item.name,
                            value: item.productId,
                            rpmitemList : item.rpmitemList
                        }));
                        this.optionList = options;
                    }
                }  else {
                    this.returnList = []
                }
                deleteRow({itemValue2 : this.deleteList})
                .then((deleteRow)=>{
                    this.updateOptions();
                    this.isLoading = false;
                    this.ShowToast('Success', 'Success', 'success', 'dismissable');
                    window.location.reload();          
                })
                .catch(error =>{
                    this.error = error;
                });
            }).catch(error => {
                this.error = error;
            });
        } catch (error) {
            this.error = error;
        }
    }

    addRow(e) {
        this.secondindex++;
        const newRow = {
            RetailProgramID__c : this.recordId,
            Registered__c : '',
            Amount__c : '',
        };

        this.payoutList = [...this.payoutList, newRow];
    }

    handlePayoutChange(e) {
        const idx = e.target.dataset.index;
        const name = e.target.name;

        try {
            if(name === 'Registered') {
                if(parseInt(e.target.value) === 0) {
                    e.target.value = null;
                    throw new Error('Registered cannot be 0.');
                }
                this.payoutList[idx].Registered__c = e.target.value;
            }
            if(name === 'Amount') this.payoutList[idx].Amount__c = e.target.value;

        } catch (error) {
            this.error = error;
            this.ShowToast('Error', error.message, 'error', 'dismissable');
        }
    }

    onClickPayoutSave(e) {
        try{
            let isZero;
            this.payoutList.forEach(el => {
                if(el.Registered__c == '0' || !el.Registered__c) isZero = true;
            });
            if(isZero) {
                this.ShowToast('Error', 'Registered cannot be 0.', 'error', 'dismissable');
                return;
            }


            const dmlList = this.payoutList.filter(item => item.Registered__c !== "");

            // const dmlList2 = [];
            // this.payoutList.forEach(item => {
            //     if(item.Registered__c != null) {
            //         dmlList2.push(item);
            //     }  
            // })

            deletePayRow({payRetailId : this.deletePayoutList})
            .then((deletePayoutRow)=>{
                insertPayoutItems({payoutJSON: JSON.stringify(dmlList)}) 
                .then(result => {
                    if(result) {
                        this.payoutList = result;
                        this.payoutListValue = [...this.payoutList];
                    } else {
                        this.payoutList = [];
                    }
                    this.ShowToast('Success', 'Success', 'success', 'dismissable');
                    window.location.reload();
                }).catch(error => {
                    this.error = error;
                });
            }).catch(error =>{
                this.error = error;
            });
        } catch (error) {
            this.error = error;
        }
    }

    onClickSaveAll(e) {
        this.isLoading = true;

        setTimeout(() => {
            this.optionList.forEach(item => {

                let itemList = {
                    Amount__c : 0,
                    Discount__c : 0,
                    Unit__c : 1,
                    Payout__c : 1,
                    RetailProgramID__c: this.recordId,
                    ProductID__c: item.rpmitemList.ProductID__c
                };

                this.returnList.push({
                    name: item.label,
                    productId: item.value,
                    rpmitemList: itemList
                });
            });

            this.initialNumberValue.forEach(init => {
                this.returnList.forEach(data => {
                    if(init.productId == data.productId) {
                        data.rpmitemList.Id = init.rpmitemList.Id;
                    }
                })
            });
            
            this.deleteList = [];
            this.updateOptions();
            this.isLoading = false;
            this.isNonPick = this.returnList.length === 0;
        }, 1000);
    }

    onClickDeleteAll(e) {

        this.returnList.forEach(item => {
            this.deleteList.push(item.rpmitemList.Id);
        });

        this.returnList = [];
        this.updateOptions();
        this.isNonPick = this.returnList.length === 0;
    }

    onClickReset(e) {
        this.returnList = this.initialNumberValue;
        this.loadRetailItems();
    }
    
    onClickPayoutReset(e) {
        this.payoutList = [...this.payoutListValue];
        this.deletePayoutList = [];
    }

    removeRow(e) {
        this.idKey = e.target.dataset.id;

        if(this.deleteList.includes(this.idKey)) {
            this.deleteList = this.deleteList.filter(item => item !== this.idKey);
        } else {
            this.deleteList.push(this.idKey);
        }

        this.allItemsList.forEach(el => {
            if(el.rpmitemList.Id == this.idKey) {
                let id = el.rpmitemList.Id;
                el.rpmitemList.Id = id;
                if(this.pricingStructure == 'Dynamic' && this.programType == 'Volume Incentive') {
                    el.rpmitemList = this.initListVolumeRetailpro;
                } else el.rpmitemList = this.initListRetailpro;
            }
        });

        const key = e.target.dataset.idx;
        this.returnList.splice(key, 1);
        this.updateOptions();
    }

    removePayoutRow(e) {
        
        this.payIdkey = e.target.dataset.id;
        if(this.deletePayoutList.includes(this.payIdkey)) {
            this.deletePayoutList = this.deletePayoutList.filter(item => item !== this.payIdkey);
        } else {
            this.deletePayoutList.push(this.payIdkey);
        }

        const indexKey = e.target.dataset.idx;
        this.payoutList.splice(indexKey, 1);
    }

    onClickPointsAll(e) {
        if (this.newPointsVal !== null && this.newPointsVal !== undefined && this.newPointsVal !== '' ) {
            const newPointsValue = this.newPointsVal;
            this.returnList.forEach(item => {
                item.rpmitemList.Unit__c = newPointsValue;
            });
            this.newPointsVal = '';
        } else {
            this.ShowToast('Info', 'If there is no value, you cannot save it', 'info', 'dismissable');
        }
    }

    handlePointsAllChange(e) {
        this.newPointsVal = e.target.value;
    }

    onClickPayoutAll(e) {
        if (this.newValue !== null && this.newValue !== undefined && this.newValue !== '' && parseInt(this.newValue) !== 0) {
            const newPayoutValue = this.newValue;
            this.returnList.forEach(item => {
                item.rpmitemList.Payout__c = newPayoutValue;
            });
            
            this.newValue = '';
        } else {
            this.ShowToast('Info', 'If there is no value,(0) you cannot save it', 'info', 'dismissable');
            this.newValue = '';
        }
    }

    handlePayoutAllChange(e) {
        this.newValue = e.target.value;
    }

    onClickDiscountAll(e) {

        if (this.newDiscountVal !== null && this.newDiscountVal !== undefined && this.newDiscountVal !== '') {
            const newDiscountValue = this.newDiscountVal;
            this.returnList.forEach(item => {
                item.rpmitemList.Discount__c = newDiscountValue;
            });
            
            this.newDiscountVal = '';
        } else {
            this.ShowToast('Info', 'If there is no value, you cannot save it', 'info', 'dismissable');
        }
    }

    handleDiscountAllChange(e) {
        this.newDiscountVal = e.target.value;
    }

    onClickAmountAll(e) {
        if (this.newAmountVal !== null && this.newAmountVal !== undefined && this.newAmountVal !== '') {
            const newDiscountValue = this.newAmountVal;
            this.returnList.forEach(item => {
                item.rpmitemList.Amount__c = newDiscountValue;
            });
            
            this.newAmountVal = '';
        } else {
            this.ShowToast('Info', 'If there is no value, you cannot save it', 'info', 'dismissable');
        }
    }

    handleAmountAllChange(e) {
        this.newAmountVal = e.target.value;
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