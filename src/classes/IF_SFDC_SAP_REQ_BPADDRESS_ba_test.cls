/**
 * Created by DAEU on 2023-12-01 (001).
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_ba_test {
    @TestSetup
    static void setData() {

        Address__c objAddress = new Address__c();
        objAddress.Address__City__s = 'Atlanta';
        objAddress.Name = 'test';
        insert objAddress;

//        IF_SFDC_SAP_REQ_BPADDRESS_qu_test
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPADDRESS_qu',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPAddress/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');
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
    public static void doTest() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        IF_SFDC_SAP_REQ_BPADDRESS_ba ba = new IF_SFDC_SAP_REQ_BPADDRESS_ba();
        Database.executeBatch(ba, 100);

        Test.stopTest();
    }

}