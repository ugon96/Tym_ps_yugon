/**
 * Created by yghwang on 2023-10-05.
 */

({
    fnInit : function(component, event, helper){
        console.log('init');
        helper.doSearchCustomer(component);
        component.set('v.columns'
            , [
               {label: 'Name', fieldName: 'Name', type: 'text'},
               {label: 'Email', fieldName: 'Email', type: 'text'},
               {label: 'Phone', fieldName: 'PhoneNumber__c', type: 'text'},
               {label: 'Mobile', fieldName: 'Mobile__c', type: 'text'},
               {label: 'Address', fieldName: 'Address__c', type: 'text'}
            ]);
    },

    handleRowSelection : function (component, event, helper) {
        var listSelectedCustomer = event.getParam('selectedRows');
        var selectedCustomer = listSelectedCustomer[0];
        component.set('v.selectedCustomer', selectedCustomer);
    },

    handleConfirmBtnClicked : function (component, event, helper) {
        var selectedCustomer = component.get('v.selectedCustomer');
        if(!selectedCustomer){
            alert($A.get('$Label.c.Please_select_End_Customer'));
        } else {
            var evt = component.getEvent('selectCustomerEvt');
            evt.setParams({
                objContact : selectedCustomer
            });
            evt.fire();
        }

    },

    closeModal : function (component, event, helper) {
        var evt = component.getEvent('closeSearchResultEvt');
        evt.fire();
    },
});