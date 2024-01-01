/**
 * Created by yghwang on 2023-10-05.
 */

({
    doSearchCustomer : function(component){
        component.set('v.isShowSpinner', true);
        var keyword = component.get('v.keyword');
        console.log('keyword :: ' + keyword);
        var action = component.get('c.doSearchCustomer');
        action.setParams({
            keyword : keyword
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    console.log(returnVal);
                    component.set('v.data', returnVal);
                } else {
                    // 해당하는 사용자 없음.
                    alert('There are no search results that match \"' +keyword + '\"');
                }
            } else {
                console.log(response.getError());
            }
            component.set('v.isShowSpinner', false);
        });
        $A.enqueueAction(action);

    }
});