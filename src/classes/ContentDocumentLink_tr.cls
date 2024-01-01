/*************************************************************
 * @author : 최태욱
 * @date : 2023-12-18
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-18      최태욱         Initial Version
**************************************************************/

public with sharing class ContentDocumentLink_tr extends TriggerHandler {
    
    public ContentDocumentLink_tr() {
        listNew = (List<ContentDocumentLink>) Trigger.new;
        listOld = (List<ContentDocumentLink>) Trigger.old;
        mapOld = (Map<Id, ContentDocumentLink>) Trigger.oldMap;
        mapNew = (Map<Id, ContentDocumentLink>) Trigger.newMap;
    }

    /** TriggerHandler */
    private List<ContentDocumentLink> listNew { get; set; }
    private List<ContentDocumentLink> listOld { get; set; }
    private Map<Id, ContentDocumentLink> mapOld { get; set; }
    private Map<Id, ContentDocumentLink> mapNew { get; set; }

    public override void beforeInsert() {
        doInsertSharingAll();
        preventUploadForSpecificObjects();
    }

    public void doInsertSharingAll() {
        System.debug('doInsertSharingAll 시작');
        System.debug('UserInfo.getUserType() :: ' + UserInfo.getUserType());

        for (ContentDocumentLink obj : listNew) {

            Boolean isManualItem = String.valueOf(obj.LinkedEntityId).substring(0, 3).equals(ManualsItem__c.SObjectType.getDescribe().getKeyPrefix()) && !obj.Visibility.equals('AllUsers') || !obj.ShareType.equals('I');
            Boolean isServiceBulletin = String.valueOf(obj.LinkedEntityId).substring(0, 3).equals(ServiceBulletin__c.SObjectType.getDescribe().getKeyPrefix()) && !obj.Visibility.equals('AllUsers') || !obj.ShareType.equals('I');
            Boolean isErrorCode = String.valueOf(obj.LinkedEntityId).substring(0, 3).equals(ErrorCode__c.SObjectType.getDescribe().getKeyPrefix()) && !obj.Visibility.equals('AllUsers') || !obj.ShareType.equals('I');
            Boolean isTYMOfficial = String.valueOf(obj.LinkedEntityId).substring(0, 3).equals(TYMOfficial__c.SObjectType.getDescribe().getKeyPrefix()) && !obj.Visibility.equals('AllUsers') || !obj.ShareType.equals('I');
            Boolean isDealerSuggestion = String.valueOf(obj.LinkedEntityId).substring(0, 3).equals(DealerSuggestion__c.SObjectType.getDescribe().getKeyPrefix()) && !obj.Visibility.equals('AllUsers') || !obj.ShareType.equals('I');
            
            if (isManualItem || isServiceBulletin || isErrorCode || isTYMOfficial || isDealerSuggestion) {
                System.debug('doInsertSharingAll :: Target :: ' + obj);
                obj.ShareType = 'I';
                obj.Visibility = 'AllUsers';
            }
        }

        // if (UserInfo.getUserType().contains('Partner')) {
        //     if (!Test.isRunningTest()) obj.addError('Can not upload File');
        // }

    }

    private void preventUploadForSpecificObjects() {
        for (ContentDocumentLink link : listNew) {
            if (isBlockedObjectType(link.LinkedEntityId.getSObjectType()) && UserInfo.getUserType().contains('Partner')) {
                link.addError('Uploading files for this object is not allowed for Partners.');
            }
        }
    }
    private Boolean isBlockedObjectType(SObjectType objectType) {
        return objectType == ManualsItem__c.SObjectType ||
               objectType == ServiceBulletin__c.SObjectType ||
               objectType == ErrorCode__c.SObjectType ||
               objectType == TYMOfficial__c.SObjectType ||
               objectType == DealerSuggestion__c.SObjectType;
    }



}