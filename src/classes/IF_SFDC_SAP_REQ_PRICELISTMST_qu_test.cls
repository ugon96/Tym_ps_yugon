/*
 * File Name         : IF_SFDC_SAP_REQ_PRICELISTMST_qu_test
 * Author            : nhKim
 * Date              : 2023-12-01
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_PRICELISTMST_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-12-01        nhKim                Initial Version
*************************************************************************************/


@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_qu_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PRICELISTMST', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        try {
            System.enqueueJob(new IF_SFDC_SAP_REQ_PRICELISTMST_qu('all', 1000, 0));
        } catch (Exception e) {
            System.assertEquals('ExpectedErrorMessage', e.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }
    @IsTest
    static void testAll2() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PRICELISTMST', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMocker());

        Test.startTest();
        try {
            System.enqueueJob(new IF_SFDC_SAP_REQ_PRICELISTMST_qu('all', 1000, 0));
        } catch (Exception e) {
            System.assertEquals('ExpectedErrorMessage', e.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","PriceListMasterList":[{"PriceList":"4","Name":"test","BasePriceList":"3","Factor":"1"}]}');
            return response;
        }
    }
    private class HttpCalloutSuccessMocker implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            response.setBody('{"responseCode":"E","ErrorMessage":"","PriceListMasterList":[{"PriceList":"4","Name":"test","BasePriceList":"3","Factor":"1"}]}');
            return response;
        }
    }
}