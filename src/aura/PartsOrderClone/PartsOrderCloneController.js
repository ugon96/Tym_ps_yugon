({
    doInit: function(component, event, helper) {
        console.log('doInit 시작');
        component.set("v.isLoading", true);

        var recordId = component.get("v.recordId");
        var action = component.get("c.selectPartsOrder");
        action.setParams({"recordId": recordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var record = response.getReturnValue();
                component.set("v.inputPONum", record.PONumber__c);
                component.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.isLoading", false);
                helper.showToastError(component, event, helper);
            }
        });

        $A.enqueueAction(action);
    },

    onSubmitSave : function(component, event, helper) {
        component.set("v.isLoading", true);
        console.log('onSubmitSave:::::');

        var inputNumField = component.find("numField").get("v.value");
        console.log('inputNumField:', inputNumField);

        var partsOrderMap = {
            'poNum': inputNumField
        };

        var recordId = component.get("v.recordId");

        var action = component.get("c.partsOrderClone");

        action.setParams({"recordId": recordId, "partsOrderMap": partsOrderMap});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result:::: ', result);
                component.set("v.isLoading", false);
                
                helper.showToast(component, event, helper);

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.Id,
                    "slideDevName": "detail"
                });
                navEvt.fire();

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.isLoading", false);
                helper.showToastError(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },

    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

})