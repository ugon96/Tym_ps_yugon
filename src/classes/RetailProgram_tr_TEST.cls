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
private with sharing class RetailProgram_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();
        User tymUser = [SELECT Id FROM User WHERE Profile.Name = 'TYM USA' AND IsActive = TRUE LIMIT 1];
        RetailProgram__c retailProgram = TestObjectCreator.objRetailProgram;
        retailProgram.Status__c = 'Received';
        insert retailProgram;

        retailProgram.Status__c = 'Submitted';
        update retailProgram;

        RetailProgramItem__c retailProgramItem = TestObjectCreator.objRetailProgramItem;
        retailProgramItem.RetailProgramID__c = retailProgram.Id;
        insert retailProgramItem;

        System.runAs(tymUser) {
            retailProgram.Status__c = 'Received';
            retailProgram.AssetID__c = null;
            update retailProgram;
        }
        Test.stopTest();
    }
}