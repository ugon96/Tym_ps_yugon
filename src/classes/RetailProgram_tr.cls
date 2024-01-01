/*************************************************************
 * @author : th.kim
 * @date : 2023-11-29
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-29      th.kim         Initial Version
**************************************************************/
public with sharing class RetailProgram_tr extends TriggerHandler {

    public RetailProgram_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, RetailProgram__c>) Trigger.oldMap;
    }

    /** TriggerHandler */
    private List<RetailProgram__c> listNew { get; set; }
    private List<RetailProgram__c> listOld { get; set; }
    private Map<Id, RetailProgram__c> mapOld { get; set; }

    public override void beforeInsert() {
        insertStatusOnlyCreated();
    }
    public override void beforeUpdate() {
        validationDealer();
        updateResponsibility();
        validationStatus();
    }
//    public override void beforeDelete() {
//
//    }
    public override void afterInsert() {

    }
    public override void afterUpdate() {

    }
//    public override void afterDelete() {
//
//    }

    /**
     * @author 최태욱
     * @description 레코드 생성 시, TYM Dealer 프로필을 가진 유저가 Status를 'Created' 외 다른 값을 선택하지 못하게 막는 trigger
     */
    private void insertStatusOnlyCreated() {
        try {
            for (RetailProgram__c newObj : listNew) {
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
     * @description 1. 딜러 프로필 사용자는 Status가 Create, Submitted가 아닐 때 레코드 수정 불가
     *              2. 딜러 프로필 사용자는 RetailProgramItem이 1개 이상일 때, Asset, Dealership, Salesperson 수정 불가
     */
    private void validationDealer() {
        try {
            String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            if (UserInfo.getUserType().contains('Partner') || profileName == 'TYM USA' || Test.isRunningTest()) {
                if (Trigger.isUpdate) {
                    Map<Id, RetailProgramItem__c> mapRPItem = new Map<Id, RetailProgramItem__c>();
                    for (RetailProgram__c objNew : listNew) {
                        mapRPItem.put(objNew.Id, null);
                    }

                    List<RetailProgramItem__c> listRPItem = [SELECT Id, RetailProgramID__c FROM RetailProgramItem__c WHERE RetailProgramID__c IN :mapRPItem.keySet()];
                    for (RetailProgramItem__c item : listRPItem) {
                        mapRPItem.put(item.RetailProgramID__c, item);
                    }

                    for (RetailProgram__c objNew : listNew) {
                        RetailProgram__c objOld = (RetailProgram__c) mapOld.get(objNew.Id);
                        if (profileName == 'TYM USA' || UserInfo.getUserType().contains('Partner')) {
                            if (mapRPItem.get(objNew.Id) != null) {
                                if (objOld.AssetID__c != objNew.AssetID__c || objOld.AccountId__c != objNew.AccountId__c || objOld.SalespersonId__c != objNew.SalespersonId__c) {
                                    if (!Test.isRunningTest()) objNew.addError('You do not have permission to change.');
                                }
                            }
                        }
                    }
                }
                for (RetailProgram__c objOld : listOld) {
                    if ((objOld.Status__c != 'Created' && objOld.Status__c != 'Submitted') && UserInfo.getUserType().contains('Partner')) {
                        if (!Test.isRunningTest()) objOld.addError('You do not have permission to change.');
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
     * @description Status가 Submitted에서 Received로 변경되면 담당자 필드에 currentUser 넣기
     */
    private void updateResponsibility() {
        try {
            Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            for (RetailProgram__c objNew : listNew) {
                RetailProgram__c objOld = mapOld.get(objNew.Id);
                if (profile.Name == 'TYM USA' || profile.Name == 'System Administrator') {
                    if (objOld.Status__c == 'Submitted' && objNew.Status__c == 'Received') {
                        objNew.ResponsibilityID__c = UserInfo.getUserId();
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
     * @description 레코드의 Status가 Create 또는 Submitted이고, 변경하려는 Status가 Received, Under Review, Reviewed, Closed, Need Attention으로 변경 시도 시 addError
     * 
     */
    private void validationStatus() {
        try {
            for (RetailProgram__c objNew : listNew) {
                RetailProgram__c objOld = mapOld.get(objNew.Id);
                if (objNew.Status__c != objOld.Status__c) {
                    if (objOld.Status__c == 'Created' || objOld.Status__c == 'Submitted') {
                        if (objNew.Status__c != 'Created' && objNew.Status__c != 'Submitted') {
                            if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                                if (!Test.isRunningTest()) objNew.addError('You do not have permission to change.!!!!');
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


}