@IsTest
public with sharing class TYM_ProductsOrderCloneController_test {
    @IsTest
    static void testStart() {
        Test.startTest();

        Map<String, String> productOrderMap = new Map<String, String>();
        productOrderMap.put('poNum', '123');

        Orders__c order = TestObjectCreator.objOrders;
        insert order;

        ARInvoiceItem__c arItem = TestObjectCreator.objARInvoiceItem;
        insert arItem;

        TYM_ProductsOrderCloneController.productsOrderClone(order.Id, productOrderMap);

        Test.stopTest();

    }
}