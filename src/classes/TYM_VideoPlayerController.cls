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
public with sharing class TYM_VideoPlayerController {

    @AuraEnabled
    public static String getUrl(String recordId) {
        // 현재 Object Api Name 가져오기
        Id idRecordId = (Id) recordId;
        String objName = idRecordId.getSobjectType().getDescribe().getName();
        System.debug('objName :: ' + objName);

        String fieldApiName = 'URL__c';

        // 현재 Object와 Field 데이터로 쿼리
        SObject listSObject = Database.query('SELECT ' + fieldApiName + ' FROM ' + objName + ' WHERE Id = :recordId ');
        System.debug('listSObject :: ' + listSObject);

        String returnUrl = (String) listSObject.get(fieldApiName);

        return returnUrl;
    }
}