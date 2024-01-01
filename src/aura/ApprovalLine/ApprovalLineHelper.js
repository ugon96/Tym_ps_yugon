/**
 * Created by Taejun.Kang on 2023-11-13.
 */

({
	getApprovalLines : function(component) {
	    console.log("■■■Approval Line Initialize■■■");
		// component.log("recordId >>>> " + component.get("v.recordId"));
		var action   = component.get("c.getApprovalLines");
		var bHistory = component.get("v.bHistory");
		var recordId = component.get("v.recordId");
		var sObjectName = component.get("v.sObjectName");

	    console.log("■ Page Separator :: " + bHistory);
	    console.log("■ sObject Name :: " + sObjectName);

		if(bHistory == true){
			recordId = component.get("v.recordId");
			console.log("■ recordId :: " + recordId);
		}

        action.setParams({
            recordId : recordId,
            sObjectName : sObjectName

        });
		action.setCallback(this, function(response) {
			var state = response.getState();

            console.log("■ STATE :: [ " + state + " ]");

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                console.log("■ returnValue ↓ ↓ ↓ ↓ ",returnValue);
                component.set("v.mapReturnValue", returnValue);
                component.set("v.listLabel", 	  returnValue["listLabel"]);
                component.set("v.objUser",  	  returnValue["objUser"]);
                component.set("v.iLineLimit",     returnValue["iLineLimit"]);
                component.set("v.iApproverLimit", returnValue["iApproverLimit"]);

                console.log("■ objUser ↓ ↓ ↓ ↓ ");
                console.log(returnValue["objUser"]);

                console.log("■ Approver Limit :: " + returnValue["iApproverLimit"]);
                console.log("■ Approval Line Creation Limit :: " + returnValue["iLineLimit"]);

                // helper.fnInitLooupSet(component, event, helper);

            }
		});

		$A.enqueueAction(action);
	},


	doCreate : function(component, event, helper) {
		var recordId  	   = component.get("v.recordId");
		var listLabel 	   = component.get("v.listLabel");
		var bHistory  	   = component.get("v.bHistory");
		var iLineLimit     = component.get("v.iLineLimit");
		var iApproverLimit = component.get("v.iApproverLimit");

		console.log("recordId >>> " + recordId);
        console.log("listLabel >>> "+ listLabel);
		var newData = {
			fieldName : '',
			label: '',
			userDatas:[]
		};

        // message appears when the limit on the number of approval line creations is reached.
		if(	listLabel.length == iLineLimit && bHistory == false) {
			this.showToast('error','Approval Lines can be created up to : '+ iLineLimit);

		} else {

			$A.createComponent(
				"c:ApprovalLineCreate",
				{
					'sId'       	   : recordId ,
					'listLabel'		   : newData,
					'objUser'		   : component.get("v.objUser"),
					'bHistory'		   : component.get("v.bHistory"),
					'sObjectName'	   : component.get("v.sObjectName"),
					'sHistoryRecordId' : component.get("v.sHistoryRecordId"),
					'iApproverLimit'   : component.get("v.iApproverLimit")
				},
				function(cApprovalLineCreate, status, errorMessage) {
					if(status === "SUCCESS") {
						component.set("v.LineCreateCmp", cApprovalLineCreate);
//						document.body.style.overflow = "hidden";
					} else if (status === "INCOMPLETE") {
                    	console.log("No response from server or client is offline.");
                    } else if (status === "ERROR") {
						console.log("Error : " + errorMessage);
					}
				}
			);
		}

	},


	doEdit : function(component, event, helper, listData){
		console.log('■ doEdit helper');


		var fieldName = event.getSource().get("v.name"); //필드명
		var listLabel = component.get("v.listLabel");

		$A.createComponent(
				"c:ApprovalLineCreate",
				{
					'sId'       	    : component.get("v.recordId") ,
					'fieldName'		    : fieldName,
					'listLabel'		    : listData,
					'title'		        : listData.title,
					'objUser'		    : component.get("v.objUser"),
					'bHistory'		    : component.get("v.bHistory"),
					'sObjectName'	    : component.get("v.sObjectName"),
					'sHistoryRecordId'	: component.get("v.sHistoryRecordId"),
					'iApproverLimit'    : component.get("v.iApproverLimit")
				},


				function(cApprovalLineCreate, status, errorMessage) {
					if(status === "SUCCESS") {
						component.set("v.LineCreateCmp", cApprovalLineCreate)

					} else if (status === "INCOMPLETE") {
                    	console.log("No response from server or client is offline.");
                    } else if (status === "ERROR") {
						console.log("Error : " + errorMessage);
					}
				}
			);


	},


	doDelete : function(component, event, helper){
		var fieldName = event.getSource().get("v.name"); //fieldname
		var action = component.get("c.doDelete");

		action.setParams({
			'sId'       	 : component.get("v.recordId"),
			'objUser'		 : component.get("v.objUser"),
			'fieldName' 	 : fieldName

		});

		action.setCallback(this, function(response){
			var state = response.getState();

            console.log("필드네임 : " + fieldName);
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var values = returnValue.split('/');

                this.showToast(values[0], values[1]);

                if(values[0] == "success"){
					this.doNavigateSObject(values[2]);
	            }
            }
		});

		$A.enqueueAction(action);
		$A.get('e.force:refreshView').fire();
	},


	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },

    doNavigateSObject : function(recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId : recordId
        });
        navEvt.fire();
    },



})