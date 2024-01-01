({
    getInitData: function(component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.selectengineReplaceAsset");
        action.setParams({ "recordId" : recordId});

        action.setCallback(this, function(response) {
            console.log('action');
            if (response.getState() === "SUCCESS") {

                let engineReplacementRecord = response.getReturnValue();
                console.log('engineReplacementRecord :: ',engineReplacementRecord);
                let createRecordEvent = $A.get("e.force:createRecord");
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                dismissActionPanel.fire();
                
                createRecordEvent.setParams({
                    "entityApiName": "EngineReplacement__c",
                    "defaultFieldValues": {
                        "AssetId__c": engineReplacementRecord.asset[0].Id,
                        "DealershipID__c": engineReplacementRecord.accId,
                        "OldSN__c": engineReplacementRecord.asset[0].EngineSerialNumber__c,
                        "TractorSerialnumber__c": engineReplacementRecord.asset[0].SerialNumber,
                        "WarrantyDate__c" : engineReplacementRecord.asset[0].EngineWarrantyDate__c
                    }
                });
                createRecordEvent.fire();

            } else {
                console.log("Failed with state: " + response);
            }
        });
        $A.enqueueAction(action);

    },
    
})