@isTest
public with sharing class TYM_PartsOrderCloneController_TEST {
    @isTest 
    static void testHandeler() {
        Test.startTest();
        Map<String, String> poMap = new Map<String, String>();
        poMap.put('poNum', '123');

        PartsOrder__c po = TestObjectCreator.objPartsOrder;
        insert po;

        PartsOrderItem__c poi = TestObjectCreator.objPartsOrderItem;
        insert poi;

        TYM_PartsOrderCloneController.partsOrderClone(po.Id, poMap);

        Test.stopTest();
    }

    @isTest
    static void selectPartsOrderTest() {
        Test.startTest();

        PartsOrder__c po = TestObjectCreator.objPartsOrder;
        insert po;

        PartsOrderItem__c poi = TestObjectCreator.objPartsOrderItem;
        insert poi;

        TYM_PartsOrderCloneController.selectPartsOrder(po.Id);

        Test.stopTest();
    }
}