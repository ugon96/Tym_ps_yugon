/**
 * Created by 천유정 on 2023-09-19.
 */

({
    fnInit : function(component, event, helper){
        let TableDisplayList = [];
        TableDisplayList.push("No.");
        TableDisplayList.push("LP");
        TableDisplayList.push("Causal Part");
        TableDisplayList.push("Parts No.");
        TableDisplayList.push("Description");
        TableDisplayList.push("Quantity");
        TableDisplayList.push("Parts Value");
        TableDisplayList.push("Amount");
        component.set("v.TableDisplayList", TableDisplayList);
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
        //Labor
        var data = component.get("v.listDataLabor");
        var deletedData = component.get("v.listDataLaborDeleted");
        //Parts
        var dataParts = component.get("v.listDataParts");
        var deletedDataParts = component.get("v.listDataPartsDeleted");

        if (!helper.isNullCheck(data)) {
            for (var i = 0; i < data.length; i++){
                if (isPartnerUser) {
                    if(helper.isNullCheck(data[i].LaborHour__c)) {
                        validMessage =  "Please fill the request labor hours. row number :  " + (i+1);
                    }
                } else {
                    if(helper.isNullCheckExceptZero(data[i].ApprovedLaborHour__c)) {
                        validMessage =  "Please fill the approved labor hours. row number :  " + (i+1); 
                    }
                }
            }
        }

        if (!helper.isNullCheck(dataParts)) {
            var CausalPartCount = 0;
            for (var i = 0; i < dataParts.length; i++){
                if (dataParts[i].CausalPart__c == true) CausalPartCount++;
                if(helper.isNullCheck(dataParts[i].ProductId__c) && dataParts[i].LP__c == false) {
                    validMessage =  "Please fill the parts. row number :  " + (i+1);
                } else if(helper.isNullCheck(dataParts[i].LocalParts__c) && dataParts[i].LP__c == true) {
                    validMessage =  "Please select the local parts. row number :  " + (i+1);
                } else if(helper.isNullCheck(dataParts[i].Quantity__c)) {
                    validMessage =  "Please fill the request quantity. row number :  " + (i+1);
                } else if(helper.isNullCheck(dataParts[i].PartValue__c)) {
                    validMessage =  "Please fill the request value. row number :  " + (i+1);
                }
                if (!isPartnerUser) {
                    if(helper.isNullCheckExceptZero(dataParts[i].ApprovedQuantity__c)) {
                        validMessage =  "Please fill the approve quantity. row number :  " + (i+1);
                    } else if(helper.isNullCheckExceptZero(dataParts[i].ApprovedPartValue__c)) {
                        validMessage =  "Please fill the approved value. row number :  " + (i+1);
                    }
                }
                if (dataParts[i].hasInvoice == true && helper.isNullCheck(dataParts[i].InvoiceNumber)) {
                    validMessage =  "Please select the invoice number. row number :  " + (i+1);
                }
            }
            if (CausalPartCount > 1) {
                validMessage =  "You cannot select more than one Causal Part. Please check only one."; 
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
                 helper.doSave(component, event, helper, data, deletedData, dataParts, deletedDataParts)},
             100 
         );
        console.log('[fnSave] End =============================>');
    },

    fnAddParts: function(component, event, helper){
        console.log('fnAddParts =========> Start !!' );
        component.set("v.toggleSpinner", true);
        var validMessage = '';
        var objClaim = component.get("v.objClaim");
        var priceList = component.get("v.priceList");

        if (helper.isNullCheck(priceList)) {
            validMessage = 'The price list for the account is not specified. Please contact your Territory Manager.';
        }
        if (helper.isNullCheck(objClaim.AssetId)) {
            validMessage = 'Asset is not specified. Fill in the asset field of this claim.'; 
        }

        // Validation 실패 시
        if(validMessage != '') {
            component.set("v.toggleSpinner", false);
            helper.showToast('info', validMessage);
            return;
        }

        var data = component.get("v.listDataParts");
        let obj = {
                'sobjectType'            :'Parts__c',
                'ClaimId__c'             : component.get("v.recordId"),
                'CausalPart__c'          : false,
                'LP__c'                  : false,
                'ProductId__c'           : null,
                'PartValue__c'           : 0.0,
                'fm_Description__c'      : null,
                'fm_PartsName__c'        : null,
                'fm_PartsNo__c'          : null,
                'Quantity__c'            : 1,
                'ApprovedQuantity__c'    : 1,
                'LocalParts__c'          : null,
                'ApprovedPartValue__c'   : 0.0,
                'hasInvoice'             : false,
                'listARInvoice'          : [],
                'InvoiceNumber'          : null,
                'InvoiceItem__c'          : null,
        };
        data.push(obj);
        component.set("v.listDataParts", data);
        helper.doRenderPage(component);
        console.log('[fnAddParts] listDataParts : ', JSON.stringify(component.get("v.listDataParts")));
        component.set("v.toggleSpinner", false);
    },

    fnEventAddRowLabor: function(component, event, helper) {
        console.log('======================> [fnEventAddRowLabor] Start!!! ');
        var eventTarget = event.getParam("index");
        var eventTarget2 = event.getParam("targetObject");

        console.log('======================> eventTarget : '+JSON.stringify(eventTarget));
        console.log('======================> eventTarget2 : '+JSON.stringify(eventTarget2));

        var data = component.get("v.listDataLabor");
        var objClaim = component.get("v.objClaim");
        let obj = {
                'sobjectType'                       : 'LaborCode__c',
                'ClaimId__c'                        : component.get("v.recordId"),
                'LaborCodeMasterId__c'              : eventTarget2.Id,
                'fm_LaborGroup__c'                  : eventTarget2.LaborGroup__c,
                'fm_Diagram__c'                     : eventTarget2.Diagram__c,
                'fm_LaborCode__c'                   : eventTarget2.LaborCode__c,
                'fm_Description__c'                 : eventTarget2.Description__c,
                'Remarks__c'                        : null,
                'LaborHour__c'                      : eventTarget2.LaborHour__c,
                'ApprovedLaborHour__c'              : eventTarget2.LaborHour__c, //23.12.01 Approved도 반영
                'LaborCost__c'                      : objClaim.Account.LaborRate__c,
                'fm_TotalApprovedLaborCost__c'      : eventTarget2.fm_TotalApprovedLaborCost__c,
                'fm_TotalRequestLaborCost__c'       : eventTarget2.fm_TotalRequestLaborCost__c,
        };
        data.push(obj);
        component.set("v.listDataLabor", data);
        helper.changeValue(component, event, helper, 'LaborCode', 'RequestHour', data.length-1, eventTarget2.LaborHour__c);
        helper.doRenderPage(component);
        component.set("v.toggleSpinner", false);
        console.log('[fnEventAddRowLabor] listDataLabor : ', JSON.stringify(component.get("v.listDataLabor")));
        console.log('[fnEventAddRowLabor] End =============================>');
    },

    handlerCheck : function(component, event, helper) {
        console.log('======================> handlerCheckLP listDataLabor : '+ JSON.stringify(component.get("v.listDataParts")));
        var index = event.getSource().get("v.accesskey");
        var target = event.getSource().get("v.class");
        var isChecked = event.getSource().get("v.checked");
        console.log('======================> handlerCheckLP index : '+ index);
        console.log('======================> handlerCheckLP target : '+ target);

        var data = component.get("v.listDataParts");
        if (target == 'LP') {
            data[index].LP__c = isChecked;
            data[index].PartValue__c = 0.0;
            data[index].ApprovedPartValue__c = 0.0;
            data[index].fm_Amount__c = 0.0;
            data[index].fm_ApprovedAmount__c = 0.0;  
        } else {
            data[index].CausalPart__c = isChecked;
        }
        component.set("v.listDataParts", data);
        console.log('======================> handlerCheckLP isChecked : '+isChecked);
        console.log('======================> listDataParts : '+ JSON.stringify(component.get("v.listDataParts")));
    },

    handleDeleteLabor: function (component, event, helper) {
        console.log('======================> [handleDeleteLabor] Start!!! ');
        var selectedItem = event.currentTarget;
        var row = selectedItem.dataset.record;
        console.log('======================> row ' + row);
        console.log('======================> row.Id ' + row.Id);

        var listDataLabor = component.get("v.listDataLabor");
        var listDataLaborDeleted = component.get("v.listDataLaborDeleted");

        if (listDataLabor[row].Id != null) listDataLaborDeleted.push(listDataLabor[row]);
        listDataLabor.splice(listDataLabor.indexOf(listDataLabor[row]), 1);

        component.set("v.listDataLabor", listDataLabor);
        component.set("v.listDataLaborDeleted", listDataLaborDeleted);
        console.log('======================> [handleDeleteLabor] 222');

        helper.doChangeTotal(component, event, helper);
        console.log('======================> [handleDeleteLabor] listDataLabor : '+JSON.stringify(listDataLabor));
        console.log('======================> [handleDeleteLabor] listDataLaborDeleted : '+JSON.stringify(listDataLaborDeleted));
    },

   handleDeleteParts: function (component, event, helper) {
        console.log('======================> [handleDeleteParts] Start!!! ');
        var selectedItem = event.currentTarget;
        var row = selectedItem.dataset.record;
        console.log('======================> row ' + row);
        console.log('======================> row.Id ' + row.Id);

        var listDataParts = component.get("v.listDataParts");
        var listDataPartsDeleted = component.get("v.listDataPartsDeleted");

        if (listDataParts[row].Id != null) listDataPartsDeleted.push(listDataParts[row]);
        listDataParts.splice(listDataParts.indexOf(listDataParts[row]), 1);

        component.set("v.listDataParts", listDataParts);
        component.set("v.listDataPartsDeleted", listDataPartsDeleted);
        console.log('======================> [handleDeleteParts] 222');

        helper.doChangeTotal(component, event, helper);
        console.log('======================> [handleDeleteParts] listDataLabor : '+JSON.stringify(listDataParts));
        console.log('======================> [handleDeleteParts] listDataLaborDeleted : '+JSON.stringify(listDataPartsDeleted));
    },

   /*
   * Description : DN_Lookup 컴포넌트로 Product 값 선택 시
   */
   fnHandleSelected: function(component, event, helper) {
       console.log('[fnHandleSelected] Start =============================>');
       var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
       console.log('[fnHandleSelected] uniqueLookupIdentifier', uniqueLookupIdentifier);
       console.log('[fnHandleSelected] uniqueLookupIdentifier', JSON.stringify(uniqueLookupIdentifier));
       var targetValue = event.getParam("selectedId");
       console.log('[fnHandleSelected] selectedId', targetValue);
       console.log('[fnHandleSelected] selectedName', event.getParam("selectedName"));
       console.log('[fnHandleSelected] selectedLabel', event.getParam("selectedLabel")); 
       if(targetValue.length > 0){
           var type = uniqueLookupIdentifier[0];
           var idx = parseInt(uniqueLookupIdentifier[1],10);
           helper.getPartsValue(component, event, helper, idx, targetValue);
       }
       console.log('[fnHandleSelected] End =============================>');
   },

   fnChangeParts: function(component, event, helper) {
       var targetValue = event.getSource().get("v.value");
       var idx = event.getSource().get("v.accesskey");
       var listDataParts = component.get("v.listDataParts");

       console.log('[fnChangeParts] targetValue', targetValue);
       console.log('[fnChangeParts] idx', idx);
       if(targetValue.length > 0){
           //helper.getPartsValue(component, event, helper, idx, targetValue);
           helper.getInvoiceNumber(component, event, helper, idx, targetValue);
       } else {
           listDataParts[idx].PartValue__c = 0;
           listDataParts[idx].fm_Amount__c =  0;
           listDataParts[idx].fm_PartsName__c =  null;
           listDataParts[idx].InvoiceItem__c = null;
           listDataParts[idx].hasInvoice = false;
           listDataParts[idx].InvoiceNumber = null;
           listDataParts[idx].ApprovedPartValue__c = 0.0;
           listDataParts[idx].fm_ApprovedAmount__c = 0.0;
           component.set("v.listDataParts", listDataParts);
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
       var listDataParts = component.get("v.listDataParts");
       var objData = listDataParts[idx];
       console.log('[fnHandelRemoved] uniqueLookupIdentifier', uniqueLookupIdentifier);
       console.log('[fnHandelRemoved] selectedId', targetValue);
       console.log('[fnHandelRemoved] type', type);
       console.log('[fnHandelRemoved] idx', idx);
       console.log('[fnHandelRemoved] objData', objData);
       switch (type) {
            case 'PricebookEntry' :
            objData.fm_Description__c = null;
            objData.Quantity__c = 1.0;
            objData.ApprovedQuantity__c = 1.0;
            objData.PartValue__c = 0.0;
            objData.ApprovedPartValue__c = 0.0;
            objData.fm_Amount__c = 0.0;
            objData.fm_ApprovedAmount__c = 0.0;
            objData.fm_PartsName__c = null;
            break;
       }
       component.set("v.listDataParts", listDataParts);
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

   /*
   * Description : Invoice 변경 시, 해당하는 가격 가져오기
   */
   handleChangeInvoice: function(component, event, helper){
        var InvoiceNumber = event.getSource().get("v.value");
        var mapUnitPriceByInvoice = component.get("v.mapUnitPriceByInvoice");
        var listDataParts = component.get("v.listDataParts");

        var target = event.getSource().get("v.class").split('-');
        var type1 = target[0];
        var productId = target[1];
        var idx = parseInt(target[2],10);
        console.log('[handleChangeInvoice] type1 ', type1);
        console.log('[handleChangeInvoice] productId ', productId);
        console.log('[handleChangeInvoice] idx ', idx);
        console.log('[handleChangeInvoice] InvoiceNumber ', InvoiceNumber);
        if(!helper.isNullCheck(InvoiceNumber)){
            var price = mapUnitPriceByInvoice[productId][InvoiceNumber].UnitPrice__c;
            console.log('[handleChangeInvoice] price => ' + price);
            listDataParts[idx].PartValue__c = price;
            listDataParts[idx].fm_Amount__c =  listDataParts[idx].Quantity__c * price;
            listDataParts[idx].InvoiceItem__c =  mapUnitPriceByInvoice[productId][InvoiceNumber].Id;
        } else {
            listDataParts[idx].PartValue__c = 0;
            listDataParts[idx].fm_Amount__c =  0;
            listDataParts[idx].InvoiceItem__c = null;
        }
        component.set("v.listDataParts", listDataParts);
        console.log('handleChangeInvoice ===> listDataParts :' + JSON.stringify(component.get("v.listDataParts")));
        helper.doChangeTotal(component, event, helper);
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
});