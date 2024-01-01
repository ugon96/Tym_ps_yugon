/*
 * File Name   		: IF_SFDC_SAP_REQ_ITEM_sc_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-12-05
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_ITEM_sc 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-05       taekyun.yoon        Initial Version
*/

@IsTest
private class IF_SFDC_SAP_REQ_ITEM_sc_test {

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


        IF_SFDC_SAP_REQ_ITEM_sc sc = new IF_SFDC_SAP_REQ_ITEM_sc();
        String sch = '0 0 0 * * ?';
        String jobID = system.schedule('Item upsert job 00:00 every day', sch, sc);

        Test.stopTest();
    }

}