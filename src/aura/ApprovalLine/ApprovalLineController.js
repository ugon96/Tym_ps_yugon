/**
 * Created by Taejun.Kang on 2023-11-13.
 */

({
	fnInit : function(component, event, helper) {
		helper.getApprovalLines(component);
	},

	fnClickNew : function(component, event, helper) {
//		component.set("v.isModal", false);
        component.set('v.isModal', false);
		helper.doCreate(component,event, helper);

	},

    // 프로필에서 라인 편집
	handleSelect : function(component, event, helper) {
		var selectItem = event.getParams("v.value");
		var temp = event.getSource().get("v.class");
		var list = component.get("v.listLabel");

		if(selectItem.value === 'Edit') {
			helper.doEdit(component, event, helper, list[temp]);
		} else if (selectItem.value === 'Delete') {
			helper.doDelete(component, event, helper);
		}
	},

    // 승인 요청 시 생성된 라인 클릭 시 LineCreate 에 값 넣기
	fnEdit : function(component, event, helper) {
		console.log('fnEdit >>>>');
		var temp = event.getSource().get("v.value");
		var list = component.get("v.listLabel");
		component.set('v.isModal', false);
		helper.doEdit(component, event, helper, list[temp]);
	},

	fnClose : function(component, event, helper) {
	    console.log("fnClose♥");
	    $A.get("e.force:closeQuickAction").fire();

//		var modal = component.find('divModal');      /* aura:id 'divModal'찾기*/
//        $A.util.removeClass(modal, 'slds-show');
//        $A.util.addClass(modal, 'slds-hide');
//        component.set('v.holidayModalView', false);
//        /*scroll 방지 해제*/
//		document.body.style.overflow="auto";
	},


    closeNewApprovalModal : function(component, event, helper) {
        console.log('closeNewApprovalModal');
        component.set('v.LineCreateCmp', null);
    },


})