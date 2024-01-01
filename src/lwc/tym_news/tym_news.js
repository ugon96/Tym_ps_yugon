/*************************************************************
 * @author : th.kim
 * @date : 2023-12-07
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-07      th.kim         Initial Version
**************************************************************/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNews from '@salesforce/apex/TYM_NewsController.getNews';

const categoryOptions = [
    { 'label': 'All', 'value': 'All' },
    { 'label': 'Corporate', 'value': 'Corporate' },
    { 'label': 'ESG', 'value': 'ESG' },
    { 'label': 'Others', 'value': 'Others' },
    { 'label': 'Tractor', 'value': 'Tractor' }
];

const sortOptions = [
    { 'label': 'Most recent', 'value': 'Most recent' },
    { 'label': 'Oldest', 'value': 'Oldest' }
];

export default class TymNews extends NavigationMixin(LightningElement) {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    categoryValue = 'All';
    topicValue = 'All';
    sortValue = 'Most recent';
    categoryOptions = categoryOptions;
    sortOptions = sortOptions;
    @track listReturn = [];
    @track pageArea = [];
    @track pageNumList = [];
    @track pageNum = 1;
    page;
    pageListNumLength;
    pageAreaNum;
    // isAddButton;
    isLoading;

    connectedCallback() {
        this.pageNum = this.pageRef.state.pageNum ? this.pageRef.state.pageNum : 1;
        this.pageAreaNum = this.pageRef.state.pageAreaNum ? Number(this.pageRef.state.pageAreaNum) : 0;
        this.getDatas();
    }

    onCategoryChange(e) {
        this.categoryValue = e.target.value;
        this.pageNum = 1;
        this.getDatas();
    }

    onSortChange(e) {
        this.sortValue = e.target.value;
        this.pageNum = 1;
        this.getDatas();
    }

    onContentsClick(e) {
        const id = e.currentTarget.dataset.id;
        console.log('id :: ',id);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'tymNewsDetail__c'
            },
            state: {
                recordId: id,
                pageNum: this.pageNum,
                pageAreaNum: this.pageAreaNum
            }
        });
    }

    onTopicClick(e) {
        e.stopPropagation();
        this.topicValue = e.target.dataset.type;
        const nonTarget = this.template.querySelectorAll('.active');
        const target = this.template.querySelector('button[data-type="' + this.topicValue + '"]');
        nonTarget.forEach(el => {
            el.classList.remove('active');
        });
        target.classList.add('active');
        this.pageNum = 1;
        this.getDatas();
    }

    onCategoryClick(e) {
        e.stopPropagation();
        console.log('target :: ',e.target.dataset.value);
        this.categoryValue = e.target.dataset.value;
        this.pageNum = 1;
        this.getDatas();
    }

    // onShowMoreButton() {
    //     if (this.pageNum < this.page) {
    //         this.pageNum++;
    //         this.getDatas();
    //     }
    // }

    /** 페이징 숫자 클릭 */
    onPageNumClick(e) {
        this.pageNum = Number(e.target.label);
        this.getDatas();
    }

    /** 페이징 화살표 클릭 */
    onArrowClick(e) {
        const arrow = e.target.label;
        switch (arrow) {
            case '<<':
                if (this.pageAreaNum > 0) {
                    this.pageAreaNum--;
                    this.pageNum = 1 + (this.pageAreaNum * 5);
                    this.getDatas();
                } else {
                    this.pageNum = 1;
                    this.getDatas();
                }
                break;
            case '<':
                if (this.pageNum % 5 == 1 && this.pageAreaNum !== 0) {
                    this.pageAreaNum--;
                    this.pageNum = 1 + (this.pageAreaNum * 5);
                    this.getDatas();
                } else if (this.pageNum % 5 !== 1) {
                    this.pageNum--;
                    this.getDatas();
                }
                break;
            case '>':
                if (this.pageNum % 5 == 0 && this.pageAreaNum !== this.pageArea.length - 1) {
                    this.pageAreaNum++;
                    this.pageNum = 1 + (this.pageAreaNum * 5);
                    this.getDatas();
                } else if (this.pageNum % 5 !== 0 && this.pageNum !== this.pageListNumLength) {
                    this.pageNum++;
                    // console.log(this.pageNumList[this.pageNum-1]);
                    // this.pageNumList[this.pageNum - 1].active = true;
                    this.getDatas();
                }
                break;
            case '>>':
                if (this.pageAreaNum !== this.pageArea.length - 1) {
                    this.pageAreaNum++;
                    this.pageNum = (1 + (5 * this.pageAreaNum));
                    this.pageNumList = this.pageArea[this.pageAreaNum];
                    this.getDatas();
                } else {
                    this.pageNum = this.pageListNumLength;
                    this.getDatas();
                }
                break;
        }
    }

    /** 데이터 가져오기 */
    getDatas() {
        this.isLoading = true;
        this.listReturn = [];
        getNews({
            count: this.pageNum,
            category: this.categoryValue,
            topic: this.topicValue,
            sortType: this.sortValue
        }).then(res => {
            console.log('res :: ', res);
            if (res.size > 0) {
                this.page = Number(res.page);
                this.listReturn = JSON.parse(res.listReturn);
                this.listReturn.forEach(el => {
                    if (!el.objContents) {
                        el.objContents = { Name: null, ContentDownloadUrl: null };
                    }
                });

                // 페이징 버튼 만들기
                this.pageListNumLength = Math.ceil(this.page);
                let pageTempList = [];
                this.pageArea = [];
                for (let i = 1; i <= this.pageListNumLength; i++) {
                    pageTempList.push({value : i});
                    if (i % 5 === 0) {
                        this.pageArea.push(pageTempList);
                        pageTempList = [];
                    }
                    else if (i === this.pageListNumLength) {
                        this.pageArea.push(pageTempList);
                        pageTempList = [];
                    }
                }
                this.pageNumList = this.pageArea[this.pageAreaNum];
                this.pageNumList.forEach(el => {
                    if(el.value == this.pageNum) el.active = true;
                    else el.active = false;
                });
            } else {
                this.pageArea = [];
                this.pageNumList = [1];
            }
            // if(this.count >= this.page) this.isAddButton = false;
            // else this.isAddButton = true;
            this.isLoading = false;
        }).catch(err => {
            console.log('err :: ', err);
            this.isLoading = false;
        });
    }
}