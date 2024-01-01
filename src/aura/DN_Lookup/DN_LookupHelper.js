/**
 * Created by 천유정 on 2022-08-17.
 */

({
    // 만들어진 쿼리로 레코드 조회 
    doQueryRecords : function(component) {
        console.log('--------------------------------------------------     DN_Lookup.helper.doQueryRecords - start');
        var action = component.get('c.querySalesforceRecord');
        action.setParams({queryString : component.get('v.query')});
        action.setCallback(this, function(response){
            var responseState = response.getState();
            console.log('--------------------------------------------------     DN_Lookup.helper.responseState -' + responseState);
            console.log('--------------------------------------------------     DN_Lookup.helper.response.getReturnValue() -' + response.getReturnValue());
            if(responseState === 'SUCCESS') {
                component.set('v.objectList',response.getReturnValue());
                component.set('v.selectedIndex',undefined);
                component.set('v.searching',false);
                component.set('v.lookupInputFocused',true);
                console.log('--------------------------------------------------     DN_Lookup.helper.objectList -' + JSON.stringify(component.get("v.objectList")));
            }else {
                component.set('v.queryErrorMessage',response.getError()[0].message);
                component.set('v.queryErrorFound',true);
                component.set('v.objectList',[]);
                component.set('v.selectedIndex',undefined);
                component.set('v.searching',false);
                console.log('error',response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    onValueselect : function(component, selectedObject, selectedObjectIndex) {
        console.log('--------------------------------------------------     DN_Lookup.helper.onValueselect - start');
        console.log('@@@ selectedObjectIndex @@@');
        console.log(selectedObjectIndex);
        if(!selectedObject || selectedObjectIndex == undefined) {
            return false;
        } else {
            var primaryDisplayField = component.get('v.primaryDisplayField');

            if(component.get('v.multiSelect')) {
                var listSelectedOptions = component.get('v.listSelectedOptions');
                var listSelectedObject = component.get('v.selectedObject');
                if(!listSelectedObject) listSelectedObject = [];

                // 중복 선택 검사
                var isValid = true;
                for(var i in listSelectedObject) {
                    var obj = listSelectedObject[i];
                    if(obj.Id == selectedObject.Id) {
                        isValid = false;
                        this.showToast('error', '중복 선택 하셨습니다.');
                        break;
                    }
                }

                if(!isValid) return;

                // 유효성 검사 통과
                var listLookupIds = component.get('v.listLookupIds');

                listLookupIds.push(selectedObject.Id);
                listSelectedObject.push(selectedObject);
                listSelectedOptions.push(selectedObject[primaryDisplayField]);

                component.set('v.selectedObject', listSelectedObject);
                component.set('v.listSelectedOptions', listSelectedOptions);
                component.set('v.selectedId', listLookupIds.join(';'));
                component.set('v.listLookupIds', listLookupIds);
            } else {
                component.set('v.selectedObject',selectedObject);
                component.set('v.selectedLabel',selectedObject[primaryDisplayField]);
                component.set('v.selectedName',selectedObject['Name']); //23.10.23 수기로 추가함 
                component.set('v.selectedId',selectedObject['Id']);
                component.set('v.lookupInputFocused',false);
            }
            component.set('v.enteredValue','');

            var lookupSelectedEvent = component.getEvent('lookupSelected');
                lookupSelectedEvent.setParams({
                    'uniqueLookupIdentifier' : component.get('v.uniqueLookupIdentifier'),
                    'selectedId' : component.get('v.selectedId'),
                    'selectedLabel' : component.get('v.selectedLabel'),
                    'selectedName' : component.get('v.selectedName'),
                    'selectedObject' : component.get('v.selectedObject')
                });
            lookupSelectedEvent.fire();

            return true;
        }
    },

    doRemoveOption : function(component, event) {
        console.log('--------------------------------------------------     DN_Lookup.doRemoveOption - start');

        var listSelectedObject = component.get('v.selectedObject');
        var selectedObject = JSON.stringify(component.get('v.selectedObject'));

        var selectedObjectIndex = component.get('v.selectedIndex');

        console.log('@@@ selectedObjectIndex @@@');
        console.log(selectedObjectIndex);

        if(selectedObjectIndex == undefined) {
            //return false;
        }

        if(component.get('v.multiSelect')) {

            var idx = event.currentTarget.dataset.idx;
            var listSelectedOptions = component.get('v.listSelectedOptions');
            var listLookupIds = component.get('v.listLookupIds');

            listLookupIds.splice(idx, 1);
            listSelectedObject.splice(idx, 1);
            listSelectedOptions.splice(idx, 1);

            component.set('v.listSelectedOptions', listSelectedOptions);
            component.set('v.selectedObject', listSelectedObject);
            component.set('v.selectedId', (listLookupIds.join(';') === '' ? undefined : listLookupIds.join(';')));
        } else {
            component.set('v.selectedObject',undefined);
            component.set('v.selectedLabel','');
            component.set('v.selectedName','');
            component.set('v.selectedId',undefined);
        }

        component.set('v.enteredValue', '');

        var selectedLookupRemoved = component.getEvent('selectedLookupRemoved');
        selectedLookupRemoved.setParams({
            'uniqueLookupIdentifier' : component.get('v.uniqueLookupIdentifier'),
            'selectedId' : component.get('v.selectedId'),
            'selectedLabel' : component.get('v.selectedLabel'),
            'selectedName' : component.get('v.selectedName'),
            'selectedObject' : component.get('v.selectedObject')
        });
        selectedLookupRemoved.fire();
    },

    getLookupDatas : function(component, query, searchKey) {
        var action = component.get('c.getLookupDatas');
        action.setParams({
            query           : query,
            sObjectName     : component.get('v.objectName'),
            fieldSet        : component.get('v.fieldSet'),
            searchKey       : searchKey,
            viewObjectName  : component.get('v.viewObjectName'),
            viewObjectId    : component.get('v.viewObjectId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
console.log('!!!!!1111111 !');
            if(state === 'SUCCESS') {
                console.log('!!!!!!');
                var result = response.getReturnValue();

                component.set('v.tableColumns', result.listColumns);
                component.set('v.tableDatas', result.listDatas);

                var dataLength = component.get('v.tableDatas').length;

                component.set('v.pageNumber', 1);
                component.set('v.total', dataLength);
                component.set('v.pages', Math.ceil(dataLength / 15));
                component.set('v.maxPage', Math.floor((dataLength + 19) / 20));

                this.doRenderPage(component);
            }
        });

        $A.enqueueAction(action);
    },

    doRenderPage: function(component) {
        var tableDatas = component.get('v.tableDatas');
        var pageNumber = component.get('v.pageNumber');
        var pageRecords = tableDatas.slice((pageNumber - 1) * 20, pageNumber * 20);

        component.set('v.pagingDatas', pageRecords);
        component.set('v.isShowSpinner', false);
        component.find('searchKey').focus();
    },

    // 레코드 검색 결과 모달
    doOpenModal : function(component) {
        // 메인 페이지 scroll 방지
        document.body.style.overflow = 'hidden';
        component.set('v.isOpenModal', true);
        component.set('v.isShowSpinner', true);
        component.find('searchKey').set('v.value', component.get('v.enteredValue'));

        this.getLookupDatas(component, component.get('v.query'), component.get('v.enteredValue'));
    },
    doCloseModal : function(component) {
        // 메인 페이지 scroll 방지 해제
        document.body.style.overflow = 'auto';
        component.set('v.isOpenModal', false);
        component.set('v.isShowSpinner', false);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },
});