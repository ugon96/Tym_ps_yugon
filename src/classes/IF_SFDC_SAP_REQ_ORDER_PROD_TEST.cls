/*
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PROD_TEST
 * Author           : seungyeon.kang
 * Date            : 2023-12-01
 * @Group           : Daeunextier
 * Description       :
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ORDER_PROD_TEST {
    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster(
                'IF_SFDC_SAP_REQ_ORDER_PROD',
                'http://',
                'GET'
        );

        Account objAccount = DN_TestUtil.createAccount();
        objAccount.BPCode__c = 'BP1';
        TestObjectCreator.objAccount = objAccount;
        insert TestObjectCreator.objAddress;

        Contact objContact = new Contact();
        objContact.LastName = 'test';
        objContact.ExternalId__c = '2104361';
        insert objContact;

        Orders__c objOrder = new Orders__c();
        objOrder.Dealership__c = objAccount.Id;

        Address__c objAddresss = new Address__c();
        objAddresss.Name = 'Daeu';
        objAddresss.ExternalId__c = '2104361';
        insert objAddresss;

        PriceList__c objPriceList = new PriceList__c();
        objPriceList.ExternalId__c = '20';
    }

    private static HttpResponse response(Integer statusCode) {
        List<Contact> objcon = new List<Contact>();
        objcon = [
                SELECT Id, ExternalId__c
                FROM Contact
                LIMIT 1
        ];
        List<Address__c> objadd = new List<Address__c>();
        objadd = [
                SELECT Id,ExternalId__c
                FROM Address__c
                WHERE ExternalId__c = '2104361'
                LIMIT 1
        ];
        System.debug('objadd:'+objadd);
        String ExternalId = objcon[0].ExternalId__c;
        String ExternalIdadd = objadd[0].ExternalId__c;
        System.debug('ExternalIdadd::'+ExternalIdadd);
        System.debug('ExternalId::'+ExternalId);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        // 테스트에 필요한 가상의 응답 데이터
        res.setBody('{"ResponseCode":"200", "ErrorMessage": "", "Orders": [{"SFDCKey": "ID", "SFDCOrderType": "Type1", "SAPOtype": "OType1", "BPCode": "BP1", "ContactPerson": "'+ExternalId+'", "Shipto": "'+ExternalIdadd+'", "Billto": "'+ExternalIdadd+'", "SalesEmployee": "", "PaymentTerm": "", "Remarks": "Remark1", "OrderProducts": [{"SFDCKey": "ID", "ItemCode": "Item1", "UnitPrice": 50.0, "Quantity": 2.0, "DiscountRate": 0.1, "TotalPrice": 90.0}], "Discount": 0.05, "SAPKey": "SAP1", "TotalPrice": 200.0}]}');
        System.debug('res::'+res);

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

        IF_SFDC_SAP_REQ_ORDER_PROD obj = new IF_SFDC_SAP_REQ_ORDER_PROD();
        obj.execute();

        Test.stopTest();
    }
}