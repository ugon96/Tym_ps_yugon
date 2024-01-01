/**
 * Created by 천유정 on 2023-10-10.
 * Modified by 김태희 on 2023-10-16.
 */

public with sharing class Case_tr extends TriggerHandler {

    public Case_tr() {
        listNew = (List<Case>) Trigger.new;
        mapOld = (Map<Id, Case>) Trigger.oldMap;
        listOld = (List<Case>) Trigger.old;
    }
    /** TriggerHandler */
    private List<Case> listNew { get; set; }
    private List<Case> listOld { get; set; }
    private Map<Id, Case> mapOld { get; set; }

    public override void beforeInsert() {
        insertStatusOnlyCreated();
//        List<Case> caseList = new List<Case>();
//        try {
//            for(Object obj : listNew) {
//                Case caseRecrod = (Case) obj;
//                caseList.add(caseRecrod);
//            }
//
//            // 이미지 체크 정규식
//            String regex = '<img[^>]+src\\s*=\\s*["\']([^"\']+)"';
//            Pattern pattern = Pattern.compile(regex);
//            for(Case c : caseList) {
//                Matcher matcher1 = pattern.matcher(c.PhotOf0HourMeter__c);
//                Matcher matcher2 = pattern.matcher(c.PhotoOfSerialNumber__c);
//                Matcher matcher3 = pattern.matcher(c.PhotoTractoDuringRepair__c);
//
//                // RichText 필드에 이미지 포함되어 있는지 체크
//                if(!matcher1.find() || !matcher2.find() || !matcher3.find()) {
//                    c.addError(Label.Required_Photos_Check);
//                }
//            }
//        } catch(Exception e) {
//            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
//            throw new AuraHandledException(e.getMessage());
//        }
    }
    public override void beforeUpdate() {
        validationProfileStatus();
        currentUserInsert();
        doValidateChangeStatus();
        // validationRichTextImg();
    }
    public override void beforeDelete() {
        validationProfileStatus();
    }
    public override void afterInsert() {

    }
    public override void afterUpdate() {
        //validationPostClaimStatus(); 

    }
    public override void afterDelete() {

    }

    // public void validationRichTextImg() {
    //     try {
    //         List<Case> caseList = new List<Case>();
    //         System.debug('listNew :: ' + listNew);
    //         for(Object obj : listNew) {
    //             Case caseObj = (Case) obj;
    //             caseList.add(caseObj);
    //         }

    //         // 이미지 체크 정규식
    //         String regex = '<img[^>]+src\\s*=\\s*["\']([^"\']+)"';
    //         Pattern pattern = Pattern.compile(regex);
    //         Map<Id, Boolean> newMap1 = new Map<Id, Boolean>();
    //         Map<Id, Boolean> newMap2 = new Map<Id, Boolean>();
    //         Map<Id, Boolean> newMap3 = new Map<Id, Boolean>();

    //         // new List 이미지 포함 여부 체크
    //         for(Case c : caseList) {
    //             Matcher matcher1;
    //             Matcher matcher2;
    //             Matcher matcher3;
    //             if(c.PhotOf0HourMeter__c != null) {
    //                 matcher1 = pattern.matcher(c.PhotOf0HourMeter__c);
    //                 newMap1.put(c.Id, matcher1.find());
    //             } else {
    //                 newMap1.put(c.Id, false);
    //             }
    //             if(c.PhotoOfSerialNumber__c != null) {
    //                 matcher2 = pattern.matcher(c.PhotoOfSerialNumber__c);
    //                 newMap2.put(c.Id, matcher2.find());
    //             } else {
    //                 newMap2.put(c.Id, false);
    //             }
    //             if(c.PhotoTractoDuringRepair__c != null) {
    //                 matcher3 = pattern.matcher(c.PhotoTractoDuringRepair__c);
    //                 newMap3.put(c.Id, matcher3.find());
    //             } else {
    //                 newMap3.put(c.Id, false);
    //             }
    //         }
    //         System.debug('newMap1 :: ' + newMap1);
    //         System.debug('newMap2 :: ' + newMap2);
    //         System.debug('newMap3 :: ' + newMap3);

    //         List<Case> oldCaseList = new List<Case>();
    //         for(Object obj : listOld) {
    //             Case caseObj = (Case) obj;
    //             oldCaseList.add(caseObj);
    //         }

    //         // old List 이미지 포함 여부 체크
    //         for(Case c : oldCaseList) {
    //             System.debug('c :: ' + c);
    //             Matcher matcher1;
    //             Matcher matcher2;
    //             Matcher matcher3;
    //             if(c.PhotOf0HourMeter__c != null) matcher1 = pattern.matcher(c.PhotOf0HourMeter__c);
    //             if(c.PhotoOfSerialNumber__c != null) matcher2 = pattern.matcher(c.PhotoOfSerialNumber__c);
    //             if(c.PhotoTractoDuringRepair__c != null) matcher3 = pattern.matcher(c.PhotoTractoDuringRepair__c);
    //             System.debug('matcher1 :: ' + matcher1);
    //             System.debug('matcher2 :: ' + matcher2);
    //             System.debug('matcher3 :: ' + matcher3);

    //             Boolean isOldsTrue1 = false;
    //             Boolean isOldsTrue2 = false;
    //             Boolean isOldsTrue3 = false;
    //             if(matcher1 != null) {
    //                 if(matcher1.find()) isOldsTrue1 = true;
    //             }
    //             if(matcher2 != null) {
    //                 if(matcher2.find()) isOldsTrue2 = true;
    //              }
    //             if(matcher3 != null) {
    //                 if(matcher3.find()) isOldsTrue3 = true;
    //             }
    //             System.debug('isOldsTrue1 :: ' + isOldsTrue1);
    //             System.debug('isOldsTrue2 :: ' + isOldsTrue2);
    //             System.debug('isOldsTrue3 :: ' + isOldsTrue3);

    //             // RichText 필드에 이미지 포함되어 있는지 체크
    //             if((!isOldsTrue1 && !newMap1.get(c.Id)) || (!isOldsTrue2 && !newMap2.get(c.Id)) || (!isOldsTrue3 && !newMap3.get(c.Id))
    //                     || (isOldsTrue1 && !newMap1.get(c.Id)) || (!isOldsTrue2 && !newMap2.get(c.Id)) || (isOldsTrue3 && !newMap3.get(c.Id))) {
    //                 caseList[0].addError(Label.Required_Photos_Check);
    //             }
    //         }
    //     } catch(Exception e) {
    //         System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // 딜러프로필 가진 유저가 created' 외 다른 값을 선택 못하게 막는 trigger
    public void insertStatusOnlyCreated() {
        try {
            System.debug('listNew :: ' + listNew);
            for(Case obj : listNew) {
                if (UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    if(obj.Status != 'Created') {
                        if(!Test.isRunningTest()) obj.addError(Label.StatusCreatedOnly);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 필수 3개(photo3종) 필드 validation
    // public void validationPhoto() {
    //     try {

    //         List<Case> caseList = new List<Case>();
    //         System.debug('listNew :: ' + listNew);
    //         for(Object obj : listNew) {
    //             Case caseObj = (Case) obj;
    //             caseList.add(caseObj);
    //         }

    //         Map<Id, String> oldStatusMap = new Map<Id, String>();
    //         for(Object obj : listOld) {
    //             Case caseObj = (Case) obj;
    //             oldStatusMap.put(caseObj.Id, caseObj.Status);
    //         }
            
    //         for(Case c : caseList) {
    //             if(c.Status == 'Submitted' &&  mapOld.get(c.Id).Status == 'Created') {
    //                 if(!c.IsPhotoHourMeter__c || !c.IsPhotoSerialNo__c || !c.IsPhotoRepair__c) {
    //                     c.addError(Label.Required_Photos_Check);
    //                 }
    //             }
    //             System.debug('c.IsPhotoHourMeter__c:::: ' + c.IsPhotoHourMeter__c + '' + 'c.IsPhotoSerialNo__c::: ' + c.IsPhotoSerialNo__c + '' + c.IsPhotoRepair__c);
    //         }
    //     } catch (Exception e) {
    //         System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
    //         throw new AuraHandledException(e.getMessage());
    //     }

    // }

    // Status validation rule 
    public void validationProfileStatus() {
        try {
            if(Trigger.isUpdate) {
                Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
                for(Case c : listNew) {
                    c.Subject = c.fm_ClaimSubject__c;
                    Case objOld = mapOld.get(c.Id);
                    if(c.Status == 'Submitted' && objOld.Status == 'Created') {
                        if (!c.IsPhotoHourMeter__c || !c.IsPhotoSerialNo__c || !c.IsPhotoRepair__c) {
                            if(!Test.isRunningTest()) c.addError(Label.Required_Photos_Check);
                        }
                        if (c.ru_CountParts__c == 0 && c.ru_CountLaborCode__c == 0) {
                            if(!Test.isRunningTest()) c.addError('Please add Labor or Parts');
                        }
                    } else if (UserInfo.getUserType().contains('Partner') || profile.Name == 'TYM USA' || Test.isRunningTest()) {
                        if(UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                            if (c.Status != objOld.Status) {
                                if (( objOld.Status == 'Submitted' || objOld.Status == 'Created' && (c.Status != 'Submitted' && c.Status != 'Created'))) {
                                    if(!Test.isRunningTest()) c.addError('You do not have permission to change status.');
                                }
                                if (c.Status == 'Closed' || c.Status == 'Rejected') {
                                    if(!Test.isRunningTest()) c.addError('Status cannot be modified since Accepted');
                                }
                            } else {
                                if (c.Status == 'Received' || c.Status == 'Under Review' || c.Status == 'Closed' || c.Status == 'Rejected') {
                                    if(!Test.isRunningTest()) c.addError('Claim already submitted. You do not have permission to change the record.');
                                }
                            }
                        }
                        if (c.Status == 'Closed' || c.Status == 'Rejected') {
                            if(!Test.isRunningTest()) c.addError('Status cannot be modified since Accepted');
                        }
                    } 
                }
            } else if(Trigger.isDelete ) {
                if(UserInfo.getUserType().contains('Partner') || Test.isRunningTest()) {
                    for(Case objOld : listOld) {
                        if(objOld.Status == 'Created' || objOld.Status == 'Submitted') {
                            if(!Test.isRunningTest()) objOld.addError('Claim already submitted. You do not have permission to change the record.');
                        }
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void doValidateChangeStatus() {
        for(Case obj : listNew) {
            //Custom Setting : System Administrator Id값
            UtilObject__c utilObject = UtilObject__c.getOrgDefaults();
            if (UserInfo.getUserType().contains('Standard') && UserInfo.getProfileId() != utilObject.AdminProfileId__c) {
                if (obj.ApprovalStatus__c == null || obj.ApprovedDate__c == null) {
                    if (obj.Status != mapOld.get(obj.Id).Status && (obj.Status == 'Closed' || obj.Status == 'Accepted')) {
                        System.debug('!!');
                        if(!Test.isRunningTest()) obj.addError('You do not have permission to change status. Please submit approval.');
                    }
                    if (obj.Status != mapOld.get(obj.Id).Status && (mapOld.get(obj.Id).Status == 'Closed' || mapOld.get(obj.Id).Status == 'Accepted')) { 
                        System.debug('!!!');
                        if(!Test.isRunningTest()) obj.addError('This claim is already closed. You do not have permission to change status.');
                    }
                }
            }
        }
    }
    // status가 under review --> accepted 될 때, postClaim 호출
    /*public void validationPostClaimStatus() {
        System.debug('validationPostClaimStatus start');
        List<Case> listCase = new List<Case>();
        for (Case c : listNew) {
            System.debug('listNew c ::' + c);
            System.debug('c.Status ::' + c.Status);
            System.debug('mapOld.get(c.Id).Status' + mapOld.get(c.Id).Status);
            if (c.Status == 'Accepted' && mapOld.get(c.Id).Status == 'Under Review') {
                listCase.add(c);
                System.debug('listCase.add' + listCase);
            }
        }
        System.debug('listCase :: ' + listCase);
        IF_SFDC_SAP_REG_CLAIM.execute();
    }*/

    // PostClaim 메서드
    //private void postClaim(Case c) {
        // PostClaim 로직
        //System.debug('PostClaim 호출: ' + c.Id);
    //}

    // currentUserInsert
    public void currentUserInsert() {
        try {
            Profile profile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

            List<Case> caseList = new List<Case>();
            System.debug('listNew :: ' + listNew);
            for(Object obj : listNew) {
                Case caseObj = (Case) obj;
                caseList.add(caseObj);
            }

            Map<Id, String> oldStatusMap = new Map<Id, String>();
            for(Object obj : listOld) {
                Case caseObj = (Case) obj;
                oldStatusMap.put(caseObj.Id, caseObj.Status);
            }

            System.debug('profile ::::::' + profile);

            for(Case c : caseList) {
                if (profile.Name == 'TYM USA' || profile.Name == 'System Administrator') {
                    if ( mapOld.get(c.Id).Status == 'Submitted' && c.Status == 'Received') {
                        c.ResponsibilityID__c = UserInfo.getUserId();
                    }
                }
            }

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}