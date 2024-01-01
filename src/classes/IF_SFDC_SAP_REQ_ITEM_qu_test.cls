/*
 * File Name   		: IF_SFDC_SAP_REQ_ITEM_qu_test
 * Author	  		: taekyun.yoon@daeunextier.com
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_ITEM_qu 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       taekyun.yoon        Initial Version
*/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ITEM_qu_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_ITEM',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetItem/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');
    }
    private static HTTPResponse response(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        String responseBody = '{' +
                '"ErrorMessage": "Success.",' +
                '"ResponseCode": "S",' +
                '"item": [' +
                '{' +
                '"CountryofOrigin": "",' +
                '"Description": "Inside Handle Chrome",' +
                '"IsActive": "Y",' +
                '"ItemCode": "001-101-040",' +
                '"ItemGroupCode": "119",' +
                '"ItemName": "Inside Handle Chrome",' +
                '"LP": "",' +
                '"Model": "",' +
                '"Remarks": "purchase austin hdw part number BP I-8002  CH",' +
                '"Tier": 0,' +
                '"Weight": 0,' +
                '"Series": 0' +
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

        System.Queueable job = new IF_SFDC_SAP_REQ_ITEM_qu('new', 1000,0);
        System.enqueueJob(job);


        Test.stopTest();
    }
}