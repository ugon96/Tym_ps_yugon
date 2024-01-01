/**
 * Created by ally6 on 2023-11-22.
 */

({
    getInitData : function(component) {
        var action = component.get("c.getInitData");

        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            console.log('list:');

            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.myClaim", returnValue[0]);
                console.log('myClaim:'+component.get("v.myClaim.Name"));
                var listOption = [];
                returnValue.forEach((e, index) => {
                    if(index!=0){
                        var options = {
                            label: e.Name,
                            value: e.Id
                            };
                         listOption.push(options);
                    }
                })
                component.set("v.options", listOption);
                var objStudent = {
                };
                component.set("v.objStudent", objStudent);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    //참고 :에러가 났을경우는 주로 ShowToast 함수를 이용하여 토스트 메시지를 띄움
                } else {
                }
            }
        });
        $A.enqueueAction(action);
    },
});