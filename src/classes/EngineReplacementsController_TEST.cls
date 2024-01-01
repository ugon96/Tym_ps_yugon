/*************************************************************
 * @author : 최태욱
 * @date : 2023-12-26
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-26      최태욱         Initial Version
**************************************************************/
@isTest
public with sharing class EngineReplacementsController_TEST {
    @isTest
    static void testHandeler() {
        
        Test.startTest();

        Asset asset = TestObjectCreator.objAssetTractor;
        insert asset;

        EngineReplacementsController.selectengineReplaceAsset(asset.Id);

        Test.stopTest();
    }

}