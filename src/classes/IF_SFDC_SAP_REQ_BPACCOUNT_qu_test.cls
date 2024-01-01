/*
 * File Name         : IF_SFDC_SAP_REQ_BPACCOUNT_qu_test
 * Author            : seungyeon.kang
 * Date              : 2023-12-19
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_BPACCOUNT_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-12-19       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_BPACCOUNT_qu_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPACCOUNT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBusinessPartner/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Account objAccount = new Account();
        objAccount.Name = 'Test Dealership';
        objAccount.LaborRate__c = 0.1;
        objAccount.Phone = '010-1234-1234';
        objAccount.Email__c = 'TestDealership@tymusa.com';
        objAccount.Active__c = 'Active';
        objAccount.BPCode__c = '00000000011';
        insert objAccount;

        Contact objContact = new Contact();
        objContact.LastName = 'Test Contact';
        objContact.ExternalId__c = '00000000011';
        objContact.UserStatus__c = 'Active';
        objContact.AccountId = objAccount.Id;
        insert objContact;

        PriceList__c objPriceList = new PriceList__c();
        objPriceList.Name = 'Test Price List';
        objPriceList.ExternalId__c = '7';
        objPriceList.Factor__c = 2;
        objPriceList.IsActive__c = true;
        insert objPriceList;


        Address__c addressBill = new Address__c();
        addressBill.Name = 'new addressBill';
        addressBill.ExternalId__c = '00000000011';
        addressBill.Dealership__c = objAccount.Id;
        addressBill.BillorShip__c = 'Billing Address';
        insert addressBill;

        Address__c addressShip = new Address__c();
        addressShip.Name = 'new addressShip';
        addressShip.ExternalId__c = '00000000011';
        addressShip.Dealership__c = objAccount.Id;
        addressShip.BillorShip__c = 'Shipping address';
        insert addressShip;

        IF_SFDC_SAP_REG_BPACCOUNT_qu.BPMaster testBPMaster = new  IF_SFDC_SAP_REG_BPACCOUNT_qu.BPMaster();
        testBPMaster.BPCode = 'TestBPCode';
        testBPMaster.Dealership = 'TestDealership';
        testBPMaster.PhoneNumber = 'TestPhoneNumber';

        String strDeal = addressBill.ExternalId__c;
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strDeal));
        Test.startTest();
        try {
            System.enqueueJob(new IF_SFDC_SAP_REQ_BPACCOUNT_qu('all', 1000, 0));
        } catch (Exception e) {
            System.assertEquals('ExpectedErrorMessage', e.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        private String strDeal;

    public HttpCalloutSuccessMock(String strId) {
            this.strDeal = strId;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            String responseBody = '{'+
                    '"responseCode": "S",'+
                    '"ErrorMessage": "Success.",'+
                    '"isContinue": "N",'+
                    '"customerList": ['+
                    '{'+
                    '"BPCode": "00000000011",'+
                    '"Dealership": "' + strDeal + '",'+
                    '"PhoneNumber": "",'+
                    '"PriceList": "7",'+
                    '"BPAddrress": ['+
                    '{'+
                    '"ParentKey": "000000000",'+
                    '"LineNum": "11",'+
                    '"AddressName": "",'+
                    '"Street": "",'+
                    '"ZipCode": "",'+
                    '"City": "",'+
                    '"Country": "",'+
                    '"State": "",'+
                    '"AddressType": "B"'+
                    '}'+
                    '],'+
                    '"ContactPerson": ['+
                    '{'+
                    '"ParentKey": "000000000",'+
                    '"LineNum": "11",'+
                    '"FirstName": "",'+
                    '"MiddleName": "",'+
                    '"LastName": "",'+
                    '"Phone": "",'+
                    '"MobilePhone": "",'+
                    '"Email": "",'+
                    '"Gender": "",'+
                    '"Active": "",'+
                    '"Address": "",'+
                    '"ContactId": ""'+
                    '}'+
                    ']'+
                    '}'+
                    ']'+
                    '}';

            response.setBody(responseBody);
            return response;
        }
    }
}