/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REG_PRICELISTETR_BA_TEST
 * Author	  		: sy.kang@daeunextier.com
 * Date				: 2023-12-05
 * @Group              : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       sy.kang@daeunextier.com        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_ba_test {
    @TestSetup
    static void setData() {

        PriceListEntry__c objPriceListEntry = new PriceListEntry__c();
        objPriceListEntry.ExternalId__c = 'P00117001040110';
        objPriceListEntry.Name = '17001040110';
        objPriceListEntry.PriceListID__c = 'a0H1m000004QO3TEAW';
        insert objPriceListEntry;

//      IF_SFDC_SAP_REQ_PRICELISTETR_qu_test
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PRICELISTETR',
                'https://',
                'GET');
    }
    private static HTTPResponse response(Integer statusCode) {
//        HttpResponse res = new HttpResponse();
//        res.setHeader('Content-Type', 'application/json');
//        res.setStatusCode(statusCode);
//        String responseBody = '{' +
//                '"ErrorMessage": "Success.",' +
//                '"ResponseCode": "S",' +
//                '"PriceListEntryList": [' +
//                '{' +
//                '"PriceList": "test",' +
//                '"ItemCode": "itemcode",' +
//                '"Price": "10000",' +
//                '"CurrencyType": "USD",' +
//                '}' +
//                ']' +
//                '}';
//        res.setBody(responseBody);
//
//        return res;
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        // 테스트에 필요한 가상의 응답 데이터
        res.setBody('{"ResponseCode":"200", "ErrorMessage": "", "PriceListMasterList": [{"PriceList": "SamplePriceList", "ItemCode": "ItemCode", "Price": 100.0, "inputCurrency": "USD"}], "isContinue": "true"}');
        return res;
    }
//    private static HttpResponse response(Integer statusCode) {
//        HttpResponse res = new HttpResponse();
//        res.setHeader('Content-Type', 'application/json');
//        res.setStatusCode(statusCode);
//        // 테스트에 필요한 가상의 응답 데이터
//        res.setBody('{"ResponseCode":"200", "ErrorMessage": "", "PriceListMasterList": [{"PriceList": "SamplePriceList", "ItemCode": "ItemCode", "Price": 100.0, "inputCurrency": "USD"}], "isContinue": "true"}');
//        return res;
//    }

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


    @IsTest
    public static void doTest() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        IF_SFDC_SAP_REQ_PRICELISTETR_ba ba = new IF_SFDC_SAP_REQ_PRICELISTETR_ba();
        Database.executeBatch(ba, 100);

        Test.stopTest();
    }

}