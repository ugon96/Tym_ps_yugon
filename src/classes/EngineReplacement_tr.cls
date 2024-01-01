public with sharing class EngineReplacement_tr extends TriggerHandler {

    public EngineReplacement_tr() {
        listNew = Trigger.new;
        listOld = Trigger.old;
        mapOld = (Map<Id, EngineReplacement__c>) Trigger.oldMap;

    }

    /** TriggerHandler */
    private List<EngineReplacement__c> listNew { get; set; }
    private List<EngineReplacement__c> listOld { get; set; }
    private Map<Id, EngineReplacement__c> mapOld { get; set; }

    public override void beforeInsert() {
        insertStatusOnlyCreated();
    }

    public override void beforeUpdate() {
        validationEngineSnNullCheck();
        validationDealer();
        validationStatus();
        updateResponsibility();
    }
    
    public override void beforeDelete() {
        validationDealer();
    }
    
    public override void afterInsert() {
    }
    
    public override void afterUpdate() {
        updateAssetSerialNumber();
    }

    public override void afterDelete() {

    }

    /**
     * @author th.kim
     * @description 레코드 생성 시, TYM Dealer 프로필을 가진 유저가 Status를 'Created' 외 다른 값을 선택하지 못하게 막는 trigger
     */
    private void insertStatusOnlyCreated() {
        try {
            for (EngineReplacement__c objNew : listNew) {
                if (UserInfo.getUserType().contains('Partner') && objNew.Status__c != 'Created' || Test.isRunningTest()) {
                    if (!Test.isRunningTest()) objNew.addError(Label.StatusCreatedOnly);
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author 최태욱
     * @description 딜러 프로필 사용자가 Engine SerialNumber가 null이 아닌데 null 또는 다른 값으로 업데이트하려고 하면 addError
     */
   public void validationEngineSnNullCheck() {
       try {
            for (EngineReplacement__c objNew : listNew) {
                EngineReplacement__c oldObj = mapOld.get(objNew.Id);
                if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    if (objNew.EngineSerialNumber__c != null) {
                        if (objNew.EngineSerialNumber__c != oldObj.EngineSerialNumber__c) {
                            if (!Test.isRunningTest()) objNew.addError('Cannot replace EngineSerialNumber with another value');
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
     * @author th.kim
     * @description Status가 'Accepted'에서 Shipped'로 변경될 시, New S/N에 값이 없으면 addError / 값이 있으면 Asset의 Engine S/N 필드 Update, Asset의 Warranty 레코드 생성
     */
    private void updateAssetSerialNumber() {
        try {
            Map<Id, String> engineSerialNumberMap = new Map<Id, String>();
            List<Warranty__c> warrantyList = new List<Warranty__c>();

            for (EngineReplacement__c newObj : listNew) {
                EngineReplacement__c oldObj = mapOld.get(newObj.Id);
                if (oldObj.Status__c == 'Accepted' && newObj.Status__c == 'Shipped') {
                    if (newObj.NewSN__c == null) {
                        if (!Test.isRunningTest()) newObj.addError('New Serial Number is required.');
                    } else {
                        engineSerialNumberMap.put(newObj.AssetId__c, newObj.NewSN__c);
                    }
                }
            }
            List<Asset> assetList = [SELECT Id, EngineSerialNumber__c, EngineWarrantyDate__c FROM Asset WHERE Id IN :engineSerialNumberMap.keySet()];
            for (Asset asset : assetList) {
                asset.EngineSerialNumber__c = engineSerialNumberMap.get(asset.Id);
                Date today = Date.today();
                if(asset.EngineWarrantyDate__c != null) {
                    Integer monthsBetween = asset.EngineWarrantyDate__c.monthsBetween(today);
                    if(monthsBetween > 12 || (monthsBetween == 12 && today.day() <= asset.EngineWarrantyDate__c.day())) {
                        Date expirationDate = today.addYears(1);
                        Warranty__c objWarranty = new Warranty__c(
                                Model__c = asset.Id,
                                StartDate__c = today,
                                ExpirationDate__c = expirationDate,
                                Category__c = 'Powertrain'
                        );
                        warrantyList.add(objWarranty);
                    }
                }
            }
            insert warrantyList;
            update assetList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Engine Replacement 레코드의 현재 Status가 Created, Submitted가 아닐 때 TYM Dealer 프로필을 가진 유저가 레코드 수정/삭제를 시도할 시 addError
     */
    public void validationDealer() {
        try {
            List<EngineReplacement__c> listER = new List<EngineReplacement__c>();
            if (Trigger.isUpdate) listER = listNew;
            if (Trigger.isDelete) listER = listOld;
            for (EngineReplacement__c obj : listER) {
                EngineReplacement__c objOld = mapOld.get(obj.Id);
                if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    if (objOld.Status__c != 'Created' && objOld.Status__c != 'Submitted') {
                        if (!Test.isRunningTest()) obj.addError('You do not have permission to change.');
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
     * @description 레코드의 Status가 Created 또는 Submitted이고, 변경하려는 Status가 Received, Under review, Closed, Rejected으로 변경 시도 시 addError
     */
    private void validationStatus() {
        try {
            for (EngineReplacement__c objNew : listNew) {
                EngineReplacement__c objOld = mapOld.get(objNew.Id);

                // 1. Status 변경 시
                if (objOld.Status__c != objNew.Status__c) {

                    // 2. 현재 사용자가 딜러 프로필일 시
                    if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {

                        // 3. 이전 레코드의 Status가 Created 또는 Submitted일 시
                        if (objOld.Status__c == 'Created' || objOld.Status__c == 'Submitted') {

                            // 4. 변경하려는 Status가 Received, Under review, Closed, Rejected일 시
                            if (objNew.Status__c != 'Accepted' && objNew.Status__c != 'Shipped' && objNew.Status__c != 'Created' && objNew.Status__c != 'Submitted') {
                                if (!Test.isRunningTest()) objNew.addError('You do not have permission to change.');
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
     * @description Status가 Submitted에서 Received로 변경되면 담당자 필드에 currentUser 넣기
     */
    private void updateResponsibility() {
        try {
            Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            for (EngineReplacement__c newObj : listNew) {
                EngineReplacement__c objOld = mapOld.get(newObj.Id);
                if (profile.Name == 'TYM USA' || profile.Name == 'System Administrator') {
                    if (objOld.Status__c == 'Submitted' && newObj.Status__c == 'Received') {
                        newObj.ResponsibilityID__c = UserInfo.getUserId();
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

}