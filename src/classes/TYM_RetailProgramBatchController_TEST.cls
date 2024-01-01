/*************************************************************
 * @author : th.kim
 * @date : 2023-11-24
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-24      th.kim         Initial Version
**************************************************************/

@IsTest
public with sharing class TYM_RetailProgramBatchController_TEST {

    static Product2 product;
    static Account account;
    static Contact contact;
    static Asset asset;
    static RetailProgram__c retailProgram;
    static RetailProgramMaster__c retailProgramMaster;
    static RetailProgramMasterItem__c retailProgramMasterItem;
    static RetailProgramItem__c retailProgramItem;
    static PayoutStructure__c payoutStructure;

    static {
        product = new Product2(
                Name = 'test',
                ItemGroupCode__c = '112',
                ProductCode = 'test01'
        );
        insert product;

        account = new Account(
                Name = 'test'
        );
        insert account;

        contact = new Contact(
                LastName = 'test',
                AccountId = account.Id
        );
        insert contact;

        asset = new Asset(
                Name = 'test',
                Product2Id = product.Id,
                AccountId = account.Id,
                ContactId = contact.Id,
                RegisteredDate__c = Date.today(),
                Status = 'Registered',
                RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Tractor').getRecordTypeId()
        );
        insert asset;

        retailProgram = new RetailProgram__c(
                AssetID__c = asset.Id,
                AccountId__c = account.Id,
                ProgramType__c = 'Volume',
                Description__c = 'test',
                IsPayToDealer__c = false
        );
        insert retailProgram;

        retailProgramMaster = new RetailProgramMaster__c(
                Name = 'Volume Incentive Test 1',
                ProgramType__c = 'Volume Incentive',
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addMonths(1)
        );
        insert retailProgramMaster;

        retailProgramMasterItem = new RetailProgramMasterItem__c(
                Unit__c = 1,
                Amount__c = 100,
                Discount__c = 10,
                Payout__c = 1,
                RetailProgramID__c = retailProgramMaster.Id,
                ProductID__c = product.Id
        );
        insert retailProgramMasterItem;

        retailProgramItem = new RetailProgramItem__c(
                RetailProgramID__c = retailProgram.Id,
                ProductID__c = product.Id,
                RetailProgramMasterID__c = retailProgramMaster.Id,
                SalespersonId__c = contact.Id,
                Description__c = 'test',
                Claimed__c = 100,
                Adjusted__c = 100
        );
        insert retailProgramItem;

        payoutStructure = new PayoutStructure__c(
                RetailProgramID__c = retailProgramMaster.Id,
                Registered__c = 1,
                Amount__c = 100
        );
        insert payoutStructure;
    }

    @IsTest
    static void testCallBatch() {
        Test.startTest();
        TYM_RetailProgramBatchController.callBatch(retailProgramMaster.Id);
        Test.stopTest();
    }
}