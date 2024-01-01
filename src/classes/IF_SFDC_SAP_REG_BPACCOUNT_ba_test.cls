/**
 * Created by nhkim on 2023-12-07.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REG_BPACCOUNT_ba_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPACCOUNT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBusinessPartner/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        IF_SFDC_SAP_REG_BPACCOUNT_ba ba = new IF_SFDC_SAP_REG_BPACCOUNT_ba();
        Database.executeBatch(ba, 400);
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","customerList":[{"BPCode":"","Dealership":"","PhoneNumber":"","BPAddress":[{"ParentKey":"","LineNum":"","AddressName":"","Street":"","ZipCode":"","City":"","Country":"","State":"","AddressType":"B"}],"ContactPerson":[{"ParentKey":"","LineNum":"","FirstName":"","MiddleName":"","LastName":"","Phone":"","MobilePhone":"","Email":"","Gender":"","Active":"","Address":"","ContactId":""}],"PaymentTerm":"","PriceList":"","IsActive":"","TerritoryManager":"","WebsiteAddress":"","FederalTaxID":"","LaborRate":"","Remarks":"","Email":"","Mobile":"","Fax":""}]}');
            return response;
        }
    }
}