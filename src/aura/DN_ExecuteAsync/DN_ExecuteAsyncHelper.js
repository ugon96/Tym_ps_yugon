({
	
    /**
     * @description 초기화 ( 검색조건 및 데이터 테이블 기본값 설정)
     */
	// doInit : function(component, event, helper) {
	// 	component.set("v.showSpinner", true);
    //     var action = component.get("c.doInit");
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if(state === "SUCCESS") {
    //             let returnValue = response.getReturnValue();
    //             let strStatus = returnValue.strStatus;
    //             let strMessage = returnValue.strMessage;

    //             if(strStatus == 'SUCCESS'){

    //                 let listQueueable = returnValue.listQueueable;
    //                 let listBatch = returnValue.listBatch;
    //                 component.set("v.listBatch", listBatch);
    //                 component.set("v.listQueueable", listQueueable);

    //                 if ( listBatch.length > 0){
    //                     let strCodeName = listBatch[0].value;
    //                     component.set("v.strCodeName", strCodeName);
    //                 }

    //             }else{
    //                 helper.showToast("ERROR",strMessage);
    //             }
    //         }
    //         else if (state === "INCOMPLETE") {
    //             alert("From server: " + response.getReturnValue());
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if(errors) {
    //                 if(errors[0] && errors[0].message) {
    //                     helper.showToast('ERROR', errors[0].message);
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             }
    //             else {
    //                 console.log("Unknown error");
    //             }
    //         }
	// 		component.set("v.showSpinner", false);
    //     });
    //     $A.enqueueAction(action);
    // },

    /**
     * @description 승인 및 반려 처리
     */
	doExecute : function(component, event, helper, strClassName, strConstructorNo) {
        console.log('strClassName: ', strClassName);
        console.log('strConstructorNo: ', strConstructorNo);

        component.set("v.showSpinner", true);		
        var action = component.get("c.doExecute");
        action.setParams({
			'strClassName' : strClassName,
			'strConstructorNo' : strConstructorNo,
            'strObject' : JSON.stringify(component.get('v.' + strClassName))
        });

		action.setCallback(this, function(response) {
            var state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
                console.log('returnVal: ', returnVal);
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;

				if(strStatus == "SUCCESS") {
					helper.showToast('Success', '성공적으로 실행되었습니다.');
                    let strClassName = returnVal.strClassName;
                    console.log('strClassName: ', strClassName);
                    let strConstructorNo = returnVal.strConstructorNo;
                    console.log('strConstructorNo: ', strConstructorNo);
                    let mapParam = returnVal.mapParam;
                    console.log('mapParam: ', JSON.stringify(mapParam));
                    component.set('v.strExecuteConfirm', '');
				}else {	
					helper.showToast('ERROR', strMessage);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				if(errors) {
					if(errors[0] && errors[0].message) {
						helper.showToast('ERROR', errors[0].message);
						console.log("Error message: " + errors[0].message);
					}
				}
				else {
					console.log("Unknown error");
				}
			}
			component.set("v.showSpinner", false);
		});

        $A.enqueueAction(action);
	},

    /**
     * @description 토스트 알림 창 표시 
     */
	showToast : function(type, message) {
		var evt = $A.get("e.force:showToast");
		evt.setParams({
			key     : "info_alt",
			type    : type,
			message : message
		});
		evt.fire();
	},
})