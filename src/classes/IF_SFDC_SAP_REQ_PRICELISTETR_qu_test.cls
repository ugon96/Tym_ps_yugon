/*
 * File Name         : IF_SFDC_SAP_REQ_PRICELISTR_qu_test
 * Author            : seungyeon.kang
 * Date              : 2023-11-30
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_PRICELISTR_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_qu_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster(
                'IF_SFDC_SAP_REQ_PRICELISTETR',
                'http://',
                'GET'
        );
        PriceList__c objProduct2s = new PriceList__c();
        objProduct2s.ExternalId__c = 'SamplePriceList';
        insert objProduct2s;

        Product2 objProduct2 = TestObjectCreator.objProductTractor;
        insert objProduct2;
    }

    private static HttpResponse response(Integer statusCode, String responseBody) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Provide valid data for PriceListEntryList in the mock response
            String mockResponse = '{"ResponseCode":"200", "ErrorMessage": "", "PriceListEntryList": [{"PriceList": "SamplePriceList", "ItemCode": "objProductTractor", "Price": 100.0, "inputCurrency": "USD"}], "isContinue": "true"}';
            return response(200, mockResponse);
        }
    }

    private class HttpCalloutFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Provide a mock response for failure
            String mockResponse = '{"ResponseCode":"404", "ErrorMessage": "Not Found", "PriceListEntryList": null, "isContinue": "false"}';
            return response(404, mockResponse);
        }
    }

    @IsTest
    static void testExecuteMethod() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.Queueable job1 = new IF_SFDC_SAP_REQ_PRICELISTETR_qu('SamplePriceList', 1000, 0);
        System.Queueable job2 = new IF_SFDC_SAP_REQ_PRICELISTETR_qu('SamplePriceList', 1000,0,'0000','item','item1');
        System.Queueable job3 = new IF_SFDC_SAP_REQ_PRICELISTETR_qu('SamplePriceList', 1000);

        System.enqueueJob(job2);

        Test.stopTest();
    }


    @IsTest
    static void testExecuteMethodFailure() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailMock());

        System.Queueable job = new IF_SFDC_SAP_REQ_PRICELISTETR_qu('SamplePriceList', 1000, 0);

        System.enqueueJob(job);

        Test.stopTest();
    }
}