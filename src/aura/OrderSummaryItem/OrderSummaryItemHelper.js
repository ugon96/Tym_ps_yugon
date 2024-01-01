/**
 * Created by yghwang on 2023-10-19.
 */

({
    getTractorImage : function(component, productId) {
        console.log('===getTractorImage===');
        var action = component.get('c.getTractorImage');
        action.setParams({
            productId : productId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    console.log('imageUrl :: ' + returnVal);
                    component.set('v.imageUrl', returnVal);
                }
            }
        });
        $A.enqueueAction(action);
    },

    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == '' || value == 0 || value =='----none----'){
            return true;
        }
        else{
            return false;
        }
    },
});