/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REG_ORDER_PARTS
 * Author	  		: taekyun.yoon@daeunextier.com
 * Date				: 2023-11-22
 * @Group           : Daeunextier
 * Description 		: SFDC에서 Parts Order 정보 생성 시 SAP API 호출하여 SAP에 Order 생성
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-22       taekyun.yoon        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REG_ORDER_PARTS {

    private static final String IFID = 'IF_SFDC_SAP_REG_ORDER_PARTS'; 
    private static List<PartsOrder__c> PartsOrders;
    private static List<PartsOrderItem__c> PartsOrderItems;

    public IF_SFDC_SAP_REG_ORDER_PARTS(List<PartsOrder__c> listPartsOrder, List<PartsOrderItem__c> listPartsOrderItem){
        PartsOrders = listPartsOrder;
        PartsOrderItems = listPartsOrderItem;
        System.debug('PartsOrders is created :: ' + PartsOrders);
        System.debug('partsOrderItem : '+ PartsOrderItems);
    }

    private class Input{
        String siteCode;
        String apiPartner;
        String apiKey;
        List<PartsOrder> PartsOrders;
    }

    private class Output{
        String ResponseCode;
        String ErrorMessage;
        List<String> ErrorList;
    }

    private class PartsOrder{
        private PartsOrder(
                String SFDCKey,
                String SFDCOrderType,
                String SAPOtype,
                String BPCode,
                String Shipto,
                String Billto,
                String Remarks,
                String SalesEmployee,
                String OrderType,
                String ShippingMode,
                String DiscountMode,
                String PartialShipment,
                List<OrderParts> listOrderParts,
                Date DocumentDate,
                String Comments,
                String PONumber
        ){
            this.SFDCKey = SFDCKey;
            this.SFDCOrderType = SFDCOrderType;
            this.SAPOtype = SAPOtype;
            this.BPCode = BPCode;
            this.Shipto = Shipto == null ? '' : Shipto;
            this.Billto = Billto == null ? '' : Billto;
            this.Remarks = Remarks == null ? '' : Remarks ;
            this.SalesEmployee = SalesEmployee == null ? '' : SalesEmployee ;
            this.OrderType = OrderType;
            this.ShippingMode = ShippingMode;
            this.DiscountMode = DiscountMode;
            this.PartialShipment = PartialShipment;
            this.OrderParts = listOrderParts;
            this.DocumentDate = DocumentDate;
            this.Comments = Comments;
            this.PONumber = PONumber;
        }
        String SFDCKey;
        String SFDCOrderType = 'PartsOrder';
        String SAPOtype = 'As Parts';
        String BPCode;
        String Shipto;
        String Billto;
        String Remarks;
        String SalesEmployee ='';
        String OrderType;
        String ShippingMode;
        String DiscountMode;
        String PartialShipment; 
        List<OrderParts> OrderParts;
        Date DocumentDate;
        String Comments;
        String PONumber;
    }

    private class OrderParts{
        String SFDCKey;
        String SFDCHeaderKey;
        String ItemCode;
        Integer Quantity;
        Integer UnitPrice;
    }

    public String execute() {
        System.debug('IF_SFDC_SAP_REG_ORDER_PARTS.execute() start');
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'SFDC에서 Parts Order 정보 생성 시 SAP API 호출하여 SAP에 Order 생성';

        // 결과 기록용 변수
        Integer outputCnt = 0;
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorDealerCode = new List<String>();
        List<String> listErrorMessage = new List<String>();

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        Input objInput = new Input();

        objInput.siteCode = 'TYM';
        objInput.apiPartner = 'SalesForce';
        objInput.apiKey = '9gvz5=UcEu8XTXni274pObEpywTiPcpB73(';

        List<PartsOrder> listPartsOrder = new List<IF_SFDC_SAP_REG_ORDER_PARTS.PartsOrder>();

        if (PartsOrders != null) {
            Set<String> setDealershipId = new Set<String>();
            System.debug('PartsOrders[0].DealershipId__c '+PartsOrders[0].DealershipId__c);
            for (PartsOrder__c objPartsOrder : PartsOrders) {
                setDealershipId.add(objPartsOrder.DealershipId__c);
            }

            Map<Id, String> mapDealershipToBPCode = new Map<Id, String>();
            System.debug('PartsOrders[0].PartsOrderItem__r '+PartsOrders[0].PartsOrderItem__r);
            for (Account objAccount : [SELECT Id, BPCode__c FROM Account WHERE Id IN :setDealershipId]){
                mapDealershipToBPCode.put(objAccount.Id, objAccount.BPCode__c);
            }

            System.debug('PartsOrders :::::'+PartsOrders);
            List<OrderParts> listOrderPart = new List<IF_SFDC_SAP_REG_ORDER_PARTS.OrderParts>();

            for (PartsOrderItem__c objPartsOrderItem : PartsOrderItems) {
                OrderParts objOrderPart = new OrderParts();
                objOrderPart.SFDCKey = objPartsOrderItem.Id;
                objOrderPart.ItemCode = objPartsOrderItem.Replacement__r.ExternalId__c == null? objPartsOrderItem.ProductId__r.ExternalId__c : objPartsOrderItem.Replacement__r.ExternalId__c;
                objOrderPart.Quantity = (Integer) objPartsOrderItem.Quantity__c;
                objOrderPart.UnitPrice = (Integer) objPartsOrderItem.Price__c;
                // 23.12.15 - SAP 컬럼 추가
                objOrderPart.SFDCHeaderKey = objPartsOrderItem.PartsOrderId__c;
                listOrderPart.add(objOrderPart);
            }

            for (PartsOrder__c objPartsOrder : PartsOrders) {
                if (mapDealershipToBPCode.size() == 1) {
                    System.debug('mapDealershipToBPCode.get ::::::::;;' + mapDealershipToBPCode.get(objPartsOrder.DealershipId__c));
                    listPartsOrder.add(new PartsOrder(
                            objPartsOrder.Id,
                            'PartsOrder',
                            'As Parts',
                            mapDealershipToBPCode.get(objPartsOrder.DealershipId__c),
                            objPartsOrder.ShiptoAddressId__r.ExternalId__c,
                            objPartsOrder.BilltoAddressID__r.ExternalId__c,
                            objPartsOrder.Remarks__c != null? objPartsOrder.Remarks__c : '',
                            objPartsOrder.ResponsibilityID__r.EmployeeNumber,
                            objPartsOrder.OrderType__c != null? objPartsOrder.OrderType__c : '',
                            objPartsOrder.ShippingMode__c != null? objPartsOrder.ShippingMode__c : '',
                            objPartsOrder.Discount__c != null? objPartsOrder.Discount__c : '',
                            objPartsOrder.PartialShipment__c,
                            listOrderPart,
                            Date.today(),
                            objPartsOrder.Comment__c != null? objPartsOrder.Comment__c : '',
                            objPartsOrder.PONumber__c != null? objPartsOrder.PONumber__c : ''
                    ));
                } else{
                    System.debug('Dealership__c is required field');
                    strStatus = 'ERROR';
                    return strStatus;
                }
            }
        }
        System.debug('listPartsOrder :: ' + listPartsOrder );

        //set requestBody
        objInput.PartsOrders = listPartsOrder; 

        String requestBody = JSON.serialize(objInput);
        System.debug('requestBody : ' + requestBody);
        String responseBody;
        /* request 예시
            {"PartsOrders":[{
            "ShipTo":"1002341",
            "ShippingMode":"Truck",
            "SFDCOrderType":"PartsOrder",
            "SFDCKey":"a041m00000eq51HAAQ",
            "SAPOtype":"As Parts",
            "SalesEmployee":"",
            "Remarks":"",
            "PartialShipment":"Allowed",
            "OrderType":"Level 2 Stock order",
            "OrderParts":[
                {"SFDCKey":"a0E1m000008y55ZEAQ", "Quantity":1, "ItemCode":"16501000060M"},
                {"SFDCKey":"a0E1m000008y55aEAA", "Quantity":1, "ItemCode":"0118 1432"},
                {"SFDCKey":"a0E1m000008y55bEAA", "Quantity":1, "ItemCode":"32K0405600"},
                {"SFDCKey":"a0E1m000008y55cEAA", "Quantity":1, "ItemCode":"3434000700"},
                {"SFDCKey":"a0E1m000008y55dEAA", "Quantity":3, "ItemCode":"EA00005449A"},
                {"SFDCKey":"a0E1m000008y55eEAA", "Quantity":1, "ItemCode":"FTE11H181D"},
                {"SFDCKey":"a0E1m000008y55fEAA", "Quantity":1, "ItemCode":"FTE43H181A"},
                {"SFDCKey":"a0E1m000008y57IEAQ", "Quantity":1, "ItemCode":"36767022220"},
                {"SFDCKey":"a0E1m000008y57JEAQ", "Quantity":1, "ItemCode":"BH12A6175Z"},
                {"SFDCKey":"a0E1m000008y57KEAQ", "Quantity":1, "ItemCode":"19026622102MS"},
                {"SFDCKey":"a0E1m000008y57LEAQ", "Quantity":1, "ItemCode":"85211007010"},
                {"SFDCKey":"a0E1m000008y57MEAQ", "Quantity":1, "ItemCode":"Y100-203030"},
                {"SFDCKey":"a0E1m000008y578EAA", "Quantity":1, "ItemCode":"3346A009"},
                {"SFDCKey":"a0E1m000008y560EAA", "Quantity":1, "ItemCode":"18012160040"},
                {"SFDCKey":"a0E1m000008y55vEAA", "Quantity":1, "ItemCode":"1A091-23482"},
                {"SFDCKey":"a0E1m000008y55wEAA", "Quantity":1, "ItemCode":"S212231010"}
                ],
            "Discount":"Within 7 Days",
            "BPCode":"100234",
            "BillTo":"1002340"}
            ]}
        */

        //여기까지 requestBody 들어옴
        try{
            IFUtil objIF = new IFUtil(IFID);

            System.debug('IFUtil setting ---------------------------');

            HttpResponse response = objIF.webCallout(requestBody, true);
            System.debug('response :: '+ response);
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug(response.getStatus());

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                System.debug('objOutput :: ' + objOutput);
            }
            else {
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

        System.debug(LogWrapper);
        // IF_Log에 데이터 저장
        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);

        return strStatus;
    }
}