/**
 * Created by Taejun.Kang on 2023-11-13.
 */

({
    fnInit  : function(component, event, helper) {
        var listLabel = component.get("v.listLabel");
        var fieldName = component.get("v.fieldName");
        var iApproverLimit = component.get("v.iApproverLimit");


    },

    fnClose : function(component, event, helper) {
        if(component.get('v.bHistory')){
            var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
            $A.util.removeClass(modal, 'slds-show');
            $A.util.addClass(modal, 'slds-hide');
            $A.get("e.force:closeQuickAction").fire();
            component.set('v.holidayModalView', false);
            /*scroll 방지 해제*/
            document.body.style.overflow="auto";
        } else {
            var evt = component.getEvent("closeSearchResultEvt");
            evt.fire();
        }
    },

    fnViewControll : function(component, event, helper){
        console.log('fnViewControll');
        helper.doInit(component,event, helper);
        component.set('v.listLabel', [{}]);
        component.set('v.emptyCheck', true);
        component.set("v.isVisible", true);
        console.log('listLabel:   '+JSON.stringify(component.get('v.listLabel')));
    },


    fnAddRow : function(component, event, helper) {
        var iApproverLimit = component.get("v.iApproverLimit");
        var listLabel 	   = component.get("v.listLabel");

        console.log('iApproverLimit >>>>>>>>>>> ' + iApproverLimit);
        console.log('listLabel:   '+JSON.stringify(listLabel));

        var userobj = {  Id  : null };

        listLabel.userDatas.push(userobj);
        component.set("v.listLabel", listLabel);

        if(listLabel.userDatas.length === iApproverLimit) {
            var strButtonElement = component.find('addApprover');
            $A.util.addClass(strButtonElement, 'slds-hide');
        }
    },

    fnDeleteRow : function(component, event, helper) {
        var iApproverLimit = component.get("v.iApproverLimit");
        var listUser    = component.get("v.listLabel");
        var idx 		= event.getSource().get("v.name"); //idx  0

        console.log("idx ↓↓↓↓");
        console.log(idx);
        console.log("lsituser ↓↓↓↓");
        console.log(listUser);
        if(idx <= iApproverLimit){
            var strButtonElement = component.find('addApprover');
            $A.util.removeClass(strButtonElement, 'slds-hide');
        }
        for(var i=listUser.userDatas.length-1; i>=0; i--){
            if(idx == i) listUser.userDatas.splice(i, 1);
        }
        component.set("v.listLabel", listUser);
    },

    fnSubmit : function(component, event, helper){
        var strObjectName = component.get("v.sObjectName");
        var listReApprovalObject = component.get("v.listReApprovalObject");
        var listLabel = component.get('v.listLabel.userDatas');

        if(!$A.util.isEmpty(listLabel[0].Id) && listLabel[0].Id != null){
            helper.doSubmit(component, event, helper)
        } else {
            helper.showToast('error', 'Select an Approver.');
        };
    },


    /*fnSubmit : function(component, event, helper) {
            console.log("fnSubmit!!  >> bHistory >>> : "+ component.get("v.bHistory") );

            // var listLabel   = component.get("v.listLabel");
            var strObjectName = component.get("v.sObjectName");
            var listReApprovalObject = component.get("v.listReApprovalObject");
            var bValidation = true;
            var listUser 	= component.get("v.listLabel").userDatas;
            var bHistory 	= component.get("v.bHistory");
            console.log("↓↓↓리스트유저↓↓↓");
            console.log(JSON.stringify(listUser));

            // 중복 및 null 검사
            if(listUser == '' || listUser == null){
                bValidation = false;
                helper.showToast('error', 'Please add an Approver.');

            }

            for(var i in listUser){
                i = parseInt(i);

                if(listUser[i].Id == null) {
                    bValidation = false;
                    helper.showToast('error', 'Approver has not been selected.');
                    console.log("ddddddd >>" + listUser[i].Id);
                    break;
                }
                for(var j=i+1; j<=listUser.length-1; j++) {
                    if(i == listUser.length-1) break;
                    if(listUser[i].Id === listUser[j].Id){
                        bValidation = false;
                        helper.showToast('error', 'The selected approver is duplicated.');
                    }
                }
            }


            if(bValidation == true ){
                helper.doSubmit(component, event, helper);
                helper.showSpinner(component);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                helper.hideSpinner(component);

            }

            /*else if(bValidation == true ){
                helper.doSubmit(component,event, helper);
            }*//*
        },*/




    fnSave : function(component, event, helper) {
        console.log("fnSave!!  >> bHistory >>> : "+ component.get("v.bHistory") );

        var titleValidate = component.find("LineTitle").get("v.value");
        var bValidation = true;
        var listUser 	= component.get("v.listLabel").userDatas;
        var bHistory 	= component.get("v.bHistory");
        console.log("↓↓↓리스트유저↓↓↓");
        console.log(JSON.stringify(listUser));


        // 중복 및 null 검사

        // Title 입력 안했을 시
        if(titleValidate == '' || titleValidate == null){
            bValidation = false;
            helper.showToast('error', 'Enter The Line Title');
        }

        // Approver 추가 안됐을 시
        if(listUser == '' || listUser == null){
            bValidation = false;
            helper.showToast('error', 'Please add an Approver.');

        }

        for(var i in listUser){
            i = parseInt(i);

            // Approver 지정 안됐을 시
            if(listUser[i].Id == null) {
                bValidation = false;
                helper.showToast('error', 'Approver has not been selected.');
                console.log("ddddddd >>" + listUser[i].Id);
                break;
            }

            // Approver 중복일 때
            for(var j=i+1; j<=listUser.length-1; j++) {
                if(i == listUser.length-1) break;
                if(listUser[i].Id === listUser[j].Id){
                    bValidation = false;
                    helper.showToast('error', 'The selected approver is duplicated.');
                }
            }
        }


        if(bValidation == true ){
            var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
                setTimeout(function() {
                        $A.util.addClass(modal, 'slds-hide');
                }, 1000);
            helper.doSave(component, event, helper);


        }



        /*else if(bValidation == true ){
            helper.doSubmit(component,event, helper);
        }*/
    },
});