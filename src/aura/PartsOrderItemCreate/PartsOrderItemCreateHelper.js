/**
 * Created by 천유정 on 2023-10-30.
 */

({
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
                    component.set("v.listLV1", result['listLV1']);
                    console.log('[getInitData] Start =============================> listLV1' + component.get("v.listLV1"));
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

    doSearch : function(component, event, helper) {
        console.log('[doSearch] Start =============================>');
        var action = component.get("c.getPartsHierarchy");
        action.setParams({
            model: component.get("v.model"),
            lv1: component.get("v.lv1"),
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
                    var mapLv3 = result['mapLv3'];
                    this.convertDataToJavaScript(component, mapLv3);
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

    convertDataToJavaScript : function(component, data) {
        console.log('item start : ' + JSON.stringify(data));
        var items = [];
        for (var key in data) {
            var topLevelItem = {
               "label": key,
               "name": key,
               "disabled": false,
               "expanded": false,
               "items": []
            };
            var subData = data[key];
            for (var subKey in subData) {
                var subItem = {
                   "label": subKey,
                   "name": key+'+'+subKey,
                   "disabled": false,
                   "expanded": false,
                   "items": []
                };
                // Add items to the subItem
                var subSubData = subData[subKey];
                for (var subSubKey in subSubData) {
                    subItem.items.push({
                    "label": subSubKey,
                    "name": key+'+'+subKey+'+'+subSubKey,
                    "disabled": false,
                    "expanded": false,
                    "items": []
                });
                }
                topLevelItem.items.push(subItem);
            }
            items.push(topLevelItem);
        }
        component.set('v.items', items);
    },

    doSearchParts : function(component, event, helper, lv3, section, figNo) {
        console.log('[doSearchParts] Start =============================>');
        var action = component.get("c.doSearchParts");
        action.setParams({
            lv3: lv3,
            section: section,
            figNo : figNo,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doSearchParts] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[doSearchParts] strStatus =============================>' + strStatus);
                    var listParts = result['listParts'];
                    component.set("v.listParts", listParts); 
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

    // Null , Undefined , '' 체크
    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == ''){
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
});