/* eslint-disable radix */
/* eslint-disable default-case */
import { LightningElement, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import customCSS from "@salesforce/resourceUrl/customCSS";
import searchForecast from "@salesforce/apex/TYM_ForecastController.searchForecast";
import dmlForecast from "@salesforce/apex/TYM_ForecastController.dmlForecast";
import USER_ID from "@salesforce/user/Id";
// import SuccessMessage from "@salesforce/label/c.ForecastWasSuccessfullyCreatedUpdated";
import SaveBtn from "@salesforce/label/c.Save";
import CancelBtn from "@salesforce/label/c.Cancel";
import SearchBtn from "@salesforce/label/c.Search";
import Year from "@salesforce/label/c.Year";
import Products from "@salesforce/label/c.Products";

export default class Tym_forecast extends LightningElement {

    label = {
        SaveBtn,
        CancelBtn,
        SearchBtn,
        Year,
        Products
    };

    @track productReturn = [];
    @track filteredOptions = [];
    @track selectedValues = [];
    @track optionLength = 0;
    @track productDataList = [];
    @track initListForecast = [{ "Product__c": "", "X1__c": 0, "X2__c": 0, "X3__c": 0, "X4__c": 0, "X5__c": 0, "X6__c": 0, "X7__c": 0, "X8__c": 0, "X9__c": 0, "X10__c": 0, "X11__c": 0, "X12__c": 0 }];
    deleteList = [];
    picklistValue;
    error;
    searchYear = '';
    forecastEdit;
    tempForecast;
    isLoaded;
    isHideBtn = false;
    isAddButtonTrue = true;
    listForecast = [];

    //hook
    connectedCallback() {
        let today = new Date();
        let currentYear = today.getFullYear();
        this.searchYear = currentYear;
        this.handleSearch();
    }

    renderedCallback() {
        /* loadStyle(this, customCSS + "/customCSS.css"); */
    }

    //function
    handleYearChange(event) {
        this.searchYear = event.target.value;
    }

    /** Product Input 클릭 시 드롭다운 Active */
    toggleDropdown(e) {
        const idx = e.target.dataset.idx;
        if (!this.productDataList[idx].isDropdown && this.optionLength > 0) {
            if (this.isAddButtonTrue || !this.productDataList[idx].Id) {
                this.productDataList.forEach(el => {
                    el.isDropdown = false;
                    console.log(el);
                });
                this.productDataList[idx].isDropdown = true;
            }
        } else {
            this.productDataList[idx].isDropdown = false;
        }
    }

    /** 드롭다운 옵션 클릭 */
    dropdownClick(e) {
        const idx = e.target.dataset.idx;
        const optionIdx = e.target.dataset.optionidx;
        const data = e.target.dataset;
        if (this.productDataList[idx].Id) {
            this.selectedValues = this.selectedValues.filter(value => value !== this.productDataList[idx].Id);
        }
        this.productDataList[idx] = {
            Id: data.id,
            Name: data.name,
            imgUrl: data.imgUrl,
            listForecast: this.filteredOptions[optionIdx].listForecast,
            isDropdown: false
        };
        this.dropdownFiltering();
    }

    /** + Add Product 버튼 */
    handleAdd() {
        this.productDataList.push({ listForecast: this.initListForecast });
        this.calcListLength();
    }

    /** Forecast Qunatity 데이터 입력 onchange() */
    handleNumberChange(event) {
        let indexRow = parseInt(event.currentTarget.dataset.indexrow);
        let indexColumn = parseInt(event.currentTarget.dataset.indexcolumn);
        try {
            if (this.productDataList) {
                switch (indexColumn) {
                    case 1:
                        if (event.target.name === "Probability01") this.productDataList[indexRow].listForecast[0].Probability01__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X1__c = parseInt(event.target.value);
                        break;
                    case 2:
                        if (event.target.name === "Probability02") this.productDataList[indexRow].listForecast[0].Probability02__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X2__c = parseInt(event.target.value);
                        break;
                    case 3:
                        if (event.target.name === "Probability03") this.productDataList[indexRow].listForecast[0].Probability03__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X3__c = parseInt(event.target.value);
                        break;
                    case 4:
                        if (event.target.name === "Probability04") this.productDataList[indexRow].listForecast[0].Probability04__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X4__c = parseInt(event.target.value);
                        break;
                    case 5:
                        if (event.target.name === "Probability05") this.productDataList[indexRow].listForecast[0].Probability05__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X5__c = parseInt(event.target.value);
                        break;
                    case 6:
                        if (event.target.name === "Probability06") this.productDataList[indexRow].listForecast[0].Probability06__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X6__c = parseInt(event.target.value);
                        break;
                    case 7:
                        if (event.target.name === "Probability07") this.productDataList[indexRow].listForecast[0].Probability07__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X7__c = parseInt(event.target.value);
                        break;
                    case 8:
                        if (event.target.name === "Probability08") this.productDataList[indexRow].listForecast[0].Probability08__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X8__c = parseInt(event.target.value);
                        break;
                    case 9:
                        if (event.target.name === "Probability09") this.productDataList[indexRow].listForecast[0].Probability09__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X9__c = parseInt(event.target.value);
                        break;
                    case 10:
                        if (event.target.name === "Probability10") this.productDataList[indexRow].listForecast[0].Probability10__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X10__c = parseInt(event.target.value);
                        break;
                    case 11:
                        if (event.target.name === "Probability11") this.productDataList[indexRow].listForecast[0].Probability11__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X11__c = parseInt(event.target.value);
                        break;
                    case 12:
                        if (event.target.name === "Probability12") this.productDataList[indexRow].listForecast[0].Probability12__c = parseFloat(event.target.value);
                        else this.productDataList[indexRow].listForecast[0].X12__c = parseInt(event.target.value);
                        break;
                }
            }
        } catch (error) {
            this.showToast("Error", error.body.message, "Error");
        }
    }

    /** Product 삭제 버튼 */
    handleDelete(e) {
        const idx = e.target.dataset.idx;
        const id = e.target.dataset.id;
        const fId = e.target.dataset.fid;
        if (!this.deleteList.includes(fId) || fId) this.deleteList.push(fId);
        if (this.productDataList.length > 1) {
            this.productDataList.splice(idx, 1);
        } else {
            this.productDataList = [{ listForecast: this.initListForecast }];
        }
        this.productReturn.forEach(el => {
            if(el.Id == id) el.listForecast = this.initListForecast;
        });
        // this.selectedValues = this.selectedValues.filter(value => value !== id);
        // this.filteredOptions = this.productReturn.filter(option => {
        //     // 선택한 값이 없거나 현재 옵션의 programId가 선택한 값 중에 포함되지 않으면 반환
        //     return !this.selectedValues.length || !this.selectedValues.includes(option.Id);
        // });
        this.productDataList.forEach(el => {
            el.isDropdown = false;
        });
        this.dropdownFiltering();
        this.calcListLength();
    }

    handleSave() {
        this.isLoaded = false;
        try {
            dmlForecast({
                productWrapperJSON: JSON.stringify(this.productDataList),
                userId: USER_ID,
                searchYear: this.searchYear,
                deleteList: this.deleteList
            }).then((result) => {
                if (result) {
                    console.log('res :: ', result);
                    if (result.products) {
                        this.productDataList = JSON.parse(result.products);
                        if (this.productDataList.length < 1) this.productDataList.push({ listForecast: this.initListForecast });
                        this.showToast("Success", 'Success Message', "success"); // 커스텀 라벨 교환 필요
                        this.isLoaded = true;
                        // window.location.reload();
                    } else {
                        this.productDataList = [];
                        this.isLoaded = true;
                        this.isHideBtn = true;
                    }
                }
            }).catch((error) => {
                this.showToast("Error", error.body.message, "Error");
            });
        } catch (error) {
            this.isLoaded = true;
            this.showToast("Error", error.body.message, "Error");
        }
    }

    handleCancel() {
        this.handleSearch();
    }

    handleSearch() {
        this.isLoaded = false;
        try {
            searchForecast({ userId: USER_ID, searchYear: this.searchYear })
                .then((result) => {
                    if (result) {
                        console.log('res.product :: ', result.products);
                        if (result.products) {
                            this.productReturn = JSON.parse(result.products);
                            console.log('res :: ', JSON.stringify(this.productReturn));
                            this.productDataList = [];
                            this.filteredOptions = [];
                            this.selectedValues = [];
                            this.filteredOptions = this.productReturn;
                            this.optionLength = this.filteredOptions.length;
                            this.productReturn.forEach(el => {
                                if (el.isExistence) this.productDataList.push(el);
                            });
                            if (this.productDataList.length < 1) this.productDataList.push({ listForecast: this.initListForecast });
                            // this.productDataList.forEach(el => {
                                this.dropdownFiltering();
                            // });
                            this.calcListLength();

                            this.isLoaded = true;
                            this.isHideBtn = false;
                        } else {
                            this.productReturn = [];
                            this.isLoaded = true;
                            this.isHideBtn = true;
                        }
                    }
                }).catch((error) => {
                    this.showToast("Error", error.body.message, "Error");
                });
        } catch (error) {
            this.isLoaded = true;
            this.showToast("Error", error.body.message, "Error");
        }
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({ variant: type, title: title, message: message });
        this.dispatchEvent(event);
    }

    /** 드롭다운 옵션 길이 체크해서 버튼 Disabled or Active */
    calcListLength() {
        if (this.productDataList.length >= this.optionLength) {
            this.isAddButtonTrue = false;
        } else {
            this.isAddButtonTrue = true;
        }
    }

    /** 선택한 드롭다운 옵션은 현재 드롭다운 옵션에서 필터링 하는 함수 */
    dropdownFiltering() {
        const filterDataList = [];
        this.productDataList.forEach(el => {
            filterDataList.push(el.Id);
        });
        this.filteredOptions = this.productReturn.filter(option => !filterDataList.includes(option.Id));
        // const isSelected = this.selectedValues.includes(id);
        // if (isSelected) {
        //     this.selectedValues = this.selectedValues.filter(value => value !== id);
        // } else {
        //     this.selectedValues = [...this.selectedValues, id];
        // }
        // this.filteredOptions = this.productReturn.filter(option => {
        //     return !this.selectedValues.length || !this.selectedValues.includes(option.Id);
        // });
    }
}