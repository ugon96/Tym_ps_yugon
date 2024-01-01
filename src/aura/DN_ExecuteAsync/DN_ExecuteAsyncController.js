({
    /**
     * @description 초기화 
     */
	fnInit : function(component, event, helper) {
        
        // 1. Business Partner (IF_SFDC_SAP_REQ_BPACCOUNT)
        let IF_SFDC_SAP_REQ_BPACCOUNT = {
            CARDCD: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_BPACCOUNT', IF_SFDC_SAP_REQ_BPACCOUNT);

        // 2. BPAddress (IF_SFDC_SAP_REQ_BPADDRESS)
        let IF_SFDC_SAP_REQ_BPADDRESS = {
            CARDCD: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_BPADDRESS', IF_SFDC_SAP_REQ_BPADDRESS);

        // 3. Contact Person (IF_SFDC_SAP_REQ_CONTACT)
        let IF_SFDC_SAP_REQ_CONTACT = {
            CARDCD: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_CONTACT', IF_SFDC_SAP_REQ_CONTACT);

        // 4. Item (IF_SFDC_SAP_REQ_ITEM)
        let IF_SFDC_SAP_REQ_ITEM = {
            ItemCode: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_ITEM', IF_SFDC_SAP_REQ_ITEM);

        // 5. Price List Master (IF_SFDC_SAP_REQ_PRICELISTMST)
        let IF_SFDC_SAP_REQ_PRICELISTMST = {
            PriceList: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_PRICELISTMST', IF_SFDC_SAP_REQ_PRICELISTMST);

        // 6. Price List (IF_SFDC_SAP_REQ_PRICELISTETR)
        let IF_SFDC_SAP_REQ_PRICELISTETR = {
            PriceList: 'new',
            Count : '10000',
            ItemGroupCode : '',
            ItemCode : '',
            inputCurrency : 'USD',
        };
        component.set('v.IF_SFDC_SAP_REQ_PRICELISTETR', IF_SFDC_SAP_REQ_PRICELISTETR);

        // 7. Order (IF_SFDC_SAP_REQ_ORDER_PROD)
        let IF_SFDC_SAP_REQ_ORDER_PROD = {
            DocNum: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_ORDER_PROD', IF_SFDC_SAP_REQ_ORDER_PROD);

        // 8. Parts Order (IF_SFDC_SAP_REQ_ORDER_PARTS)
        let IF_SFDC_SAP_REQ_ORDER_PARTS = {
            DocEntry: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_ORDER_PARTS', IF_SFDC_SAP_REQ_ORDER_PARTS);

        // 9. 여신/채권 (IF_SFDC_SAP_REQ_AR)
        let IF_SFDC_SAP_REQ_AR = {
            BPCode: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_AR', IF_SFDC_SAP_REQ_AR);

        // 10. 기준정보 (IF_SFDC_SAP_REQ_MASTERDATA)
        let IF_SFDC_SAP_REQ_MASTERDATA = {
            Type: 'Country',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_MASTERDATA', IF_SFDC_SAP_REQ_MASTERDATA);

        // 11. 부품 재고 (IF_SFDC_SAP_REQ_PARTSIVT)
        let IF_SFDC_SAP_REQ_PARTSIVT = {
            ItemCode: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_PARTSIVT', IF_SFDC_SAP_REQ_PARTSIVT);

        // 12. Finished Goods (IF_SFDC_SAP_REQ_FINISHEDGOODS)
        let IF_SFDC_SAP_REQ_FINISHEDGOODS = {
            ItemCode: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_FINISHEDGOODS', IF_SFDC_SAP_REQ_FINISHEDGOODS);

        // 13. A/R Credit Memo (IF_SFDC_SAP_REQ_CREDITMEMO)
        let IF_SFDC_SAP_REQ_CREDITMEMO = {
            CARDCD: 'new',
            Count : '10000',
        };
        component.set('v.IF_SFDC_SAP_REQ_CREDITMEMO', IF_SFDC_SAP_REQ_CREDITMEMO);

		// helper.doInit(component, event, helper);
    },

    /**
     * @description 비동기 코드 실행
     */
	fnExecute : function(component, event, helper) {
        let strClassName = event.getSource().get('v.value');
        let strConstructorNo = event.getSource().get('v.name');

        // 파라미터 Error 체크 
        let strValidTarget = 'validTarget_' + strClassName;
        if (strConstructorNo != null) strValidTarget = strValidTarget + '_' + strConstructorNo;
        console.log('strValidTarget: ', strValidTarget);

        let validTarget = component.find(strValidTarget);
        console.log('validTarget: ', validTarget);

        let isError = false;
        let validationTarget = [];
        if ( validTarget.length == undefined){
            validationTarget.push(validTarget);
        } else {
            validationTarget = validTarget;
        }

        for(let i in validationTarget) {
            if(!validationTarget[i].checkValidity()) {
                if ( isError == false) {
                    isError = true;
                }
                validationTarget[i].set("v.validity", false);
                validationTarget[i].showHelpMessageIfInvalid();
            }
        }
        console.log('isError: ', isError);
        
        // Confirm 체크 (두번 클릭)
        let strExecuteConfirm = strClassName;
        if (strConstructorNo != null) strExecuteConfirm = strExecuteConfirm + '_' + strConstructorNo;
        let strPreviousExecuteConfirm = component.get('v.strExecuteConfirm');

        let isNotConfirm = false;
        if ( strPreviousExecuteConfirm != strExecuteConfirm){
            isNotConfirm = true;
        }

        // Error 및 Confirm 체크 후 Execute
        if ( isError){
            helper.showToast("error", '[' + strClassName + '] 파라미터 값이 적절하지 않습니다.');
            component.set('v.strExecuteConfirm', '');
            return false;
        } else if ( isNotConfirm) {
            helper.showToast("info", '파라미터 검사가 완료되었습니다. 실행을 위해 한번 더 클릭하세요.');
            component.set('v.strExecuteConfirm', strExecuteConfirm);
            return false;
        } else {
            helper.doExecute(component, event, helper, strClassName, strConstructorNo);
        }
    }




})