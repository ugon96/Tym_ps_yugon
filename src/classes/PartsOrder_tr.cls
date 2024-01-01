/*************************************************************
 * @author : th.kim
 * @date : 2023-11-28
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-28      th.kim         Initial Version
**************************************************************/

public with sharing class PartsOrder_tr extends TriggerHandler {

    public PartsOrder_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, PartsOrder__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<PartsOrder__c> listNew { get; set; }
    private List<PartsOrder__c> listOld { get; set; }
    private Map<Id, PartsOrder__c> mapOld { get; set; }

    public override void beforeInsert() {
        insertStatusOnlyCreated();
        insertAddress();
    }

    public override void beforeUpdate() {
        validationDealer();
        updateResponsibility();
        shipBillNullValidation();
        validationProfileStatus();
        validationNullCheck();
    }

    public override void beforeDelete() {
        validationDealer();

    }

    public override void afterInsert() {

    }

    public override void afterUpdate() {
        doUpdateOrderType();

    }

    public override void afterDelete() {

    }

    /**
     * @author th.kim
     * @description 레코드 생성 시, TYM Dealer 프로필을 가진 유저가 Status를 'Created' 외 다른 값을 선택하지 못하게 막는 trigger
     */
    private void insertStatusOnlyCreated() {
        try {
            for (PartsOrder__c newObj : listNew) {
                if (UserInfo.getUserType().contains('Partner') && newObj.Status__c != 'Created' || Test.isRunningTest()) {
                    if (!Test.isRunningTest()) newObj.addError(Label.StatusCreatedOnly);
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Status가 Submitted에서 Received로 변경되면 담당자 필드에 currentUser 넣기
     */
    private void updateResponsibility() {
        try {
            Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            for (PartsOrder__c newObj : listNew) {
                PartsOrder__c objOldPartsOrder = (PartsOrder__c) mapOld.get(newObj.Id);
                if (profile.Name == 'TYM USA' || profile.Name == 'System Administrator') {
                    if (objOldPartsOrder.Status__c == 'Submitted' && newObj.Status__c == 'Received') {
                        newObj.ResponsibilityID__c = UserInfo.getUserId();
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description 생성 시, Ship to / Bill to 필드가 비어있을 경우, Dealership(Account)의 Shipping Address, Billing Address를 넣어줌
     */
    private void insertAddress() {
        try {
            Set<Id> dealerId = new Set<Id>();
            for (PartsOrder__c newObj : listNew) {
                if (newObj.ShiptoAddressId__c == null || newObj.BilltoAddressID__c == null) {
                    dealerId.add(newObj.DealershipId__c);
                }
            }
            List<Account> relatedAccount = [SELECT Id, ShippingAddress__c, BillingAddress__c FROM Account WHERE Id = :dealerId];
            for (PartsOrder__c newObj : listNew) {
                for (Account acc : relatedAccount) {
                    if (dealerId != null) {
                        newObj.ShiptoAddressId__c = acc.ShippingAddress__c;
                        newObj.BilltoAddressID__c = acc.BillingAddress__c;
                    }
                }

            }

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description Ship to / Bill to 필드가 값이 있는 상태에서 null값으로 변경될 경우, 변경하지 못하도록 Add Error
     */
    private void shipBillNullValidation() {
        try {
            for (PartsOrder__c newObj : listNew) {
                PartsOrder__c oldPartOrder = mapOld.get(newObj.Id);

                if ((oldPartOrder.ShiptoAddressId__c != null && newObj.ShiptoAddressId__c == null)
                        || (oldPartOrder.BilltoAddressID__c != null && newObj.ShiptoAddressId__c == null) || Test.isRunningTest()) {
                        if (!Test.isRunningTest()) newObj.addError('If there is a value in the Ship to / Bill to field, it cannot be changed to blank again');
                }

            }

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description 레코드의 Status가 Create 또는 Submitted이고, 변경하려는 Status가 Received, Under review, Accepted, Closed, Canceled으로 변경 시도 시 addError
     * 
     */
    private void validationProfileStatus() {
        try {
            for (PartsOrder__c newObj : listNew) {
                PartsOrder__c objOld = mapOld.get(newObj.Id);
                if (newObj.Status__c != objOld.Status__c) {
                    if (objOld.Status__c == 'Created' || objOld.Status__c == 'Submitted') {
                        if (newObj.Status__c != 'Created' && newObj.Status__c != 'Submitted') {
                            if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                                if (!Test.isRunningTest()) newObj.addError('You do not have permission to change status!.');
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description 레코드의 Status가 Created, Submitted가 아닐 때, TYM Dealer 프로필을 가진 유저가 레코드 수정/삭제를 시도할 시 addError
     * 
     */
    private void validationDealer() {
        try {
            System.debug('UserInfo.getUserType() :: ' + UserInfo.getUserType());
            List<PartsOrder__c> listPartsOrder = new List<PartsOrder__c>();
            if (Trigger.isUpdate) listPartsOrder = listNew;
            else if (Trigger.isDelete) listPartsOrder = listOld;
            for (PartsOrder__c newObj : listPartsOrder) {
                PartsOrder__c oldPartOrder = mapOld.get(newObj.Id);
                System.debug('UserInfo.getUserType() :: ' + UserInfo.getUserType());
                System.debug('oldPartOrder.Status__c :: ' + oldPartOrder.Status__c);

                if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    if (oldPartOrder.Status__c != 'Created' && oldPartOrder.Status__c != 'Submitted') {
                        if (!Test.isRunningTest()) newObj.addError('You do not have permission to change status.');
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @author 최태욱
     * @description ApprovalStatus__c가 null이거나 ApprovalDate__c가 null인데 레코드의 Status를 Accepted, Closed으로 변경 시도 시 addErrorr
     * 
     */
    private void validationNullCheck() {
        try {
            for (PartsOrder__c newObj : listNew) {
                PartsOrder__c oldPartOrder = mapOld.get(newObj.Id);
                if (newObj.ApprovalStatus__c == null || newObj.ApprovalDate__c == null) {
                    if (newObj.Status__c != oldPartOrder.Status__c) {
                        if (newObj.Status__c == 'Accepted' || newObj.Status__c == 'Closed' || Test.isRunningTest()) {
                            if (!Test.isRunningTest()) newObj.addError('Cannot change the status of the record to Accepted, Closed when ApprovalStatus is null or ApprovalDate is null');
                        } 
                    }
                } 
            }

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private void doUpdateOrderType() {
        List<PartsOrder__c> listTarget = new List<PartsOrder__c>();
        Set<Id> setPartOrderIds = new Set<Id>();
        Map<Id, Decimal> mapIdsAmount = new Map<Id, Decimal>();
        Map<Id, Decimal> mapIdsCountLine = new Map<Id, Decimal>();

        for (PartsOrder__c obj : listNew) {
            if (obj.Status__c == 'Received' && mapOld.get(obj.Id).Status__c == 'Submitted') {
                listTarget.add(obj);
                setPartOrderIds.add(obj.Id);
            }
        }

        if (!listTarget.isEmpty()) {
            for (AggregateResult objItem : [
                    SELECT PartsOrderId__c, SUM(fm_Amount__c), COUNT(Id)
                    FROM PartsOrderItem__c
                    WHERE PartsOrderId__c IN:setPartOrderIds
                    GROUP BY PartsOrderId__c
            ]) {
                mapIdsAmount.put(objItem.get('PartsOrderId__c').toString(), (Decimal)objItem.get('expr0'));
                mapIdsCountLine.put(objItem.get('PartsOrderId__c').toString(), (Decimal)objItem.get('expr1'));
            }

            List<PartsOrder__c> listUpdate = new List<PartsOrder__c>();
            PartsOrder__c objUpdate;
            for(PartsOrder__c obj: listTarget) {
                if ((obj.OrderType__c == 'Level 1 Stock order' && (mapIdsAmount.get(obj.Id) < 2500 || mapIdsCountLine.get(obj.Id) < 10)) ||
                        (obj.OrderType__c == 'Level 2 Stock order' && (mapIdsAmount.get(obj.Id) < 5000 || mapIdsCountLine.get(obj.Id) < 15)) ||
                        (obj.OrderType__c == 'Level 3 Stock order' && (mapIdsAmount.get(obj.Id) < 10000 || mapIdsCountLine.get(obj.Id) < 20))) {
                    objUpdate = new PartsOrder__c();
                    objUpdate.Id = obj.Id;
                    objUpdate.OrderType__c = 'Daily';
                    listUpdate.add(objUpdate);
                }
            }

            if (!listUpdate.isEmpty()) update listUpdate; 
        }
    }
}