/**
 * Created by yghwang on 2023-10-10.
 */

({
    init : function (component, event, helper) {

    },

    doSave : function (component, event, helper) {
        if(component.get('v.lastName') == null || component.get('v.lastName') == '') {
            alert('Please Enter Last Name');
        } else {
            helper.doCreateCustomer(component);
        }
    },

    handleSaveBtnClicked : function (component, event, helper) {
        helper.doCreateCustomer(component);
    },

    closeModal : function (component, event, helper) {
        var evt = component.getEvent('closeCreateCustomerEvt');
        evt.fire();
    },
});