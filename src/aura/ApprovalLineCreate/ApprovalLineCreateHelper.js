/**
 * Created by Taejun.Kang on 2023-11-13.
 */

({
    doInit : function(component, event, helper){
        var action = component.get("c.doInit");

        var recordId = component.get("v.recordId");
        action.setParams({
            'recordId'      : recordId,
            'strObjectName'	: component.get("v.sObjectName")
        });

        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                if(returnVal == 'ERROR') {
                    $A.get("e.force:closeQuickAction").fire();
                    this.showToast('error', PleaseAddAProduct);
                }
            }
        });
        $A.enqueueAction(action);
    },

    doSave : function(component, event, helper) {

        var objUser 	= component.get("v.objUser");
        var listLabel   = component.get("v.listLabel");
        var listUser  	= listLabel.userDatas;
        var fieldName  	= listLabel.fieldName;
        var insertValue ='';
        var titleField  ='';

        // inputfield 에서 입력한 라인 타이틀 가져오기 (from component)
        var strLineTitle  = component.find("LineTitle").get("v.value");

        console.log("Helper - LineTitle ::: " + strLineTitle);
        console.log("Helper - fieldName ::: " + fieldName);

        // new
        if(fieldName == '' || fieldName == null){
            if(objUser.ApprovalLine1__c == null){
                insertValue = 'ApprovalLine1/ApprovalLine1/';
                fieldName = 'ApprovalLine1';
                titleField = 'ApprovalLine1Title';
            } else if (objUser.ApprovalLine2__c == null) {
                insertValue = 'ApprovalLine2/ApprovalLine2/';
                fieldName = 'ApprovalLine2';
                titleField = 'ApprovalLine2Title';
            } else if (objUser.ApprovalLine3__c == null) {
                insertValue = 'ApprovalLine3/ApprovalLine3/';
                fieldName = 'ApprovalLine3';
                titleField = 'ApprovalLine3Title';
            } else if (objUser.ApprovalLine4__c == null) {
                insertValue = 'ApprovalLine4/ApprovalLine4/';
                fieldName = 'ApprovalLine4';
                titleField = 'ApprovalLine4Title';
            }
            console.log("titleField ??? " + titleField);

            // insertValue(승인자들) 만들기
            for(var u in listUser){
                insertValue = (u == listUser.length-1) ? insertValue+listUser[u].Id : insertValue + listUser[u].Id + '/' ;
            }
        }
        //edit 편집할때!!!!!!!!!! 여기수정
        else {
            if(fieldName == 'ApprovalLine1'){
                titleField = 'ApprovalLine1Title';
            } else if (fieldName == 'ApprovalLine2') {
                titleField = 'ApprovalLine2Title';
            } else if (fieldName == 'ApprovalLine3') {
                titleField = 'ApprovalLine3Title';
            } else if (fieldName == 'ApprovalLine4') {
                titleField = 'ApprovalLine4Title';
            }
            insertValue = fieldName + '/' +fieldName +'/';
            for(var u in listUser){
                insertValue = (u == listUser.length-1) ? insertValue+listUser[u].Id : insertValue + listUser[u].Id + '/' ;
            }
        }

        var action = component.get("c.doSave");
        action.setParams({
            "titleField"  : titleField,
            "strLineTitle": strLineTitle,
            "sId" 		  : component.get("v.sId"),
            "insertValue" : insertValue,
            "fieldName"   : fieldName,
            "objUser" 	  : component.get("v.objUser")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                console.log("titleField >>●●●●●>> " + titleField);
                console.log("strLineTitle >>●●●●●>> " + strLineTitle);

                this.showToast("Success","New Approval Line has been Saved");

                $A.get('e.force:refreshView').fire();
                console.log("■■■■■ Refreshed ■■■■■")


                /*var returnValue = response.getReturnValue();
                var values = returnValue.split('/');

                this.showToast(values[0], values[1]);*/


                /*// console.log("returnValue : " + returnValue);
                if(values[0] == "success"){
                    this.doNavigateSObject(values[2]);
                }*/
                console.log(response.getReturnValue());
            } else {
                console.log(response.getReturnValue());
            }
        });

        $A.enqueueAction(action);

        /*scroll 방지 해제*/
        // document.body.style.overflow="auto";
    },


    doSubmit : function(component, event, helper){
        console.log("doSubmit ★");
        var strComments  = component.find("comments").get("v.value");
        var listLabel = component.get("v.listLabel.userDatas");
        var action    = component.get("c.doSubmit");

        action.setParams({
            'strObjectName' 	: component.get("v.sObjectName"),
            'strComments'    	: strComments,
            'sHistoryRecordId'  : component.get("v.sId"),
            'listApproverId'   	: listLabel.map(data => data.Id)
        });

        action.setCallback(this, function(response){

            var state = response.getState();
            console.log("State >>>>>>>> " + state);
            if (state === "SUCCESS"){
                this.showToast("Success", "Successfully Requested.");

                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();

            }

            else if (state === "ERROR"){
                var errors = response.getError();
                var message = errors[0].message;

//                console.log('이미 승인 요청된 데이터 에러메세지 >>>>> '+errors[0].message);
//                this.showToast("Error", "이미 요청된 데이터입니다.");

                if (errors) {
                    if(message.indexOf('ALREADY_IN_PROCESS') != -1) {

                        this.showToast('ERROR', "Approval is processing already.");
                        $A.get("e.force:closeQuickAction").fire();

                    }

                    else if (errors[0] && message) {
                        this.showToast("error", message)
                    }
                }

                else {
                    this.showToast("error", "Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },



    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },

    showSpinner: function (component) {
            /* this will show the <lightning:spinner /> */
            component.set('v.isShowSpinner', true);
        },

    hideSpinner: function (component) {
        /* this will hide the <lightning:spinner /> */
        component.set('v.isShowSpinner', false);
    },




});