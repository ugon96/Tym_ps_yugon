/*************************************************************
 * @author : taekyun.yoon
 * @date : 2023-12-20
 * @group : daeunextier
 * @group-content :
 * @description : ARInvoiceItem_tr 테스트 클래스
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-20      taekyun.yoon         Initial Version
**************************************************************/

@IsTest
public with sharing class ARInvoiceItem_tr_test {
        @IsTest
        static void TestStart(){
                Test.startTest();

                PartsOrderItem__c objPartsOrderItem = TestObjectCreator.objPartsOrderItem;
                insert objPartsOrderItem;

                ARInvoiceItem__c objArInvoiceItem = TestObjectCreator.objARInvoiceItem;
                objArInvoiceItem.PartsOrderItem__c = objPartsOrderItem.Id;
                insert objArInvoiceItem;

                Test.stopTest();
        }

        @IsTest
        static void TestStart2(){
                PartsOrderItem__c objPartsOrderItem = TestObjectCreator.objPartsOrderItem;
                insert objPartsOrderItem;

                ProductOrderItem__c objProductOrderItem = TestObjectCreator.objProductOrderItem;
                objProductOrderItem.Quantity__c = 5;
                insert objProductOrderItem;

                ARInvoiceItem__c objArInvoiceItem = TestObjectCreator.objARInvoiceItem;
                objArInvoiceItem.PartsOrderItem__c = objPartsOrderItem.Id;
                objArInvoiceItem.ProductOrderItem__c = objProductOrderItem.Id;
                insert objArInvoiceItem;

                Test.startTest();
                objArInvoiceItem.Quantity__c = 2;
                update objArInvoiceItem;
                Test.stopTest();
        }



/*        @IsTest
    static void doTest() {
        Test.startTest();

        PartsOrder__c partsOrder = TestObjectCreator.objPartsOrder;
        insert partsOrder;

        System.debug('insert partsOrder');

        PartsOrderItem__c partsOrderItem = TestObjectCreator.objPartsOrderItem;
        partsOrderItem.Quantity__c = 10;
        insert partsOrderItem;

        System.debug('insert partsOrderItem');

        ARInvoice__c arInvoiceParts = TestObjectCreator.objARInvoice;
//        arInvoiceParts.PartsOrderId__c = partsOrder.Id;
        arInvoiceParts.Type__c = 'Part Order';
        insert arInvoiceParts;

        System.debug('insert arInvoiceParts');

        //case: Insert PartsOrderItem
        ARInvoiceItem__c arInvoiceItemParts = new ARInvoiceItem__c();
        arInvoiceItemParts.Type__c = 'Part Order';
        arInvoiceItemParts.CountryOfOrigin__c = 'BuSan';
        arInvoiceItemParts.Model__c = 'model';
        arInvoiceItemParts.Quantity__c = 5;
        arInvoiceItemParts.UnitPrice__c = 5;
        arInvoiceItemParts.Subtotal__c = 5;
        arInvoiceItemParts.Total__c = 5;
        arInvoiceItemParts.Description__c = 'objARInvoiceItem';
        arInvoiceItemParts.ARInvoiceMaster__c = arInvoiceParts.Id;
        arInvoiceItemParts.PartsOrderItem__c = partsOrderItem.Id;
        arInvoiceItemParts.PartsOrderItem__r = partsOrderItem;
        arInvoiceItemParts.Quantity__c = 10;
        insert arInvoiceItemParts;

        System.debug('insert arInvoiceItemParts');

        partsOrderItem.Quantity__c = 15;
        partsOrderItem.Status__c = 'Opened';
        update partsOrderItem;

        System.debug('update partsOrderItem');


        //case: Update PartsOrderItem quantity
        arInvoiceItemParts.Quantity__c = 5;
        update arInvoiceItemParts;

        System.debug('update arInvoiceItemParts');



        Orders__c objProductOrder = TestObjectCreator.objOrders;
        insert objProductOrder;

        ProductOrderItem__c productOrderItem = TestObjectCreator.objProductOrderItem;
        productOrderItem.Quantity__c = 10;
        insert productOrderItem;

        ARInvoice__c arInvoiceProd = TestObjectCreator.objARInvoice;
        arInvoiceProd.Type__c = 'order';
        insert arInvoiceProd;

        ARInvoiceItem__c arInvoiceItemProd = new ARInvoiceItem__c();
        arInvoiceItemProd.Type__c = 'Part Order';
        arInvoiceItemProd.CountryOfOrigin__c = 'BuSan';
        arInvoiceItemProd.Model__c = 'model';
        arInvoiceItemProd.Quantity__c = 5;
        arInvoiceItemProd.UnitPrice__c = 5;
        arInvoiceItemProd.Subtotal__c = 5;
        arInvoiceItemProd.Total__c = 5;
        arInvoiceItemProd.Description__c = 'objARInvoiceItem';
        arInvoiceItemProd.ARInvoiceMaster__c = arInvoiceProd.Id;
        arInvoiceItemProd.ProductOrderItem__c = productOrderItem.Id;
        arInvoiceItemProd.ProductOrderItem__r = productOrderItem;
        arInvoiceItemProd.Quantity__c = null;
        insert arInvoiceItemProd;

        //case: Insert ProductOrder Quantity
        arInvoiceItemProd.Quantity__c = 10;
        update arInvoiceItemProd;

        productOrderItem.Quantity__c = 15;
        productOrderItem.Status__c = 'Opened';
        update productOrderItem;

        //case: Update ProductOrder Quantity
        arInvoiceItemProd.Quantity__c = 15;
        update  arInvoiceItemProd;


        Test.stopTest();
    }*/
}