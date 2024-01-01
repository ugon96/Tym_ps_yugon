/**
 * Created by nhkim on 2023-11-30.
 */

public with sharing class IF_SFDC_SAP_REQ_AR_ba implements Database.Batchable<IF_SFDC_SAP_REQ_AR.ARInvoice>, Database.Stateful {
    public List<IF_SFDC_SAP_REQ_AR.ARInvoice> listARData;

    public IF_SFDC_SAP_REQ_AR_ba() {
        IF_SFDC_SAP_REQ_AR ar = new IF_SFDC_SAP_REQ_AR('120079', 10000);
        //listARData = ar.executeCall();
    }

    public List<IF_SFDC_SAP_REQ_AR.ARInvoice> start(Database.BatchableContext context) {
        return listARData;
    }

    public void execute(Database.BatchableContext context, List<IF_SFDC_SAP_REQ_AR.ARInvoice> scope) {
        List<String> listBpCode = new List<String>();
        List<ARInvoice__c> listARInvoices = new List<ARInvoice__c>();
        List<ARInvoiceItem__c> listARInvoiceItems = new List<ARInvoiceItem__c>();

        for (IF_SFDC_SAP_REQ_AR.ARInvoice ar : scope) {
            listBpCode.add(ar.DealerCode);
        }

        Map<String, String> mapBPCodeToDealershipId = new Map<String, String>();
        for (Account acc : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c =: listBpCode LIMIT 50000]) {
            mapBPCodeToDealershipId.put(acc.BPCode__c, acc.Id);
        }

        Map<String, String> mapExternalIdToContact = new Map<String, String>();
        for (Contact cont : [SELECT Id, ExternalId__c FROM Contact WHERE Account.BPCode__c =: listBpCode LIMIT 50000]) {
            mapExternalIdToContact.put(cont.ExternalId__c, cont.Id);
        }

        for (IF_SFDC_SAP_REQ_AR.ARInvoice ar : scope) {
            ARInvoice__c thisARInvoice = new ARInvoice__c();
            thisARInvoice.ExternalId__c = ar.InvoiceNumber;
            // Bill to Address, Ship to Address, Payment Term은 포뮬러 필드
            thisARInvoice.Id = ar.SFDCKey == '' ? null : ar.SFDCKey;
            thisARInvoice.OrdersId__c = ar.SalesOrderNumber == '' ? null : ar.SalesOrderNumber;
            thisARInvoice.Postingdate__c = thisARInvoice.Postingdate__c == null ? IF_SFDC_SAP_REQ_AR.convertStringToDate(ar.PostingDate) : null;
            thisARInvoice.Duedate__c = thisARInvoice.Duedate__c == null ? IF_SFDC_SAP_REQ_AR.convertStringToDate(ar.DueDate) : null;
            thisARInvoice.OrderDate__c = thisARInvoice.OrderDate__c == null ? IF_SFDC_SAP_REQ_AR.convertStringToDate(ar.OrderDate) : null;
            thisARInvoice.Dealership__c = mapBPCodeToDealershipId.get(ar.DealerCode);
            thisARInvoice.ContactId__c = ar.Salesperson == '' ? null : mapExternalIdToContact.get(ar.DealerCode + ar.Salesperson);
            thisARInvoice.ShipVia__c = ar.Shipvia;
            thisARInvoice.ShippingNumber__c = ar.Shippingnumber;
            thisARInvoice.ShipDate__c = thisARInvoice.ShipDate__c == null ? IF_SFDC_SAP_REQ_AR.convertStringToDate(ar.Shipdate) : null;
            thisARInvoice.ShipFrom__c = ar.Shipfrom;
            thisARInvoice.Discount__c = ar.Discount;
            thisARInvoice.Freight__c = ar.Freight;
            thisARInvoice.Total__c = ar.Total;
            thisARInvoice.Remarks__c = ar.Remarks;
            if (ar.ARInvoiceLines != null) {
                for (IF_SFDC_SAP_REQ_AR.ARInvoiceLines arl : ar.ARInvoiceLines) {
                    ARInvoiceItem__c avi = new ARInvoiceItem__c();
                    avi.ARInvoiceMaster__c = ar.SFDCKey == '' ? null : ar.SFDCKey;
                    avi.UnitPrice__c = arl.UnitPrice;
                    // quantity가 string으로 정의되어 있음
                    avi.Quantity__c = arl.Quantity;
                    avi.Total__c = arl.TotalPrice;
                    avi.Subtotal__c = arl.SubTotal;
                    avi.Description__c = arl.Description;
                    if (arl.ItemGroupCode != '101') {
                        avi.SerialNumber__c = arl.SerialNumber;
                    }
                    else {
                        List<String> finishedGoods = arl.SerialNumber.split('_');
                    }
                    listARInvoiceItems.add(avi);
                }
            }
            listARInvoices.add(thisARInvoice);
        }

        List<Database.SaveResult> listDmlResult = Database.insert(listARInvoices, false);
        List<Database.SaveResult> listInsertResult = Database.insert(listARInvoiceItems, false);
    }

    public void finish(Database.BatchableContext context) {

    }
}