/**
 * Created by nhkim on 2023-12-07.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_ba_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PRICELISTMST', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        IF_SFDC_SAP_REQ_PRICELISTMST_ba ba = new IF_SFDC_SAP_REQ_PRICELISTMST_ba();
        Database.executeBatch(ba, 400);
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
}