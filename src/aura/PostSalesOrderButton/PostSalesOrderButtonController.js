/**
 * Created by nhkim on 2023-12-01.
 */

({
    fnInit : function (component, event, helper) {
        var action = component.get('c.doInit');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    component.set('v.isConfirmedOrder', returnVal);
                    console.log(returnVal);
                }
            }
            component.set('v.isShowSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fnCancel : function(component, event) {
        var cancel = $A.get("e.force:closeQuickAction");
        cancel.fire();
    },

    fnSend : function(component) {
        component.set('v.isShowSpinner', true);
        var action = component.get('c.doPost');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            component.set('v.isShowSpinner', false);
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result == 'success') {
                    var url = "/lightning/r/" + component.get("v.recordId") + "/view";
                    window.parent.location = url;
                    component.find('notifLib').showToast({
                       "variant":"success",
                       "title": "성공",
                       "message": "저장이 완료되었습니다."
                    });
                }
                else {
                    component.find('notifLib').showToast({
                       "variant":"info",
                       "title": "Info",
                       "message": "이 주문에 대한 Finished Goods가 존재하지 않습니다."
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },
    fnConfirm : function (component, event, helper) {
        component.set('v.isShowSpinner', true);

        var action = component.get('c.doConfirmationOrder');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            component.set('v.isShowSpinner', false);
            var state = response.getState();
            if(state == 'SUCCESS'){
                var returnVal = response.getReturnValue();
                console.log(returnVal)
                if(returnVal.state == 'success'){
                    console.log('fnConfirm success');
                    component.set('v.isConfirmedOrder', true);
                }else if(returnVal.state == 'error'){
                    console.log(returnVal.msg);
                }
            }
        });
        $A.enqueueAction(action);
    },
});