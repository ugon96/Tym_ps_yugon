/**
 * Created by 천유정 on 2023-12-26.
 */

@isTest
public with sharing class IFUtil_test {
    @testSetup
    static void setData() {

        Set<String> setIFId = new Set<String>{'IF_HOME_TEST', 'IF_NAVER_TEST'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
    }

    @isTest
    static void itShould() {
        Test.startTest();

        System.debug(IFUtil.getToday('yyyy-MM-dd'));
        System.debug(IFUtil.getToday('yyyy-MM-dd', 1));
        System.debug(IFUtil.getLastLogDate('test'));
        System.debug(IFUtil.conversionDate('20210101'));

        String str = 'Test';
        String strEnc = IFUtil.setEncrypt(str);

        System.debug(IFUtil.setEncrypt(str));
        System.debug(IFUtil.setDecrypt(strEnc));
        System.debug(IFUtil.getRandomNumber());

        LogWrapper LogWrapper = new LogWrapper();

        LogWrapper.status = 'SUCCESS';
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestHeader = 'test';
        LogWrapper.requestBody = 'test';
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseHeader = 'test';
        LogWrapper.responseBody = 'test';
        LogWrapper.errorCode = 'E';

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');
        clsIF.setLog(LogWrapper);
    }

    @isTest
    static void testSyncSAPSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAP());

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, false);
    }

    @isTest
    static void testSyncSAPError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAPError());

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, false);
    }

    @isTest
    static void testSyncOtherSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOther());

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, false);
    }

    @isTest
    static void testSyncOtherError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOtherError());

        IFUtil clsIF = new IFUtil('IF_HOME_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, false);
    }

    @isTest
    static void testASyncSAPSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAP());

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_HOME_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest
    static void testASyncSAPError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockSAPError());

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_HOME_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest
    static void testASyncOtherSuccess() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOther());

        IFUtil clsIF = new IFUtil('IF_NAVER_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, true);

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_NAVER_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    @isTest
    static void testASyncOtherError() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockOtherError());

        IFUtil clsIF = new IFUtil('IF_NAVER_TEST');

        String strBody = '{"Test":"Test"}';

        clsIF.webCallout(strBody, true);

        String strJsonBody = '';

        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, Object> mapData = new Map<String, Object>();

        mapBody.put('Test', 'Test');

        mapData.put('if_id', 'IF_NAVER_TEST');
        mapData.put('body', mapBody);

        IFUtil.webCalloutFuture(JSON.serialize(mapData));

        Test.stopTest();
    }

    private class HttpCalloutSuccessMockSAP implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseSAP(200);

            return response;
        }
    }

    private static HTTPResponse newResponseSAP(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"resultCode":"0000", "resultMessage":"Test"}');

        return response;
    }

    private class HttpCalloutSuccessMockSAPError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseErrorSAP(200);

            return response;
        }
    }

    private static HTTPResponse newResponseErrorSAP(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"resultCode":"-1", "resultMessage":"Error Test"}');

        return response;
    }

    private class HttpCalloutSuccessMockOther implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseOther(200);

            return response;
        }
    }

    private static HTTPResponse newResponseOther(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"data":{"ES_RESULT":{"CODE":"0","MESSAGE":"Success"}}}');

        return response;
    }

    private class HttpCalloutSuccessMockOtherError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseErrorOther(200);

            return response;
        }
    }

    private static HTTPResponse newResponseErrorOther(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"data":{"ES_RESULT":{"CODE":"-1","MESSAGE":"Error"}}}');

        return response;
    }
}