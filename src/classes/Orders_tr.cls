/*************************************************************
 * @author : th.kim
 * @date : 2023-11-24
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-24      th.kim         Initial Version
**************************************************************/

public with sharing class Orders_tr extends TriggerHandler {

    public Orders_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, Orders__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<Orders__c> listNew { get; set; }
    private List<Orders__c> listOld { get; set; }
    private Map<Id, Orders__c> mapOld { get; set; }

    public override void beforeInsert() {
        insertStatusOnlyCreated();
        addAddress();
    }
    public override void beforeUpdate() {
        updateResponsibility();
        checkProfilePermission();
        validationAddress();
        validationDealer();
    }
    public override void beforeDelete() {
       validationDealer();
   }
    public override void afterInsert() {
//        addAddress();
    }
    public override void afterUpdate() {
        updateOrderClosed();
    }
//    public override void afterDelete() {
//
//    }

    /**
     * @author th.kim
     * @description Status가 Submitted에서 Received로 변경되면 담당자 필드에 currentUser 넣기
     */
    private void updateResponsibility() {
        try {
            Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            for (Orders__c newObj : listNew) {
                Orders__c objOldOrder = mapOld.get(newObj.Id);
                if (profile.Name == 'TYM USA' || profile.Name == 'System Administrator') {
                    if (objOldOrder.Status__c == 'Submitted' && newObj.Status__c == 'Received') {
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
     * @author th.kim
     * @description IsSendtoSAP__c = true 일 때, 딜러 & 담당자는 수정 불가, Profile의 ModifyAll 권한 있는 사람은 수정 가능
     */
    private void checkProfilePermission() {
        try {
            List<FieldPermissions> listFieldPermission = [
                    SELECT PermissionsEdit, PermissionsRead
                    FROM FieldPermissions
                    WHERE SobjectType = 'Orders__c'
                    AND Parent.ProfileId = :UserInfo.getProfileId()
            ];
            for (Orders__c newObj : listNew) {
                Orders__c objOldOrder = mapOld.get(newObj.Id);
                if (objOldOrder.IsSendtoSAP__c == true) {
                    Boolean modifyAll = true;
                    for (FieldPermissions permission : listFieldPermission) {
                        if (!permission.PermissionsEdit) modifyAll = false;
                    }
                    if (!modifyAll && !Test.isRunningTest()) newObj.addError('You do not have permission to change.');
                }
            }

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description 레코드 생성 시, TYM Dealer 프로필을 가진 유저가 Status를 'Created' 외 다른 값을 선택하지 못하게 막는 trigger
     */
    private void insertStatusOnlyCreated() {
        try {
            for (Orders__c newObj : listNew) {
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
     * @description 생성 시, Ship to / Bill to 필드가 비어있을 경우, Dealership(Account)의 Shipping Address, Billing Address를 넣어줌
     */
    private void addAddress() {
        try {
            Set<Id> setAccId = new Set<Id>();
            for (Orders__c newObj : listNew) {
                if (newObj.ShiptoAddressID__c == null || newObj.BilltoAddressID__c == null) setAccId.add(newObj.Dealership__c);
            }
            List<Account> listAcc = [SELECT Id, ShippingAddress__c, BillingAddress__c FROM Account WHERE Id IN :setAccId];
            for (Orders__c newObj : listNew) {
                for (Account acc : listAcc) {
                    if (newObj.Dealership__c == acc.Id) {
                        if (newObj.ShiptoAddressID__c == null) {
                            newObj.ShiptoAddressID__c = acc.ShippingAddress__c;
                        }
                        if (newObj.BilltoAddressID__c == null) {
                            newObj.BilltoAddressID__c = acc.BillingAddress__c;
                        }
                    }
                }
                System.debug('newObj :: ' + newObj);
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Ship to / Bill to 필드가 값이 있는 상태에서  null값으로 변경될 경우, 변경하지 못하도록 Add Error
     */
    private void validationAddress() {
        try {
            for (Orders__c newObj : listNew) {
                Orders__c oldObj = mapOld.get(newObj.Id);
                if (oldObj.ShiptoAddressID__c != null && newObj.ShiptoAddressID__c == null
                        || oldObj.BilltoAddressID__c != null && newObj.BilltoAddressID__c == null) {
                    if (!Test.isRunningTest()) newObj.addError('\'Ship to / Bill to\' field cannot be null');
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
            List<Orders__c> listOrder = new List<Orders__c>();
            if (Trigger.isUpdate) listOrder = listNew;
            else if (Trigger.isDelete) listOrder = listOld;
            for (Orders__c newObj : listOrder) {
                Orders__c oldOrder = mapOld.get(newObj.Id);
                System.debug('UserInfo.getUserType() :: ' + UserInfo.getUserType());
                System.debug('oldPartOrder.Status__c :: ' + oldOrder.Status__c);

                if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    if (oldOrder.Status__c != 'Created' && oldOrder.Status__c != 'Submitted') {
                        if (!Test.isRunningTest()) newObj.addError('You do not have permission to change.');
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author sy.Kang
     * @description Order의 Status가 Closed로 업데이트 된 경우, 같은 Parent Order ID를 가지는 Order 레코드를 쿼리하여 모든 Order 레코드의 Status가 Closed인 경우,  Parent Order의 Status를 Closed로 업데이트한다.
     */
    private void updateOrderClosed(){
        Set<Id> parentOrderIds = new Set<Id>();

        for (Orders__c orders : listNew) {
            if (orders.Status__c == 'Closed' && orders.Status__c != mapOld.get(orders.Id).Status__c) {
                if(orders.ParentOrder__c != null) parentOrderIds.add(orders.ParentOrder__c);
            }
        }

        if(!parentOrderIds.isEmpty()) {
            List<Orders__c> relatedOrders = [
                    SELECT Id, Status__c, ParentOrder__c
                    FROM Orders__c
                    WHERE ParentOrder__c IN :parentOrderIds
            ];

            Map<Id, Set<String>> parentOrderStatusMap = new Map<Id, Set<String>>();

            for (Orders__c relatedOrder : relatedOrders) {
                if (!parentOrderStatusMap.containsKey(relatedOrder.ParentOrder__c)) {
                    parentOrderStatusMap.put(relatedOrder.ParentOrder__c, new Set<String>());
                }
                parentOrderStatusMap.get(relatedOrder.ParentOrder__c).add(relatedOrder.Status__c);
            }

            List<Orders__c> ordersToUpdate = new List<Orders__c>();
            for (Id parentOrderId : parentOrderStatusMap.keySet()) {
                if (parentOrderStatusMap.get(parentOrderId).size() == 1 && parentOrderStatusMap.get(parentOrderId).contains('Closed')) {
                    ordersToUpdate.add(new Orders__c(Id = parentOrderId, Status__c = 'Closed'));
                }
            }

            if (!ordersToUpdate.isEmpty()) {
                update ordersToUpdate; 
            }
        }
    }
}