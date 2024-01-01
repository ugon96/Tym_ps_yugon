/**
 * Created by yghwang on 2023-11-02.
 */

({
    getIsPortalUser : function (component){
        var action = component.get('c.getIsPortalUser');
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                component.set('v.isPortalUser', returnVal);
            }
        });
        $A.enqueueAction(action);
    },
    getData : function (component){
        component.set('v.toggleSpinner', true);
        var action = component.get('c.getData');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                console.log('returnVal :: ' + JSON.stringify(returnVal));
                component.set('v.toggleSpinner', false);
                if(returnVal.status == 'SUCCESS'){
                    var modelOptions = [];
                    if(returnVal.modelOptions != null){
                        modelOptions = returnVal.modelOptions;
                        console.log('modelOptions :: ' + JSON.stringify(modelOptions));
                    }
                    console.log('modelOptions :: ' + JSON.stringify(modelOptions));
                    modelOptions.unshift('Implements/Tires');
                    modelOptions.unshift('----none----');
                    component.set('v.modelOptions', modelOptions);
                    component.set('v.loaderOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.backhoeOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.mowerOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    var totalAmount = 0;

                    var discount = returnVal.discount;
                    component.set('v.discount', discount);

                    var strListOrderSummary = returnVal.listOrderSummary;
                    if(!this.isNullCheck(strListOrderSummary)){
                        console.log('listOrderSummary :: ' + strListOrderSummary);
                        var listOrderSummary = JSON.parse(strListOrderSummary);

                        listOrderSummary.forEach(function(orderSummary){
                            totalAmount += orderSummary.subtotal;
                        });
                        console.log('listOrderSummary :: ' + JSON.stringify(listOrderSummary));
                        component.set('v.listOrderSummary', listOrderSummary);
                    }
                    component.set('v.priceListId', returnVal.priceListId);
                    console.log('priceListId :: ' + returnVal.priceListId);
                    component.set('v.totalAmount', totalAmount);


                    var orderStatus = returnVal.orderStatus;
                    console.log('orderStatus :: ' + orderStatus);
                    component.set('v.orderStatus', orderStatus);
                } else {
                    alert(returnVal.message);
                }
            } else {
                alert(response.getError().error());
                component.set('v.toggleSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },

    getConfiguration : function (component) {
        console.log('===getConfiguration===');
        component.set('v.toggleSpinner', true);
        var selectModel = component.get('v.inputModel');
        console.log('selectModel :: ' + selectModel);

        if( this.isNullCheck(selectModel) || selectModel == 'Implements/Tires'){
            component.set('v.configOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
            component.set('v.inputConfig', null);
            var evt = component.get('c.handleConfigChanged');
            $A.enqueueAction(evt);
        } else {
            var action = component.get('c.getConfiguration');
            action.setParams({
                tractorProductCode : selectModel,
                priceListId : component.get('v.priceListId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var returnVal = response.getReturnValue();
                    if(returnVal != null){
                        var selectedValue = returnVal[0].value;
                        var objConfig = component.get('v.objConfig');
                        if(!this.isNullCheck(objConfig)){
                            console.log('objConfig.value :: ' + objConfig.value);
                            component.set('v.isAssembled', objConfig.isAssembled);
                            returnVal.forEach(function(option){
                                if(option.value == objConfig.value){
                                    option.selected = true;
                                    selectedValue = option.value;
                                }
                            });
                        }
                        component.set('v.objConfig', null);
                        component.set('v.configOptions', returnVal);
                        component.set('v.inputConfig', selectedValue);
                        var evt = component.get('c.handleConfigChanged');
                        $A.enqueueAction(evt);
                    } else {
                        component.set('v.configOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                        component.set('v.inputConfig', null);
                        var evt = component.get('c.handleConfigChanged');
                        $A.enqueueAction(evt);
                    }
                } else {
                    alert(response.getError().error());
                }
            });
            $A.enqueueAction(action);
        }
    },

    calculateSubtotal : function(component) {
        console.log('===calculateSubtotal===');
        var subtotal = 0;

        var selectConfig = component.get('v.inputConfig');
        var selectTire = component.get('v.inputTire');
        var selectLoader = component.get('v.inputLoader');
        var selectBackhoe = component.get('v.inputBackhoe');
        var selectMower = component.get('v.inputBackhoe');
        var selectedAdditionalOptions = component.get('v.selectedAdditionalOptions');
        console.log('selectConfig :: ' + selectConfig);
        console.log('selectTire :: ' + selectTire);
        console.log('selectLoader :: ' + selectLoader);
        console.log('selectBackhoe :: ' + selectBackhoe);
        console.log('selectMower :: ' + selectMower);

        if(!this.isNullCheck(selectConfig)){
            var configOptions = component.get('v.configOptions');
            configOptions.forEach(function(option){
                if(option.value == selectConfig){
                    subtotal += option.price;
                    console.log('configPrice :: ' + option.price);
                }
            });
        }
        if(!this.isNullCheck(selectTire)){
            var tireOptions = component.get('v.tireOptions');
            tireOptions.forEach(function(option){
                if(option.value == selectConfig){
                    subtotal += option.price;
                    console.log('tirePrice :: ' + option.price);
                }
            });
        }
        if(!this.isNullCheck(selectLoader)){
            var loaderOptions = component.get('v.loaderOptions');
            loaderOptions.forEach(function(option){
                console.log('option.value :: ' + option.value);
                if(option.value == selectLoader){
                    subtotal += option.price;
                    console.log('loaderPrice :: ' + option.price);
                }
            });
        }
        if(!this.isNullCheck(selectBackhoe)){
            var backhoeOptions = component.get('v.backhoeOptions');
            backhoeOptions.forEach(function(option){
                if(option.value == selectBackhoe){
                    subtotal += option.price;
                    console.log('backhoePrice :: ' + option.price);
                }
            });
        }
        if(!this.isNullCheck(selectMower)){
            var mowerOptions = component.get('v.mowerOptions');
            mowerOptions.forEach(function(option){
                if(option.value == selectMower){
                    subtotal += option.price;
                    console.log('mowerPrice :: ' + option.price);
                }
            });
        }
        if(selectedAdditionalOptions.length > 0){
            selectedAdditionalOptions.forEach(function(option){
                subtotal += option.price;
                console.log('optionPice :: ' + option.price);
            });
        }

        console.log('subtotal :: ' + subtotal);
        component.set('v.subtotal', subtotal);
    },

    getTire : function (component) {
        console.log('===getTire===');
        var action = component.get('c.getTire');
        var selectModel = component.get('v.inputModel');
        console.log('selectModel :: ' + selectModel);
        action.setParams({
            selectModel : selectModel,
            priceListId : component.get('v.priceListId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state :: ' + state);
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(selectModel == 'Implements/Tires'){
                    returnVal.unshift({'label':'----none----', 'value':null, 'selected' : true});
                }
                console.log('returnVal :: ' + returnVal);
                if(returnVal != null){
                    var selectedValue = returnVal[0].value;
                    var objFTire = component.get('v.objFTire');
                    if(!this.isNullCheck(objFTire)){
                        console.log('objFTire.value :: ' + objFTire.value);
                        returnVal.forEach(function(option){
                            if(option.value == objFTire.value){
                                option.selected = true;
                                selectedValue = option.value;
                            }
                        });
                    }
                    component.set('v.objFTire', null);
                    component.set('v.tireOptions', returnVal);
                    component.set('v.inputTire', selectedValue);
                } else {
                    component.set('v.tireOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.inputTire', null);
                }
                component.set('v.toggleSpinner', false);
            } else {
                component.set('v.toggleSpinner', false);
                alert(response.getError().error());
            }
        });
        $A.enqueueAction(action);
    },
    getLoader : function (component) {
        console.log('===getLoader===');
        component.set('v.isLoaderAssembled', false);

        var action = component.get('c.getLoader');
        var tractorId = component.get('v.inputConfig');
        console.log('tractorId :: ' + tractorId);
        action.setParams({
            tractorId : tractorId,
            selectModel : component.get('v.inputModel'),
            priceListId : component.get('v.priceListId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    returnVal.unshift({'label':'----none----', 'value':null, 'selected' : true});

                    var selectedValue = returnVal[0].value;
                    var objLoader = component.get('v.objLoader');
                    if(!this.isNullCheck(objLoader)){
                        console.log('objLoader.value :: ' + objLoader.value);
                        component.set('v.isLoaderAssembled', objLoader.isAssembled);
                        returnVal.forEach(function(option){
                            if(option.value != null &&option.value == objLoader.value){
                                option.selected = true;
                                selectedValue = option.value;
                            }
                        });
                    }
                    component.set('v.objLoader', null);
                    component.set('v.loaderOptions', returnVal);
                    component.set('v.inputLoader', selectedValue);
                } else {
                    component.set('v.loaderOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.inputLoader', null);
                }
            } else {
                alert(response.getError().error());
            }
        });
        $A.enqueueAction(action);
    },

    getBackhoe : function (component) {
        console.log('===getBackhoe===');
        component.set('v.isBackhoeAssembled', false);

        var action = component.get('c.getBackhoe');
        var tractorId = component.get('v.inputConfig');
        console.log('tractorId :: ' + tractorId);
        action.setParams({
            tractorId : tractorId,
            selectModel : component.get('v.inputModel'),
            priceListId : component.get('v.priceListId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('1');
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                console.log('returnVal :: ' + JSON.stringify(returnVal));
                if(returnVal != null){
                    returnVal.unshift({'label':'----none----', 'value':null, 'selected' : true});

                    var selectedValue = returnVal[0].value;
                    var objBackhoe = component.get('v.objBackhoe');
                    if(!this.isNullCheck(objBackhoe)){
                        console.log('objBackhoe.value :: ' + objBackhoe.value);
                        component.set('v.isBackhoeAssembled', objBackhoe.isAssembled);
                        returnVal.forEach(function(option){
                            if(option.value != null && option.value == objBackhoe.value){
                                console.log('backhoeselected');
                                option.selected = true;
                                selectedValue = option.value;
                            }
                        });
                    }
                    component.set('v.objBackhoe', null);
                    component.set('v.backhoeOptions', returnVal);
                    component.set('v.inputBackhoe', selectedValue);
                } else {
                    component.set('v.backhoeOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.inputBackhoe', null);
                }
            } else {
                alert(response.getError().error());
            }
        });
        $A.enqueueAction(action);
    },
    getMower : function (component) {
        console.log('===getMower===');
        component.set('v.isMowerAssembled', false);
        var action = component.get('c.getMower');
        var tractorId = component.get('v.inputConfig');
        console.log('tractorId :: ' + tractorId);
        action.setParams({
            tractorId : tractorId,
            selectModel : component.get('v.inputModel'),
            priceListId : component.get('v.priceListId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    returnVal.unshift({'label':'----none----', 'value':null, 'selected' : true});

                    var selectedValue = returnVal[0].value;
                    var objMower = component.get('v.objMower');
                    if(!this.isNullCheck(objMower)){
                        console.log('objMower.value :: ' + objMower.value);
                        component.set('v.isMowerAssembled', objMower.isAssembled);
                        returnVal.forEach(function(option){
                            if(option.value != null && option.value == objMower.value){
                                option.selected = true;
                                selectedValue = option.value;
                            }
                        });
                    }
                    component.set('v.objMower', null);
                    component.set('v.mowerOptions', returnVal);
                    component.set('v.inputMower', selectedValue);
                } else {
                    component.set('v.mowerOptions', [{'label':'----none----', 'value':null, 'selected' : true}]);
                    component.set('v.inputMower', null);
                }
            } else {
                alert(response.getError().error());
            }
        });
        $A.enqueueAction(action);
    },
    getOption : function (component) {
        console.log('===getOption===');
        var action = component.get('c.getOption');
        var tractorId = component.get('v.inputConfig');
        console.log('tractorId :: ' + tractorId);
        action.setParams({
            tractorId : tractorId,
            selectModel : component.get('v.inputModel'),
            priceListId : component.get('v.priceListId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    var objOptions = component.get('v.objOptions');
                    console.log('objOptions :: ' + JSON.stringify(objOptions));
                    if(objOptions.length > 0){
                        var optionValues = [];
                        objOptions.forEach(function(option){
                            if(option.value != null && option.value != ''){
                                optionValues.push(option.value);
                            }
                        });

                        returnVal.forEach(function(option) {
                            console.log('option.value :: ' + option.value);
                            if(option.value != null && optionValues.indexOf(option.value) >= 0){
                                console.log('truetrue');
                                option.checked = true;
                            }
                        });
                    } else {
                        component.set('v.objOptions', []);
                    }
                    component.set('v.additionalOptions', returnVal);
                    var objOrderSummary = component.get('v.objOrderSummary');
                } else {
                    component.set('v.additionalOptions', []);
                }
            } else {
                alert(response.getError().error());
            }
        });
        $A.enqueueAction(action);
    },

    // Order Summary 생성 Required Field 는 받아오고 나머지는 여기서 가져온다.
    createNewOrderSummary : function (component, selectModel, selectConfig, selectTire, orderQuantity, poNumber) {
        console.log('======createNewOrderSummary======')
        console.log('selectModel :: ' + selectModel);

        var isRetailed = component.get('v.isRetailed');
        var notes = component.get('v.notes');

        var loaderOptions = component.get('v.loaderOptions');
        var selectLoader = component.get('v.inputLoader');
        loaderOptions.forEach(function(option){
            if( option.value != null && option.value == selectLoader){
                selectLoader= option;
//                selectLoader = {'name': option.label, 'value':option.value};
                console.log('selectLoader :: ' + selectLoader);
                return false;
            }
        });
        

        var backhoeOptions = component.get('v.backhoeOptions');
        var selectBackhoe = component.get('v.inputBackhoe');
        backhoeOptions.forEach(function(option) {
            if(option.value != null && option.value == selectBackhoe) {
                selectBackhoe = option;
//                selectBackhoe = {'name': option.label, 'value':option.value};
                console.log('selectBackhoe :: ' + selectBackhoe);
                return false;
            }
        });
        

        var mowerOptions = component.get('v.mowerOptions');
        var selectMower = component.get('v.inputMower');
        mowerOptions.forEach(function(option){
            if(option.value != null && option == selectMower){
                selectMower = option;
//                selectMower = {'name': option.label, 'value':option.value};
                console.log('selectMower :: ' + selectMower);
                return false;
            }
        });

        var isAssembled = component.get('v.isAssembled');
        var isLoaderAssembled = component.get('v.isLoaderAssembled');
        var isBackhoeAssembled = component.get('v.isBackhoeAssembled');
        var isMowerAssembled = component.get('v.isMowerAssembled');
        var selectedAdditionalOptions = component.get('v.selectedAdditionalOptions');
        var subtotal = component.get('v.subtotal') * component.get('v.orderQuantity');

        var objTractor = null;
        var objLoader = null;
        var objBackhoe = null;
        var objFTire = null;
        var objRTire = null;
        var objMower = null;
        var listOptions = component.get('v.selectedAdditionalOptions');
        console.log('listOptions :: ' + JSON.stringify(listOptions));

        var isAssembled = component.get('v.isAssembled');

        if(selectModel == 'Implements/Tires'){
            objTractor = {'label':'Implements/Tires'};
        } else {
            objTractor = {'label':selectModel, 'value':selectConfig.value, 'configName':selectConfig.label, 'isAssembled': isAssembled};
        }
        
        if(!this.isNullCheck(selectTire.value)){
//            objFTire = {'label':selectTire.label,'value':selectTire.value, 'isAssembled':isAssembled};
            selectTire.isAssembled = isAssembled;
        }
        if(!this.isNullCheck(selectLoader)){
//            objLoader = {'label':selectLoader.label,'value':selectLoader.value, 'isAssembled':isLoaderAssembled};
            selectLoader.isAssembled = isLoaderAssembled;
        }
        if(!this.isNullCheck(selectBackhoe)){
//            objBackhoe = {'label':selectBackhoe.label, 'value':selectBackhoe.value, 'isAssembled':isBackhoeAssembled};
            selectBackhoe.isAssembled = isBackhoeAssembled;
        }
        if(!this.isNullCheck(selectMower)){
//            objMower = {'label':selectMower.label,'value':selectMower.value, 'isAssembled':isMowerAssembled};
            selectMower.isAssembled = isMowerAssembled;
        }

        var objSummary = {
            'Id' : null,
            'poNumber' : poNumber,
            'notes' : notes,
            'qty' : orderQuantity,
            'isRetailed' : isRetailed,
            'isAssembled' : isAssembled,
            'subtotal'   : subtotal,
            'objTractor' : objTractor,
            'objLoader'  : selectLoader,
            'objBackhoe' : selectBackhoe,
            'objTires'   : selectTire,
            'objMower'   : objMower,
            'listOptions' : listOptions
        };
        console.log('objSummary :: ' + JSON.stringify(objSummary));

        var listOrderSummary = component.get('v.listOrderSummary');

        listOrderSummary.push(objSummary);
        console.log('listOrderSummary :: ' + listOrderSummary);
        component.set('v.listOrderSummary', listOrderSummary);
        this.calculateTotal(component);
        // 주문 템플릿 초기화
        this.doResetTemplate(component);

    },

    updateOrderSummary : function (component, selectModel, selectConfig, selectTire, orderQuantity, poNumber) {
        console.log('======updateOrderSummary======')
        console.log('selectModel :: ' + selectModel);

        var objOrderSummary = component.get('v.objOrderSummary');

        var isRetailed = component.get('v.isRetailed');
        var notes = component.get('v.notes');

        var loaderOptions = component.get('v.loaderOptions');
        var selectLoader = component.get('v.inputLoader');
        loaderOptions.forEach(function(option){
            if( option.value != null && option.value == selectLoader){
                selectLoader= option;
//                selectLoader = {'name': option.label, 'value':option.value};
                console.log('selectLoader :: ' + selectLoader);
                return false;
            }
        });


        var backhoeOptions = component.get('v.backhoeOptions');
        var selectBackhoe = component.get('v.inputBackhoe');
        backhoeOptions.forEach(function(option) {
            if(option.value != null && option.value == selectBackhoe) {
                selectBackhoe = option;
//                selectBackhoe = {'name': option.label, 'value':option.value};
                console.log('selectBackhoe :: ' + selectBackhoe);
                return false;
            }
        });


        var mowerOptions = component.get('v.mowerOptions');
        var selectMower = component.get('v.inputMower');
        mowerOptions.forEach(function(option){
            if(option.value != null && option == selectMower){
                selectMower = option;
//                selectMower = {'name': option.label, 'value':option.value};
                console.log('selectMower :: ' + selectMower);
                return false;
            }
        });

        var isAssembled = component.get('v.isAssembled');
        var isLoaderAssembled = component.get('v.isLoaderAssembled');
        var isBackhoeAssembled = component.get('v.isBackhoeAssembled');
        var isMowerAssembled = component.get('v.isMowerAssembled');
        var selectedAdditionalOptions = component.get('v.selectedAdditionalOptions');
        var subtotal = component.get('v.subtotal') * component.get('v.orderQuantity');

        var objTractor = null;
        var objLoader = null;
        var objBackhoe = null;
        var objFTire = null;
        var objRTire = null;
        var objMower = null;
        var listOptions = component.get('v.selectedAdditionalOptions');
        console.log('listOptions :: ' + JSON.stringify(listOptions));

        var isAssembled = component.get('v.isAssembled');


        if(selectModel == 'Implements/Tires'){
            objTractor = {'label':'Implements/Tires'};
        } else {
            objTractor = {'label':selectModel, 'value':selectConfig.value, 'configName':selectConfig.label, 'isAssembled': isAssembled};
        }

        if(!this.isNullCheck(selectTire.value)){
//            objFTire = {'label':selectTire.label,'value':selectTire.value, 'isAssembled':isAssembled};
            selectTire.isAssembled = isAssembled;
        }
        if(!this.isNullCheck(selectLoader)){
//            objLoader = {'label':selectLoader.label,'value':selectLoader.value, 'isAssembled':isLoaderAssembled};
            selectLoader.isAssembled = isLoaderAssembled;
        }
        if(!this.isNullCheck(selectBackhoe)){
//            objBackhoe = {'label':selectBackhoe.label, 'value':selectBackhoe.value, 'isAssembled':isBackhoeAssembled};
            selectBackhoe.isAssembled = isBackhoeAssembled;
        }
        if(!this.isNullCheck(selectMower)){
//            objMower = {'label':selectMower.label,'value':selectMower.value, 'isAssembled':isMowerAssembled};
            selectMower.isAssembled = isMowerAssembled;
        }

        var objSummary = {
            'Id' : objOrderSummary.Id,
            'poNumber' : poNumber,
            'notes' : notes,
            'qty' : orderQuantity,
            'isRetailed' : isRetailed,
            'isAssembled' : isAssembled,
            'subtotal'   : subtotal,
            'objTractor' : objTractor,
            'objLoader'  : selectLoader,
            'objBackhoe' : selectBackhoe,
            'objTires'   : selectTire,
            'objMower'   : objMower,
            'listOptions' : listOptions
        };
        console.log('objSummary :: ' + objSummary);

        var listOrderSummary = component.get('v.listOrderSummary');
        var index = component.get('v.summaryIndex');
        listOrderSummary.splice(index,1);   // 기존 요소를 제거하고
        listOrderSummary.splice(index,0,objSummary);    // 해당 위치에 요소 추가
        component.set('v.isUpdateOrder', false);
        console.log('listOrderSummary :: ' + listOrderSummary);
        component.set('v.listOrderSummary', listOrderSummary);
        this.calculateTotal(component);

        // 주문 템플릿 초기화
        this.doResetTemplate(component);
    },

    // 주문 템플릿 초기화
    doResetTemplate : function(component){
        console.log('===doResetTemplate===');
        component.set('v.isAssembled', false);
        component.set('v.isRetailed', false);
        component.set('v.isLoaderAssembled', false);
        component.set('v.isBackhoeAssembled', false);
        component.set('v.isMowerAssembled', false);
        component.set('v.inputBackhoe', null);
        component.set('v.inputLoader', null);
        component.set('v.inputMower', null);
        component.set('v.subtotal', 0);

        component.set('v.orderQuantity', 1);
        component.set('v.poNumber', '');
        component.set('v.notes','');

        component.set('v.inputModel','----none----');

        $A.enqueueAction(component.get('c.handleModelChanged'));
    },

    doSaveOrderItem : function (component) {
        var listOrderSummary = JSON.stringify(component.get('v.listOrderSummary'));
        var totalAmount = component.get('v.totalAmount');
        var discount = component.get('v.discount');
        var extendedAmount =  totalAmount - (totalAmount * discount / 100);

        var action = component.get('c.doSaveOrderItem');
        action.setParams({
            recordId : component.get('v.recordId'),
            listOrderSummary : listOrderSummary,
            extendedAmount : extendedAmount
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    console.log('success');
                    this.doResetTemplate(component);
                    this.getData(component);
                    component.set('v.isEditable', false);
                } else {
                    alert('error2');
                }
            } else {
                alert('error');
            }
            component.set('v.toggleSpinner', false);
        });
        $A.enqueueAction(action);
    },

    doCheckOrderStatus : function (component) {
        console.log('===doCheckOrderStatus===');
        var recordId = component.get('v.recordId');
        var action = component.get('c.doCheckOrderStatus');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVal = response.getReturnValue();
                console.log('returnVal :: '+ returnVal);
                if(returnVal == 'Created' || returnVal == 'Submitted'){
                    component.set('v.isEditable', true);
                } else if(component.get('v.isPortalUser') == false) {
                    component.set('v.isEditable', true);
                }
                else if (returnVal == null) {
                    alert('Unknown Error');
                } else {
                    alert('Please check order status, Editing is possible only if the Order\'s status is \'Created\' or \'Approved\'.');
                }
            } else {

            }
        });
        $A.enqueueAction(action);
    },
    doSubmit : function(component) {
        var action = component.get('c.doSubmit');
        action.setParams({
            recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' ){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    this.showToast('success', 'Submit Successfully');
                    component.set('v.toggleSpinner', false);
                    location.reload(true);
                } else {
                    alert('Submit Failed');
                    component.set('v.toggleSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    calculateTotal : function (component) {
        console.log('===calculateTotal===');
        var listOrderSummary = component.get('v.listOrderSummary');
        var totalAmount = 0;
        if(!this.isNullCheck(listOrderSummary)){
            listOrderSummary.forEach(function(orderSummary){
                totalAmount += orderSummary.subtotal;
            });
        }
        component.set('v.totalAmount', totalAmount);
        console.log('===calculateTotal===End');
    },

    getTractorImage : function(component, productId) {
        var action = component.get('c.getTractorImage');
        action.setParams({
            productId : productId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    console.log('imageUrl :: ' + returnVal);
                    component.set('v.imageUrl', returnVal);
                }
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

    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == '' || value == 0 || value =='----none----'){
            return true;
        }
        else{
            return false;
        }
    },


});