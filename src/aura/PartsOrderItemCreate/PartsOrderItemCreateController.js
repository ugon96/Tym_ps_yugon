/**
 * Created by 천유정 on 2023-10-30.
 */

({
    fnInit : function(component, event, helper){
        component.set("v.toggleSpinner", true);
        component.set("v.isShowPopup", true);
        helper.getInitData(component, event, helper);
        component.set('v.columns', [
            {label: 'No', fieldName: 'No1__c', type: 'text'},
            {label: 'Part No', fieldName: 'fm_PartNo__c', type: 'text'},
            {label: 'Supplied Part No', fieldName: 'fm_suppliedPartNo__c', type: 'text'},
            {label: 'Description', fieldName: 'fm_PartName__c', type: 'text'},
            {label: 'on Hand', fieldName: 'fm_ohHand__c', type: 'number'},
        ]);
        component.set("v.toggleSpinner", false);
    },

    fnCancel: function(component, event, helper) {
        component.set("v.isShowPopup", false);
        $A.get("e.force:closeQuickAction").fire();
    },

    handleChange : function(component, event, helper) {
        var value = event.getSource().get("v.value");
        console.log('================> handleChange value : '+ value);
    },

    fnSearch: function(component, event, helper) {
        var model = component.get("v.model");
        console.log('[fnSearch] model===> ' + model);
        var lv1 = component.get("v.lv1"); 
        console.log('[fnSearch] lv1===> ' + lv1);

        var validMessage = '';
        if (helper.isNullCheck(lv1)) {
            validMessage =  "Please select Product Type.";
        }
        if (helper.isNullCheck(model)) {
            validMessage =  "Please fill the Model.";
        }
        // Validation 실패 시
        if(validMessage != '') {
            component.set("v.toggleSpinner", false);
            helper.showToast('info', validMessage);
            return;
        }
        helper.doSearch(component, event, helper, model);
    },

    handleSelect: function (component, event, helper) {
        var targetValue = event.getParam('name');
        var lv3 = '';
        var section = '';
        var figNo = '';
        if(targetValue.length > 0){
           var target = targetValue.split('+');
           lv3 = target[0];
           section = target[1];
           figNo = target[2];
        }
        if (!helper.isNullCheck(figNo)) {
            helper.doSearchParts(component, event, helper, lv3, section, figNo);
        }
    },

    handleSelectParts: function (component, event, helper) {
        console.log('[handleSelectParts] start ===> ');
        console.log(event.getParam('selectedRows'));
    }
});