/********************************************************************
* File Name   : createEngineReplacement.cmp
* Author      : 최태욱
* Date        : 2023.10.20
* Class       : EngineReplacementsController.cls
* Description : Asset의 정보를 조회하여 aura에서 사용
* Modification Log
* ====================================================================
* Ver      Date            Author              Modification
* ====================================================================
1.0      2023.10.20        최태욱               Create
<*********************************************************************/


public without sharing class EngineReplacementsController {
    

    /**
     * @author 최태욱
     * @description : Asset 데이터 조회
     * @param recordId
     * @return aList
     */
    @AuraEnabled
    public static Map<String, Object> selectengineReplaceAsset(String recordId) {
        String strAccId = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
        List<Asset> aList = [
            SELECT Id, Name, AccountId, EngineSerialNumber__c, SerialNumber, EngineWarrantyDate__c 
            FROM Asset 
            WHERE Id =: recordId
        ];
        Map<String, Object> mapReturn = new Map<String, Object>{
            'accId' => strAccId,
            'asset' => aList
        };

        System.debug('aList:::::' + aList);
        return mapReturn;
    }
}