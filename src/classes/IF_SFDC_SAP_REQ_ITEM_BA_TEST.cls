/**
 * Created by DAEU on 2023-12-05 (005).
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ITEM_BA_TEST {
    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_ITEM',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetItem/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.ProductCode = '0000-0001';
        insert objProduct;
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
                '"Tier": "",' +
                '"Weight": 0' +
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

        IF_SFDC_SAP_REQ_ITEM_BA ba = new IF_SFDC_SAP_REQ_ITEM_BA();
        Database.executeBatch(ba, 100);

        Test.stopTest();
    }
}