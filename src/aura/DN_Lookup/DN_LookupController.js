/**
 * Created by 천유정 on 2022-08-17.
 */

({
     doInit: function (component, event, helper) {  
        console.log('--------------------------------------------------     DN_Lookup.doInit - start');

        var objectName = component.get('v.objectName');
        console.log('>>>> objectName : '+objectName);

        component.set('v.queryErrorMessage','');
        component.set('v.queryErrorFound',false);
        component.set('v.lookupInputFocused',false);

        // 다중 선택인 경우 넘겨받은 오브젝트 리스트로 필 셋팅
        if(component.get('v.multiSelect')) {
            console.log('--------------------------------------------------     v.multiSelect == true');
            var values = component.get('v.selectedObject');
            var primaryDisplayField = component.get('v.primaryDisplayField');
            var listLookupIds = [], listSelectedOptions = [], listSelectedObject = [];
            for(var i in values) {
                var obj = values[i];

                listLookupIds.push(obj.Id);
                listSelectedOptions.push(obj[primaryDisplayField]);
            }

            component.set('v.listLookupIds', listLookupIds);
            component.set('v.selectedId', listLookupIds.length === 0 ? undefined : listLookupIds.join(';'));
            component.set('v.listSelectedOptions', listSelectedOptions);
        }
//        console.log('v.selectedId      '+component.set('v.selectedId','merong'));
        console.log('--------------------------------------------------     DN_Lookup.doInit - END');

        // Edit 화면에서 라벨로 표기할 값
        var displayLabel = component.get("v.displayLabel");
        if(displayLabel) {
            component.set("v.selectedLabel", displayLabel);
        }

        component.set('v.selectedIndex',undefined);
        component.set('v.searching',false);
    },

    // 검색어 입력란 이벤트
    searchRecords : function(component,event,helper) {
        console.log('-------------------------------------------------------    DN_Lookup.searchRecords - start');

        var keyCode = event.getParams().keyCode;
        var userEnteredValue = component.get('v.enteredValue');
        var sObjectType = component.get('v.objectName');
        var fields = component.get('v.fieldSet');
        var conditions = component.get('v.whereCondition');
        var limit = component.get('v.limit');
        var comparisonField = component.get('v.comparisonField');
        var primaryDisplayField = component.get('v.primaryDisplayField');
        var minimumCharacter = component.get('v.minimumCharacter');
        var objectList = component.get('v.objectList');
        var selectedObjectIndex = component.get('v.selectedIndex');
        var openResults = component.get('v.openResults');
        var objectListLength = objectList.length;

        // 검색 결과 모달 li의 인덱스가 0으로 설정되기 때문
        if(openResults) {
            objectListLength++;
        }

        console.log('keyCode', keyCode);
        switch(keyCode) {
            //up key
            case 38:
                if(objectListLength > 0 || openResults) {
                    if(selectedObjectIndex != undefined && selectedObjectIndex-1 >=0) {
                        selectedObjectIndex--;
                        component.set('v.selectedIndex',selectedObjectIndex);
                    } else if((selectedObjectIndex != undefined && selectedObjectIndex-1 <0) || selectedObjectIndex == undefined) {
                        selectedObjectIndex = objectListLength-1;
                        component.set('v.selectedIndex',selectedObjectIndex);
                    }
                }
                break;
            //down key
            case 40:
                if(objectListLength > 0 || openResults) {
                    if(selectedObjectIndex != undefined && selectedObjectIndex+1 < objectListLength) {
                        selectedObjectIndex++;
                        component.set('v.selectedIndex',selectedObjectIndex);
                    } else if((selectedObjectIndex != undefined && selectedObjectIndex+1 ==objectListLength) || selectedObjectIndex == undefined) {
                        selectedObjectIndex = 0;
                        component.set('v.selectedIndex',selectedObjectIndex);
                    }
                }
                break;
            //escape key
            case 27 :
                component.set('v.objectList',[]);
                component.set('v.lookupInputFocused',false);
                break;
            //enterKey
            case 13:
                if(openResults && selectedObjectIndex === 0) {
                    helper.doOpenModal(component);
                } else if(userEnteredValue == '') {
                    var query = "SELECT Id,"+fields.join(",")+" FROM "+sObjectType + " WHERE ";
                    if(conditions != undefined && conditions != '') query = query +" "+ conditions;
                    query += " ORDER BY Name "; //22.12.15 - 이름순으로 정렬 
                    query += " LIMIT "+limit;
                    console.log('query '+ query);
                    component.set('v.query', query);
                    helper.doOpenModal(component);
                } else if(userEnteredValue.toUpperCase() === 'ALL') {
                    helper.doOpenModal(component);
                } else {
                    var objectList = component.get('v.objectList');
                    var selectedObjectIndex = component.get('v.selectedIndex');
                    if(openResults) selectedObjectIndex--;

                    helper.onValueselect(component, objectList[selectedObjectIndex], selectedObjectIndex);
                }

                break;
            //Right Key:
            case 39 :
                //don't to anything
                break;
            //Left Key
            case 37 :
                //don't to anything
                break;
            //CapsLock Key
            case 20 :
                //don't to anything
                break;
            //home
            case 35 :
                //don't to anything
                break;
            //End
            case 36 :
                //don't to anything
                break;
            //any other character entered.
            default:
                // component.set('v.selectedObject',undefined);
                component.set('v.selectedLabel','');
                component.set('v.queryErrorMessage','');
                component.set('v.queryErrorFound',false);

                if(minimumCharacter === '' || !minimumCharacter || userEnteredValue.length >= minimumCharacter) {
                    component.set('v.searching',true);
                    component.set('v.objectList',[]);

                    var comparisionStringArray=[];
                    //코드추가
                    console.log('userEnteredValue ==========> ' + userEnteredValue);
                    if (userEnteredValue.toUpperCase() === 'ALL') {
                        var query = "SELECT Id,"+fields.join(",")+" FROM "+sObjectType + " WHERE "; 
                    } else {
                        for(var i = 0;i<comparisonField.length;i++) {
                            comparisionStringArray.push(comparisonField[i]+" LIKE '"+userEnteredValue+"%'"); //22.12.15 - 제품검색 시 시작하는 단어로 검색 (앞에 %제외)
                        }
                        var comparisionString = comparisionStringArray.join(' OR ');
                        var query = "SELECT Id,"+fields.join(",")+" FROM "+sObjectType+" WHERE ("+comparisionString+") AND";
                    }

                   /* for(var i = 0;i<comparisonField.length;i++) {
                        comparisionStringArray.push(comparisonField[i]+" LIKE '%"+userEnteredValue+"%'");
                    }
                    var comparisionString = comparisionStringArray.join(' OR ');
                    var query = "SELECT Id,"+fields.join(",")+" FROM "+sObjectType+" WHERE ("+comparisionString+") AND";*/

                    if(conditions != undefined && conditions != '') {
                        query = query +" "+ conditions;
                    }
                    query += " ORDER BY Name "; //22.12.15 - 이름순으로 정렬
                    query += " LIMIT "+limit;
                    console.log('query '+ query);
                    component.set('v.query', query);

                    helper.doQueryRecords(component);
                } else {
                    component.set('v.objectList',[]);
                    component.set('v.selectedIndex',undefined);
                    component.set('v.searching',false);
                }
        }

    },
    inputBlurred : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.inputBlurred - start');

        //component.set('v.lookupInputFocused',false);
        //delaying the setting of this flag. This is to make sure that the flag is set post the selection of the dropdown.
        window.setTimeout(
            $A.getCallback(function() {
                component.set('v.lookupInputFocused',false);
            })
            , 200);
    },
    inputInFocus : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.inputInFocus - start');
        component.set('v.lookupInputFocused',true);
    },

    // 검색 결과 li 이벤트
    showColorOnMouseEnter : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.showColorOnMouseEnter - start');

        $A.util.addClass( event.currentTarget, 'highlight');
    },
    hideColorOnMouseLeave : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.hideColorOnMouseLeave - start');

        $A.util.removeClass( event.currentTarget, 'highlight');
    },

    // 선택값 제거
    removeSelectedOption : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.removeSelectedOption - start2');

        helper.doRemoveOption(component, event);
    },

    // 검색 결과 레코드 클릭하여 선택
    onRowSelected : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.onRowSelected - start');

        var openResults = component.get('v.openResults');
        var currentIndex = event.currentTarget.dataset.currentIndex;
        component.set('v.selectedIndex', parseInt(currentIndex));

        // 검색 결과 모달 li를 선택한 경우
        if(openResults && parseInt(currentIndex) === 0) {
            helper.doOpenModal(component);
        }
        else {
            var objectList = component.get('v.objectList');
            var selectedObjectIndex = component.get('v.selectedIndex');
            console.log('-------------------------------------------------------   objectList[selectedObjectIndex] ' + JSON.stringify(objectList[selectedObjectIndex]));
            if(openResults) selectedObjectIndex--;

            helper.onValueselect(component, objectList[selectedObjectIndex], selectedObjectIndex);
        }
    },

    // 다중 선택 필 키업 이벤트
    fnKeyupItem : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnKeyupItem - start');

        var keyCode = event.keyCode;

        switch(keyCode) {
            //escape key
            case 27:
                helper.doRemoveOption(component, event);

                break;
        }
    },

    // 검색 결과 모달에서 레코드 선택
    fnResultSelected : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnResultSelected - start');

        var currentIndex = event.currentTarget.dataset.currentIndex;
        var pagingDatas = component.get('v.pagingDatas');
        var primaryDisplayField = component.get('v.primaryDisplayField');

        var valid = helper.onValueselect(component, pagingDatas[currentIndex], currentIndex);
        if(valid) {
            helper.doCloseModal(component);
        }
    },

    // 레코드 검색 결과 모달에서 검색
    fnHandleKeyup : function(component, event, helper) {
        console.log('-------------------------------------------------------    DN_Lookup.fnHandleKeyup - start');

        var isEnterKey = event.keyCode === 13;

        if(isEnterKey) {
            component.set('v.isShowSpinner', true);

            var userEnteredValue = component.find("searchKey").get("v.value");
            var comparisonField = component.get('v.comparisonField');
            var comparisionStringArray = [];
            for(var i = 0;i<comparisonField.length;i++) {
                //22.12.15 - 제품검색 시 시작하는 단어로 검색 (앞에 %제외)
                comparisionStringArray.push(comparisonField[i]+" LIKE '"+userEnteredValue+"%'");
            }

            var fields = component.get('v.fieldSet');
            var sObjectType = component.get('v.objectName');
            var conditions = component.get('v.whereCondition');
            var limit = component.get('v.limit');
            var comparisionString = comparisionStringArray.join(' OR ');

            var query = "SELECT Id,"+fields.join(",")+" FROM "+sObjectType+" WHERE ("+comparisionString+")";
            if(conditions != undefined && conditions != '') {
                query = query +" AND"+ conditions;
            }
            // query += " LIMIT "+limit;
            console.log(query);

            helper.getLookupDatas(component, query);
        }
    },

    fnKeyUpModal : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnKeyUpModal - start');

        if(event.keyCode === 27) { // ESC
            helper.doCloseModal(component);
        }
    },

    fnSearchClose : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnSearchClose - start');

        helper.doCloseModal(component);
    },

    fnRenderPage: function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnRenderPage - start');

        component.set('v.isShowSpinner', true);
        helper.doRenderPage(component);
    },

    // 필수값 체크
    fnCheckRequired : function(component, event, helper) {
//        console.log('-------------------------------------------------------    DN_Lookup.fnCheckRequired - start');

        var isValid = true;
        var isRequired = component.get("v.required");
        var lookUpInputElement = component.find("lookUpInputElement");

        if(isRequired && lookUpInputElement && !component.get("v.selectedId")) {
            isValid = false;
        }

        return isValid;
    },
});