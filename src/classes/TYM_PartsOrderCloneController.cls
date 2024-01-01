/********************************************************************
* File Name   : PartsOrderClone.cmp
* Author      : 최태욱
* Date        : 2023.12.19
* Class       : TYM_PartsOrderCloneController.cls
* Description : Parts Order의 정보를 조회하여 aura에서 사용, Clone메소드
* Modification Log
* ====================================================================
* Ver      Date            Author              Modification
* ====================================================================
1.0      2023.12.19        최태욱               Create
<*********************************************************************/

public with sharing class TYM_PartsOrderCloneController {

    @AuraEnabled
    public static PartsOrder__c partsOrderClone(String recordId, Map<String, String> partsOrderMap) {
        try {
            PartsOrder__c objPart = [SELECT Id, Name, PONumber__c, Status__c, IsSendtoSAP__c, ResponsibilityID__c, TrackingNo__c, DealershipId__c,
                                            SalespersonId__c, OrderType__c, PartialShipment__c, Discount__c, ShippingMode__c, ShiptoAddressId__c, BilltoAddressID__c, Comment__c
                                     FROM PartsOrder__c WHERE Id =: recordId];

            System.debug('objPart:::::' +  objPart);

            PartsOrder__c cloneRecord = objPart.clone(false, true);

            cloneRecord.Status__c = 'Created';
            cloneRecord.IsSendtoSAP__c = false;
            cloneRecord.ResponsibilityID__c = null;
            cloneRecord.TrackingNo__c = null;
            cloneRecord.PONumber__c = partsOrderMap.get('poNum');
            System.debug('cloneRecord::::::::' +  cloneRecord);
            
            insert cloneRecord;
            
            System.debug('insert cloneRecord::::::::' +  cloneRecord);

            List<PartsOrderItem__c> partOrderList = [SELECT Id, Name, PartsOrderId__c, Quantity__c, Price__c, ProductId__c, Remarks__c, Replacement__c
                                                     FROM PartsOrderItem__c
                                                     WHERE PartsOrderId__c =: recordId ];

            List<PartsOrderItem__c> clonePartOrderList = new List<PartsOrderItem__c>();

            for (PartsOrderItem__c objPartOrder : partOrderList) {
                PartsOrderItem__c clonedItem = new PartsOrderItem__c(
                    ProductId__c = objPartOrder.ProductId__c,
                    Price__c = objPartOrder.Price__c,
                    Quantity__c = objPartOrder.Quantity__c,
                    Replacement__c = null,
                    PartsOrderId__c = cloneRecord.Id
                );

                clonePartOrderList.add(clonedItem);
            }

            insert clonePartOrderList;
            System.debug('clonePartOrderList::::' +  clonePartOrderList );



            return cloneRecord;
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PartsOrder__c selectPartsOrder(String recordId) {
        try {
            PartsOrder__c objPart = [SELECT Id, Name, PONumber__c, Status__c, IsSendtoSAP__c, ResponsibilityID__c, TrackingNo__c, DealershipId__c,
                                            SalespersonId__c, OrderType__c, PartialShipment__c, Discount__c, ShippingMode__c, ShiptoAddressId__c, BilltoAddressID__c, Comment__c
                                     FROM PartsOrder__c WHERE Id =: recordId];

            System.debug('objPart:::::' +  objPart);

            return objPart;
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }



    

}