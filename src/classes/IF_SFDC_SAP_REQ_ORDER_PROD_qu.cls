/*
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PROD_qu
 * Author            : seungyeon.kang
 * Date              : 2023-12-01
 * @Group            : Daeunextier
 * Description       : SAP에서 변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_ORDER_PROD_qu implements System.Queueable, Database.AllowsCallouts {

    private static final String IFID = 'IF_SFDC_SAP_REQ_ORDER_PROD';

    private String DocNum;
    private Integer Count;
    private Integer i;

    public IF_SFDC_SAP_REQ_ORDER_PROD_qu(String docNum, Integer i, Integer Count) {
        this.DocNum = docNum;
        this.i = i;
        this.Count = Count;
    }

    private class input {
        String SFDCKey;
        Integer Count;
    }

    private class output {
        String ResponseCode;
        String ErrorMessage;
        List<Orders> Data;
        String isContinue;
    }

    public class Orders {
        String SFDCKey;
        String SFDCOrderType;
        String SAPOtype;
        String BPCode;
        String ContactPerson;
        String Shipto;
        String Billto;
        String SalesEmployee;
        String PaymentTerm;
        String Remarks;
        List<OrderProducts> OrderProducts;
        Decimal Discount;
        Date DocumentDate;
        String SAPKey;
        Decimal TotalPrice;
    }
    public class OrderProducts {
        String SFDCKey;
        String SAPKey;
        String LineNum;
        String ItemCode;
        String ItemGroupCode;
        Decimal UnitPrice;
        Decimal Quantity;
        Decimal TotalPrice;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;

        // 결과 기록용 변수
        Integer outputCnt = 0;
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorDealerCode = new List<String>();
        List<String> listErrorMessage = new List<String>();

        Id jobId = null;
        IFUtil objIF;
        String requestParam;
        String responseBody;

        if (this.DocNum != null && this.DocNum != '') {
            requestParam += '/' + this.DocNum;
            if (this.Count != null && this.Count != 0) {
                requestParam += '/' + String.valueOf(this.Count);
            }
        } else {
            requestParam += '/all';
        }

        try {
            objIF = new IFUtil(IFID);
            //String requestBody = JSON.serialize(objInput);
            //String requestBody = 'TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(' +'/'+ SFDCKey + '/' +COUNT;
            String requestBody = '/' + '210084';

            HttpResponse response = objIF.webCallout(requestBody, true);
            System.debug(response);
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug(response.getStatus());

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            System.debug('response.getStatusCode1() :: ' + response.getStatusCode());
            if (response.getStatusCode() == 200) {
                System.debug('response.getStatusCode2() :: ' + response.getStatusCode());
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                System.debug('objOutput.Data.size() :: ' + objOutput.Data.size());
                if (objOutput.Data != null && objOutput.Data.size() > 0) {
                    Set<String> setSFDCKey = new Set<String>();
                    Set<String> setBPCode = new Set<String>();
                    Set<String> setBillorShipTo = new Set<String>();
                    Set<String> setEmployeeNumber = new Set<String>();
                    Set<String> setPaymentTerm = new Set<String>();
                    Set<String> setContactPerson = new Set<String>();
                    Set<String> setOrderProductsSFDCKey = new Set<String>();

                    for (Orders objBPA : objOutput.Data) {
                        if (objBPA.SFDCKey != null) {
                            setSFDCKey.add(objBPA.SFDCKey);
                        }
                        if(objBPA.BPCode != null) {
                            setBPCode.add(objBPA.BPCode);
                        }
                        if(objBPA.Billto != null){
                            setBillorShipTo.add(objBPA.Billto);
                        }
                        if(objBPA.Shipto != null) {
                            setBillorShipTo.add(objBPA.Shipto);
                        }
                        if(objBPA.SalesEmployee != null) {
                            setEmployeeNumber.add(objBPA.SalesEmployee);
                        }
                        if(objBPA.PaymentTerm != null) {
                            setPaymentTerm.add(objBPA.PaymentTerm);
                        }
                        if(objBPA.ContactPerson != null) {
                            setContactPerson.add(objBPA.ContactPerson);
                        }
                        for(OrderProducts objOP : objBPA.OrderProducts) {
                            if (objOP.SFDCKey != null) {
                                setOrderProductsSFDCKey.add(objOP.SFDCKey);
                            }
                        }

                    }

                    Map<String, Orders__c> mapOrders = new Map<String, Orders__c>();
                    Map<String, ProductOrderItem__c> mapProductOrderItems = new Map<String, ProductOrderItem__c>();
                    Map<String, Id> mapBPCodeToAccountId = new Map<String, Id>();
                    Map<String, Id> mapBillOrShipToToAddress = new Map<String, Id>();
                    Map<String, Id> mapSalesEmployeeToUser = new Map<String, Id>();
                    Map<String, Id> mapPaymentTermToPL = new Map<String, Id>();
                    Map<String, Id> mapSalesPersonToContact = new Map<String, Id>();

                    if (setSFDCKey != null) {
                        for (Orders__c objOrders : [
                                SELECT  Id,
                                        sObjectName__c,
                                        IsAssembled__c,
                                        Dealership__c,
                                        //SalespersonId__r.ExternalId__c,
                                        ShiptoAddressId__r.ExternalId__c,
                                        BilltoAddressID__r.ExternalId__c,
                                        ResponsibilityID__r.EmployeeNumber__c,
                                        PaymentTermDev__c,
                                        Notes__c,
                                        //List<OrderProducts>
                                        Discount__c,
                                        DocumentDate__c,
                                        ExternalId__c,
                                        TotalAmount__c
                                FROM Orders__c WHERE Id IN :setSFDCKey]) {
                            mapOrders.put(objOrders.Id, objOrders);
                        }
                    }
                    if(setOrderProductsSFDCKey != null) {
                        for(ProductOrderItem__c objProductOrderItems : [
                                SELECT Id
                                        //ExternalId__c
                                FROM  ProductOrderItem__c WHERE Id IN :setOrderProductsSFDCKey]) {
                            mapProductOrderItems.put(objProductOrderItems.Id, objProductOrderItems);
                        }

                    }
                    if (setBPCode != null) {
                        for (Account objAccount : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN :setBPCode]) {
                            mapBPCodeToAccountId.put(objAccount.BPCode__c, objAccount.Id);
                        }
                    }
                    if (setBillorShipTo != null) {
                        for (Address__c objAddress : [SELECT Id, ExternalId__c FROM Address__c WHERE ExternalId__c IN : setBillorShipTo]) {
                            mapBillOrShipToToAddress.put(objAddress.ExternalId__c, objAddress.Id);
                        }
                    }
                    if (setEmployeeNumber != null) {
                        for (User objUsr : [SELECT Id, EmployeeNumber__c FROM User WHERE EmployeeNumber__c IN : setEmployeeNumber]) {
                            mapSalesEmployeeToUser.put(objUsr.EmployeeNumber__c, objUsr.Id);
                        }
                    }
                    if (setPaymentTerm != null) {
                        for (PriceList__c objPriceList : [SELECT Id, ExternalId__c FROM PriceList__c WHERE ExternalId__c IN : setPaymentTerm]) {
                            mapPaymentTermToPL.put(objPriceList.ExternalId__c, objPriceList.Id);
                        }
                    }

                    if (setContactPerson != null) {
                        for (Contact objContact : [SELECT Id, ExternalId__c FROM Contact WHERE ExternalId__c IN : setContactPerson]) {
                            mapSalesPersonToContact.put(objContact.ExternalId__c, objContact.Id);
                        }
                    }

                    for(Orders orders : objOutput.Data) {
                        if(requiredFieldNullCheck(orders)) {
                            Orders__c objOrders = mapOrders.get(orders.SFDCKey);
                            objOrders.Id = orders.SFDCKey;
                            System.debug('objOrders.Id :: ' + objOrders.Id);
                            objOrders.sObjectName__c = orders.SFDCOrderType;
                            objOrders.IsAssembled__c = orders.SAPOtype != null && orders.SAPOtype.equalsIgnoreCase('true');
                            objOrders.Dealership__c = mapBPCodeToAccountId.get(orders.BPCode);
                            objOrders.Salesperson__r.ExternalId__c = mapSalesPersonToContact.get(orders.ContactPerson);
                            System.debug('objOrders.Salesperson__r.ExternalId__c  :: ' + objOrders.Salesperson__r.ExternalId__c );
                            objOrders.ShiptoAddressID__r.ExternalId__c = mapBillOrShipToToAddress.get(orders.Shipto);
                            objOrders.BilltoAddressID__r.ExternalId__c = mapBillOrShipToToAddress.get(orders.Billto);
                            objOrders.ResponsibilityID__r.EmployeeNumber__c = mapSalesEmployeeToUser.get(orders.SalesEmployee);
                            objOrders.PaymentTermDev__c = mapPaymentTermToPL.get(orders.PaymentTerm);
                            objOrders.Notes__c = orders.Remarks;
                            objOrders.Discount__c  = orders.Discount;
                            objOrders.DocumentDate__c = orders.DocumentDate;
                            objOrders.ExternalId__c = orders.SAPKey;
                            objOrders.TotalAmount__c = orders.TotalPrice;

                            //OrderProduct
                            List<ProductOrderItem__c> listProductOrderItems = new List<ProductOrderItem__c>();
                            for(OrderProducts objSAPOrderProducts : orders.OrderProducts) {
                                if(itemRequiredFieldNullCheck(objSAPOrderProducts)) {
                                    if(mapProductOrderItems != null){
                                        ProductOrderItem__c objProductOrderItem = mapProductOrderItems.get(objSAPOrderProducts.SFDCKey);
                                        objProductOrderItem.Id = objSAPOrderProducts.SFDCKey;
                                        //objProductOrderItem.ExternalId__c = objSAPOrderProducts.SAPKey + objSAPOrderProducts.LineNum;  // ExternalId__c 필드 없음
                                        objProductOrderItem.ProductId__r.ExternalId__c = objSAPOrderProducts.ItemCode;
                                        objProductOrderItem.Price__c = objSAPOrderProducts.UnitPrice;
                                        objProductOrderItem.Quantity__c = objSAPOrderProducts.Quantity;
                                        //TotalPrice

                                        update listProductOrderItems;
                                        listProductOrderItems.add(objProductOrderItem);
                                    }
                                }
                            }
                            update objOrders;
                        }
                    }
                    System.debug('mapNew.size =>' + mapOrders.size());
                    Database.update(mapOrders.values());
                    System.debug('Update :: success execute ==> i => ' + this.i);
                }else {System.debug('objOutput.Data == null!!');}

                //isContinue, Count 반영 시 조건 변경  if(objOutput.isContinue == 'Y')
                if (i < 3) {
                    this.i ++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_ORDER_PROD_qu('all', this.i, this.Count));
                }
            } else {
                System.debug('response.getStatusCode != 200 :: ');
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }
        if (outputCnt == successCnt + failCnt && outputCnt != 0) {
            strMessage += '\n Total : ' + outputCnt + '. Success : ' + successCnt + '. Fail : ' + failCnt + '.';
            if (failCnt > 0) {
                strMessage += ' Fail List : ' + listErrorDealerCode.toString();
                strMessage += ' Fail Reason : ' + listErrorMessage.toString();
            }
        }
        // IF_Log에 기록할 데이터 저장
        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;

        LogWrapper.enqueueJobId = jobId;

        System.debug(LogWrapper);
        // IF_Log에 데이터 저장
        objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
        System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());
    }

    public Boolean requiredFieldNullCheck(IF_SFDC_SAP_REQ_ORDER_PROD_qu.Orders objSAPOrder){
        Boolean result = true;

        if( objSAPOrder.SFDCKey == null) {result = false;}
        else { System.debug('SFDCKey is not null !');}
        if( objSAPOrder.SFDCOrderType == null) {result = false;}
        else { System.debug('SFDCOrderType is not null !');}
        if( objSAPOrder.SAPOtype == null) {result = false;}
        else { System.debug('SAPOtype is not null !');}
        if( objSAPOrder.BPCode == null) {result = false;}
        else { System.debug('BPCode is not null !');}
        if( objSAPOrder.ContactPerson == null) {result = false;}
        else { System.debug('ContactPerson is not null !');}
        if( objSAPOrder.Shipto == null) {result = false;}
        else { System.debug('Shipto is not null !');}
        if( objSAPOrder.Billto == null) {result = false;}
        else { System.debug('Billto is not null !');}
        if( objSAPOrder.SalesEmployee == null) {result = false;}
        else { System.debug('SalesEmployee is not null !');}
        if( objSAPOrder.PaymentTerm == null) {result = false;}
        else { System.debug('PaymentTerm is not null !');}
        if( objSAPOrder.Remarks == null) {result = false;}
        else { System.debug('ShippingMode is not null !');}
        if( objSAPOrder.Discount == null) {result = false;}
        else { System.debug('Discount is not null !');}
        if( objSAPOrder.DocumentDate == null) {result = false;}
        else { System.debug('DocumentDate is not null !');}
        if( objSAPOrder.SAPKey == null) {result = false;}
        else { System.debug('SAPKey is not null !');}
        if( objSAPOrder.TotalPrice == null) {result = false;}
        else { System.debug('TotalPrice is not null !');}

        return result;
    }

    public Boolean itemRequiredFieldNullCheck(IF_SFDC_SAP_REQ_ORDER_PROD_qu.OrderProducts objSAPOrderItem) {
        Boolean result = true;

        if(objSAPOrderItem.SFDCKey == null) { result = false;}
        else{ System.debug('SFDCKey is not null !!');}
        if(objSAPOrderItem.SAPKey == null) { result = false;}
        else{ System.debug('SAPKey is not null !!');}
        if(objSAPOrderItem.LineNum == null) { result = false;}
        else{ System.debug('LineNum is not null !!');}
        if(objSAPOrderItem.ItemCode == null) { result = false;}
        else{ System.debug('ItemCode is not null !!');}
        if(objSAPOrderItem.ItemGroupCode == null) { result = false;}
        else{ System.debug('ItemGroupCode is not null !!');}
        if(objSAPOrderItem.UnitPrice == null) { result = false;}
        else{ System.debug('UnitPrice is not null !!');}
        if(objSAPOrderItem.Quantity == null) { result = false;}
        else{ System.debug('Quantity is not null !!');}
        if(objSAPOrderItem.TotalPrice == null) { result = false;}
        else{ System.debug('TotalPrice is not null !!');}

        return result;
    }
}