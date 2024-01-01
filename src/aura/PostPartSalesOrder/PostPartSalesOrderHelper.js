/**
 * Created by taekyun.yoon on 2023-11-22.
 */


({
    sendSAP : function(component, event, helper) {
        console.log('[sendSAP] Start =============================>');
        console.log('[sendSAP]record id in helper:' + component.get("v.recordId"));

        var action = component.get("c.sendSAP");
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            console.log('[setCallback] ::::::::');
            try{
                var state = response.getState();
                var returnValue = response.getReturnValue();
                console.log('[setCallback] return value : '+ returnValue);
                console.log('[setCallback] state : '+state);

                if(state === "SUCCESS") {
                    if(returnValue == "SUCCESS") {
                        this.showToast("success", "Successfully sent to SAP.");
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    } else {
                        this.showToast("error", "Error occurred. Please contact to system administrator.");
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    console.log('[setCallback]error : '+ errors);
                    if(errors) {
                        this.showToast('error','실패');
                    }
                }
            } catch(e){
                console.log('There is an error in setCallback ');
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
});