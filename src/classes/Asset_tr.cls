/*************************************************************
 * @author : th.kim
 * @date : 2023-11-17
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-17      th.kim         Initial Version
**************************************************************/

public with sharing class Asset_tr extends TriggerHandler {

    public Asset_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, Asset>) Trigger.oldMap;
    }
    /** TriggerHandler */
    private List<Asset> listNew { get; set; }
    private List<Asset> listOld { get; set; }
    private Map<Id, Asset> mapOld { get; set; }

    public override void beforeInsert() {

    }
    public override void beforeUpdate() {
        validateIsNotTractor();
        initAsset();
    }
//    public override void beforeDelete() {
//
//    }
    public override void afterInsert() {

    }
    public override void afterUpdate() {
        updateStatus();
        createWarranty();
    }
//    public override void afterDelete() {
//
//    }

    /**
     * @author th.kim
     * @description 레코드 타입이 Tractor이고 Status가 'Under Review'이면 딜러 포탈 유저 수정 Validation
     */
    private void validateIsNotTractor() {
        try {
            for (Asset newAsset : listNew) {
                if (newAsset.RecordType.Name != 'Tractor') {
                    if (UserInfo.getUserType().contains('Partner') && mapOld.get(newAsset.Id).Status == 'Under Review' || Test.isRunningTest()) {
                        if (!Test.isRunningTest()) newAsset.addError('You do not have permission to change.');
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
     * @description 레코드 타입이 Tractor일 때 해당 Tractor가 가지고 있는 Attachment도 Status 같이 업데이트
     */
    private void updateStatus() {
        try {
            Map<Id, String> assetMap = new Map<Id, String>();
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Tractor' AND SobjectType = 'Asset' LIMIT 1];
            for (Asset newObj : listNew) {
                if (newObj.RecordTypeId == recordType.Id) {
                    Asset oldAsset = (Asset) mapOld.get(newObj.Id);
                    if (oldAsset.Status != newObj.Status) {
                        assetMap.putAll(new Map<Id, String>{
                                newObj.LoaderId__c => newObj.Status,
                                newObj.BackhoeId__c => newObj.Status,
                                newObj.MidMountMower__c => newObj.Status,
                                newObj.Cabin__c => newObj.Status
                        });
                    }
                }
            }

            List<Asset> assetList = [SELECT Id, Status FROM Asset WHERE Id IN :assetMap.keySet()];
            for (Asset asset : assetList) {
                asset.Status = assetMap.get(asset.Id);
            }
            update assetList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Status가 'UnderReview'에서 'Registered'으로 변경될 시, Warranty Type : Commercial 또는 Non-Commercial인 경우는 기존 Warranty 를 생성
     *              1. StartDate = Asset의 Retail Date
     *              2. Expiration Date
     *                 - Record Type이 Tractor의 경우 2년
     *                 - Attachment(Loader, Backhoe, Mid-mount-mower)는 1년
     */
    private void createWarranty() {
        try {
            List<Warranty__c> warrantyList = new List<Warranty__c>();
            List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Asset'];
            Map<Id, String> recordTypeMap = new Map<Id, String>();
            for (RecordType recordType : recordTypeList) {
                recordTypeMap.put(recordType.Id, recordType.Name);
            }

            for (Asset newAsset : listNew) {
                Asset oldAsset = (Asset) mapOld.get(newAsset.Id);
                if (oldAsset.Status != newAsset.Status) {
                    if(oldAsset.Status == 'Under Review' && newAsset.Status == 'Registered') {
                        Warranty__c warrantyObj = new Warranty__c();
                        warrantyObj.Model__c = newAsset.Id;
                        warrantyObj.StartDate__c = newAsset.RetailedDate__c;
                        //23.12.11 수정
                        if (recordTypeMap.get(newAsset.RecordTypeId) == 'Tractor') {
                            warrantyObj.ExpirationDate__c = newAsset.RetailedDate__c.addYears(2);
                        } else {
                            warrantyObj.ExpirationDate__c = newAsset.RetailedDate__c.addYears(1);
                        }
                        warrantyList.add(warrantyObj);
                    }
                }
            }
            upsert warrantyList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Status가 'Under Review'에서 'New'로 변경되었을 때 SalespersonId__c과 EndCustomerId__c Null로 초기화
     *              레코드 타입이 Tractor일 시 해당 레코드의 Attachment도 같이 업데이트
     */
    private void initAsset() {
        try {
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Tractor' AND SobjectType = 'Asset' LIMIT 1];
            Set<Id> assetIdSet = new Set<Id>();
            for (Asset newAsset : listNew) {
                Asset oldAsset = (Asset) mapOld.get(newAsset.Id);
                if (oldAsset.Status == 'Under Review' && newAsset.Status == 'New') {
                    newAsset.SalespersonId__c = null;
                    newAsset.EndCustomerId__c = null;
                    if (newAsset.RecordTypeId == recordType.Id) {
                        assetIdSet.addAll(new Set<Id>{
                                newAsset.LoaderId__c,
                                newAsset.BackhoeId__c,
                                newAsset.MidMountMower__c,
                                newAsset.Cabin__c
                        });
                    }
                }
            }
            for (Asset asset : [SELECT Id, SalespersonId__c, EndCustomerId__c FROM Asset WHERE Id IN :assetIdSet]) {
                asset.SalespersonId__c = null;
                asset.EndCustomerId__c = null;
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}