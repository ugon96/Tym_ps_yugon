/*
 * File Name   		: IF_SFDC_SAP_REQ_BPADDRESS_sc_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-12-01
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_BPADDRESS_sc 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-01       taekyun.yoon           Initial Version
**/

@IsTest
private class IF_SFDC_SAP_REQ_BPADDRESS_sc_test {
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

        IF_SFDC_SAP_REQ_BPADDRESS_sc sc = new IF_SFDC_SAP_REQ_BPADDRESS_sc();
        String sch = '0 1 * * * ?';
        String jobID = system.schedule('Address update job every 1 min', sch, sc);
        System.debug(jobID);


        Test.stopTest();
    }

}