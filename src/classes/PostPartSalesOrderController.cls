/**
 * Created by taekyun.yoon on 2023-11-22.
 */

public with sharing class PostPartSalesOrderController {
    @AuraEnabled
    public static String sendSAP(String recordId){
        System.debug('Apex Class[sendSAP] start');

        String strStatus = '';
        String strMessage = '';

        try {

            List<PartsOrder__c> listPartsOrder = [
                    SELECT  Id,
                            DealershipId__c,
                            ShiptoAddressId__r.ExternalId__c,
                            BilltoAddressID__r.ExternalId__c,
                            Remarks__c,
                            OrderType__c,
                            ShippingMode__c,
                            Discount__c,
                            PartialShipment__c,
                            IsSendtoSAP__c,
                            Comment__c,
                            PONumber__c,
                            DocumentDate__c,
                            ResponsibilityID__r.EmployeeNumber,
                            // 23.12.15 - SAP 컬럼 추가
                            (SELECT Id, ProductId__r.ExternalId__c, Quantity__c, Price__c, PartsOrderId__c,
                                    Replacement__r.ExternalId__c FROM PartsOrderItem__r)
                    FROM PartsOrder__c
                    WHERE Id =: recordId
            ];

            System.debug('Before update: '+listPartsOrder);
            System.debug('partsOrderItem : '+listPartsOrder[0].PartsOrderItem__r);
            List<PartsOrderItem__c> listPartsOrderItem = new List<PartsOrderItem__c>();

            for (PartsOrderItem__c objPartsOrderItem : listPartsOrder[0].PartsOrderItem__r) {
                objPartsOrderItem.Quantity__c = objPartsOrderItem.Quantity__c == null ? 0 : objPartsOrderItem.Quantity__c;
                listPartsOrderItem.add(objPartsOrderItem);
            }

            System.debug('listPartsOrderItem : '+listPartsOrderItem);
            if (listPartsOrder.size() > 0) {
                if (listPartsOrder[0].IsSendtoSAP__c == false) {
                    IF_SFDC_SAP_REG_ORDER_PARTS ifSfdcSapRegOrderParts = new IF_SFDC_SAP_REG_ORDER_PARTS(listPartsOrder, listPartsOrderItem);
                    if (ifSfdcSapRegOrderParts.execute() == 'SUCCESS'){
                        System.debug('IF_SFDC_SAP_REG_ORDER_PARTS : SUCCESS');
                        listPartsOrder[0].IsSendtoSAP__c = true;
                        update listPartsOrder;
                        strStatus = 'SUCCESS';
                    } else {
                        System.debug('IF_SFDC_SAP_REG_ORDER_PARTS : ERROR');
                        strStatus = 'ERROR';
                    } 
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

//        System.debug('After update: '+listPartsOrder);
        System.debug('Status: '+strStatus);
        System.debug('Message: '+strMessage);
        return strStatus;
    }
}