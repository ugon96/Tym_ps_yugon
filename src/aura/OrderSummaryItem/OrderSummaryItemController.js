/**
 * Created by yghwang on 2023-10-19.
 */

({
    fnInit : function(component, event, helper) {
        console.log('===fnInit===');
        var objSummary = component.get('v.objSummary');
        if(!helper.isNullCheck(objSummary)) {
            if(objSummary.objTractor != null){
                if(objSummary.objTractor.value != null){
                    helper.getTractorImage(component, objSummary.objTractor.value);
                }
            }
        }
    },
});