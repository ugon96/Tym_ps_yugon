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
private with sharing class PartsOrder_tr_TEST {
    static User user;
    static Profile profile;
    static {
        profile = [SELECT Id FROM Profile WHERE Name = 'TYM USA'];
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

    @IsTest
    static void testHandler() {
        Test.startTest();
        PartsOrder__c partsOrder = TestObjectCreator.objPartsOrder;
        partsOrder.OrderType__c = 'Level 3 Stock order';
        insert partsOrder;
        PartsOrderItem__c paoI = TestObjectCreator.objPartsOrderItem;
        insert paoI;
        System.runAs(user) {
            partsOrder.Status__c = 'Submitted';
            update partsOrder;
        }
        partsOrder.Status__c = 'Received';
        update partsOrder;
        // partsOrder.OrderType__c = 'Daily';
        // partsOrder.Status__c = 'Received';
        // update partsOrder;

        delete partsOrder;
        Test.stopTest();
    }
}