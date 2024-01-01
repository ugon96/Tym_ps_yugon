/************************************************************************************
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PARTS_qu
 * Author           : taekyun.yoon@daeunextier.com
 * Date            : 2023-11-21
 * @Group           : Daeunextier
 * Description       : SAP에서 변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       taekyun.yoon        Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_ORDER_PARTS_qu implements System.Queueable, Database.AllowsCallouts{
    private static final String IFID = 'IF_SFDC_SAP_REQ_ORDER_PARTS';

    private String DocEntry;
    private Integer Count;
    private Integer i;

    public IF_SFDC_SAP_REQ_ORDER_PARTS_qu(String docEntry,Integer i){
        this.DocEntry = docEntry;
        this.i = i;
    }
    public IF_SFDC_SAP_REQ_ORDER_PARTS_qu(String docEntry, Integer count, Integer i){
        this.DocEntry = docEntry;
        this.Count = count;
        this.i = i;
    }

    private class Input {
        String SFDCKey;
        //요청 개수
        Integer Count;
    }

    private class Output{
        //성공, 실패(S, E)
        String ResponseCode;
        String isContinue;
        String ErrorMessage;
        List<SAPPartsOrders> Data;

        //Y : 전송해야 할 데이터가 남아 있음
        //N : 모든 데이터가 전송 완료됨
//        String isContinue;
    }

    private class SAPPartsOrders{
        String SFDCKey;
        String SFDCOrderType;
        String BPCode;
        String Shipto;
        String Billto;
        String Remarks;
        String SalesEmployee;  //사원번호
        String OrderType;
        String ShippingMode;
        String DiscountMode;
        String PartialShipment;
        List<SAPPartsOrderItem> PartsOrderItems;
        String SAPKey;
        Integer TotalPrice;
        //Date(yyyy-mm-dd)
        Date DocumentDate;
        Integer DiscountRate;
    }

    private class SAPPartsOrderItem{
        String SFDCKey;
        String SAPKey;
        String LineNum;
        String ItemCode;
        Integer UnitPrice;
        Integer Quantity;
//        Decimal DiscountRate; 삭제
        Integer TotalPrice;
    }

    public void execute(QueueableContext context){
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'SAP에서 변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)';

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

        if (this.DocEntry != null && this.DocEntry != '') {
            requestParam = '/' + this.DocEntry;
            if (this.Count != null && this.Count != 0) {
                requestParam += '/' + String.valueOf(this.Count);
            }
        } else {
            requestParam = '/all';
        }
        System.debug('requestParam : ' + requestParam);

        try{
            objIF = new IFUtil(IFID);

            HttpResponse response = objIF.webCallout(requestParam, true);
            System.debug(response);
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug(response.getStatus());

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            System.debug('response.body : ' + response.getBody());
            System.debug('response.getStatusCode() : ' + response.getStatusCode());

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                //Map<String, PartsOrder__c> mapNew = new Map<String, PartsOrder__c>();

                if (objOutput.Data != null && objOutput.Data.size() > 0) {

                    Set<String> setSFDCKey = new Set<String>();
                    Set<String> setBPCode = new Set<String>();
                    Set<String> setShipTo = new Set<String>();
                    Set<String> setBillTo = new Set<String>();
                    Set<String> setEmployeeNumber = new Set<String>();

                    for (SAPPartsOrders objSAPPartsOrder : objOutput.Data) {
                        if (objSAPPartsOrder.SFDCKey != null) {
                            setSFDCKey.add(objSAPPartsOrder.SFDCKey);
                        }
                        if (objSAPPartsOrder.BPCode != null) {
                            setBPCode.add(objSAPPartsOrder.BPCode);
                        }
                        if (objSAPPartsOrder.Billto != null) {
                            setBillTo.add(objSAPPartsOrder.Billto);
                        }
                        if (objSAPPartsOrder.Shipto != null) {
                            setShipTo.add(objSAPPartsOrder.Shipto);
                        }
                        if (objSAPPartsOrder.SalesEmployee != null) {
                            setEmployeeNumber.add(objSAPPartsOrder.SalesEmployee);
                        }
                    }

                    Map<String, PartsOrder__c> mapSFDCKeyToPartsOrder = new Map<String, PartsOrder__c>();
                    Map<String, Id> mapBPCodeToAccountId = new Map<String, Id>();
                    Map<String, Id> mapBillToToAddress = new Map<String, Id>();
                    Map<String, Id> mapShipToToAddress = new Map<String, Id>();

                    if (setSFDCKey != null) {
                        for (PartsOrder__c objPartsOrder : [
                                SELECT  Id,
                                        DealershipId__c,
                                        ShiptoAddressId__r.ExternalId__c,
                                        BilltoAddressID__r.ExternalId__c,
                                        Remarks__c,
                                        OrderType__c,
                                        ShippingMode__c,
                                        Discount__c,
                                        PartialShipment__c,
                                        ExternalId__c,
                                        TotalAmount__c,
                                        DocumentDate__c
                                FROM PartsOrder__c WHERE Id IN :setSFDCKey]) {
                            mapSFDCKeyToPartsOrder.put(objPartsOrder.Id, objPartsOrder);
                        }
                    }
                    if (setBPCode != null) {
                        for (Account objAccount : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN :setBPCode]) {
                            mapBPCodeToAccountId.put(objAccount.BPCode__c, objAccount.Id);
                        }
                    }
                    if (setBillTo != null) {
                        for (Address__c objAddress : [SELECT Id, ExternalId__c FROM Address__c WHERE ExternalId__c IN : setBillTo]) {
                            mapBillToToAddress.put(objAddress.Id, objAddress.Id);
                        }
                    }
                    if (setShipTo != null) {
                        for (Address__c objAddress : [SELECT Id, ExternalId__c FROM Address__c WHERE ExternalId__c IN : setShipTo]) {
                            mapShipToToAddress.put(objAddress.Id, objAddress.Id);
                        }
                    }

                    System.debug('objOutput.Data ::: ' + objOutput.Data);
                    if (!mapSFDCKeyToPartsOrder.isEmpty()) {
                        List<PartsOrder__c> listPartsOrder = new List<PartsOrder__c>();
                        List<PartsOrderItem__c> listPartsOrderItems;

                        for (SAPPartsOrders objSAPPartsOrder : objOutput.Data) {
                            if (requiredFieldNullCheck(objSAPPartsOrder)) {
                                PartsOrder__c objPartsOrder = mapSFDCKeyToPartsOrder.get(objSAPPartsOrder.SFDCKey);
                                if (objPartsOrder != null) {
                                    objPartsOrder.DealershipId__c = mapBPCodeToAccountId.get(objSAPPartsOrder.BPCode);
                                    System.debug('objSAPPartsOrder.Shipto :: ' + objSAPPartsOrder.Shipto);
                                    objPartsOrder.ShiptoAddressId__r.ExternalId__c = mapShipToToAddress.get(objSAPPartsOrder.Shipto);
                                    objPartsOrder.BilltoAddressID__r.ExternalId__c = mapBillToToAddress.get(objSAPPartsOrder.Billto);
                                    objPartsOrder.Remarks__c = objSAPPartsOrder.Remarks;
                                    objPartsOrder.OrderType__c = objSAPPartsOrder.OrderType;
                                    objPartsOrder.ShippingMode__c = objSAPPartsOrder.ShippingMode;
                                    objPartsOrder.Discount__c = objSAPPartsOrder.DiscountMode;
                                    objPartsOrder.PartialShipment__c = objSAPPartsOrder.PartialShipment;
                                    objPartsOrder.ExternalId__c = objSAPPartsOrder.SAPKey;
                                    objPartsOrder.TotalAmount__c = objSAPPartsOrder.TotalPrice;
                                    objPartsOrder.DocumentDate__c = objSAPPartsOrder.DocumentDate;
                                    objPartsOrder.Discount__c = String.valueOf(objSAPPartsOrder.DiscountRate);

                                    for (SAPPartsOrderItem objSAPPartsOrderItem : objSAPPartsOrder.PartsOrderItems) {
                                        if (itemRequiredFieldNullCheck(objSAPPartsOrderItem) ) {
                                            PartsOrderItem__c objPartsOrderItem = new PartsOrderItem__c();

                                            objPartsOrderItem.Id = objSAPPartsOrderItem.SFDCKey;
                                            objPartsOrderItem.ExternalId__c = objSAPPartsOrderItem.SAPKey + objSAPPartsOrderItem.LineNum;
                                            objPartsOrderItem.ProductId__r.ExternalId__c = objSAPPartsOrderItem.ItemCode;
                                            objPartsOrderItem.Price__c = objSAPPartsOrderItem.UnitPrice;
                                            objPartsOrderItem.Quantity__c = objSAPPartsOrderItem.Quantity;
                                            objPartsOrderItem.Price__c = objSAPPartsOrderItem.TotalPrice;

                                            listPartsOrderItems.add(objPartsOrderItem);
                                        }
                                    }
                                    listPartsOrder.add(objPartsOrder);

                                }
                            }
                        }
                        update listPartsOrderItems;
                        update listPartsOrder;
                    }
                    System.debug('Upsert :: success execute ==> i => ' + this.i);
                }

                //isContinue, Count 반영 시 조건 변경  if(objOutput.isContinue == 'Y')
                if(objOutput.isContinue == 'Y') {
                    this.i ++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_ORDER_PARTS_qu(this.DocEntry, this.Count, this.i));
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

    public Boolean requiredFieldNullCheck(IF_SFDC_SAP_REQ_ORDER_PARTS_qu.SAPPartsOrders objSAPPartsOrder){
        Boolean result = true;
        if( objSAPPartsOrder.SFDCKey == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.SFDCKey);}
        if( objSAPPartsOrder.SFDCOrderType == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.SFDCOrderType);}
        if( objSAPPartsOrder.BPCode == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.BPCode); }
        if( objSAPPartsOrder.Shipto == null && objSAPPartsOrder.Billto == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.Shipto + ' : ' + objSAPPartsOrder.Billto);}
        if( objSAPPartsOrder.Remarks == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.Remarks);}
        if( objSAPPartsOrder.SalesEmployee == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.SalesEmployee);}
        if( objSAPPartsOrder.OrderType == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.OrderType);}
        if( objSAPPartsOrder.ShippingMode == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.ShippingMode);}
        if( objSAPPartsOrder.DiscountMode == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.DiscountMode);}
        if( objSAPPartsOrder.PartialShipment == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.PartialShipment);}
        if( objSAPPartsOrder.PartsOrderItems == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.PartsOrderItems);}
        if( objSAPPartsOrder.SAPKey == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.SAPKey);}
        if( objSAPPartsOrder.TotalPrice == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.TotalPrice);}
        if( objSAPPartsOrder.DocumentDate == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.DocumentDate);}
        if( objSAPPartsOrder.DiscountRate == null) {result = false; System.debug('testtest :: ' +objSAPPartsOrder.DiscountRate);}

        System.debug('result : '+result);

        return result;
    }

    public Boolean itemRequiredFieldNullCheck(IF_SFDC_SAP_REQ_ORDER_PARTS_qu.SAPPartsOrderItem objSAPPartsOrderItem) {
        Boolean result = true;

        System.debug(objSAPPartsOrderItem);
        if(objSAPPartsOrderItem.SFDCKey == null) { result = false;}
        else{ System.debug('SFDCKey is not null !!'+objSAPPartsOrderItem.SFDCKey );}
        if(objSAPPartsOrderItem.SAPKey == null) { result = false;}
        else{ System.debug('SAPKey is not null !!'+objSAPPartsOrderItem.SAPKey);}
        if(objSAPPartsOrderItem.LineNum == null) { result = false;}
        else{ System.debug('LineNum is not null !!'+objSAPPartsOrderItem.LineNum);}
        if(objSAPPartsOrderItem.ItemCode == null) { result = false;}
        else{ System.debug('ItemCode is not null !!'+objSAPPartsOrderItem.ItemCode);}
        if(objSAPPartsOrderItem.UnitPrice == null) { result = false;}
        else{ System.debug('UnitPrice is not null !!'+objSAPPartsOrderItem.UnitPrice);}
        if(objSAPPartsOrderItem.Quantity == null) { result = false;}
        else{ System.debug('Quantity is not null !!'+objSAPPartsOrderItem.Quantity);}
        if(objSAPPartsOrderItem.TotalPrice == null) { result = false;}
        else{ System.debug('TotalPrice is not null !!'+objSAPPartsOrderItem.TotalPrice);}
        System.debug('result : '+result);
        return result;
    }
}