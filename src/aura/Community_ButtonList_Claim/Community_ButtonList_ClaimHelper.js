/**
 * Created by 천유정 on 2023-11-07.
 */

({
    showQuickAction : function(target, component, helper) {
        var actionAPI = component.find("quickActionAPI");
        var args = {actionName: target};

        actionAPI.selectAction(args).then(function(result){
            //Action selected; show data and set field values
            console.log('===============> success');
        }).catch(function(e){
            if(e.errors){
                console.log('===============> error');
                //If the specified action isn't found on the page, show an error message in the my component
            }
        });
    },
    doCreateComponent : function(component, cmpName, param) {
        $A.createComponent(
            cmpName, // 컴포넌트이름
            param, // Attribute param
            function(cCmp, status, errorMessage) {
                if(status === "SUCCESS") {
                    console.log("success");
                    // callback action
                    console.log('jin>>>>>>>>>>>>>>>>>>>>>>>::::::::::cCmp?: '+cCmp);
                    component.set("v.CustomComponent", cCmp); // 새로운 Attribute에 저장
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }, 

    showSpinner: function (component) {
        /* this will show the <lightning:spinner /> */
        component.set('v.isShowSpinnerButton', true);
    },
    hideSpinner: function (component) {
        /* this will hide the <lightning:spinner /> */
        component.set('v.isShowSpinnerButton', false);
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