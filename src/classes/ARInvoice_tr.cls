/*************************************************************
 * @author : th.kim
 * @date : 2023-12-04
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-04      th.kim         Initial Version
**************************************************************/
public with sharing class ARInvoice_tr extends TriggerHandler {

    public ARInvoice_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, ARInvoice__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<ARInvoice__c> listNew { get; set; }
    private List<ARInvoice__c> listOld { get; set; }
    private Map<Id, ARInvoice__c> mapOld { get; set; }

    public override void beforeInsert() {

    }
//    public override void beforeUpdate() {
//
//    }
//    public override void beforeDelete() {
//
//    }
    public override void afterInsert() {
        //updateAssetInvoiceDate(); 
    }
//    public override void afterUpdate() {
//
//    }
//    public override void afterDelete() {
//
//    }

    /**
     * @author th.kim
     * @description ARInvoice 생성 시 생성 날짜를 Asset의 Invoice Date에 업데이트
     */
    private void updateAssetInvoiceDate() {
        try {
            Set<Id> setOrdersId = new Set<Id>();
            for(ARInvoice__c objNew : listNew) {
                setOrdersId.add(objNew.OrdersId__c);
            }

            List<Asset> listAsset = [SELECT Id, InvoiceDate__c FROM Asset WHERE OrdersId__c IN :setOrdersId];
            List<Asset> listUpdate = new List<Asset>();
            for(Asset asset : listAsset) {
                asset.InvoiceDate__c = Date.today();
                listUpdate.add(asset);
            }
            update listUpdate;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

}