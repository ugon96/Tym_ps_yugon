/**
 * Created by yghwang on 2023-10-26.
 */

({
    fnInit: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Order Tractor"
            });
        })
            .catch(function (error) {
                console.log(error);
            });

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:product",
                iconAlt: "product"
            });
        })
            .catch(function (error) {
                console.log(error);
            });
        helper.getIsPortalUser(component);
        helper.getData(component);
    },
    handleSubmitButtonClicked : function (component, event, helper) {
        component.set('v.toggleSpinner', true);
        helper.doSubmit(component);
        console.log('===handleSubmitButtonClicked===');
    },
    handleModelChanged: function (component, event, helper) {
        console.log('===handleModelChanged===');
        if(component.get('v.inputModel') == 'Implements/Tires'){
            component.set('v.isAssembled',false);
            component.set('v.isLoaderAssembled',false);
            component.set('v.isBackhoeAssembled',false);
            component.set('v.isMowerAssembled',false);
            component.set('v.isImplements', true);
        } else {
            component.set('v.isImplements', false);
        }
        helper.getConfiguration(component);
        component.set('v.selectedAdditionalOptions',[]);
    },

    handleConfigChanged: function (component, event, helper) {
        console.log('===handleConfigChanged===');
        var tractorId = component.get('v.inputConfig');
        console.log('tractorId :: ' + tractorId);
        // component.set('v.selectedTractor.Id', tractorId);
        var productId = component.get('v.inputConfig')
        if(!helper.isNullCheck(productId)){
            helper.getTractorImage(component,productId);
        } else {
            component.set('v.imageUrl', null);
        }
        helper.calculateSubtotal(component);
        helper.getTire(component);
        helper.getBackhoe(component);
        helper.getLoader(component);
        helper.getMower(component);
        helper.getOption(component);
    },

    handleTireChanged: function (component, event, helper) {
        console.log('===handleTireChanged===');
        helper.calculateSubtotal(component);
    },

    handleLoaderChanged: function (component, event, helper) {
        console.log('===handleLoaderChanged===');
        helper.calculateSubtotal(component);
    },

    handleBackhoeChanged: function (component, event, helper) {
        console.log('===handleBackhoeChanged===');
        helper.calculateSubtotal(component);
    },

    handleMowerChanged: function (component, event, helper) {
        console.log('===handleMowerChanged===');
        helper.calculateSubtotal(component);
    },

    handleEditBtnClicked: function (component, event, helper) {
        /*if(helper.isNullCheck(component.get('v.priceListId'))){
            console.log('handleEditBtnClicked');
            alert('Price List is not set in Dealership.');
        }else {
            helper.doCheckOrderStatus(component);
        }*/
        helper.doCheckOrderStatus(component);
    },
    handleDiscardBtnClicked: function (component, event, helper) {
        helper.doResetTemplate(component);
        helper.getData(component);
        component.set('v.isEditable', false);
        component.set('v.isUpdateOrder', false);
    },

    handleSaveBtnClicked: function (component, event, helper) {
        console.log('===handleSaveBtnClicked===');
        component.set('v.toggleSpinner', true);
        helper.calculateTotal(component);
        helper.doSaveOrderItem(component);
    },

    handleAddOrderBtnClicked: function (component, event, helper) {
        console.log('===handleAddOrderBtnClicked===');
        event.preventDefault();
        // Null Check
        if (helper.isNullCheck(component.get('v.inputModel'))) {
            alert('selectModel null');
            return
        } else {
            if (selectModel != 'Implements/Tires') {
                if (helper.isNullCheck(component.get('v.inputConfig'))) {
                    alert('selectConfig null');
                    return
                }
            }
        }
        if (helper.isNullCheck(component.get('v.inputTire'))) {
            alert('selectTire null');
            return
        } else if (helper.isNullCheck(component.get('v.orderQuantity'))) {
            alert('Quantity null');
            return
        }

        // get variable
        var selectModel = component.get('v.inputModel');
        console.log('selectModel :: ' + selectModel);

        var configOptions = component.get('v.configOptions');
        var selectConfig;
        configOptions.forEach(function(option){
            if(option.value == component.get('v.inputConfig')){
                selectConfig = option;
            }
        });

        var tireOptions = component.get('v.tireOptions');
        var selectTire;
        tireOptions.forEach(function(option){
            if(option.value == component.get('v.inputTire')){
                selectTire = option;
            }
        });

//        selectConfig = {'name':selectConfig.label, 'value':selectConfig.value};
//        selectTire = {'name':selectTire.label, 'value': selectTire.value};

        var orderQuantity = component.get('v.orderQuantity');
        var poNumber = component.get('v.poNumber');


        helper.createNewOrderSummary(component, selectModel, selectConfig, selectTire, orderQuantity, poNumber);
    },

    handleUpdateOrderBtnClicked: function (component, event, helper) {
        // Null Check
        component.set('v.toggleSpinner', true);
        console.log('===handleAddOrderBtnClicked===');
        event.preventDefault();
        // Null Check
        if (helper.isNullCheck(component.get('v.inputModel'))) {
            alert('selectModel null');
            component.set('v.toggleSpinner', false);
            return
        } else {
            if (selectModel != 'Implements/Tires') {
                if (helper.isNullCheck(component.get('v.inputConfig'))) {
                    alert('selectConfig null');
                    component.set('v.toggleSpinner', false);
                    return
                }
            }
        }
        if (helper.isNullCheck(component.get('v.inputTire'))) {
            alert('selectTire null');
            component.set('v.toggleSpinner', false);
            return
        } else if (helper.isNullCheck(component.get('v.orderQuantity'))) {
            alert('Quantity null');
            component.set('v.toggleSpinner', false);
            return
        }

        // get variable
        var selectModel = component.get('v.inputModel');
        console.log('selectModel :: ' + selectModel);

        var configOptions = component.get('v.configOptions');
        var selectConfig;
        configOptions.forEach(function(option){
            if(option.value == component.get('v.inputConfig')){
                selectConfig = option;
            }
        });

        var tireOptions = component.get('v.tireOptions');
        var selectTire;
        tireOptions.forEach(function(option){
            if(option.value == component.get('v.inputTire')){
                selectTire = option;
            }
        });

    //        selectConfig = {'name':selectConfig.label, 'value':selectConfig.value};
    //        selectTire = {'name':selectTire.label, 'value': selectTire.value};
        var orderQuantity = component.get('v.orderQuantity');
        var poNumber = component.get('v.poNumber');

        helper.updateOrderSummary(component, selectModel, selectConfig, selectTire, orderQuantity, poNumber);

    },


    handleOptionChecked: function (component, event, helper) {
        console.log('value :: ' + JSON.stringify(event.getParams('v.value').checked));
        console.log('v.accesskey :: ' + event.getSource().get('v.accesskey'));
        var additionalOptions = component.get('v.additionalOptions');
        var selectedAdditionalOptions = component.get('v.selectedAdditionalOptions');

        var sourceId = event.getSource().get('v.accesskey');
        console.log('sourceId :: ' + sourceId);
        console.log('checked :: ' + event.getParams('v.value').checked);
        if (event.getParams('v.value').checked) {
            additionalOptions.forEach(function (option) {
                if (option.value === sourceId) {
                    selectedAdditionalOptions.push(option);
                    console.log('selected option : ' + JSON.stringify(option));
                }
            });
        } else {
            selectedAdditionalOptions.forEach(function (target, idx) {
                console.log('target.Id :: ' + JSON.stringify(target));
                if (target.value == sourceId) {
                    selectedAdditionalOptions.splice(idx, 1);
                }
            });
        }
        console.log('selectedAdditionalOptions :: ' + JSON.stringify(selectedAdditionalOptions));
        component.set('v.selectedAdditionalOptions', selectedAdditionalOptions);
        helper.calculateSubtotal(component);
    },

    handleEditItemBtnClicked : function(component, event, helper) {
        console.log('handleEditItemBtnClicked :: ');

        var listOrderSummary = component.get('v.listOrderSummary');
        var objOrderSummary = listOrderSummary[event.getSource().get('v.accesskey')];
        component.set('v.objOrderSummary', objOrderSummary);
        console.log('event.getSource().get("v.accesskey") :: ' + event.getSource().get('v.accesskey'));
        console.log('objOrderSummary :: ' + JSON.stringify(objOrderSummary));

        // 편집할 Order Summary 인덱스 번호 저장
        component.set('v.summaryIndex', event.getSource().get('v.accesskey'));
        // Order Summary 업데이트 모드 ON.
        component.set('v.isUpdateOrder', true);
        // 선택한 Order Summary 의 데이터를 가져와 세팅
        component.set('v.inputModel', objOrderSummary.objTractor.label);
        component.set('v.isRetailed', objOrderSummary.isRetailed);
        component.set('v.orderQuantity', objOrderSummary.qty);
        component.set('v.poNumber', objOrderSummary.poNumber);
        component.set('v.notes', objOrderSummary.notes);
        component.set('v.objOptions', objOrderSummary.listOptions);
        console.log('objOrderSummary.listOptions ::  ' + JSON.stringify(objOrderSummary.listOptions));


        if(!helper.isNullCheck(objOrderSummary.objTractor)){
            component.set('v.objConfig', objOrderSummary.objTractor);
            console.log('objTractor ::  ' + JSON.stringify(objOrderSummary.objTractor));
        }
        if(!helper.isNullCheck(objOrderSummary.objTires)){
            var objTires = objOrderSummary.objTires;
            component.set('v.objTires', objTires);
            console.log('objTires :: ' + JSON.stringify(component.get('v.objTires')));
            console.log('objTires :: ' + JSON.stringify(objTires));
        }
        if(!helper.isNullCheck(objOrderSummary.objLoader)){
            var objLoader = objOrderSummary.objLoader;
            component.set('v.objLoader', objLoader);
            console.log('objLoader ::  ' + JSON.stringify(objLoader));
        }
        if(!helper.isNullCheck(objOrderSummary.objBackhoe)){
            var objBackhoe = objOrderSummary.objBackhoe;
            component.set('v.objBackhoe', objBackhoe);
            console.log('objBackhoe ::  ' + JSON.stringify(objBackhoe));
        }
        if(!helper.isNullCheck(objOrderSummary.objMower)){
            var objMower = objOrderSummary.objMower;
            component.set('v.objMower', objMower);
            console.log('objMower ::  ' + JSON.stringify(objMower));
        }

        helper.getConfiguration(component);
    },
    handleDeleteItemBtnClicked : function(component, event, helper) {
        var listOrderSummary = component.get('v.listOrderSummary');
        listOrderSummary.splice(event.getSource().get('v.accesskey'),1);
        component.set('v.listOrderSummary', listOrderSummary);
    },
    handleDuplicateItemBtnClicked : function(component, event, helper) {
        var listOrderSummary = component.get('v.listOrderSummary');
        var objOrderSummary = listOrderSummary[event.getSource().get('v.accesskey')];
        objOrderSummary.Id = null;
        if(objOrderSummary.objTractor != null){
            objOrderSummary.objTractor.Id = null;
        }
        if(objOrderSummary.objTires != null){
            objOrderSummary.objTires.Id = null;
        }
        if(objOrderSummary.objLoader != null){
            objOrderSummary.objLoader.Id = null;
        }
        if(objOrderSummary.objBackhoe != null){
            objOrderSummary.objBackhoe.Id = null;
        }
        if(objOrderSummary.objMower != null){
            objOrderSummary.objMower.Id = null;
        }
        if(objOrderSummary.listOptions.length > 0){
            objOrderSummary.listOptions.forEach(function(option) {
                option.Id = null;
            });
        }
        listOrderSummary.splice(event.getSource().get('v.accesskey'),0,objOrderSummary);
        component.set('v.listOrderSummary', listOrderSummary);
    },

});