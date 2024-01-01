/**
 * Created by 조주은 on 2021-08-27.
 */

({
    fnInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },

    fnErase : function(component, event, helper){
        helper.doErase(component, event, helper);
    },

    fnSave : function(component, event, helper){
        helper.doSave(component, event, helper);
    }
    
    // fnCancel : function(component, event, helper){
    //     $A.get("e.force:closeQuickAction").fire();
    // },
});