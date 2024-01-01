/*
 * File Name         : IF_SFDC_SAP_REQ_PRICELISTR_TEST
 * Author           : seungyeon.kang
 * Date            : 2023-11-30
 * @Group           : Daeunextier
 * Description       :
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_TEST {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster(
                'IF_SFDC_SAP_REQ_PRICELISTETR',
                'http://',
                'GET'
        );
    }

    private static HttpResponse response(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        // 테스트에 필요한 가상의 응답 데이터
        res.setBody('{"ResponseCode":"200", "ErrorMessage": "", "PriceListMasterList": [{"PriceList": "SamplePriceList", "ItemCode": "ItemCode", "Price": 100.0, "inputCurrency": "USD"}], "isContinue": "true"}');
        return res;
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = response(200);
            return res;
        }
    }
    private class HttpCalloutFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = response(404);
            return res;
        }
    }
    @IsTest
    static void testExecuteMethod() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        // Given
        String priceList = 'SamplePriceList';
        Integer count = 10;
        String itemGroupCode = 'GroupCode';
        String itemCode = 'ItemCode';
        String inputCurrency = 'USD';

        IF_SFDC_SAP_REQ_PRICELISTETR obj = new IF_SFDC_SAP_REQ_PRICELISTETR(priceList, count, itemGroupCode, itemCode, inputCurrency);

        obj.execute();
        Test.stopTest();
    }

}