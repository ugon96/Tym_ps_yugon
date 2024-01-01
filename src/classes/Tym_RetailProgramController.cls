/********************************************************************
* File Name   : Tym_RetailProgramController.cls
* Author      : 최태욱
* Date        : 2023.11.09
* Class       : ClaimViewDetailController.cls
* Description : RetailProgramMasterItem__c, PayoutStructure__c 추가/수정/삭제
* Modification Log
* ====================================================================
* Ver      Date            Author              Modification
* ====================================================================
1.0      2023.11.09        최태욱               Create
<*********************************************************************/

public with sharing class Tym_RetailProgramController {

    public class itemWrapper {
        public String productId;
        public String name;

        public RetailProgramMasterItem__c rpmitemList;
    }

    /**
     * @author 최태욱
     * @description : Product2 오브젝트의 ItemGroupCode__c의 label과 value를 가져오기
     * @return returnMap
     */
    @AuraEnabled
    public static Map<String, List<String>> getItemGroupCodes() {
        try {

            Map<String, List<String>> returnMap = new Map<String, List<String>>();
            List<String> labelList = new List<String>();
            List<String> valueList = new List<String>();

            Schema.DescribeFieldResult fieldResult = Product2.ItemGroupCode__c.getDescribe();
            for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
                labelList.add(picklistEntry.getLabel());
                valueList.add(picklistEntry.getValue());
            }
            returnMap.put('label', labelList);
            returnMap.put('value', valueList);
            return returnMap;
            
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @author 최태욱
     * @description : Product2 별 RetailProgramMasterItem__c 데이터 가져오기 
     * @param itemValue
     * @param recordId
     * @return mapReturn
     */
    
    @AuraEnabled
    public static Map<String, Object> selectRetailMasterItemInfo(List<String> itemValue, String recordId){
        Map<String, Object> mapReturn = new Map<String, Object>();

        try {
            List<itemWrapper> listitemWrapper = new List <itemWrapper>();
            List<itemWrapper> listAllWrapper = new List <itemWrapper>();
            List<Product2> rpmiList = [SELECT Id, Name, ItemGroupCode__c, ProductName__c,
                                        (SELECT Id, Amount__c, RetailProgramID__c, Payout__c, Discount__c, Unit__c FROM Retail_Program_Item__r WHERE RetailProgramID__c =: recordId) 
                                        FROM Product2 WHERE ItemGroupCode__c IN: itemValue];
            RetailProgramMaster__c objRetailProgramMaster = [SELECT ProgramType__c, PricingStructure__c FROM RetailProgramMaster__c WHERE Id =: recordId];

            for (Product2 r : rpmiList) {

                itemWrapper proWrapper = new itemWrapper();

                if (r.Retail_Program_Item__r.size() > 0) {
                    proWrapper.productId = r.Id;
                    proWrapper.name = r.Name;
                    proWrapper.rpmitemList = r.Retail_Program_Item__r;
                    listitemWrapper.add(proWrapper);
                } else {
                    List<RetailProgramMasterItem__c> rpmit = new List<RetailProgramMasterItem__c>();
                    RetailProgramMasterItem__c p = new RetailProgramMasterItem__c();
                    p.ProductID__c = r.Id;
                    p.Payout__c = 1;
                    p.Discount__c = 0;
                    p.Amount__c = 0;
                    p.RetailProgramID__c = recordId;
                    if(objRetailProgramMaster.ProgramType__c == 'Volume Incentive' && objRetailProgramMaster.PricingStructure__c == 'Dynamic') {
                        p.Unit__c = 1;
                    } else {
                        p.Unit__c = 0;
                    }
                    
                    proWrapper.productId = r.Id;
                    proWrapper.name = r.Name;
                    proWrapper.rpmitemList = p;
                }
                listAllWrapper.add(proWrapper);
            }
            mapReturn.put('products', JSON.serialize(listitemWrapper));
            mapReturn.put('allOptions', JSON.serialize(listAllWrapper));
            
            return mapReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }    
    }

    /**
     * @author 최태욱
     * @description : 선택된 RetailProgramMasterItem__c의 ID를 delete하는 메서드
     * @param itemValue2
     * @return rpmIMasterItemList
     */
    @AuraEnabled
    public static List<RetailProgramMasterItem__c> deleteRow(List<String> itemValue2){
        try {

            List<RetailProgramMasterItem__c> rpmIMasterItemList = [SELECT Id FROM RetailProgramMasterItem__c WHERE Id IN :itemValue2];
            
            if(rpmIMasterItemList.size() > 0) {
                try {
                    delete rpmIMasterItemList;

                } catch (Exception e) {
                    throw new AuraHandledException('Unable to delete the record due to: ' + e.getMessage());
                }
                    
            }
            return rpmIMasterItemList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description : 선택된 PayoutStructure__c ID를 delete하는 메서드
     * @param payRetailId
     * @return payList
     */
    @AuraEnabled
    public static List<PayoutStructure__c> deletePayRow(List<String> payRetailId){
        try {
            List<PayoutStructure__c> payList = [SELECT Id FROM PayoutStructure__c WHERE Id IN :payRetailId];
            
            if(payList.size() > 0) {
                try{
                    delete payList;

                } catch (Exception e) {
                    throw new AuraHandledException('Unable to delete the record due to: ' + e.getMessage());
                }
                    
            }
            return payList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @author 최태욱
     * @description : RetailProgramMasterItem__c 생성, 업데이트 
     * @param productWrapperJSON
     * @return mapReturn
     */
    @AuraEnabled
    public static Map<String, Object> insertRetailProgramMasterItem(String productWrapperJSON){
        
        Map<String, Object> mapReturn = new Map<String, Object>();
        List<RetailProgramMasterItem__c> listCreate = new List<RetailProgramMasterItem__c>();
        List<RetailProgramMasterItem__c> listUpdate = new List<RetailProgramMasterItem__c>();
        List<String> listIdProduct = new List<String>();
        List<RetailProgramMasterItem__c> listProductAfterDML = new List<RetailProgramMasterItem__c>();
        List<itemWrapper> listProductWrapperReturn = new List<itemWrapper>();
        
        try {

            List<itemWrapper> listProductWrapper = (List<itemWrapper>) JSON.deserialize(productWrapperJSON, List<itemWrapper>.class);
            for (itemWrapper item : listProductWrapper) {
                
                RetailProgramMasterItem__c itemRetailProItem = item.rpmitemList;

                if (String.isEmpty(itemRetailProItem.Id)) listCreate.add(itemRetailProItem);
                else listUpdate.add(itemRetailProItem);
            }

            List<String> productIdSet = new List<String>();
            
            if (!listCreate.isEmpty()) {
                insert listCreate;
                for(RetailProgramMasterItem__c r : listCreate) {
                    productIdSet.add(r.Id);
                }
            }
            
            if (!listUpdate.isEmpty()) {
                Database.update(listUpdate, false);
                for(RetailProgramMasterItem__c r : listUpdate) {
                    productIdSet.add(r.Id);
                }
            }
            
            listProductAfterDML = [SELECT Id, Name, ProductID__c, ProductID__r.Name, Payout__c, Unit__c, RetailProgramID__c, Amount__c, Discount__c FROM RetailProgramMasterItem__c 
                                    WHERE Id IN: productIdSet];
            
            for(RetailProgramMasterItem__c ptProItem : listProductAfterDML) {

                if(productIdSet.contains(ptProItem.Id)) {
                    itemWrapper itemWrapper = new itemWrapper();
                    itemWrapper.productId = ptProItem.ProductID__c;
                    itemWrapper.name = ptProItem.ProductID__r.Name;
                    itemWrapper.rpmitemList = ptProItem;
                    listProductWrapperReturn.add(itemWrapper);
                }
            }

            if(!productIdSet.isEmpty()) {
                mapReturn.put('products', JSON.serialize(listProductWrapperReturn));

            } else {
                mapReturn.put('null', null);

            }
            
        } catch (Exception e) {
            System.debug('err  :: ' +e.getMessage() + ' }} ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return mapReturn;
    }

    /**
     * @author 최태욱
     * @description : PayoutStructure__c 데이터 가져오기 
     * @param retailId
     * @return payList
     */
    @AuraEnabled
    public static List<PayoutStructure__c> selectpayoutStructure(String retailId) {
        try {
            List<PayoutStructure__c> payList = [SELECT Id, Name, Amount__c, Registered__c, RetailProgramID__c FROM PayoutStructure__c WHERE RetailProgramID__c =: retailId ];

            if(payList.isEmpty()) {
                PayoutStructure__c p = new PayoutStructure__c();
                p.Amount__c = 0;
                p.Registered__c = 0;
                p.RetailProgramID__c = retailId;
                payList.add(p);
            } 
            return payList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    /**
     * @author 최태욱
     * @description : PayoutStructure__c 생성, 업데이트
     * @param rId
     * @param payoutJSON
     * @return payList
     */
    @AuraEnabled
    public static List<PayoutStructure__c> insertPayoutItems(String payoutJSON) {
        List<PayoutStructure__c> payoutList= new List<PayoutStructure__c>();
        List<PayoutStructure__c> listCreate = new List<PayoutStructure__c>();
        List<PayoutStructure__c> listUpdate = new List<PayoutStructure__c>();

        try {
            List<PayoutStructure__c> listPayout = (List<PayoutStructure__c>) JSON.deserialize(payoutJSON, List<PayoutStructure__c>.class);

            for(PayoutStructure__c payout : listPayout) {
                PayoutStructure__c pi = payout;

                if (String.isEmpty(pi.Id)) listCreate.add(pi);
                else listUpdate.add(pi);
            }

            List<String> payoutIdSet = new List<String>();
            
            if (!listCreate.isEmpty()) {
                Database.insert(listCreate, false);
                for(PayoutStructure__c r : listCreate) {
                    payoutIdSet.add(r.RetailProgramID__c);
                }
            }
            
            if (!listUpdate.isEmpty()) {
                Database.update(listUpdate, false);
                for(PayoutStructure__c r : listUpdate) {
                    payoutIdSet.add(r.RetailProgramID__c);
                }
            }

            List<PayoutStructure__c> payList = [SELECT Id, Name, Amount__c, Registered__c, RetailProgramID__c 
                                                FROM PayoutStructure__c 
                                                WHERE RetailProgramID__c IN: payoutIdSet];
            return payList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}