/**
 * Created by DAEU on 2023-12-04 (004).
 */

@IsTest
public with sharing class IF_SFDC_SAP_REG_ORDER_PARTS_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REG_ORDER_PARTS',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/PostPartsSalesOrder',
                'POST');

        Account objAccount = new Account();
        objAccount.Name = 'Test Dealership';
        objAccount.LaborRate__c = 0.1;
        objAccount.Phone = '010-1234-1234';
        objAccount.Email__c = 'TestDealership@tymusa.com';
        objAccount.Active__c = 'Active';
        objAccount.BPCode__c = '000000000';
        insert objAccount;
    }

    private static HttpResponse response(Integer statusCode){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        String responseBody = '{' +
                '"ResponseCode": "S",' +
                '"ErrorMessage": "Success.",' +
                '"ErrorList": [' +
                '{' + '}' + ']' +
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


        Account objAccount = new Account();
        objAccount.Name = 'Test Dealership';
        objAccount.LaborRate__c = 0.1;
        objAccount.Phone = '010-1234-1234';
        objAccount.Email__c = 'TestDealership@tymusa.com';
        objAccount.Active__c = 'Active';
        objAccount.BPCode__c = '000000000';
        insert objAccount;

        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product 2';
        objProduct.ExternalId__c = 'a1s2d3d4';
        insert objProduct;



        PartsOrder__c objPartsOrder = new PartsOrder__c();
        objPartsOrder.DealershipId__c = objAccount.Id;
        objPartsOrder.OrderType__c = 'Daily';
        objPartsOrder.PartialShipment__c = 'Allowed';
        objPartsOrder.ShippingMode__c = 'Truck';
        objPartsOrder.Status__c = 'Created';
        insert objPartsOrder;

        PartsOrderItem__c objPartsOrderItem = new PartsOrderItem__c();
        objPartsOrderItem.Quantity__c = 50;
        objPartsOrderItem.PartsOrderId__c = objPartsOrder.Id;
        insert objPartsOrderItem;

        List<PartsOrderItem__c> listPartsOrderItem = new List<PartsOrderItem__c>();
        listPartsOrderItem.add(objPartsOrderItem);

        objPartsOrder.PartsOrderItem__r.add(objPartsOrderItem);

        List<PartsOrder__c> listPartsOrder = new List<PartsOrder__c>();
        listPartsOrder.add(objPartsOrder);

        IF_SFDC_SAP_REG_ORDER_PARTS ifSfdcSapRegOrderParts = new IF_SFDC_SAP_REG_ORDER_PARTS(listPartsOrder, listPartsOrderItem);
        ifSfdcSapRegOrderParts.execute();


        Test.stopTest();
    }
}