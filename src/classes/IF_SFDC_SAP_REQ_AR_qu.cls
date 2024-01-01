/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_AR_qu
 * Author	  		: nh.kim@daeunextier.com
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		           Modification
 * 1.0     2023-11-21        nh.kim@daeunextier.com        Initial Version
 * 1.1     2023-12-28        yujeong.chun@daeunextier.com  Update
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_AR_qu implements Queueable, Database.AllowsCallouts {
    private static final String IFID = 'IF_SFDC_SAP_REQ_AR';

    private String BPCode;
    private Integer Count;
    private Integer QueueCount;
    private String jobId;

    public IF_SFDC_SAP_REQ_AR_qu(String bpCode) {
        this.BPCode = bpCode;
    }

    public IF_SFDC_SAP_REQ_AR_qu(String bpCode, Integer count) {
        this.BPCode = bpCode;
        this.Count = count;
    }

    public IF_SFDC_SAP_REQ_AR_qu(String bpCode, Integer count, Integer queueCount) {
        this.BPCode = bpCode;
        this.Count = count;
        this.QueueCount = queueCount;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        List<ARInvoice> ARInvoices;
        String isContinue;
    }

    public class ARInvoice {
        public String InvoiceNumber;
        public String SFDCKey;
        public String SalesOrderNumber;
        public String PostingDate;
        public String DueDate;
        public String OrderDate;
        public String DealerCode;
        public String Billtoaddress;
        public String Shiptoaddress;
        public String SFDCOrderType;
        public String Salesperson;
        public String Shipvia;
        public String Paymentterm;
        public String Shippingnumber;
        public String Shipdate;
        public String Trackingnumber;
        public String Shipfrom;
        public Decimal Discount;
        public Decimal Freight;
        public Decimal Total;
        public String Remarks;
        public String PartialDelievery;
        public String DeliveryDate;
        public List<ARInvoiceLines> ARInvoiceLines;
    }

    public class ARInvoiceLines {
        public String SFDCKey;
        public String ItemCode;
        public String LineNum;
        public String ItemGroupCode;
        public Decimal UnitPrice;
        public Integer Quantity;
        public Decimal TotalPrice;
        public Decimal SubTotal;
        public String Description;
        public String SerialNumber;
        public List<SerialNumber> Data;
    }

    public class SerialNumber {
        public String Tractor;
        public String Loader;
        public String Backhoe;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '여신채권 레코드를 SFDC에 생성';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        Set<String> SetBpCode = new Set<String>();
        Set<String> setInvoiceNumber = new Set<String>();
        Set<String> setItemCode = new Set<String>();
        Set<String> setOrderId = new Set<String>();
        List<ARInvoice__c> listARInvoices = new List<ARInvoice__c>();
        List<ARInvoiceItem__c> listARInvoiceItems = new List<ARInvoiceItem__c>();

        String requestBody = '/' + this.BPCode + '/' + this.Count;
        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        // CARDCD valid check
        if (this.BPCode == null || this.BPCode == '') {
            this.BPCode = 'new';
        }

        try {
            IFUtil objIF = new IFUtil(IFID);

            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();


            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                for (ARInvoice ar : objOutput.ARInvoices) {
                    SetBpCode.add(ar.DealerCode);
                    SetInvoiceNumber.add(ar.InvoiceNumber);
                    setOrderId.add(ar.SFDCKey);
                    if (ar.ARInvoiceLines != null) {
                        for (ARInvoiceLines arl : ar.ARInvoiceLines) {
                            setItemCode.add(arl.ItemCode);
                        }
                    }
                }

                Map<String, String> mapBPCodeToDealershipId = new Map<String, String>();
                for (Account acc : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN: SetBpCode LIMIT 50000]) {
                    mapBPCodeToDealershipId.put(acc.BPCode__c, acc.Id);
                }

                Map<String, String> mapExternalIdToContact = new Map<String, String>();
                for (Contact cont : [SELECT Id, ExternalId__c FROM Contact WHERE Account.BPCode__c IN: SetInvoiceNumber LIMIT 50000]) {
                    mapExternalIdToContact.put(cont.ExternalId__c, cont.Id);
                }

                Map<String, String> mapExternalIdToProduct = new Map<String, String>();
                for (Product2 prod : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN: setItemCode LIMIT 50000]) {
                    mapExternalIdToProduct.put(prod.ExternalId__c, prod.Id);
                }

                // 23.12.28 수정 - A/R Invoice Order의 Parernt Order를 위해 Map 세팅
                Map<String, String> mapExternalIdToParentOrder = new Map<String, String>();
                for (Orders__c objOrder : [SELECT Id, ExternalId__c, ParentOrder__c FROM Orders__c WHERE Id IN: setOrderId LIMIT 50000]) {
                    mapExternalIdToParentOrder.put(objOrder.Id, objOrder.ParentOrder__c);
                }

                for (ARInvoice ar : objOutput.ARInvoices) {
                    ARInvoice__c thisARInvoice = new ARInvoice__c();
                    thisARInvoice.ExternalId__c = ar.InvoiceNumber;
                    if (ar.SFDCOrderType == 'Order') {
                        thisARInvoice.OrdersId__c = ar.SFDCKey == '' ? null : ar.SFDCKey;
                    } else if (ar.SFDCOrderType == 'PartsOrder'){
                        thisARInvoice.PartsOrderId__c = ar.SFDCKey == '' ? null : ar.SFDCKey;
                    }
                    thisARInvoice.Postingdate__c = thisARInvoice.Postingdate__c == null ? convertStringToDate(ar.PostingDate) : null;
                    thisARInvoice.Duedate__c = thisARInvoice.Duedate__c == null ? convertStringToDate(ar.DueDate) : null;
                    thisARInvoice.OrderDate__c = thisARInvoice.OrderDate__c == null ? convertStringToDate(ar.OrderDate) : null;
                    thisARInvoice.Dealership__c = mapBPCodeToDealershipId.get(ar.DealerCode);
                    thisARInvoice.ContactId__c = ar.Salesperson == '' ? null : mapExternalIdToContact.get(ar.DealerCode + ar.Salesperson);
                    thisARInvoice.ShipVia__c = ar.Shipvia;
                    thisARInvoice.ShippingNumber__c = ar.Shippingnumber;
                    thisARInvoice.ShipDate__c = thisARInvoice.ShipDate__c == null ? convertStringToDate(ar.Shipdate) : null;
                    thisARInvoice.DeliveryDate__c = thisARInvoice.DeliveryDate__c == null ? convertStringToDate(ar.DeliveryDate) : null;
                    thisARInvoice.ShipFrom__c = ar.Shipfrom;
                    thisARInvoice.Discount__c = ar.Discount;
                    thisARInvoice.Freight__c = ar.Freight;
                    thisARInvoice.Total__c = ar.Total;
                    thisARInvoice.Remarks__c = ar.Remarks;
                    listARInvoices.add(thisARInvoice);
                }
                Upsert listARInvoices ExternalId__c;

                Map<String, String> mapExternalIdToARInvoice = new Map<String, String>();
                for (ARInvoice__c ARIn : [SELECT Id, ExternalId__c FROM ARInvoice__c WHERE ExternalId__c IN: setInvoiceNumber LIMIT 50000]) {
                    mapExternalIdToARInvoice.put(ARIn.ExternalId__c, ARIn.Id);
                }

                for (ARInvoice ar : objOutput.ARInvoices) {
                    if (ar.ARInvoiceLines != null) {
                        for (ARInvoiceLines arl : ar.ARInvoiceLines) {
                            ARInvoiceItem__c avi = new ARInvoiceItem__c();
                            avi.ARInvoiceMaster__c = ar.SFDCKey == '' ? mapExternalIdToARInvoice.get(ar.InvoiceNumber) : ar.SFDCKey;
                            avi.UnitPrice__c = arl.UnitPrice;
                            avi.ExternalId__c = ar.InvoiceNumber + arl.LineNum;
                            avi.Quantity__c = arl.Quantity; 
                            avi.Subtotal__c = arl.SubTotal;
                            avi.Description__c = arl.Description;
                            avi.SerialNumber__c = arl.SerialNumber;
                            avi.Product__c = mapExternalIdToProduct.get(arl.ItemCode);
                            if (arl.SerialNumber != '') {
                                //Asset 생성에 대한 트리거 생성 필요
                                avi.SerialNumber__c = arl.SerialNumber;
                            }
                            listARInvoiceItems.add(avi);
                        }
                    }
                }

                Upsert listARInvoiceItems ExternalId__c;

                //Queueable Method 재귀 호출
                if (objOutput.isContinue == 'Y') {
                    QueueCount++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_AR_qu(this.BPCode, this.Count, QueueCount));
                }
            }
            else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        }
        catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.requestCount = QueueCount;
        LogWrapper.enqueueJobId = jobId;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
    }


    public static Date convertStringToDate(String thisDate) {
        // ex) "7/17/2008 12:00:00 AM"
        Date targetDate;
        thisDate = thisDate.split(' ')[0];
        Integer month = Integer.valueOf(thisDate.split('/')[0]);
        Integer day = Integer.valueOf(thisDate.split('/')[1]);
        Integer year = Integer.valueOf(thisDate.split('/')[2]);

        targetDate = Date.newInstance(year, month, day);

        return targetDate;
    }
}