/**
 * Created by nhkim on 2023-12-07.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_CONTACT_ba_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_CONTACT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBPContactPerson/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        System.enqueueJob(new IF_SFDC_SAP_REQ_CONTACT_qu('all', 500, 0));
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