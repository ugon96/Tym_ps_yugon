/**
 * Created by nhkim on 2023-12-07.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_CONTACT_sc_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_CONTACT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPContactPerson/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        String cronExpr = '0 0 * * * ?';
        Test.startTest();
        IF_SFDC_SAP_REQ_CONTACT_sc contactSc = new IF_SFDC_SAP_REQ_CONTACT_sc();
        System.schedule('getContact',cronExpr,contactSc);
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","contactList":[{"ParentKey":"","LineNum":"","FirstName":"","MiddleName":"","LastName":"","Phone":"","MobilePhone":"","Email":"","Gender":"F","Active":"","Address":"","ContactId":""}]}');
            return response;
        }
    }
}