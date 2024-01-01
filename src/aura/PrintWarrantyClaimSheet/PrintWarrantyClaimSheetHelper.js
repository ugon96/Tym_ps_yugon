/**
 * Created by 천유정 on 2023-09-11.
 */

({
    getInitData : function(component){
        var action = component.get("c.doGetInitData");
        console.log('action :: ',action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :: ',state);
            if(state === "SUCCESS") {
                var result = response.getReturnValue();

                /*if(result == null || result == 0 || result == 'null') {
                        this.showToast("error", "There is no product. Please register your product and try again.");
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                }*/

                var urlInfo = window.location.origin;
                var communityName = "";

                if(urlInfo.indexOf("lightning") < 0){
                    communityName = result; 
                }

                if (!communityName) {
                    component.set("v.vfPageUrl" , communityName + "/apex/PrintWarrantyClaimSheet?Id=" + component.get("v.recordId"));
                } else {
                    component.set("v.vfPageUrl" , urlInfo + '/' + communityName + "/apex/PrintWarrantyClaimSheet?Id=" + component.get("v.recordId")); 
                }
            } else {
                this.showToast("error", "An error has occurred. Please try again.");
                //창 닫기
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    },

    saveAction : function(component, bEmailYn){
         console.log(' saveAction___in');
         var action = component.get("c.doSavePdf");
         console.log('pdfType:::::', component.get("v.pdfType"));
         action.setParams({
             strRecordId : component.get("v.recordId") ,
             pdfType : component.get("v.pdfType")
         });
         action.setCallback(this, function(response) {
             var state = response.getState();
             if(state === "SUCCESS") {
                 var  result = response.getReturnValue();
                 if(result == "success"){
                     this.showToast("success", "PDF File has been created.");

                     if(bEmailYn){
                         var evt = $A.get("e.c:QuickAction_evt");
                         evt.fire();
                     }
                     $A.get('e.force:refreshView').fire();
                     $A.get("e.force:closeQuickAction").fire();
                 }
                 else{
                     this.showToast("error", "PDF File creation failed.");
                 }

             }else{
                 this.showToast("error", "PDF File creation failed.");
             }
         });
         $A.enqueueAction(action);
    },

    showToast : function(type, message) {
         var evt = $A.get("e.force:showToast");
         evt.setParams({
             key : "info_alt"
             , type : type
             , message : message
         });
         evt.fire();
    }
});