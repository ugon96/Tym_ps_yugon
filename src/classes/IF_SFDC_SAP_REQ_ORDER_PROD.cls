/*
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PROD
 * Author           : seungyeon.kang
 * Date            : 2023-12-01
 * @Group           : Daeunextier
 * Description       :
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_ORDER_PROD implements System.Queueable, Database.AllowsCallouts {

    private static final String IFID = 'IF_SFDC_SAP_REQ_ORDER_PROD';

    private String SFDCKey;
    private Integer COUNT;
    private Integer i;

    public IF_SFDC_SAP_REQ_ORDER_PROD(){

    }
    public IF_SFDC_SAP_REQ_ORDER_PROD(String SFDCKey, Integer i) {
        this.SFDCKey = SFDCKey;
        this.i = i;
    }
//    public IF_SFDC_SAP_REQ_ORDER_PROD(String SFDCKey, Integer count) {
//        this.SFDCKey = SFDCKey;
//        this.COUNT = count;
//    }

    private class input {
        String SFDCKey;
        Integer Count;
    }

    private class output {
        String ResponseCode;
        String ErrorMessage;
        List<Orders> Orders;
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
        String SAPKey;
        Decimal TotalPrice;
    }
    private class OrderProducts {
        String SFDCKey;
        String ItemCode;
        Decimal UnitPrice;
        Decimal Quantity;
        Decimal TotalPrice;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)';

        Integer successCnt = 0;
        Integer failCnt = 0;
        Id jobId = null;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestCount = i;

        Input objInput = new Input();

        if (SFDCKey == null || SFDCKey == '') {
            SFDCKey = 'new';
        }
        objInput.SFDCKey = this.SFDCKey;
        objInput.Count = this.Count;

        try {
            IFUtil objIF = new IFUtil(IFID);
            //String requestBody = JSON.serialize(objInput);
            //String requestBody = 'TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(' +'/'+ SFDCKey + '/' +COUNT;
            String requestBody = '/' + '210084';
            System.debug('requestBody :: ' + requestBody);

            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();
            System.debug('responseBody :: ' + responseBody);
            List<String> listSAPOrder = new List<String>();
            List<Orders__c> listOrders = new List<Orders__c>();

            if (response.getStatusCode() == 200) {
                System.debug('response.getStatusCode() :: ' + response.getStatusCode());
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                if(objOutput.Orders != null){
                    for(Orders orders : objOutput.Orders){
                        listSAPOrder.add(orders.SFDCKey);
                    }
                }

                listOrders = new List<Orders__c>(
                        [
                                SELECT Id, Dealership__c
                                FROM Orders__c
                                WHERE Id = :listSAPOrder
                        ]
                );
                //sap 에서 보낸 애들 중 sfdc에 있는 애들 -> mapSAPOrderToOrder
                Map<String, Orders__c> mapSAPOrderToOrder = new Map<String, Orders__c>();
                for(Orders__c objOrders : listOrders) {
                    mapSAPOrderToOrder.put(objOrders.Id, objOrders);
                }

                Set<String> setBPCode = new Set<String>();
                if(objOutput.Orders != null){
                    for (Orders objSAPOrder : objOutput.Orders){
                        if (objSAPOrder.BPCode != null) {
                            setBPCode.add(objSAPOrder.BPCode);
                        }
                    }
                }

                //sap 가 준 애들의 account가 sfdc에 있는 애들 -> mapBPCodeToOrder
                System.debug('setBPCode :::' + setBPCode);
                Map<String, Id> mapBPCodeToOrder = new Map<String, String>();
                if (setBPCode != null) {
                    for (Account objAccount : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN :setBPCode]){
                        mapBPCodeToOrder.put(objAccount.BPCode__c, objAccount.Id);
                    }
                }
                System.debug('mapBPCodeToOrder :: '+ mapBPCodeToOrder);

                Set<String> setSalesperson = new Set<String>();
                if(objOutput.Orders != null){
                    for (Orders objSAPOrder : objOutput.Orders){
                        if (objSAPOrder.ContactPerson != null) {
                            setSalesperson.add(objSAPOrder.ContactPerson);
                        }
                    }
                }

                System.debug('setSalesperson :::' + setSalesperson);

                //sap가 준 애들중 contact에 있는데 sfdc에 있는 애들 -> mapContactToOrder
                Map<String, Id> mapContactToOrder = new Map<String, String>();
                if (setSalesperson != null) {
                    for (Contact objContact : [SELECT Id, ExternalId__c FROM Contact WHERE ExternalId__c IN :setSalesperson]) {
                        // mapContactToOrder 추가
                        if (objContact.ExternalId__c != null) {
                            mapContactToOrder.put(objContact.ExternalId__c, objContact.Id);
                        }
                    }
                }
                System.debug('mapContactToOrder :: '+ mapContactToOrder);

                Set<String> setShipto = new Set<String>();
                if(objOutput.Orders != null) {
                    for (Orders objSAPOrder : objOutput.Orders){
                        if (objSAPOrder.Shipto != null) {
                            setShipto.add(objSAPOrder.Shipto);
                        }
                    }
                }

                System.debug('setShipto ::: ' + setShipto);

                Map<String, Id> mapAddresstoToOrder = new Map<String, String>();
                if (setShipto != null) {
                    for (Address__c objAddress : [SELECT Id, ExternalId__c FROM Address__c WHERE ExternalId__c IN :setShipto]) {
                        if (objAddress.ExternalId__c != null) {
                            mapAddresstoToOrder.put(objAddress.ExternalId__c, objAddress.Id);
                        }
                    }
                }
                System.debug('mapAddresstoToOrder :: '+ mapAddresstoToOrder);

                Set<String> setPaymentTerm = new Set<String>();
                Set<String> setProduct2 = new Set<String>();

                if(objOutput.Orders != null) {
                    for(Orders objSAPOrder :objOutput.Orders) {
                        if (objSAPOrder.PaymentTerm != null) {
                            setPaymentTerm.add(objSAPOrder.PaymentTerm);
                        }
                        for(OrderProducts objop : objSAPOrder.OrderProducts) {
                            if (objop.ItemCode != null) {
                                setProduct2.add(objop.ItemCode);
                            }
                        }
                    }
                }

                System.debug('setPaymentTerm :: '+ setPaymentTerm);
                System.debug('setProduct2 :: '+ setProduct2);

                //sap에서 받은 애들의 pricelist 애들중 sfdc에 있는 애들 - >mapPricelistToOrder
                Map<String, Id> mapPricelistToOrder = new Map<String, String>();
                if (setPaymentTerm != null) {
                    for (PriceList__c objPriceList : [SELECT Id, ExternalId__c FROM PriceList__c WHERE ExternalId__c IN :setPaymentTerm]){
                        mapPricelistToOrder.put(objPriceList.ExternalId__c, objPriceList.Id);
                    }
                }
                System.debug('mapPricelistToOrder :: '+ mapPricelistToOrder);
                Map<String, Id> mapProduct2 = new Map<String, String>();
                if (setProduct2 != null) {
                    for (Product2 objProduct2 : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :setProduct2]){
                        mapProduct2.put(objProduct2.ExternalId__c, objProduct2.Id);
                    }
                }

                if(objOutput.Orders != null){
                    for (Orders orders : objOutput.Orders) {
                        System.debug('orders::'+orders);

                        Orders__c thisOrderList = mapSAPOrderToOrder.get(orders.SFDCKey);
                        //sap 애들이 sfdc에 없는 애들인 경우
                        if (thisOrderList == null){
                            //update 면 else 처리하고 아무것도 하면 안됨 ->sfdc에 없는 애들은 건들지 않기
                            thisOrderList = new Orders__c();

                        }
                        if (orders.SFDCKey != null) {
                            System.debug('thisOrderList.Id1 ::'+thisOrderList.Id);
                            thisOrderList.Id = orders.SFDCKey;
                            System.debug('thisOrderList.Id2 ::'+thisOrderList.Id);

                        }
                        if (orders.SAPOtype != null) {
                            thisOrderList.IsAssembled__c = (orders.SAPOtype == 'Fin-Product');
                        }
                        //tk start
                        if (orders.BPCode != null) {
                            if (mapBPCodeToOrder.get(orders.BPCode) != null) {
                                thisOrderList.Dealership__c = mapBPCodeToOrder.get(orders.BPCode);
                            }
                        }
                        System.debug('강승연 Test1::');
                        if (orders.ContactPerson != null) {
                            System.debug('강승연 Test2::');
                            System.debug('test::'+mapContactToOrder.get(orders.ContactPerson));
                            if(mapContactToOrder.get(orders.ContactPerson) != null) {
                                thisOrderList.Salesperson__c = mapContactToOrder.get(orders.ContactPerson);
                                System.debug('값');
                            }
                        }
                        if(orders.Shipto != null) {
                            if(mapAddresstoToOrder.get(orders.Shipto) != null) {
                                thisOrderList.ShiptoAddressID__c = mapAddresstoToOrder.get(orders.Shipto);
                            }
                        }
                        if(orders.Billto != null) {
                            if(mapAddresstoToOrder.get(orders.Billto) != null) {
                                thisOrderList.BilltoAddressID__c = mapAddresstoToOrder.get(orders.Billto);
                            }
                        }
                        if(orders.SalesEmployee != null) {
                            if(mapContactToOrder.get(orders.SalesEmployee) != null){
                                thisOrderList.Salesperson__c = mapContactToOrder.get(orders.SalesEmployee);
                            }
                        }
                        if(orders.PaymentTerm != null) {
                            if (mapPricelistToOrder.get(orders.PaymentTerm) != null) {
                                thisOrderList.PaymentTermDev__c = mapPricelistToOrder.get(orders.PaymentTerm);
                            }
                        }
                        //tk end

                        if(orders.Remarks  != null) thisOrderList.Notes__c = orders.Remarks;
                        //SAPKey
                        if(orders.TotalPrice  != null) thisOrderList.TotalAmount__c = orders.TotalPrice;

                        //OrderProduct
                        if (orders.OrderProducts != null) {
                            for(OrderProducts op : orders.OrderProducts) {
                                ProductOrderItem__c opi = new ProductOrderItem__c();

                                opi.Price__c = op.UnitPrice;
                                opi.ProductId__c = mapProduct2.get(op.ItemCode);
                                if(op.Quantity != null){
                                    opi.Quantity__c = op.Quantity;
                                }
                            }
                        }
                        listOrders.add(thisOrderList);
                    }
                }


                System.debug('listOrders :: ' + listOrders);

                List<Database.UpsertResult> listDmlResult = Database.upsert(listOrders, false);

                System.debug('listDmlResult');
                System.debug('execute ==> i = > ' + i);
                //isContinue, Count 반영 시 조건 변경 if(objOutput.isContinue == 'Y')
                if (i < 3) {
                    i++;
                    //Queueable Method 재귀 출
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_ORDER_PROD('ALL', i));
                }

                Integer cnt = 0;
                for (Database.UpsertResult objResult : listDmlResult) {
                    if (objResult.success) {
                        successCnt++;
                    } else {
                        failCnt++;
                        if (objResult.getErrors().toString().contains('required field missing')) {
                            listErrorMessage.add('Required field missing');
                        } else {
                            listErrorMessage.add(objResult.getErrors().toString());
                        }
                    }
                    cnt++;
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
        LogWrapper.enqueueJobId = jobId;
        System.debug('LogWrapper :: ' + LogWrapper);

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
        System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());
    }
}