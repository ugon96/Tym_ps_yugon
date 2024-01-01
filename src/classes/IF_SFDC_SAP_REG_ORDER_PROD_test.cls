/*
 * File Name   		: IF_SFDC_SAP_REG_ORDER_PROD_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-12-26
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REG_ORDER_PROD 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-26       taekyun.yoon           Initial Version
**/

@IsTest
public with sharing class IF_SFDC_SAP_REG_ORDER_PROD_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REG_ORDER_PROD',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/PostSalesOrder/',
                'POST');

    }

    private static HTTPResponse response(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);

        String responseBody = '{' +
                '"ResponseCode": "S",' +
                '"ErrorMessage": "Success.",' +
                '"ErrorList": ["test", "test1"]' +
                '}';
//        String responseBody = '{"ResponseCode : "S", "ErrorMessage" : "Success.", "ErrorList" : ["testString", "testStringtwo"] }';

        res.setBody(responseBody);

        return res;
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = response(200);
            return res;
        }
    }
    private class HttpCalloutFailMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = response(404);
            return res;
        }
    }

//    @IsTest
//    static void doTest() {
//        Test.startTest();
//
//        Orders__c objOrder = TestObjectCreator.objOrders;
//        ProductOrderSummary__c objProductOrderSummary = TestObjectCreator.objProductOrderSummary;
//
//        ProductOrderItem__c objProductOrderItem = TestObjectCreator.objProductOrderItem;
//        insert objProductOrderItem;
//
//        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
//
//        IF_SFDC_SAP_REG_ORDER_PROD ifSfdcSapRegOrderProd = new IF_SFDC_SAP_REG_ORDER_PROD (objOrder, objProductOrderSummary);
//        ifSfdcSapRegOrderProd.executeCall();
//
//        Test.stopTest();
//    }
    @IsTest
    static void testExecuteCall_FinishedGoodsCodeNull() {

        Orders__c objOrder = TestObjectCreator.objOrders;
        ProductOrderSummary__c objProductOrderSummary = TestObjectCreator.objProductOrderSummary;
        objProductOrderSummary.FinishedGoodsCode__r = null;
        insert objProductOrderSummary;
        ProductOrderItem__c objProductOrderItem = TestObjectCreator.objProductOrderItem;
        insert objProductOrderItem;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.debug('testExecuteCall_FinishedGoodsCodeNull');
        IF_SFDC_SAP_REG_ORDER_PROD ifSfdcSapRegOrderProd = new IF_SFDC_SAP_REG_ORDER_PROD (objOrder, objProductOrderSummary);
        IF_SFDC_SAP_REG_ORDER_PROD ifSfdcSapRegOrderProdtest = new IF_SFDC_SAP_REG_ORDER_PROD ();
        ifSfdcSapRegOrderProd.executeCall();


        Test.stopTest();
    }

    @IsTest
    static void testExecuteCall_FinishedGoodsCodeNotNull() {

        Orders__c objOrder = TestObjectCreator.objOrders;
        ProductOrderSummary__c objProductOrderSummary = TestObjectCreator.objProductOrderSummary;
        insert TestObjectCreator.objProductTractor;
        objProductOrderSummary.FinishedGoodsCode__c = TestObjectCreator.objProductTractor.Id;
        insert objProductOrderSummary;

        ProductOrderItem__c objProductOrderItem = TestObjectCreator.objProductOrderItem;
        insert objProductOrderItem;


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.debug('testExecuteCall_FinishedGoodsCodeNotNull');
        IF_SFDC_SAP_REG_ORDER_PROD ifSfdcSapRegOrderProd = new IF_SFDC_SAP_REG_ORDER_PROD (objOrder, objProductOrderSummary);
        ifSfdcSapRegOrderProd.executeCall();

        Test.stopTest();

    }
    @IsTest
    static void testExecuteCall_objProductOrderSummaryNull() {

        Orders__c objOrder = TestObjectCreator.objOrders;

        ProductOrderItem__c objProductOrderItem = TestObjectCreator.objProductOrderItem;
        insert objProductOrderItem;


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.debug('testExecuteCall_objProductOrderSummaryNull');
        IF_SFDC_SAP_REG_ORDER_PROD ifSfdcSapRegOrderProd = new IF_SFDC_SAP_REG_ORDER_PROD (objOrder);
        ifSfdcSapRegOrderProd.executeCall();

        Test.stopTest();

    }
}