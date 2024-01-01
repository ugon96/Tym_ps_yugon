/**
 * Created by nhkim on 2023-12-10.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_AR_qu_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_AR', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetInvoice/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        Test.startTest();
        System.enqueueJob(new IF_SFDC_SAP_REQ_AR_qu('all', 500, 0));
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","ARInvoices": [{"ARInvoiceLines": [{"SFDCKey":""}],"Billtoaddress": "","DealerCode": "100241","DeliveryDate": "7/17/2008 12:00:00 AM","Discount": 1132.61,"DueDate": "7/17/2008 12:00:00 AM","Freight": 0,"InvoiceNumber": "5275","OrderDate": "7/17/2008 12:00:00 AM","PartialDelievery": "Y","Paymentterm": "1","PostingDate": "7/17/2008 12:00:00 AM","Remarks": "Do not charge frt. S/have gone on truck w/ tractors. Tractors shipped from CA","SFDCKey": "","SFDCOrderType": "","SalesOrderNumber": "","Salesperson": "-1","Shipdate": "7/17/2008 12:00:00 AM","Shipfrom": "1","Shippingnumber": "","Shiptoaddress": "","Shipvia": "12","Total": 0,"Trackingnumber": ""}]}');
            return response;
        }
    }
}