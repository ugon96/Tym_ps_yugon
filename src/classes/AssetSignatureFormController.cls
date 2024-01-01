/********************************************************************
* File Name   : AssetSignatureFormController.cls
* Author      : 최태욱
* Class       : AssetSignatureFormController.cls
* Description : 서명 데이터를 받아서 이미지로 저장
* Modification Log
* ====================================================================
* Ver      Date            Author              Modification
* ====================================================================
1.0      2023.11.24        최태욱               Modify
<*********************************************************************/

public with sharing class AssetSignatureFormController {

    /**
     * @author 최태욱
     * @description : 서명 데이터를 받아서 이미지로 저장
     * @param signatureBody
     * @param recordId
     */
    @AuraEnabled
    public static void saveSignature(String signatureBody, String recordId){

        List<ContentVersion> versionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = : recordId AND Title = 'Signiture' ];
        
        Set<Id> cdIdSet = new Set<Id>();
        for(ContentVersion cv : versionList) {
            cdIdSet.add(cv.ContentDocumentId);
        }

        System.debug('cdIdSet ::::' + cdIdSet);

        List<ContentDocument> contentList = [SELECT Id FROM ContentDocument WHERE Id IN : cdIdSet];

        System.debug('recordId:::::'+ recordId);
        
        if(!contentList.isEmpty()) delete contentList;
        
        
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.Title                     = 'Signiture';
        objContentVersion.VersionData               = EncodingUtil.base64Decode(signatureBody);
        objContentVersion.PathOnClient              = 'Signiture.png';
        objContentVersion.FirstPublishLocationId    = recordId;
        objContentVersion.OwnerId                   = UserInfo.getUserId();
        objContentVersion.ContentLocation           = 'S'; // S specify this document is in SF, use E for external files
        
        insert objContentVersion;

        System.debug('objContentVersion ::: '+ objContentVersion );
    }
}