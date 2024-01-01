/*************************************************************
 * @author : th.kim
 * @date : 2023-11-10
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-10      th.kim          Initial Version
**************************************************************/

@IsTest
public with sharing class TYM_RetailProgramRegController_TEST {

    static Profile profile;
    static User user;
    static Product2 product;
    static Account account;
    static Contact contact;
    static Orders__c orders;
    static Asset asset;
    static ARInvoice__c arInvoice;
    static ARInvoiceItem__c arInvoiceItem;
    static RetailProgram__c retailProgram;
    static List<RetailProgramMaster__c> retailProgramMaster;
    static List<RetailProgramMasterItem__c> retailProgramMasterItem;
    static RetailProgramItem__c retailProgramItem;
    static PayoutStructure__c payoutStructure;
    static ContentVersion cv;

    static {
        profile = [SELECT Id FROM Profile WHERE Name = 'Interface'];
        user = new User(
                ProfileId = profile.Id,
                LastName = 'test',
                Alias = 'test',
                Username = 'test12312234256wefgsdfsfd3@test.com',
                Email = 'test@testee.com',
                TimeZoneSidKey = 'Asia/Seoul',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert user;

        product = new Product2(
                Name = 'test',
                ItemGroupCode__c = '112',
                ProductCode = 'test01'
        );
        System.runAs(user) {
            insert product;
        }

        account = new Account(
                Name = 'test'
        );
        insert account;

        contact = new Contact(
                LastName = 'test',
                AccountId = account.Id
        );
        insert contact;

        orders = new Orders__c();
        insert orders;

        asset = new Asset(
                Name = 'test',
                SerialNumber = '001',
                Product2Id = product.Id,
                AccountId = account.Id,
                ContactId = contact.Id,
                OrdersId__c = orders.Id,
                Status = 'Registered',
                RegisteredDate__c = Date.today(),
                RetailedDate__c = Date.today(),
                InvoiceDate__c = Date.today(),
                RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Tractor').getRecordTypeId()
        );
        insert asset;

        arInvoice = new ARInvoice__c(
                OrdersId__c = orders.Id
        );
        insert arInvoice;

        arInvoiceItem = new ARInvoiceItem__c(
                ARInvoiceMaster__c = arInvoice.Id,
                SerialNumber__c = '001',
                UnitPrice__c = 100
        );
        insert arInvoiceItem;

        retailProgram = new RetailProgram__c(
                AssetID__c = asset.Id,
                Description__c = 'test',
                IsPayToDealer__c = false,
                AccountId__c = account.Id
        );
        insert retailProgram;

        retailProgramMaster = new List<RetailProgramMaster__c>{
                new RetailProgramMaster__c(
                        Name = 'Volume Incentive Test 1',
                        ProgramType__c = 'Volume Incentive',
                        PricingStructure__c = '',
                        CriterionDate__c = 'Retail Date',
                        StartDate__c = Date.today(),
                        EndDate__c = Date.today().addMonths(1)
                ),
                new RetailProgramMaster__c(
                        Name = 'Rebate Test 1',
                        ProgramType__c = 'Rebate',
                        PricingStructure__c = 'Flat Rate',
                        CriterionDate__c = 'Registered Date',
                        StartDate__c = Date.today(),
                        EndDate__c = Date.today().addMonths(1),
                        DaysFrom__c = 0,
                        DaysTo__c = 300
                )
        };
        insert retailProgramMaster;

        retailProgramMasterItem = new List<RetailProgramMasterItem__c>{
                new RetailProgramMasterItem__c(
                        Unit__c = 1,
                        Amount__c = 100,
                        Discount__c = 10,
                        RetailProgramID__c = retailProgramMaster[0].Id,
                        ProductID__c = product.Id
                ),
                new RetailProgramMasterItem__c(
                        Unit__c = 1,
                        Amount__c = 100,
                        Discount__c = 10,
                        RetailProgramID__c = retailProgramMaster[1].Id,
                        ProductID__c = product.Id
                )
        };
        insert retailProgramMasterItem;

        retailProgramItem = new RetailProgramItem__c(
                RetailProgramID__c = retailProgram.Id,
                ProductID__c = product.Id,
                RetailProgramMasterID__c = retailProgramMaster[0].Id,
                Description__c = 'test',
                Claimed__c = 100,
                Adjusted__c = 100
        );
        insert retailProgramItem;

        payoutStructure = new PayoutStructure__c(
                RetailProgramID__c = retailProgramMaster[0].Id,
                Amount__c = 100
        );
        insert payoutStructure;

        cv = new ContentVersion(
                Title = 'test',
                PathOnClient = 'test',
                FirstPublishLocationId = retailProgramItem.Id,
                VersionData = EncodingUtil.base64Decode('test')
        );
        insert cv;
    }

    @IsTest
    static void testGetProfileName() {
        Test.startTest();
        TYM_RetailProgramRegController.getProfileName();
        Test.stopTest();
    }

    @IsTest
    static void testGetSalesperson() {
        Test.startTest();
        TYM_RetailProgramRegController.getSalesperson(retailProgram.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetRetailProgram() {
        Test.startTest();
        TYM_RetailProgramRegController.getRetailProgram(retailProgram.Id);
        Test.stopTest();
    }

    @IsTest
    static void testUpsertRetailProgramItem() {
        Test.startTest();
        Map<String, String> dataMap = new Map<String, String>{
                'recordId' => retailProgram.Id,
                'payToDealer' => 'false',
                'rebateRadioValue' => 'Issue Check',
                'volumeRadioValue' => 'Issue Check'
        };
        List<TYM_RetailProgramRegController.DeleteWrap> deleteWrapList = new List<TYM_RetailProgramRegController.DeleteWrap>();
        TYM_RetailProgramRegController.DeleteWrap deleteWrap = new TYM_RetailProgramRegController.DeleteWrap();
        deleteWrap.programId = retailProgramItem.RetailProgramMasterID__c;
        deleteWrap.productId = retailProgramItem.ProductID__c;
        deleteWrapList.add(deleteWrap);

        TYM_RetailProgramRegController.FileWrap fileWrap = new TYM_RetailProgramRegController.FileWrap();
        fileWrap.fileName = 'test';
        fileWrap.base64 = 'test';

        List<TYM_RetailProgramRegController.DataWrap> dataWrapList = new List<TYM_RetailProgramRegController.DataWrap>();
        for (Integer i = 0; i < 2; i++) {
            TYM_RetailProgramRegController.DataWrap dataWrap = new TYM_RetailProgramRegController.DataWrap();
            dataWrap.productId = product.Id;
            dataWrap.programId = retailProgramMaster[i].Id;
            dataWrap.description = 'test';
            dataWrap.amount = 100;
            dataWrap.manager = 100;
            dataWrap.fileData = fileWrap;
            dataWrapList.add(dataWrap);
        }

        List<String> listCvId = new List<String>{
                cv.Id
        };
        TYM_RetailProgramRegController.upsertRetailProgramItem(dataMap, JSON.serialize(deleteWrapList), JSON.serialize(dataWrapList), listCvId);
        Test.stopTest();
    }
}