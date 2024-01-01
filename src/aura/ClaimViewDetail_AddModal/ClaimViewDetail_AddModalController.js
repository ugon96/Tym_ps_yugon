/**
 * Created by 천유정 on 2023-10-04.
 */

({
    fnInit : function(component, event, helper) {
        console.log('===================> fnInit Start');
        helper.showSpinner(component);
        let listTableColumnLabor = [];
        listTableColumnLabor.push("Labor Group");
        listTableColumnLabor.push("Diagram");
        listTableColumnLabor.push("Labor Code");
        listTableColumnLabor.push("Description");
        listTableColumnLabor.push("Labor Hour");
        component.set("v.listTableColumnLabor", listTableColumnLabor);
        helper.getInitData(component, event, helper);
        helper.hideSpinner(component);
    },

    openModel: function(component, event, helper) {
        component.set("v.isShowPopup", true);
        helper.showSpinner(component);

        var validMessage = '';
        var model = component.get("v.model");
        if (helper.isNullCheck(model)) {
            validMessage = 'Asset is not specified. Fill in the asset field of this claim.';
        }

        // Validation 실패 시
        if(validMessage != '') {
            helper.hideSpinner(component);
            component.set("v.isShowPopup", false); 
            helper.showToast('info', validMessage);
            return;
        }

        component.set("v.laborGroup", null);
        component.set("v.diagram", null);
        component.set("v.laborCode", null);
        component.set("v.description", null);
        component.set("v.searchKey", null);
        component.set("v.listMasterData", []);
        component.set("v.listLaborGroup", []);
        component.set("v.listLaborCode", []);
        component.set("v.listDiagram", []);
        component.set("v.listLaborCodeAll", []);
        helper.getInitData(component, event, helper);
        helper.hideSpinner(component);
    },

    fnCancel: function(component, event, helper) {
        component.set("v.laborGroup", null);
        component.set("v.diagram", null);
        component.set("v.laborCode", null);
        component.set("v.description", null);
        component.set("v.searchKey", null);
        component.set("v.isShowPopup", false);
        component.set("v.listLaborGroup", []);
        component.set("v.listLaborCode", []);
        component.set("v.listDiagram", []);
        component.set("v.listLaborCodeAll", []);
    },

    fnSearch: function(component, event, helper) {
        console.log('===================> fnSearch Start');
        var laborGroup = component.get("v.laborGroup");
        var diagram = component.get("v.diagram");
        var laborCode = component.get("v.laborCode");
        var description = component.get("v.description");
        var searchKey = component.get("v.searchKey");

        console.log('===================> fnSearch laborGroup :: ' + laborGroup);
        console.log('===================> fnSearch diagram :: ' + diagram);
        console.log('===================> fnSearch laborCode :: ' + laborCode);
        console.log('===================> fnSearch description :: ' + description);
        console.log('===================> fnSearch searchKey :: ' + searchKey);

        var validMessage = '';

        if(!helper.isNullCheck(laborGroup) && !helper.isNullCheck(diagram)){
            if (helper.isNullCheck(laborGroup) || helper.isNullCheck(diagram)) {
                validMessage =  'Please select labor group or enter work-hour information keywords.';
            } 
        }
        if(helper.isNullCheck(laborGroup) && helper.isNullCheck(diagram) && helper.isNullCheck(laborCode) && helper.isNullCheck(searchKey)){
            validMessage =  'Please select labor group or enter work-hour information keywords.';
        }

        if(validMessage != '') {
            helper.hideSpinner(component);
            helper.showToast('info', validMessage);
            return;
        }

        helper.doSearch(component, event, helper);
    },

    handlerClickList : function(component, event, helper) {
        var target =  event.currentTarget;
        var index = target.dataset.index;

        var listMasterData = component.get('v.listMasterData');

        component.set("v.isShowPopup", false);

        var evt = component.getEvent("ClaimViewDetail_evt"); 

        console.log('==============> get event');
        if (evt) {
            console.log('==============> event setParam');
            console.log('==============> event setParam');
            evt.setParams({
                "index" : index,
                "targetObject" : listMasterData[index]
            });
            console.log('==============> event start');
            evt.fire();
            console.log('==============> event fire');
        }else {
            console.log('==============> not event');
        }
    },

    handleChange : function(component, event, helper) {
        var value = event.getSource().get("v.value");
        var target = event.getSource().get("v.class");
        var mapSRT = component.get("v.mapSRT");

        var laborGroup = component.get("v.laborGroup");
        var listDiagram = component.get("v.listDiagram");
        var listLaborCode = component.get("v.listLaborCode");
        let listLaborCodeAll = component.get("v.listLaborCodeAll"); 

        console.log('handleChange =====> target ::  '  + target);
        console.log('handleChange =====> value ::  '  + value);
        console.log('handleChange =====> listLaborCodeAll ::  '  + listLaborCodeAll.length);

        let obj = {
            'labelName':'----none----',
            'value':null
        };

        switch (target) {
            case 'laborGroup':
                listDiagram.splice(0, listDiagram.length);
                listLaborCode.splice(0, listLaborCode.length);
                listDiagram.splice(0, 0, obj);
                listLaborCode.splice(0, 0, obj);
                if (!helper.isNullCheck(value)) {
                    for (let data of Object.keys(mapSRT[value])) {
                        let obj2 = {};
                        obj2.value = data;
                        obj2.labelName = data;
                        listDiagram.push(obj2);
                    }
                    component.set("v.listDiagram", listDiagram);
                    component.set("v.listLaborCode", listLaborCode);
                    component.set("v.diagram", null);
                    component.set("v.laborCode", null);
                } else {
                    component.set("v.listDiagram", listDiagram);
                    listLaborCode = [];
                    for (let data of listLaborCodeAll) {
                        let obj2 = {};
                        obj2.value = data.value;
                        obj2.labelName = data.labelName;
                        listLaborCode.push(obj2);
                    }
                    component.set("v.listLaborCode", listLaborCode);
                    component.set("v.diagram", null);
                    component.set("v.laborCode", null);
                }
                break;
            case 'diagram':
                listLaborCode.splice(0, listLaborCode.length);
                listLaborCode.splice(0, 0, obj);
                if (!helper.isNullCheck(value)) {
                    for (let data of (mapSRT[laborGroup])[value]){
                         let obj4 = {};
                         obj4.value = data;
                         obj4.labelName = data;
                         listLaborCode.push(obj4);
                    }
                    component.set("v.listLaborCode", listLaborCode);
                } else {
                    component.set("v.listLaborCode", listLaborCode);
                    component.set("v.laborCode", null);
                }
                break;
        }
    },
});