/**
 * Created by taekyun.yoon on 2023-11-22.
 */

({
    fnInit : function(component, event, helper) {},

    clickSend : function (component, event, helper) {
        console.log('record id :' + component.get("v.recordId"));
        helper.sendSAP(component, event, helper);
    },
    clickCancel : function (component, event, helper) {
        console.log('clickCancel')
        $A.get("e.force:closeQuickAction").fire();
    },
});