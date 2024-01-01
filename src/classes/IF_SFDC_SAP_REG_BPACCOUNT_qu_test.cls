/**
 * Created by nhkim on 2023-12-09.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REG_BPACCOUNT_qu_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_BPACCOUNT', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetBusinessPartner/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        ifMaster.IsSendParameter__c = true;
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        System.enqueueJob(new IF_SFDC_SAP_REG_BPACCOUNT_qu('all', 0));
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
//            response.setBody('{"responseCode":"S","ErrorMessage":"","isContinue":"N","customerList":[{"BPCode":"","Dealership":"","PhoneNumber":"","BPAddress":[{"ParentKey":"","LineNum":"","AddressName":"","Street":"","ZipCode":"","City":"","Country":"","State":"","AddressType":"B"}],"ContactPerson":[{"ParentKey":"","LineNum":"","FirstName":"","MiddleName":"","LastName":"","Phone":"","MobilePhone":"","Email":"","Gender":"","Active":"","Address":"","ContactId":""}],"PaymentTerm":"","PriceList":"","IsActive":"","TerritoryManager":"","WebsiteAddress":"","FederalTaxID":"","LaborRate":"","Remarks":"","Email":"","Mobile":"","Fax":""}]}');
            response.setBody('{"responseCode":"S","ErrorMessage":"","isContinue":"N","customerList":[{"BPCode":"","Dealership":"","PhoneNumber":"","BPAddrress":[{"ParentKey":"","LineNum":"","AddressName":"","Street":"","ZipCode":"","City":"","Country":"","State":"","AddressType":"B"}],"ContactPerson":[{"ParentKey":"","LineNum":"","FirstName":"","MiddleName":"","LastName":"","Phone":"","MobilePhone":"","Email":"","Gender":"","Active":"","Address":"","ContactId":""}]}]}');
            return response;
        }
    }
}