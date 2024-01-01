/**
 * Created by 천유정 on 2023-09-19.
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
                    var objClaim = result['objClaim'];
                    component.set("v.objClaim", objClaim);
                    var listDataLabor = result['listDataLabor'];
                    var listDataParts = result['listDataParts'];
                    var isPartnerUser = result['isPartnerUser'];
                    var mapARInvoiceByProducts = result['mapARInvoiceByProducts'];
                    var model = result['model'];
                    var factor = result['factor'];
                    var priceList = result['priceList'];
                    var isAdministratorUser = result['isAdministratorUser'];
                    if (listDataLabor.length != 0) {
                        console.log('[getInitData] listDataLabor.length != 0 =============================>');
                        for (var data of listDataLabor) {
                            data.fm_LaborCode__c = data.fm_LaborCode__c;
                            data.fm_LaborGroup__c = data.fm_LaborGroup__c;
                            data.fm_Diagram__c = data.fm_Diagram__c;
                            data.fm_Description__c = data.fm_Description__c;
                            data.Remarks__c = data.Remarks__c;
                            data.LaborHour__c = data.LaborHour__c;
                            data.ApprovedLaborHour__c = data.ApprovedLaborHour__c;
                            data.LaborCost__c = objClaim.Account.LaborRate__c;
                            data.Description__c = data.Description__c;
                            data.fm_TotalRequestLaborCost__c = data.fm_TotalRequestLaborCost__c;
                            data.fm_TotalApprovedLaborCost__c = data.fm_TotalApprovedLaborCost__c;
                        }
                        component.set("v.listDataLabor", listDataLabor);
                    }
                    if (listDataParts.length != 0) {
                        console.log('[getInitData] listDataParts.length != 0 =====>' + JSON.stringify(listDataParts));
                        for (var data of listDataParts) {
                            data.fm_PartsName__c = data.fm_PartsName__c;
                            data.LP__c = data.LP__c;
                            data.Quantity__c = data.Quantity__c;
                            data.ApprovedQuantity__c = data.ApprovedQuantity__c;
                            data.PartValue__c = data.PartValue__c;
                            data.ApprovedPartValue__c = data.ApprovedPartValue__c;
                            data.CausalPart__c = data.CausalPart__c;
                            data.fm_Amount__c = data.fm_Amount__c;
                            if (data.ProductId__c != undefined && data.ProductId__c != null) {
                                data.fm_PartsNo__c = data.fm_PartsNo__c;
                                data.ProductName = data.ProductId__r.ProductName__c; 
                                data.ProductCode = data.ProductId__r.Name;
                            }
                            if (data.InvoiceItem__c != undefined && data.InvoiceItem__c != null) {
                                data.InvoiceItem__c = data.InvoiceItem__c;
                                data.InvoiceNumber = data.InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c
                                data.hasInvoice = true;
                                data.listARInvoice = this.setInvoiceNumber(component, event, helper, data.ProductId__c, mapARInvoiceByProducts[data.ProductId__c]);
                            }
                            if (data.LocalParts__c != undefined && data.LocalParts__c != null) {
                                data.LocalParts__c = data.LocalParts__c;
                            }
                        }
                        component.set("v.listDataParts", listDataParts);
                    }
                    //console.log('[getInitData] listDataLabor ===============>' + JSON.stringify(component.get("v.listDataLabor")));
                    //console.log('[getInitData] listDataParts ===============>' + JSON.stringify(component.get("v.listDataParts")));
                    console.log('[getInitData] objClaim =============================>' + JSON.stringify(objClaim));
                    component.set("v.model", model); 
                    component.set("v.factor", factor);
                    component.set("v.priceList", priceList); 
                    component.set("v.TotalRequestLaborCost", objClaim.ru_TotalRequestLaborCost__c);
                    component.set("v.TotalApprovedLaborCost", objClaim.ru_TotalApprovedLaborCost__c);
                    component.set("v.TotalRequestPartsValue", objClaim.ru_PartsTotal__c);
                    component.set("v.TotalApprovedPartsValue", objClaim.ru_TotalApprovedPartsAmount__c);
                    component.set('v.isPartnerUser', isPartnerUser);
                    component.set('v.isAdministratorUser', isAdministratorUser);
                    //component.set("v.communityName", result['communityName']);
                    this.doChangeTotal(component, event, helper);
                    this.doSetDisability(component, event, helper);
                    var dataLength = component.get('v.listDataLabor').length;
                    var dataLengthParts = component.get('v.listDataParts').length;
                    component.set('v.pageNumber', 1);
                    component.set('v.total', dataLength);
                    component.set('v.pages', Math.ceil(dataLength / 5));
                    component.set('v.maxPage', Math.floor((dataLength + 4) / 5));
                    component.set('v.pageNumberParts', 1);
                    component.set('v.totalParts', dataLengthParts);
                    component.set('v.pagesParts', Math.ceil(dataLengthParts / 5));
                    component.set('v.maxPageParts', Math.floor((dataLengthParts + 4) / 5)); 
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

    doSave: function (component, event, helper, data, deletedData, dataParts, deletedDataParts) {
        console.log('[doSave] Start ==============================>');
        component.set("v.toggleSpinner", true);
        var action = component.get("c.saveRecord");

        console.log('[doSave] JSON.stringify(data) ==============================>' + JSON.stringify(data));
        console.log('[doSave] JSON.stringify(deletedData) ==============================>' + JSON.stringify(deletedData));
        console.log('[doSave] JSON.stringify(dataParts) ==============================>' + JSON.stringify(dataParts));
        console.log('[doSave] JSON.stringify(deletedDataParts) ==============================>' + JSON.stringify(deletedDataParts));

        for (var obj of dataParts) {
            console.log('data ==============================>' + JSON.stringify(obj));
            delete obj['hasInvoice'];
            delete obj['listARInvoice'];
            delete obj['InvoiceNumber'];
        }
        console.log('[doSave] JSON.stringify(dataParts) ============22222222222' + JSON.stringify(dataParts));

        action.setParams({
            recordId: component.get("v.recordId"),
            listDataLabor: JSON.stringify(data),
            listDataLaborDeleted: JSON.stringify(deletedData),
            listDataParts: JSON.stringify(dataParts),
            listDataPartsDeleted: JSON.stringify(deletedDataParts)
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

    getInvoiceNumber : function (component, event, helper, idx, targetValue) {
        console.log('[getInvoiceNumber] Start ==============================>');
        console.log('[getInvoiceNumber] Start ==============================> targetValue : ' + targetValue);
        component.set("v.toggleSpinner", true);

        var listDataParts = component.get("v.listDataParts");
        console.log('[getInvoiceNumber] Start ==============================>');
        var objClaim = component.get("v.objClaim");
        console.log('[getInvoiceNumber] Start ==============================>' + JSON.stringify(objClaim));
        var action = component.get("c.getInvoiceNumber");
        console.log('[getInvoiceNumber] Start ==============================>');
        action.setParams({
            productId : targetValue.toString(),
            dealershipId : objClaim.AccountId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getInvoiceNumber] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    var mapARInvoice = result['mapARInvoice'];
                    var mapARInvoiceSize = result['mapARInvoiceSize'];
                    if (this.isNullCheck(mapARInvoiceSize)) {
                        console.log('[getInvoiceNumber] mapInvoice is null!');
                        this.getPartsValue(component, event, helper, idx, targetValue);
                    } else {
                        console.log('[getInvoiceNumber] mapInvoice has data!');
                        listDataParts[idx].hasInvoice = true;
                        listDataParts[idx].listARInvoice = this.setInvoiceNumber(component, event, helper, targetValue, mapARInvoice);
                        component.set("v.listDataParts", listDataParts);
                    }
                } else {
                    helper.showToast('error',strMessage);

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
        console.log('[getInvoiceNumber] End ==============================>');
    },

    setInvoiceNumber : function (component, event, helper, targetValue, mapARInvoice) {
        console.log('[setInvoiceNumber] Start ==============================>');
        var mapUnitPriceByInvoice = component.get("v.mapUnitPriceByInvoice");
        var listKey = [];
        let obj = {
            'labelName':'----none----',
            'value':null
        };
        listKey.splice(0, 0, obj);
        for (let data of Object.keys(mapARInvoice)) {
            let obj2 = {};
            obj2.value = data;
            obj2.labelName = data;
            listKey.push(obj2);
        }
        mapUnitPriceByInvoice[targetValue] = mapARInvoice;
        component.set("v.mapUnitPriceByInvoice", mapUnitPriceByInvoice);
        console.log('[setInvoiceNumber] mapUnitPriceByInvoice ==============================>' + JSON.stringify(component.get("v.mapUnitPriceByInvoice")));
        return listKey;
    },

    getPartsValue : function (component, event, helper, idx, targetValue) {
        console.log('[getPartsValue] Start ==============================>');
        console.log('[getPartsValue] Start ==============================> targetValue : ' + targetValue);
        component.set("v.toggleSpinner", true);

        var listDataParts = component.get("v.listDataParts");
        var objClaim = component.get("v.objClaim");
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
                if (strStatus === 'SUCCESS') {
                    var price = result['price'];
                    var description = result['description'];
                    console.log('[getPartsValue] price ==============================> ' + price);
                    listDataParts[idx].PartValue__c = price;
                    listDataParts[idx].fm_PartsName__c = description;
                    listDataParts[idx].fm_Amount__c =  listDataParts[idx].Quantity__c * price;
                    // 23.12.01 수정 (Approved도 반영)
                    listDataParts[idx].ApprovedPartValue__c = price;
                    listDataParts[idx].fm_ApprovedAmount__c =  listDataParts[idx].Quantity__c * price; 
                    component.set("v.listDataParts", listDataParts);
                    this.doChangeTotal(component, event, helper);
                } else {
                    helper.showToast('error',strMessage);
                    listDataParts[idx].ProductId__c = null;
                    listDataParts[idx].fm_PartsName__c = '';
                    component.set("v.listDataParts", listDataParts);
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
        let listDataParts = component.get("v.listDataParts");
        let listDataLabor = component.get("v.listDataLabor");
        let TotalRequestPartsValue = 0.0;          //Parts : Request 금액 합계
        let TotalApprovedPartsValue = 0.0;         //Parts : Approved 금액 합계
        let TotalRequestLaborCost = 0.0;           //Labor : Approved 금액 합계
        let TotalApprovedLaborCost = 0.0;          //Labor : Request 금액 합계

        for (var i = 0; i < listDataLabor.length; i++){
            if (!this.isNullCheck(listDataLabor[i].fm_TotalRequestLaborCost__c)) {
                TotalRequestLaborCost +=  parseFloat(listDataLabor[i].fm_TotalRequestLaborCost__c);
            }
            if (!this.isNullCheck(listDataLabor[i].fm_TotalApprovedLaborCost__c)) {
                TotalApprovedLaborCost +=  parseFloat(listDataLabor[i].fm_TotalApprovedLaborCost__c);
            }
        }
        component.set("v.TotalRequestLaborCost", TotalRequestLaborCost);
        component.set("v.TotalApprovedLaborCost", TotalApprovedLaborCost);
        for (var i = 0; i < listDataParts.length; i++){
            if (!this.isNullCheck(listDataParts[i].fm_Amount__c)) {
                TotalRequestPartsValue +=  parseFloat(listDataParts[i].fm_Amount__c);
            }
            if (!this.isNullCheck(listDataParts[i].fm_ApprovedAmount__c)) {
                TotalApprovedPartsValue +=  parseFloat(listDataParts[i].fm_ApprovedAmount__c);
            }
        }
        component.set("v.TotalRequestPartsValue", TotalRequestPartsValue);
        component.set("v.TotalApprovedPartsValue", TotalApprovedPartsValue);
        component.set("v.toggleSpinner", false);
    },

    changeValue: function (component, event, helper, type1, type2, idx, targetValue) {
        console.log('[changeValue] Start ==============================>');
        component.set("v.toggleSpinner", true);
        console.log('[changeValue] type1', type1);
        console.log('[changeValue] type2', type2);
        console.log('[changeValue] idx', idx);
        console.log('[changeValue] targetValue', targetValue);
        var objClaim = component.get("v.objClaim");

        switch (type1) {
             case 'LaborCode':
                console.log('[changeValue] type1 ====> LaborCode');
                let listDataLabor = component.get("v.listDataLabor");
                let objData = listDataLabor[idx];
                switch (type2) {
                    case 'RequestHour':
                        console.log('[changeValue] type2 ====> RequestHour');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objData.LaborCost__c != undefined) {
                                objData.fm_TotalRequestLaborCost__c = objData.LaborCost__c * targetValue;
                            }
                        } else {
                            objData.fm_TotalRequestLaborCost__c = 0.0;
                        }
                        component.set("v.listDataLabor", listDataLabor);
                        this.doChangeTotal(component, event, helper);
                    break;
                    case 'ApprovedHour':
                        console.log('[changeValue] type2 ====> ApprovedHour');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objData.LaborCost__c != undefined) {
                                objData.fm_TotalApprovedLaborCost__c = objData.LaborCost__c * targetValue;
                            }
                        } else {
                            objData.fm_TotalApprovedLaborCost__c = 0.0;
                        }
                        component.set("v.listDataLabor", listDataLabor);
                        this.doChangeTotal(component, event, helper);
                    break;
                }
             break;
             case 'Parts':
                console.log('[changeValue] type1 ====> Parts');
                let listDataParts = component.get("v.listDataParts");
                let objDataParts = listDataParts[idx];
                switch (type2) {
                    case 'RequestQuantity':
                        console.log('[changeValue] type2 ====> RequestQuantity');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objDataParts.PartValue__c != undefined) {
                                objDataParts.fm_Amount__c = objDataParts.PartValue__c * targetValue;
                            }
                        } else {
                            objDataParts.fm_Amount__c = 0.0;
                        }
                        component.set("v.listDataParts", listDataParts);
                        this.doChangeTotal(component, event, helper);
                    break;
                    case 'RequestAmount':
                        console.log('[changeValue] type2 ====> RequestAmount'); 
                        if(!$A.util.isEmpty(targetValue)){
                            if (objDataParts.Quantity__c != undefined) {
                                objDataParts.fm_Amount__c = objDataParts.Quantity__c * targetValue;
                            }
                        } else {
                            objDataParts.fm_Amount__c = 0.0;
                        }
                        component.set("v.listDataParts", listDataParts);
                        this.doChangeTotal(component, event, helper);
                    break;
                    case 'ApprovedQuantity':
                        console.log('[changeValue] type2 ====> ApprovedQuantity');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objDataParts.ApprovedPartValue__c != undefined) {
                                objDataParts.fm_ApprovedAmount__c = objDataParts.ApprovedPartValue__c * targetValue;
                            }
                        } else {
                            objDataParts.fm_ApprovedAmount__c = 0.0;
                        }
                        component.set("v.listDataParts", listDataParts);
                        this.doChangeTotal(component, event, helper);
                    break;
                    case 'ApprovedAmount':
                        console.log('[changeValue] type2 ====> ApprovedAmount');
                        if(!$A.util.isEmpty(targetValue)){
                            if (objDataParts.ApprovedQuantity__c != undefined) {
                                objDataParts.fm_ApprovedAmount__c = objDataParts.ApprovedQuantity__c * targetValue;
                            }
                        } else {
                            objDataParts.fm_ApprovedAmount__c = 0.0;
                        }
                        component.set("v.listDataParts", listDataParts);
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
        var objClaim = component.get("v.objClaim");

        /* isAble... 의 값이 true일 때 수정&조회 가능*/
        var isAbleClickAddEdit = false;
        var isAbleToShowAdjusted = false;

        //Partner User
        if (isPartnerUser == true) {
            if (objClaim.Status == 'Created' || objClaim.Status == 'Submitted') {
                isAbleClickAddEdit = true;
                isAbleToShowAdjusted = false;
            } else if (objClaim.Status == 'Accepted' || objClaim.Status == 'Rejected' || objClaim.Status == 'Close'){
                isAbleClickAddEdit = false;
                isAbleToShowAdjusted = true;
            } else {
                isAbleClickAddEdit = false;
                isAbleToShowAdjusted = false;
            }
        }
        //Administrator
        else if (isAdministratorUser == true){
            isAbleClickAddEdit = true;
            isAbleToShowAdjusted = true;
        }
        //TYM User
        else {
            isAbleToShowAdjusted = true;
            if (objClaim.Status == 'Closed' || objClaim.Status == 'Rejected') {
                isAbleClickAddEdit = false;
            } else {
                if (objClaim.ApprovalStatus__c == 'Pending') {
                    isAbleClickAddEdit = false;
                } else {
                    isAbleClickAddEdit = true;
                }
            } 
        }

        component.set("v.isAbleClickAddEdit", isAbleClickAddEdit);
        component.set("v.isAbleToShowAdjusted", isAbleToShowAdjusted);
        console.log('isAbleToShowAdjusted => ' + component.get("v.isAbleToShowAdjusted"));
    },

    /**
     * @description DN_Paging
     */
    doRenderPage: function(component) {
        console.log('[doRenderPage] Start =============================>');
        var listDataLabor = component.get('v.listDataLabor');
        var pageNumber = component.get('v.pageNumber');
        var pageRecords = listDataLabor.slice((pageNumber - 1) * 5, pageNumber * 5);
        component.set('v.pageRecords', pageRecords);

        var listDataParts = component.get('v.listDataParts');
        var pageNumberParts = component.get('v.pageNumberParts');
        var pageRecordParts = listDataParts.slice((pageNumberParts - 1) * 5, pageNumberParts * 5);
        component.set('v.pageRecordParts', pageRecordParts);

        component.set('v.toggleSpinner', false);
    },
});