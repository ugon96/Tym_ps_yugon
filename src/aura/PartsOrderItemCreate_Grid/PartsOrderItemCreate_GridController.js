/**
 * Created by 천유정 on 2023-11-29.
 */

({
    fnInit : function(component, event, helper){
        helper.getInitData(component, event, helper);
    },

    fnClickAddEdit: function(component, event, helper){
        var isClickedAddEdit = component.get("v.isClickedAddEdit");
        if (isClickedAddEdit) {
            component.set("v.isClickedAddEdit", false);
            $A.get('e.force:refreshView').fire();
        } else {
            component.set("v.isClickedAddEdit", true);
        }
        console.log('fnClickAddEdit =========>' + component.get("v.isClickedAddEdit"));
    },

    fnCancel: function(component, event, helper){
        $A.get('e.force:refreshView').fire();
    },

    fnSave: function(component, event, helper){
        console.log('[fnSave] Start =============================>');
        component.set("v.toggleSpinner", true);
        var validMessage = '';
        var isPartnerUser = component.get("v.isPartnerUser");                 // Partner Profile 일 경우 true
        var isAdministratorUser = component.get("v.isAdministratorUser");     // Administrator Profile 일 경우 true
        var dataParts = component.get("v.listPartsOrderItem");
        var deletedDataParts = component.get("v.listPartsOrderItemDeleted");

        if (!helper.isNullCheck(dataParts)) {
            var CausalPartCount = 0;
            for (var i = 0; i < dataParts.length; i++){
                if (dataParts[i].CausalPart__c == true) CausalPartCount++;
                if(helper.isNullCheck(dataParts[i].ProductId__c)) {
                    validMessage =  "Please fill the parts. row number :  " + (i+1);
                } else if(helper.isNullCheck(dataParts[i].Quantity__c)) {
                    validMessage =  "Please fill the request quantity. row number :  " + (i+1);
                }
            }
        }

        // Validation 실패 시
        if(validMessage != '') {
            component.set("v.toggleSpinner", false);
            helper.showToast('info', validMessage);
            return;
        }
        window.setTimeout(
             function() {
                 helper.doSave(component, event, helper, dataParts, deletedDataParts)},
             150
         );
        console.log('[fnSave] End =============================>');
    },

    /*
    * Description : Check Out 버튼 클릭 시, Submitted로 변경
    */
    fnCheckout: function(component, event, helper){
        console.log('[fnCheckout] Start =============================>');
        component.set("v.toggleSpinner", true);
        var validMessage = '';
        var isPartnerUser = component.get("v.isPartnerUser");                 // Partner Profile 일 경우 true
        var isAdministratorUser = component.get("v.isAdministratorUser");     // Administrator Profile 일 경우 true
        var dataParts = component.get("v.listPartsOrderItem");
        var orderType = component.get("v.orderType");
        var TotalPrice = component.get("v.TotalPrice");
        var objPartsOrder = component.get("v.objPartsOrder");
        var listPartsOrderItem = component.get("v.listPartsOrderItem");
        console.log('[fnCheckout] orderType =============================>' + orderType);
        console.log('[fnCheckout] TotalPrice =============================>' + TotalPrice);

        var message = '';

        if (listPartsOrderItem.length == 0) {
            validMessage = 'There is no item in shopping cart. Please add item.';
        }
        if (helper.isNullCheck(objPartsOrder.ShiptoAddressId__c)) {
            validMessage = 'Shipping address does not exist. Please specify your shipping address.';
        }
        if (helper.isNullCheck(objPartsOrder.BilltoAddressID__c)) {
            validMessage = 'Billing address does not exist. Please specify your billing address.';
        }

        // Validation 실패 시
        if(validMessage != '') {
            component.set("v.toggleSpinner", false);
            helper.showToast('info', validMessage);
            return;
        }

        if (!helper.isNullCheck(dataParts)) {
            if (orderType == 'Level 1 Stock order') {
                if (TotalPrice < 2500 || dataParts.length < 10)  {
                    message = 'The discount will not be applied because the order does not meet the \'Level 1 Stock Order\' condition selected as Order Type. Would you like to proceed with the order? (Order type will be changed when status was changed to received.)';
                }
            } else if (orderType == 'Level 2 Stock order') {
                if (TotalPrice < 5000 || dataParts.length < 15)  {
                    message = 'The discount will not be applied because the order does not meet the \'Level 2 Stock Order\' condition selected as Order Type. Would you like to proceed with the order? (Order type will be changed when status was changed to received.)';
                }
            } else if (orderType == 'Level 3 Stock order') {
                if (TotalPrice < 10000 || dataParts.length < 20)  {
                    message = 'The discount will not be applied because the order does not meet the \'Level 2 Stock Order\' condition selected as Order Type. Would you like to proceed with the order? (Order type will be changed when status was changed to received.)';
                }
            }
        }
        // Order Type 조건 미충족 시
        if(message != '') {
            component.set("v.toggleSpinner", false);
            helper.openConfirm(component, event, message, 'warning', 'Please Check Order Type');
        } else {
            component.set("v.toggleSpinner", false);
            helper.openConfirm(component, event, ' Would you like to proceed with the order? You could not edit your order after submitting.', 'alt-inverse', 'Submit Order');
        }
    },

    fnAddParts: function(component, event, helper){
        console.log('fnAddParts =========> Start !!' );
        component.set("v.toggleSpinner", true);
        var validMessage = '';
        var objPartsOrder = component.get("v.objPartsOrder");
        var priceList = component.get("v.priceList");
        console.log('priceList =========> Start !!' + priceList);

        if (helper.isNullCheck(priceList)) {
            validMessage = 'The price list for the account is not specified. Please contact your Territory Manager.';
        }
        // Validation 실패 시
        if(validMessage != '') {
            component.set("v.toggleSpinner", false);
            helper.showToast('info', validMessage);
            return;
        }
        var data = component.get("v.listPartsOrderItem");
        let obj = {
                'sobjectType'            :'PartsOrderItem__c',
                'PartsOrderId__c'        : component.get("v.recordId"),
                'ProductId__c'           : null,
                'Quantity__c'            : 1.0,
                'Price__c'               : 0.0,
                'fm_Amount__c'           : 0.0,
                'ProductName'            : null,
                'fm_OnHand__c'            : 0.0,
        };
        data.push(obj);
        component.set("v.listPartsOrderItem", data);
        helper.doRenderPage(component);
        console.log('[fnAddParts] listPartsOrderItem : ', JSON.stringify(component.get("v.listPartsOrderItem")));
        component.set("v.toggleSpinner", false);
    },

    handleDeleteParts: function (component, event, helper) {
        console.log('======================> [handleDeleteParts] Start!!! ');
        var selectedItem = event.currentTarget;
        var row = selectedItem.dataset.record;
        console.log('======================> row ' + row);
        console.log('======================> row.Id ' + row.Id);

        var listPartsOrderItem = component.get("v.listPartsOrderItem");
        var listPartsOrderItemDeleted = component.get("v.listPartsOrderItemDeleted");

        if (listPartsOrderItem[row].Id != null) listPartsOrderItemDeleted.push(listPartsOrderItem[row]);
        listPartsOrderItem.splice(listPartsOrderItem.indexOf(listPartsOrderItem[row]), 1);

        component.set("v.listPartsOrderItem", listPartsOrderItem);
        component.set("v.listPartsOrderItemDeleted", listPartsOrderItemDeleted);
        console.log('======================> [handleDeleteParts] 222');

        helper.doChangeTotal(component, event, helper);
        console.log('======================> [handleDeleteParts] listDataLabor : '+JSON.stringify(listPartsOrderItem));
        console.log('======================> [handleDeleteParts] listDataLaborDeleted : '+JSON.stringify(listPartsOrderItemDeleted));
    },

    fnChangeParts: function(component, event, helper) {
       console.log('======================> [fnChangeParts] Start!!! ');
       var targetValue = event.getSource().get("v.value");
       var idx = event.getSource().get("v.accesskey");
       var listPartsOrderItem = component.get("v.listPartsOrderItem");
       var validMessage = '';

       console.log('[fnChangeParts] targetValue', targetValue);
       console.log('[fnChangeParts] idx', idx);
       console.log('======================> [listPartsOrderItem]  ' + JSON.stringify(component.get("v.listPartsOrderItem")));
       if(targetValue.length > 0){
           for (var i = 0; i < listPartsOrderItem.length; i++){
               if(listPartsOrderItem[i].ProductId__c == targetValue) {
                   validMessage =  "This part is already added at shopping cart.";
               }
           }
            console.log('[fnChangeParts] validMessage => ', validMessage); 
           helper.getPartsValue(component, event, helper, idx, targetValue, validMessage);
       } else {
           listPartsOrderItem[idx].Quantity__c = null;
           listPartsOrderItem[idx].fm_Amount__c =  null;
           listPartsOrderItem[idx].Price__c = null;
           listPartsOrderItem[idx].fm_PartsName__c =  null;
           listPartsOrderItem[idx].ProductName =  null;
           component.set("v.listPartsOrderItem", listPartsOrderItem);
       }
    },

    /*
    * Description : Labor & Parts 행 삭제 시
    */
    fnHandelRemoved: function(component, event, helper) {
       console.log('[fnHandelRemoved] Start =============================>');
       var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
       var targetValue = event.getParam("selectedId");
       var type = uniqueLookupIdentifier[0];
       var idx = parseInt(uniqueLookupIdentifier[1],10);
       var listPartsOrderItem = component.get("v.listPartsOrderItem");
       var objData = listPartsOrderItem[idx];
       console.log('[fnHandelRemoved] uniqueLookupIdentifier', uniqueLookupIdentifier);
       console.log('[fnHandelRemoved] selectedId', targetValue);
       console.log('[fnHandelRemoved] type', type);
       console.log('[fnHandelRemoved] idx', idx);
       console.log('[fnHandelRemoved] objData', objData);
       switch (type) {
            case 'Parts' :
            objData.fm_Description__c = null;
            objData.Quantity__c = 1.0;
            objData.fm_Amount__c = 0.0;
            break;
       }
       component.set("v.listPartsOrderItem", listPartsOrderItem);
       console.log('[fnHandelRemoved] End =============================>');
    },

    /*
    * Description : 입력값 변경 시, Total 변경
    */
    fnChangeValue: function(component, event, helper){
       console.log('[fnChangeValue] Start =============================>');
       component.set("v.toggleSpinner", true);
       var targetValue = event.getSource().get("v.value");
       console.log('[fnChangeValue] targetValue =========> '+targetValue);
       if(targetValue.length > 0){
           var target = event.getSource().get("v.class").split('-');
           var type1 = target[0];
           var type2 = target[1];
           var idx = parseInt(target[2],10);
           console.log('[fnChangeValue] type1 ', type1);
           console.log('[fnChangeValue] type2 ', type2);
           console.log('[fnChangeValue] idx ', idx);
           helper.changeValue(component, event, helper, type1, type2, idx, targetValue);
       }
       console.log('[fnChangeValue] End =============================>');
       component.set("v.toggleSpinner", false);
    },

    fnMouseOver : function(component, event, helper){
       component.set('v.mouseOver', true);
    },

    fnMouseOut : function(component, event, helper){
       component.set('v.mouseOver', false);
    },

    /**
    * @description Account 검색 결과 Paging(DN_Paging)
    */
    fnRenderPage: function(component, event, helper) {
       component.set('v.toggleSpinner', true);
       helper.doRenderPage(component);
    },

    openConfirm: function(component, event, helper) {
        helper.openConfirm(component, event);
    }
});