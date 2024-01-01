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
@IsTest
public with sharing class Asset_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();
        Asset asset = TestObjectCreator.objAssetTractor;
        insert asset;

        asset.Status = 'Under Review';
        asset.WarrantyType__c = 'Non-commercial';
        update asset;
        
        asset.Status = 'Registered';
        update asset;

        asset.WarrantyType__c = 'Commercial';
        update asset;

        asset.Status = 'Under Review';
        update asset;

        asset.Status = 'New';
        update asset;

        Test.stopTest();
    }

    @IsTest
    static void TestStart(){
        Asset objAssetBack = TestObjectCreator.objAssetBackhoe;
        objAssetBack.ParentId = null;
        insert objAssetBack;

        Asset objAssetLoader = TestObjectCreator.objAssetLoader;
        objAssetLoader.ParentId = null;
        insert objAssetLoader;

        Asset objMid = TestObjectCreator.objAssetMidMountMower;
        objMid.ParentId = null;
        insert objMid;

        Asset objCabin = TestObjectCreator.objAssetCabin;
        objCabin.ParentId = null;
        insert objCabin;

        Asset objAsset = TestObjectCreator.objAssetTractor;
        objAsset.LoaderId__c = null;
        objAsset.BackhoeId__c = null;
        objAsset.MidMountMower__c = null;
        objAsset.Cabin__c = null;
        upsert objAsset;

        objAsset.LoaderId__c = objAssetLoader.Id;
        objAsset.BackhoeId__c = objAssetBack.Id;
        objAsset.MidMountMower__c = objMid.Id;
        objAsset.Cabin__c = objCabin.Id;
        update objAsset;
    }
}