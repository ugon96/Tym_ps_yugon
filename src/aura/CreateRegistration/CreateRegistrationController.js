/**
 * Created by yghwang on 2023-09-01.
 */

({
    init: function (component, event, helper) {
        /*helper.simulateServerRequest(
            $A.getCallback(function handleServerResponse(serverResponse) {
                component.set('v.options', serverResponse.colors);

                /!**
                 * Targets a race condition in which the options on the component does not reflect the new selected value.
                 * Check section "Generating Options On Initialization" on the documentation tab
                 *!/
                component.set('v.selectedValue', serverResponse.selectedColorId);
            })
        );*/

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Create Registration"
            });
        })
        .catch(function(error) {
            console.log(error);
        });

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:asset_action",
                iconAlt: "assets"
            });
        })
        .catch(function(error) {
            console.log(error);
        });

        helper.getDealerData(component);
    },

    retailProgramHandleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            component.set('v.retailProgramActiveSectionsMessage', "All sections are closed");
        } else {
            component.set('v.retailProgramActiveSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    warrantyDetailsHandleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            component.set('v.warrantyDetailsActiveSectionsMessage', "All sections are closed");
        } else {
            component.set('v.warrantyDetailsActiveSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },


    handleOnClickWarrantyButton : function (component, event, helper) {
        var buttonName = event.getSource().get("v.name");
        component.set('v.warrantyType', buttonName);
        var clickedButton = event.getSource().getLocalId()

        $A.util.removeClass(component.find('non-commercial-button'), 'clicked-button');
        $A.util.removeClass(component.find('commercial-button'), 'clicked-button');
        $A.util.removeClass(component.find('stock-button'), 'clicked-button');

        $A.util.addClass(component.find(clickedButton), 'clicked-button');

        if (buttonName == 'Stock'){
            component.set('v.isNotStock', false);
            console.log('false');
        } else {
            component.set('v.isNotStock', true);
            console.log('true');
        }
    },

    handleKeyUp: function (component, event) {
        var isSearching = component.get('v.isSearching');
        if(!isSearching){
            var isEnterKey = event.keyCode === 13;
            var queryTerm = component.find('search-customer').get('v.value');
            if (isEnterKey) {
                component.set('v.keyword', queryTerm);
                console.log(queryTerm);
                component.set('v.isSearching', true);
                component.set('v.isSearchResult',true);
            }
        }
    },

    closeSearchResultModal : function (component, event, helper) {
        component.set('v.isSearchResult', false);
        component.set('v.isSearching', false);
    },

    handleSelectCustomerEventFire : function (component, event, helper) {
        var selectedCustomer = event.getParam('objContact');
        component.set('v.selectedCustomer', selectedCustomer);

        var action = component.get('c.closeSearchResultModal');
        $A.enqueueAction(action);
    },

    // Create Customer
    handleCreateNewCustomerBtnClicked : function (component, event, helper){
        component.set('v.isCreateCustomerModalOpen', true);
    },

    handleCreateCustomerEventFire : function (component, event, helper) {
        var newEndCustomer = event.getParam('objContact');
        component.set('v.selectedCustomer', newEndCustomer);

        var action = component.get('c.closeCreateCustomerModal');
        $A.enqueueAction(action);
    },

    closeCreateCustomerModal : function (component, event, helper) {
        component.set('v.isCreateCustomerModalOpen', false);
    },

    handleOnClickSaveButton : function (component, event, helper) {
        if(helper.isNullCheck(component.get('v.warrantyType'))){
            alert('Please select warranty type')
            component.find('non-commercial-button').focus();
            return;
        } else if(component.get('v.warrantyType') != 'Stock'){
            if(helper.isNullCheck(component.get('v.dateOfSales'))) {
                alert('Enter the date of sales for registration');
                component.find('DateOfSales').focus();
                return;
            } else if(helper.isNullCheck(component.get('v.selectedCustomer'))){
                alert('Enter the customer information for registration');
                component.find('searchCustomer').focus();
                return;
            }
        }

        if (helper.isNullCheck(component.get('v.selectedDealer'))){
            alert('Select dealer for registration');
            component.find('dealerId').focus();
            return;
        } else if(helper.isNullCheck(component.get('v.searchedAssetRecord'))){
            alert('Enter the serial number for registration');
            component.find('lookUpInputElement').focus();
            return;
        } else if(helper.isNullCheck(component.get('v.isExplainedWarrantyTerm')) || helper.isNullCheck(component.get('v.isExplainedWarrantyCoverage'))
          || helper.isNullCheck(component.get('v.isReviewedOperationAndProcedure')) || helper.isNullCheck(component.get('v.isKeptSignedCopyOfRegistration'))) {
            console.log(component.get('v.isExplainedWarrantyTerm'));
            console.log(component.get('v.isExplainedWarrantyCoverage'));
            console.log(component.get('v.isReviewedOperationAndProcedure'));
            console.log(component.get('v.isKeptSignedCopyOfRegistration'));
            alert('Check all required checkbox');
            component.find('checkboxGroup').focus();
            return;
        }  else {
            console.log('hi');
            helper.doCreateRegistration(component);
        }
    },

    handleTractorSelectedEvt : function (component, event, helper) {
        console.log('selectedTractorRecordId :: ' + component.get('v.selectedTractorRecordId'));
    },

    handleSearchAssetSelectedEvt : function (component, event, helper) {
        helper.getConnectedAssetInformation(component);
    },

    handleOnChangeInputCheckbox : function (component, event, helper) {
        event.getSource().set('v.value', !event.getSource().get('v.value'));
    },
    handleSearchAssetLookupRemoved : function (component, event, helper) {
        component.set('v.searchedAssetRecord', null);
        component.set('v.selectedTractorRecord', null);
        component.set('v.selectedLoaderRecord', null);
        component.set('v.selectedBackhoeRecord', null);
        component.set('v.selectedMowerRecordId', null);
        component.set('v.selectedCabinRecord', null);
    },

    handleOnclickDiscardButton : function (component, event, helper) {
        history.back();
    },
    handleSearchCustomerLookupRemoved : function (component, event, helper) {
        component.set('v.selectedCustomer', null);
    },
});