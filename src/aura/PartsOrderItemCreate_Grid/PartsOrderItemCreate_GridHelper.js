/**
 * Created by 천유정 on 2023-11-29.
 */

({
    // Null , Undefined , '', 0 체크
    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == '' || value == 0 || value == {}){
            return true;
        }
        else{
            return false;
        }
    },

    // Null , Undefined , '' 체크
    isNullCheckExceptZero : function(value){
        if(value == null || value == undefined || value == "" || value == '' || value == {}){
            return true;
        }
        else{
            return false;
        }
    },

    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt"
            , type: type
            , message: message
        });
        evt.fire();
    },

    getInitData: function (component, event, helper) {
        console.log('[getInitData] Start =============================>');
        component.set("v.toggleSpinner", true);
        var action = component.get("c.getInitData");
        action.setParams({
            recordId: component.get("v.recordId"),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getInitData] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    var objPartsOrder = result['objPartsOrder'];
                    component.set("v.objPartsOrder", objPartsOrder);
                    var listPartsOrderItem = result['listPartsOrderItem'];
                    var isPartnerUser = result['isPartnerUser'];
                    var isAdministratorUser = result['isAdministratorUser'];
                    var priceList = result['priceList'];
                    var factor = result['factor'];
                    var orderType = result['orderType'];
                    var orderTypeRate = result['orderTypeRate'];
                    var discount = result['discount'];
                    var discountRate = result['discountRate'];
                    if (listPartsOrderItem.length != 0) {
                        console.log('[getInitData] listPartsOrderItem.length != 0 =====>' + JSON.stringify(listPartsOrderItem));
                        for (var data of listPartsOrderItem) {
                            data.Quantity__c = data.Quantity__c;
                            data.Price__c = data.Price__c;
                            data.Quantity__c = data.Quantity__c;
                            data.fm_Amount__c = data.fm_Amount__c;
                            if (data.ProductId__c != undefined && data.ProductId__c != null) {
                                data.ProductName = data.ProductId__r.Name;
                                data.ProductCode = data.ProductId__r.ProductCode;
                                data.fm_PartsDescription__c = data.fm_PartsDescription__c;
                                data.fm_OnHand__c = data.fm_OnHand__c;
                                data.ProductId__c = data.ProductId__c;
                            }
                            if (data.Replacement__c != undefined && data.Replacement__c != null) {
                                data.ReplacementName = data.Replacement__r.Name;
                                data.ReplacementCode = data.Replacement__r.ProductCode;
                                data.Replacement__c = data.Replacement__c;
                            }
                        }
                        component.set("v.listPartsOrderItem", listPartsOrderItem);
                    }
                    console.log('[getInitData] objPartsOrder =============================>' + JSON.stringify(objPartsOrder));
                    component.set('v.isPartnerUser', isPartnerUser);
                    component.set('v.isAdministratorUser', isAdministratorUser);
                    component.set('v.priceList', priceList);
                    component.set('v.factor', factor);
                    component.set('v.orderType', orderType);
                    component.set('v.orderTypeRate', orderTypeRate);
                    component.set('v.discount', discount);
                    component.set('v.discountRate', discountRate);
                    this.doChangeTotal(component, event, helper);
                    this.doSetDisability(component, event, helper);
                    //Paging
                    var dataLengthParts = component.get('v.listPartsOrderItem').length;
                    component.set('v.pageNumberParts', 1);
                    component.set('v.totalParts', dataLengthParts);
                    component.set('v.pagesParts', Math.ceil(dataLengthParts / 15));
                    component.set('v.maxPageParts', Math.floor((dataLengthParts + 14) / 15));
                    this.doRenderPage(component);
                } else {
                    this.showToast("error", strMessage);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.toggleSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[getInitData] End ==============================>');
    },

    doSave: function (component, event, helper, dataParts, deletedDataParts) {
        console.log('[doSave] Start ==============================>');
        component.set("v.toggleSpinner", true);
        var action = component.get("c.saveRecord");
        console.log('[doSave] JSON.stringify(dataParts) ==============================>' + JSON.stringify(dataParts));
        console.log('[doSave] JSON.stringify(deletedDataParts) ==============================>' + JSON.stringify(deletedDataParts));

        action.setParams({
            recordId: component.get("v.recordId"),
            listPartsOrderItem: JSON.stringify(dataParts),
            listPartsOrderItemDeleted: JSON.stringify(deletedDataParts)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast('success','Successfully Save.');
                console.log('[doSave] SUCCESS!!! ==============================>');
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.toggleSpinner", false);
            component.set("v.isClickedAddEdit", false);
        });
        $A.enqueueAction(action);
        console.log('[doSave] End ==============================>');
    },

    doCheckout: function (component, event, helper, param) {
        console.log('[doCheckout] Start ==============================>');
        component.set("v.toggleSpinner", true);

        var objPartsOrder = component.get("v.objPartsOrder");
        var discountRate = component.get("v.discountRate");
        var orderTypeRate = component.get("v.orderTypeRate");
        var totalPrice = objPartsOrder.ru_TotalAmount__c * (100 - (orderTypeRate)) * 0.01; 
//        var totalPrice = objPartsOrder.ru_TotalAmount__c * (100 - (discountRate + orderTypeRate)) * 0.01;

        var action = component.get("c.doCheckout");
        action.setParams({
            recordId: component.get("v.recordId"),
            param : param,
            totalPrice : totalPrice
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('success','Successfully Save.');
                console.log('[doCheckout] SUCCESS!!! ==============================>');
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.toggleSpinner", false);
            component.set("v.isClickedAddEdit", false);
        });
        $A.enqueueAction(action);
        console.log('[doCheckout] End ==============================>');
    },

    getPartsValue : function (component, event, helper, idx, targetValue, validMessage) {
        console.log('[getPartsValue] Start ==============================>');
        console.log('[getPartsValue] Start ==============================> targetValue : ' + targetValue);
        component.set("v.toggleSpinner", true);

        var listPartsOrderItem = component.get("v.listPartsOrderItem");
        var objPartsOrder = component.get("v.objPartsOrder");
        var action = component.get("c.getPartsValue");

        action.setParams({
            productId : targetValue.toString(),
            priceListId : component.get("v.priceList"),
            factor : component.get("v.factor"),
        });

        action.setCallback(this, function (response) {
             var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getPartsValue] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS' && this.isNullCheck(validMessage)) {
                    var price = result['price'];
                    var description = result['description'];
                    var onHand = result['onHand'];
                    console.log('[getPartsValue] price ==============================> ' + price);
                    listPartsOrderItem[idx].Price__c = price;
                    listPartsOrderItem[idx].ProductName = description;
                    listPartsOrderItem[idx].fm_Amount__c = listPartsOrderItem[idx].Quantity__c * price;
                    listPartsOrderItem[idx].fm_OnHand__c = onHand;
                    listPartsOrderItem[idx].Quantity__c =  1;
                    component.set("v.listPartsOrderItem", listPartsOrderItem);
                    this.doChangeTotal(component, event, helper);
                } else {
                    helper.showToast('error', (this.isNullCheck(validMessage)) ? strMessage : validMessage);
                    listPartsOrderItem[idx].ProductId__c = null;
                    listPartsOrderItem[idx].ProductName = '';
                    listPartsOrderItem[idx].fm_OnHand__c = null;
                    component.set("v.listPartsOrderItem", listPartsOrderItem);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.toggleSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[getPartsValue] End ==============================>');
    },

    doChangeTotal : function (component, event, helper) {
        console.log('[doChangeTotal] Start ==============================>');
        let listPartsOrderItem = component.get("v.listPartsOrderItem");
        let TotalPrice = 0.0;          //Parts : 금액 합계

        for (var i = 0; i < listPartsOrderItem.length; i++){
            if (!this.isNullCheck(listPartsOrderItem[i].fm_Amount__c)) {
                TotalPrice +=  parseFloat(listPartsOrderItem[i].fm_Amount__c);
            }
        }
        component.set("v.TotalPrice", TotalPrice);
        component.set("v.toggleSpinner", false);
    },

    changeValue: function (component, event, helper, type1, type2, idx, targetValue) {
        console.log('[changeValue] Start ==============================>');
        component.set("v.toggleSpinner", true);
        console.log('[changeValue] type1', type1);
        console.log('[changeValue] type2', type2);
        console.log('[changeValue] idx', idx);
        console.log('[changeValue] targetValue', targetValue);
        var objPartsOrder = component.get("v.objPartsOrder");

        switch (type1) {
             case 'Parts':
                console.log('[changeValue] type1 ====> Parts');
                let listPartsOrderItem = component.get("v.listPartsOrderItem");
                let objDataParts = listPartsOrderItem[idx];
                switch (type2) {
                    case 'Quantity':
                        console.log('[changeValue] type2 ====> Quantity');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objDataParts.Price__c != undefined) {
                                objDataParts.fm_Amount__c = objDataParts.Price__c * targetValue;
                            }
                        } else {
                            objDataParts.fm_Amount__c = 0.0;
                        }
                        component.set("v.listPartsOrderItem", listPartsOrderItem);
                        this.doChangeTotal(component, event, helper);
                    break;
                }
             break;
        }
        //component.set("v.toggleSpinner", false);
        console.log('[changeValue] End ==============================>');
    },

    doSetDisability : function (component, event, helper) {
        console.log('[doSetDisability] Start ==============================>');
        var isPartnerUser = component.get("v.isPartnerUser");                 // Partner Profile 일 경우 true
        var isAdministratorUser = component.get("v.isAdministratorUser");     // Partner Profile 일 경우 true
        var objPartsOrder = component.get("v.objPartsOrder");

        /* isAble... 의 값이 true일 때 수정 가능*/
        var isAbleClickAddEdit = false;
        var isAbleClickCheckout = false;

        //Partner User
        if (isPartnerUser == true) {
            if (objPartsOrder.Status__c == 'Created' || objPartsOrder.Status__c == 'Submitted') {
                isAbleClickAddEdit = true;
                isAbleClickCheckout = true;
            } else {
                isAbleClickAddEdit = false;
                isAbleClickCheckout = false;
            }
        }
        //Administrator
        else if (isAdministratorUser == true){
            if (objPartsOrder.Status__c == 'Created' || objPartsOrder.Status__c == 'Submitted') {
                isAbleClickCheckout = true;
            }
            isAbleClickAddEdit = true;
        }
        //TYM User
        else {
            if (objPartsOrder.Status__c == 'Closed' || objPartsOrder.Status__c == 'Canceled') {
                isAbleClickAddEdit = false;
            } else {
                if (objPartsOrder.Status__c == 'Created' || objPartsOrder.Status__c == 'Submitted') {
                    isAbleClickCheckout = true;
                }
                if (objPartsOrder.ApprovalStatus__c == 'Pending') {
                    isAbleClickAddEdit = false;
                } else {
                    isAbleClickAddEdit = true;
                }
            }
        }

        component.set("v.isAbleClickAddEdit", isAbleClickAddEdit);
        component.set("v.isAbleClickCheckout", isAbleClickCheckout);
    },

    /**
     * @description DN_Paging
     */
    doRenderPage: function(component) {
        console.log('[doRenderPage] Start =============================>');
        var listPartsOrderItem = component.get('v.listPartsOrderItem');
        var pageNumberParts = component.get('v.pageNumberParts');
        var pageRecordParts = listPartsOrderItem.slice((pageNumberParts - 1) * 15, pageNumberParts * 15);
        component.set('v.pageRecordParts', pageRecordParts);

        component.set('v.toggleSpinner', false);
    },

    openConfirm: function(component, event, message, theme, label) {
        let parent = this; // this를 다른 변수에 저장
        console.log('this' + this);
        this.LightningConfirm.open({
            message: message,
            theme: theme,
            label: label,
        }).then(function(result, helper) {
            if (result) {
                parent.doCheckout(component, event, helper, theme); 
            } else {
                return;
            }
            console.log('confirm result is', result);
        });
    },
});