/**
 * Created by 천유정 on 2023-11-07.
 */

({
    fnInit : function(component, event, helper) {
        helper.showSpinner(component);

        var action = component.get("c.doInit");
        var recordId = component.get("v.recordId");

        action.setParams({
            recordId : recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :   '+state);
            var toast = $A.get("e.force:showToast");

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strStatus = returnVal.strStatus;
                if(strStatus == 'SUCCESS'){
                    if(returnVal.isShowBtnPrint == true){
                        component.set("v.isShowBtnPrint", true);
                    }
                }else if(strStatus == 'ERROR'){
                    console.log("Error message: " + returnVal.strMessage);
                }
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    fnCreatePrintComponent : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var cmpName = 'c:PrintWarrantyClaimSheet';
        var param = {
            "recordId" : recordId,
            "isCommunity" : true
        };
        helper.doCreateComponent(component, cmpName, param);
    }, 

    fnCommunityButtonEvt : function(component, event, helper) {
        component.set("v.CustomComponent", null);
    }
});