/**
 * Created by nhkim on 2023-12-08.
 */

@IsTest
public with sharing class PostSalesOrderButtonController_test {
    @IsTest
    static void testAll() {
        Orders__c order = TestObjectCreator.objOrders;
        insert order;

        ProductOrderSummary__c pos = TestObjectCreator.objProductOrderSummary;
//        pos.IsAssembeld__c = true;
        insert pos;

        List<Product2> listProducts = new List<Product2>();
        Product2 finishedGoods = new Product2();
        finishedGoods.Name = 'Test Product';
        finishedGoods.ProductCode = 'test';
        finishedGoods.ItemGroupCode__c = '101';
        finishedGoods.IsActive = true;
        finishedGoods.LP__c = true;
        finishedGoods.ProductName__c = 'tractor loader backhoe frontTire rearTire';

        listProducts.add(finishedGoods);

        Product2 tractor = new Product2();
        tractor.Name = 'Test Product';
        tractor.ProductCode = 'test';
        tractor.ItemGroupCode__c = '112';
        tractor.IsActive = true;
        tractor.LP__c = true;
        tractor.ProductName__c = 'tractor';

        listProducts.add(tractor);

        Product2 loader = tractor.clone();
        loader.ItemGroupCode__c = '113';
        loader.ProductName__c = 'loader';

        listProducts.add(loader);

        Product2 backhoe = loader.clone();
        backhoe.ItemGroupCode__c = '114';
        backhoe.ProductName__c = 'backhoe';

        listProducts.add(backhoe);

        Product2 fTire = backhoe.clone();
        fTire.ItemGroupCode__c = '115';
        fTire.ProductName__c = 'frontTire';

        listProducts.add(fTire);

        Product2 rTire = fTire.clone();
        rTire.ItemGroupCode__c = '116';
        rTire.ProductName__c = 'rearTire';

        listProducts.add(rTire);

        System.debug(listProducts);
        insert listProducts;

        List<ProductOrderItem__c> listProductOrderItems = new List<ProductOrderItem__c>();
        ProductOrderItem__c poiTractor = new ProductOrderItem__c();
        poiTractor.OrdersId__c = order.Id;
        poiTractor.ProductOrderSummary__c = pos.Id;
        poiTractor.Quantity__c = 1;
        poiTractor.Price__c = 1.0;
        poiTractor.Type__c = 'Tractor';
        poiTractor.ProductId__c = tractor.Id;
        poiTractor.IsAssembled__c = true;

        listProductOrderItems.add(poiTractor);

        ProductOrderItem__c poiLoader = new ProductOrderItem__c();
        poiLoader.OrdersId__c = order.Id;
        poiLoader.ProductOrderSummary__c = pos.Id;
        poiLoader.Quantity__c = 1;
        poiLoader.Price__c = 1.0;
        poiLoader.Type__c = 'Loader';
        poiLoader.ProductId__c = loader.Id;
        poiLoader.IsAssembled__c = true;

        listProductOrderItems.add(poiLoader);

        ProductOrderItem__c poiBackhoe = poiLoader.clone();
        poiBackhoe.Type__c = 'Backhoe';
        poiBackhoe.ProductId__c = backhoe.Id;

        listProductOrderItems.add(poiBackhoe);

        ProductOrderItem__c poiFTire = poiBackhoe.clone();
        poiFTire.Type__c = 'F-Tire';
        poiFTire.ProductId__c = fTire.Id;

        listProductOrderItems.add(poiFTire);

        ProductOrderItem__c poiRTire = poiFTire.clone();
        poiRTire.Type__c = 'R-Tire';
        poiRTire.ProductId__c = rTire.Id;

        listProductOrderItems.add(poiRTire);

        insert listProductOrderItems;

        Test.startTest();
        PostSalesOrderButtonController.doPost(order.Id);
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","ErrorList":null}');
            return response;
        }
    }
}