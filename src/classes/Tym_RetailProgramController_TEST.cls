@isTest
public with sharing class Tym_RetailProgramController_TEST {
    static User user;
    static Profile profile;
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
    }
    @isTest
    static void testHandeler() {
        Test.startTest();

        Product2 product = TestObjectCreator.objProductParts;
        System.runAs(user) {
            insert product;
        }

        Tym_RetailProgramController.getItemGroupCodes();

        Test.stopTest();
    }

    @isTest
    static void testSelectRetailMasterItemInfo() {

        Test.startTest();
        
        Product2 product = TestObjectCreator.objProductParts;
        System.runAs(user) {
            insert product;
        }

        Product2 product2 = new Product2();
        product2.ProductName__c = 'test';
        product2.ItemGroupCode__c = product.ItemGroupCode__c;
        product2.Name = '131313';
        System.runAs(user) {
            insert product2;
        }

        RetailProgramMasterItem__c rpmi = TestObjectCreator.objRetailProgramMasterItem;
        rpmi.ProductID__c = product2.Id;
        insert rpmi;

        List<String> itemValue = new List<String>();
        itemValue.add(product.ItemGroupCode__c);
        
        Tym_RetailProgramController.selectRetailMasterItemInfo(itemValue, rpmi.RetailProgramID__c);

        Test.stopTest();

    }

    @isTest
    static void testDeleteRow() {

        Test.startTest();

        RetailProgramMasterItem__c rpmi = TestObjectCreator.objRetailProgramMasterItem;
        insert rpmi;

        List<String> itemValue2 = new List<String>();
        itemValue2.add(rpmi.Id);

        Tym_RetailProgramController.deleteRow(itemValue2);

        Test.stopTest();

    }

    @isTest
    static void testDeletePayRow() {

        Test.startTest();

        PayoutStructure__c paySt = TestObjectCreator.objPayoutStructure;
        insert paySt;

        List<String> payRetailId = new List<String>();
        payRetailId.add(paySt.Id);

        Tym_RetailProgramController.deletePayRow(payRetailId);


        Test.stopTest();

    }

    @isTest
    static void testInsertRetailProgramMasterItem() {

        Test.startTest();

        RetailProgramMasterItem__c rpmi = TestObjectCreator.objRetailProgramMasterItem;
        insert rpmi;

        RetailProgramMasterItem__c rpmi2 = new RetailProgramMasterItem__c();
        rpmi2.ProductID__c = rpmi.ProductID__c;
        rpmi2.RetailProgramID__c = rpmi.RetailProgramID__c;

        List<Tym_RetailProgramController.itemWrapper> itemWrapperList = new List<Tym_RetailProgramController.itemWrapper>();
        Tym_RetailProgramController.itemWrapper itemWrapper = new Tym_RetailProgramController.itemWrapper();

        itemWrapper.productId = rpmi.ProductID__c;
        itemWrapper.name = rpmi.ProductID__r.ProductName__c;
        itemWrapper.rpmitemList = rpmi;
        itemWrapperList.add(itemWrapper);

        Tym_RetailProgramController.itemWrapper itemWrapper2 = new Tym_RetailProgramController.itemWrapper();
        itemWrapper2.productId = rpmi2.ProductID__c;
        itemWrapper2.name = rpmi2.ProductID__r.ProductName__c;
        itemWrapper2.rpmitemList = rpmi2;
        itemWrapperList.add(itemWrapper2);

        System.debug('itemWrapperList :: ' + itemWrapperList);

        Tym_RetailProgramController.insertRetailProgramMasterItem(JSON.serialize(itemWrapperList));
        Test.stopTest();

    }

    @isTest
    static void testSelectpayoutStructure() {

        Test.startTest();

        PayoutStructure__c ps = TestObjectCreator.objPayoutStructure;
        insert ps;

        String retailId;

        PayoutStructure__c p = new PayoutStructure__c();
        p.RetailProgramID__c = retailId;


        Tym_RetailProgramController.selectpayoutStructure(retailId);


        Test.stopTest();

    }


    @isTest
    static void testInsertPayoutItems() {

        Test.startTest();

        PayoutStructure__c ps = TestObjectCreator.objPayoutStructure;
        insert ps;


        PayoutStructure__c objPs = new PayoutStructure__c();
        objPs.Id = ps.Id;
        
        List<PayoutStructure__c> payList = new List<PayoutStructure__c>();
        PayoutStructure__c objPs1 = new PayoutStructure__c();
        objPs1.RetailProgramID__c = objPs.RetailProgramID__c;
        payList.add(objPs1);
        
        PayoutStructure__c objPs2 = new PayoutStructure__c();
        objPs2.RetailProgramID__c = objPs.RetailProgramID__c;
        objPs2.Id = objPs.Id;
        payList.add(objPs2);


        System.debug('payList::::' + payList);

        Tym_RetailProgramController.insertPayoutItems(JSON.serialize(payList));

        Test.stopTest();


    }


}