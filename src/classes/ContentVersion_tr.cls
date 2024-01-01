/************************************************************************************
 * File Name   		: ContentVersion_tr
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-16
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-16       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class ContentVersion_tr extends TriggerHandler {
    public ContentVersion_tr() {
        mapNew = (Map<Id, ContentVersion>) Trigger.newMap;
        listNew = (List<ContentVersion>) Trigger.new;
        mapOld = (Map<Id, ContentVersion>) Trigger.oldMap;
        listOld = (List<ContentVersion>) Trigger.old;
    }
    /** TriggerHandler */
    private List<ContentVersion> listNew { get; set; }
    private List<ContentVersion> listOld { get; set; }
    private Map<Id, ContentVersion> mapOld { get; set; }
    private Map<Id, ContentVersion> mapNew { get; set; }

    public override void afterInsert() {
        updateProductImageUrl();
    }

    // Product2 에 컨텐츠 업로드시 파트너 커뮤니티에서도 보여주기위해 ContentDistribution 생성
    public void updateProductImageUrl() {
        System.debug('===updateProductImageUrl===');
        List<ContentDistribution> listCDB = new List<ContentDistribution>();
        Map<Id, Id> mapProduct2IdToCvId = new Map<Id, Id>();

        for (ContentVersion objCV : listNew) {
            String objName = String.valueOf(objCV.FirstPublishLocationId.getSobjectType());
            ContentDistribution objCD = new ContentDistribution(
                    ContentVersionId = objCV.Id
            );
            if (objName == 'Product2') {
                mapProduct2IdToCvId.put(objCV.FirstPublishLocationId, objCV.Id);
                if (objCV.Title.length() > 90) {
                    objCD.Name = objCV.Title.substring(0, 90) + Date.today().format();
                } else {
                    objCD.Name = objCV.Title;
                }
                listCDB.add(objCD);
            } else if(objName == 'Case' || objName == 'EngineReplacement__c' || objName == 'News__c') {
                objCD.Name = objCV.Title;
                objCD.RelatedRecordId = objCV.FirstPublishLocationId;
                listCDB.add(objCD);
            }
        }
        System.debug('listCDB :: ' + listCDB);
        if (listCDB.size() > 0) {
            insert listCDB;
            List<ContentDistribution> listInsertedCDB = [SELECT Id, ContentVersionId, ContentDownloadUrl FROM ContentDistribution WHERE Id = :listCDB];
            Map<Id, String> mapCvIdToCdbUrl = new Map<Id, String>();
            for (ContentDistribution objCDB : listInsertedCDB) {
                mapCvIdToCdbUrl.put(objCDB.ContentVersionId, objCDB.ContentDownloadUrl);
            }

            List<Product2> listProduct = [SELECT Id, ImageUrl__c FROM Product2 WHERE Id = :mapProduct2IdToCvId.keySet()];
            List<Product2> listUpdateProduct = new List<Product2>();
            for (Product2 objProd : listProduct) {
                System.debug('mapProduct2IdToCvId.get(objProd.Id) :: ' + mapProduct2IdToCvId.get(objProd.Id));
                if (mapProduct2IdToCvId.get(objProd.Id) != null) {
                    System.debug('mapCvIdToCdbUrl.get(mapProduct2IdToCvId.get(objProd.Id)) :: ' + mapCvIdToCdbUrl.get(mapProduct2IdToCvId.get(objProd.Id)));
                    if (mapCvIdToCdbUrl.get(mapProduct2IdToCvId.get(objProd.Id)) != null) {
                        objProd.ImageUrl__c = mapCvIdToCdbUrl.get(mapProduct2IdToCvId.get(objProd.Id));
                        System.debug('objProd.ImageUrl__c :: ' + objProd.ImageUrl__c);
                        listUpdateProduct.add(objProd);
                    }
                }
            }
            if (listUpdateProduct.size() > 0) {
                update listUpdateProduct;
            }
        }
    }

}