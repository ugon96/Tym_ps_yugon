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
private with sharing class Orders_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();
        Orders__c orders = TestObjectCreator.objOrders;
        Orders__c orders2 = new Orders__c();
        orders2.Status__c = 'Created';
        insert orders2;
        orders.ParentOrder__c = orders2.Id;
        insert orders;

        Profile tymProfile = [SELECT Id FROM Profile WHERE Name = 'TYM USA'];
        User tymUser = [SELECT Id FROM User WHERE ProfileId = :tymProfile.Id AND IsActive = TRUE LIMIT 1];
        System.runAs(tymUser) {
            orders.Status__c = 'Submitted';
            orders.IsSendtoSAP__c = true;
            update orders;
            orders.Status__c = 'Received';
            update orders;
        }

        orders.Status__c = 'Received';
        update orders;

        orders.Status__c = 'Closed';
        update orders;

        delete orders;

        Test.stopTest();
    }
}