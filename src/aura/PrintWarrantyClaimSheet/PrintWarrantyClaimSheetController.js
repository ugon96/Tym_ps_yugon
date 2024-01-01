/**
 * Created by 천유정 on 2023-09-11.
 */

({
    fnInit : function(component, event, helper){
        helper.getInitData(component);
    },

    fnCancel : function(component, event, helper){
        var isCommunity = component.get("v.isCommunity");
        if(!isCommunity) {
            $A.get("e.force:closeQuickAction").fire();
        } else {
            var evt = component.getEvent("Community_ButtonList_evt"); 
            if(evt) {
                evt.fire();
            } else {
                console.log('==============> not event');
            }
        }
    },

    fnSave : function(component, event, helper){
        console.log("call save ");
        helper.saveAction(component, false); 
    }
});