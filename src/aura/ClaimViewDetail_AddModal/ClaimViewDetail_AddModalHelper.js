/**
 * Created by 천유정 on 2023-10-04.
 */

({
    getInitData : function(component, event, helper) {
        console.log('[getInitData] Start =============================>');
        var action = component.get("c.getInitAddModal");
        action.setParams({
            AddType: component.get("v.addType"),
            model: component.get("v.model"),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getInitData] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[AddModal - getInitData] strStatus =============================>' + strStatus);
                    var mapSRT = result['mapSRT'];
                    var listLaborGroup = component.get("v.listLaborGroup");
                    var listDiagram = component.get("v.listDiagram");
                    var listLaborCode = component.get("v.listLaborCode");
                    var listLaborCodeAll = component.get("v.listLaborCodeAll");
                    console.log('[AddModal - getInitData] mapSRT =============================>' + JSON.stringify(mapSRT));
                    let obj = {
                        'labelName':'----none----',
                        'value':null
                    };
                    listLaborGroup.splice(0, 0, obj);
                    listDiagram.splice(0, 0, obj);
                    listLaborCode.splice(0, 0, obj);
                    listLaborCodeAll.splice(0, 0, obj);
                    for (let data of Object.keys(mapSRT)) {
                        let obj2 = {};
                        obj2.value = data;
                        obj2.labelName = data;
                        listLaborGroup.push(obj2);
                        for (let key of Object.keys(mapSRT[data])) {
                            for (let objdata of Object.values((mapSRT[data])[key])) {
                                let obj4 = {};
                                obj4.value = objdata;
                                obj4.labelName = objdata;
                                listLaborCode.push(obj4);
                                listLaborCodeAll.push(obj4);
                            }
                        }
                    }
                    component.set("v.listLaborGroup", listLaborGroup);
                    component.set("v.listDiagram", listDiagram); 
                    component.set("v.listLaborCode", listLaborCode);
                    component.set("v.listLaborCodeAll", listLaborCodeAll);
                    component.set("v.mapSRT", mapSRT);
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
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[getInitData] End ==============================>');
    },

    doSearch : function(component, event, helper) {
        console.log('[doSearch] Start =============================>');
        var laborGroup = component.get("v.laborGroup");
        var diagram = component.get("v.diagram");
        var laborCode = component.get("v.laborCode");
        var description = component.get("v.description");
        var searchKey = component.get("v.searchKey");

        if(helper.isNullCheck(laborGroup)) component.set("v.laborGroup", null);
        if(helper.isNullCheck(diagram)) component.set("v.diagram", null);
        if(helper.isNullCheck(laborCode)) component.set("v.laborCode", null);

        var action = component.get("c.searchLaborMaster");
        action.setParams({
            model: component.get("v.model"),
            laborGroup: component.get("v.laborGroup"),
            diagram: component.get("v.diagram"),
            laborCode: component.get("v.laborCode"),
            searchKey: searchKey,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doSearch] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[doSearch] strStatus =============================>' + strStatus);
                    var listMasterData = result['listMasterData'];
                    if (listMasterData.length != 0) {
                        for (var data of listMasterData) {
                            data.Name = data.Name;
                            data.LaborGroup__c = data.LaborGroup__c;
                            data.Diagram__c = data.Diagram__c;
                            data.LaborCode__c = data.LaborCode__c;
                            data.Description__c = data.Description__c;
                            data.LaborHour__c = data.LaborHour__c;
                            data.Id = data.Id;
                        }
                        component.set("v.listMasterData", listMasterData);
                    } else {
                        component.set("v.listMasterData", []);
                    }
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
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[doSearch] End ==============================>');
    },
     
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    showSpinner: function (component) {
        /* this will show the <lightning:spinner /> */
        component.set('v.isShowSpinner', true);
    },
    hideSpinner: function (component) {
        /* this will hide the <lightning:spinner /> */
        component.set('v.isShowSpinner', false);
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
});