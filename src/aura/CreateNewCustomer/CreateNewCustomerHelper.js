/**
 * Created by yghwang on 2023-10-10.
 */

({
    doCreateCustomer : function(component) {
        component.set('v.isShowSpinner',true);
        var action = component.get('c.doCreateCustomer');
        action.setParams({
            fName : component.find('FirstName').get('v.value'),
            lName : component.find('LastName').get('v.value'),
            phone : component.find('CustomerHomePhone').get('v.value'),
            mobile : component.find('CustomerMobilePhone').get('v.value'),
            email : component.find('CustomerEmailAddress').get('v.value'),
            address : component.find('CustomerAddress').get('v.value')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    component.set('v.isShowSpinner', false);
                    console.log('returnVal :: ' + JSON.stringify(returnVal));

                    var evt = component.getEvent('createNewCustomerEvt');
                    evt.setParams({
                        objContact : returnVal
                    });
                    evt.fire();
                } else {
                    alert('customer creation error');
                    component.set('v.isShowSpinner', false);
                }
            } else {
                alert('error');
                component.set('v.isShowSpinner', false);
            }
        });
        $A.enqueueAction(action);
    }
});