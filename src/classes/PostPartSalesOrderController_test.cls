/**
 * Created by 천유정 on 2023-12-26.
 */

@IsTest
private class PostPartSalesOrderController_test {
    @IsTest
    static void PostPartSalesOrderController_test() {
        test.startTest();
        PartsOrder__c objPartsOrder = TestObjectCreator.objPartsOrder;
        objPartsOrder.OrderType__c = 'Level 3 Stock order';
        objPartsOrder.Discount__c = 'Within 7 Days';
        insert objPartsOrder;

        PartsHierarchy__c objPartsHierarchy = TestObjectCreator.objPartsHierarchy;
        insert objPartsHierarchy;

        PriceListEntry__c objPriceListEntry = TestObjectCreator.objPriceListEntry;
        insert objPriceListEntry;

        List<PartsOrderItem__c> listInsertItem = new List<PartsOrderItem__c>();
        List<PartsOrderItem__c> listDeleteItem = new List<PartsOrderItem__c>();

        PartsOrderItem__c objPartsOrderItem1 = new PartsOrderItem__c();
        objPartsOrderItem1.PartsOrderId__c = objPartsOrder.Id;
        objPartsOrderItem1.Quantity__c = 1;
        objPartsOrderItem1.Price__c = 1;
        insert objPartsOrderItem1;
        listDeleteItem.add(objPartsOrderItem1);

        PartsOrderItem__c objPartsOrderItem2 = new PartsOrderItem__c();
        objPartsOrderItem2.PartsOrderId__c = objPartsOrder.Id;
        objPartsOrderItem2.Quantity__c = 1;
        objPartsOrderItem2.Price__c = 1;
        listInsertItem.add(objPartsOrderItem2);

        PostPartSalesOrderController.sendSAP(objPartsOrder.Id);


        test.stopTest();
    }
}