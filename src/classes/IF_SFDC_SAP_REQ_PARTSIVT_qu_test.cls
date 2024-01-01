/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_PARTSIVT_qu_test
 * Author	  		: sy.Kang
 * Date				: 2023-12-20
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_PARTSIVT_qu test class
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-20       sy.Kang                Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PARTSIVT_qu_test {
    @IsTest
    static void testAll() {

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product 2';
        objProduct.ExternalId__c = 'a1s2d3d4';
        insert objProduct;

        String strId = objProduct.ExternalId__c;

        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PARTSIVT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strId));


        Test.startTest();
        System.enqueueJob(new IF_SFDC_SAP_REQ_PARTSIVT_qu('all'));
        System.enqueueJob(new IF_SFDC_SAP_REQ_PARTSIVT_qu('all', 1000));
        System.enqueueJob(new IF_SFDC_SAP_REQ_PARTSIVT_qu('all', 1000, 0));
        Test.stopTest();
    }
    @IsTest
    static void test2All() {

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product 2';
        objProduct.ExternalId__c = 'a1s2d3d4';
        insert objProduct;

        String strId = objProduct.ExternalId__c;

        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PARTSIVT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailMock(strId));


        Test.startTest();
        System.enqueueJob(new IF_SFDC_SAP_REQ_PARTSIVT_qu('all', 1000, 0));
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        private final String strId;

        public HttpCalloutSuccessMock(String strId) {
            this.strId = strId;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","InventoryList":[{"ItemCode":"'+strId+'","onHand":"45"}]}');
            return response;
        }
    }
    private class HttpCalloutFailMock implements HttpCalloutMock {
        private final String strId;

        public HttpCalloutFailMock(String strId) {
            this.strId = strId;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"responseCode":"E","ErrorMessage":"","InventoryList":[{"ItemCode":"'+strId+'","onHand":"45"}]}');
            return response;
        }
    }
}