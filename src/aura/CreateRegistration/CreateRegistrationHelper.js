/**
 * Created by yghwang on 2023-09-01.
 */

({
    getDealerData : function (component) {
        var action = component.get('c.getDealerData');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                if(!returnVal){
                    console.log('!returnVal');
                } else {
                    console.log('returnVal :: ' + returnVal);
                    component.set('v.dealerList', returnVal);
                    component.set('v.selectedDealer', returnVal[0]);
                }
            } else {
                this.showToast('error', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    getConnectedAssetInformation : function (component) {
        console.log('===== getConnectedAssetInformation =====');
        var searchedAssetRecord = component.get('v.searchedAssetRecord');
        var action = component.get('c.getConnectedAssetInformation');
        console.log('searchedAssetRecord.Id :: ' + searchedAssetRecord.Id);
        action.setParams({
            recordId : searchedAssetRecord.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = JSON.parse(response.getReturnValue());
                console.log('getConnectedAssetInformation + returnVal :: ' + JSON.stringify(returnVal));
                console.log('returnVal.state :: ' + returnVal.state);
                if(returnVal != null && returnVal.state != false){
                    component.set('v.selectedTractorRecord', returnVal.wrapTractor);
                    console.log('returnVal.wrapTractor :: ' + returnVal.wrapTractor);
                    component.set('v.selectedLoaderRecord', returnVal.wrapLoader);
                    console.log('returnVal.wrapLoader :: ' + returnVal.wrapLoader);
                    component.set('v.selectedBackhoeRecord', returnVal.wrapBackhoe);
                    console.log('returnVal.wrapBackhoe :: ' + returnVal.wrapBackhoe);
                    component.set('v.selectedCabinRecord', returnVal.wrapCabin);
                    console.log('returnVal.wrapCabin :: ' + returnVal.wrapCabin);
                    component.set('v.selectedMowerRecord', returnVal.wrapMMM);
                    console.log('returnVal.wrapMMM :: ' + returnVal.wrapMMM);
                } else {
                    if(returnVal == null){
                        console.log('unknown error');
                    } else {
                        console.log(returnVal.errMsg);
                    }
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    doCreateRegistration : function (component){
        console.log('doCreateRegistration');
        component.set('v.toggleSpinner', true);

        var searchedAssetRecord = component.get('v.searchedAssetRecord');
        var selectedDealer = component.get('v.selectedDealer');
        var selectedCustomer = component.get('v.selectedCustomer');
        var selectedCustomerId;
        if(selectedCustomer == null){
            selectedCustomerId = null;
        } else {
            selectedCustomerId = selectedCustomer.Id;
        }
        var dateOfSales = component.get('v.dateOfSales');
        var warrantyType = component.get('v.warrantyType');

        console.log('searchedAssetRecord :: ' + JSON.stringify(searchedAssetRecord));
        console.log('selectedDealer :: ' + JSON.stringify(selectedDealer));
        console.log('selectedCustomer :: ' + JSON.stringify(selectedCustomer));
        console.log('selectedCustomerId :: ' + selectedCustomerId);
        console.log('dateOfSales :: ' + JSON.stringify(dateOfSales));
        console.log('warrantyType :: ' + JSON.stringify(warrantyType));

        var action = component.get('c.doCreateRegistration');
        action.setParams({
            searchedAssetRecordId : searchedAssetRecord.Id,
            selectedDealerId : selectedDealer.Id,
            selectedCustomerId : selectedCustomerId,
            dateOfSales : dateOfSales,
            warrantyType : warrantyType
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state :: ' + state);
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                console.log('returnVal :: ' + returnVal);
                if(returnVal == null){
                    this.showToast('success', 'success');
                    component.set('v.toggleSpinner', false);
                    var evt = $A.get("e.force:navigateToURL");
                    evt.setParams({
                        url: '/asset/Asset/Default'
                    });
                    evt.fire();
                } else {
                    this.showToast('error', returnVal);
                    component.set('v.toggleSpinner', false);
                }
            } else {
                console.log(JSON.stringify(response.getError()));
                this.showToast('error',JSON.stringify(response.getError()[0]));
                component.set('v.toggleSpinner', false);
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
    },

    // Null , Undefined , '' 체크
    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == "----none----" ){
            return true;
        }
        else{
            return false;
        }
    },
//    simulateServerRequest: function (onResponse) {
//        setTimeout(function () {
//            var serverResponse = {
//                selectedColorId: 2,
//                colors: [
//                    { id: 1, label: 'Red' },
//                    { id: 2, label: 'Green', selected: true },
//                    { id: 3, label: 'Blue' }
//                ]
//            };
//
//            onResponse.call(null, serverResponse);
//        }, 2000);
//    }
});