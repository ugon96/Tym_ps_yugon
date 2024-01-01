/*
 * File Name   		: IF_SFDC_SAP_REQ_BPADDRESS_qu_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		: SAP의 Master Data인 Business Partner Address 정보를 SFDC에 Upsert하는 인터페이스 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       taekyun.yoon           Initial Version
**/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_qu_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPADDRESS',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPAddress/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');


        Account objAccount = DN_TestUtil.createAccount();
        objAccount.BPCode__c = '000000';  //response의 ParentKey 랑 동일하게
        insert objAccount;
        insert TestObjectCreator.objAddress;
    }

    private class MultiStaticResourceCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String url = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            //SAP 호출 엔드포인트 설정
            if (url.contains('https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPAddress')) {
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
                res.setStatusCode(200);
            }
            //getCustomFieldID 호출 엔드포인트 설정
            else if (url.contains('https://tym--dev.sandbox.my.salesforce.com/services/data/v59.0/tooling/query')) {
                String responseBody = '{' +
                        '"size": 1,' +
                        '"totalSize": 1,' +
                        '"done": true,' +
                        '"queryLocator": null,' +
                        '"entityTypeName": "GlobalValueSet",' +
                        '"records": [' +
                        '{' +
                        '"attributes": {' +
                        '"type": "GlobalValueSet",' +
                        '"url": "/services/data/v59.0/tooling/sobjects/GlobalValueSet/0Nt1m000000AKWBCA4"' +
                        '},' +
                        '"Id": "0Nt1m000000AKWBCA4",' +
                        '"MasterLabel": "State"' +
                        '}' +
                        ']' +
                        '}';
                res.setBody(responseBody);
                res.setStatusCode(200);
            }
            // tooling API 호출 엔드포인트 설정
            else if (url.contains('https://tym--dev.sandbox.my.salesforce.com/services/data/v59.0/tooling/sobjects/GlobalValueSet')) {
                String responseBody = ' {' +
                        '"attributes":{' +
                        '"type":"GlobalValueSet",' +
                        '"url":"/services/data/v59.0/tooling/sobjects/GlobalValueSet/0Nt1m000000AKWBCA4"' +
                        '},' +
                        '"Metadata":{' +
                        '"customValue":[' +
                        '{"color":null,' +
                        '"default":false,' +
                        '"description":null,' +
                        '"isActive":null,' +
                        '"label":"1",' +
                        '"urls":null,' +
                        '"valueName":"1"' +
                        '},' +
                        '{"color":null,' +
                        '"default":false,' +
                        '"description":null,' +
                        '"isActive":null,' +
                        '"label":"Alberta",' +
                        '"urls":null,' +
                        '"valueName":"AL"' +
                        '}' +
                        '],' +
                        '"description":null,' +
                        '"masterLabel":"State",' +
                        '"sorted":false,' +
                        '"urls":null' +
                        '},' +
                        '"FullName":"State",' +
                        '"Id":"0Nt1m000000AKWBCA4",' +
                        '"DeveloperName":"State",' +
                        '"MasterLabel":"State",' +
                        '"Description":null,' +
                        '"NamespacePrefix":null,' +
                        '"ManageableState":"unmanaged"' +
                        '}';

                res.setBody(responseBody);
                res.setStatusCode(200);
            }

            return res;
        }
    }

    @IsTest
    static void doTest() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MultiStaticResourceCalloutMock());


        System.Queueable job = new IF_SFDC_SAP_REQ_BPADDRESS_qu('new', 1000, 0);
        System.enqueueJob(job);


        Test.stopTest();
    }

}