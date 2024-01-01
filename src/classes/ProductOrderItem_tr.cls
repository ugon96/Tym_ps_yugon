/*************************************************************
 * @author : th.kim
 * @date : 2023-12-06
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-06      th.kim         Initial Version
**************************************************************/
public with sharing class ProductOrderItem_tr extends TriggerHandler {

    public ProductOrderItem_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, ProductOrderItem__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<ProductOrderItem__c> listNew { get; set; }
    private List<ProductOrderItem__c> listOld { get; set; }
    private Map<Id, ProductOrderItem__c> mapOld { get; set; }

    public override void beforeInsert() {
//        insertStatusOnlyCreated();
    }
//    public override void beforeUpdate() {
//
//    }
//    public override void beforeDelete() {
//
//    }
    public override void afterInsert() {

    }
    public override void afterUpdate() {
        orderItemClosed();
    }
//    public override void afterDelete() {
//
//    }

    /**
     * @author th.kim
     * @description 레코드 생성 시, TYM Dealer 프로필을 가진 유저가 Status를 'Created' 외 다른 값을 선택하지 못하게 막는 trigger
     */
//    private void insertStatusOnlyCreated() {
//        try {
//            for (ProductOrderItem__c newObj : listNew) {
//                if (UserInfo.getUserType().contains('Partner') && newObj.Status__c != 'Created' || Test.isRunningTest()) {
//                    if (!Test.isRunningTest()) newObj.addError(Label.StatusCreatedOnly);
//                }

//            }
//        } catch (Exception e) {
//            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
//            throw new AuraHandledException(e.getMessage());
//        }
//    }
    /**
     * @author sy.Kang
     * @description Product Order Item의 Status가 Closed된 경우, after update
     */
    private void orderItemClosed() {
        try {
            List<ProductOrderItem__c> closedItems = new List<ProductOrderItem__c>();

            for (ProductOrderItem__c updatedObj : listNew) {
                if (updatedObj.Status__c == 'Closed' && updatedObj.Status__c != mapOld.get(updatedObj.Id).Status__c) {
                    closedItems.add(updatedObj);
                }
            }

            if (!closedItems.isEmpty()) {
                System.debug('Closed items detected: ' + closedItems);
            }
        } catch (Exception e) {
            System.debug('Error in orderItemClosed: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}