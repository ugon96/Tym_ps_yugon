/**
 * Created by DAEU on 2023-11-20.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_TEST {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPADDRESS',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPAddress/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');


        Account objAccount = DN_TestUtil.createAccount();
        objAccount.BPCode__c = '000000';  //ParentKey 랑 동일하게
        TestObjectCreator.objAccount = objAccount;
        insert TestObjectCreator.objAddress;
    }
    private static HTTPResponse response(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        String responseBody = '{' +
                '"ErrorMessage": "Success.",' +
                '"ResponseCode": "S",' +
                '"addressList": [' +
                '{' +
                '"AddressName": "test",' +
                '"AddressType": "B",' +
                '"City": "Huntsville",' +
                '"Country": "US",' +
                '"LineNum": 0,' +
                '"ParentKey": "000000",' +
                '"State": "MO",' +
                '"Street": "8113 Hwy 24 West",' +
                '"ZipCode": "65259"' +
                '}' +
                ']' +
                '}';
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

    @IsTest
    static void doTest() {
        Test.startTest();


        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.Queueable job = new IF_SFDC_SAP_REQ_BPADDRESS('new');
        System.enqueueJob(job);


        Test.stopTest();
    }
//    @IsTest
//    static void doIF_SFDC_SAP_REQ_BPADDRESS() {
//        Test.startTest();
//
//        IFUtilMock mock = new IFUtilMock();
//
////        HttpCalloutSuccessMock successMock = new HttpCalloutSuccessMock();
////        HttpResponse mockResponse = successMock.respond(new HttpRequest());
//        Test.setMock(HttpCalloutMock.class, mock);
//
//        System.Queueable job = new IF_SFDC_SAP_REQ_BPADDRESS('new');
//        System.enqueueJob(job);
//
//        Test.stopTest();
//    }
}