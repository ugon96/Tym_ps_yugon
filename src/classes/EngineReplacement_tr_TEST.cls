/*************************************************************
 * @author : th.kim
 * @date : 2023-11-30
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-30      th.kim         Initial Version
**************************************************************/
@IsTest
public with sharing class EngineReplacement_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();
        User tymUser = [SELECT Id FROM User WHERE Profile.Name = 'TYM USA' AND IsActive = TRUE LIMIT 1];
        EngineReplacement__c engineReplacement = TestObjectCreator.objEngineReplacement;

        engineReplacement.NewSN__c = '123';
        insert engineReplacement;
        
        engineReplacement.Status__c = 'Accepted';
        update engineReplacement;

        
        engineReplacement.NewWarrantyDate__c = Date.valueOf('2099-12-31');
        Warranty__c w = TestObjectCreator.objWarranty;
        w.Model__c = engineReplacement.AssetId__c;
        insert w;

        engineReplacement.Status__c = 'Shipped';
        update engineReplacement;

        engineReplacement.Status__c = 'Received';
        engineReplacement.EngineSerialNumber__c = 'E12345';
        update engineReplacement;

        engineReplacement.Status__c = 'Submitted';
        update engineReplacement;

        System.runAs(tymUser) {
            engineReplacement.Status__c = 'Received';
            update engineReplacement;
        }

        engineReplacement.Status__c = 'Under review';
        update engineReplacement;

        engineReplacement.Status__c = 'Created';
        update engineReplacement;
        
        engineReplacement.Status__c = 'Rejected';
        update engineReplacement;
        
        engineReplacement.Status__c = 'Shipped';
        update engineReplacement;

        delete engineReplacement;
        Test.stopTest();
    }

}