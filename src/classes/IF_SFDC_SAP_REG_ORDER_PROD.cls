/**
 * Created by nhkim on 2023-12-01.
 */

public with sharing class IF_SFDC_SAP_REG_ORDER_PROD {
    private static final String IFID = 'IF_SFDC_SAP_REG_ORDER_PROD'; 
    public Orders__c orderData;
    public ProductOrderSummary__c orderSummary;

    public IF_SFDC_SAP_REG_ORDER_PROD() {}

    public IF_SFDC_SAP_REG_ORDER_PROD(Orders__c objOrder) {
        this.orderData = objOrder;
    }

    public IF_SFDC_SAP_REG_ORDER_PROD(Orders__c objOrder, ProductOrderSummary__c summary) {
        this.orderData = objOrder;
        this.orderSummary = summary;
    }

    private class Input {
        String siteCode;
        String apiPartner;
        String apiKey;
        List<Orders> Orders;
    }

    private class Orders {
        String SFDCKey;
        String SFDCOrderType;
        String SAPOtype;
        String BPCode;
        String Shipto;
        String Billto;
        String SalesEmployee;
        String PaymentTerm;
        String Remarks;
        List<OrderProduct> OrderProducts;
        Date DocumentDate;
        String PONumber;
        String Comments;
    }

    private class OrderProduct {
        String SFDCKey;
        String SFDCHeaderKey;
        String ItemCode;
        String ItemGroupCode;
        Decimal UnitPrice;
        Decimal Quantity;
    }

    public class Output {
        public String ResponseCode;
        public String ErrorMessage;
        public List<String> ErrorList;
    }

    public String executeCall() {
        String responseCode = '';
        List<Orders> listOrders = new List<Orders>();
        if (orderData != null) {
            List<ProductOrderItem__c> listProductOrderItems = new List<ProductOrderItem__c>();
            if (orderSummary != null) {
                if (orderSummary.FinishedGoodsCode__c == null) {
                    listProductOrderItems = [
                            SELECT Id, ProductId__r.ExternalId__c, Quantity__c, IsAssembled__c, fm_ItemGroupCode__c, Price__c, OrdersId__c
                            FROM ProductOrderItem__c
                            WHERE OrdersId__c = :orderData.Id AND IsAssembled__c = FALSE
                    ];
                } else {
                    listProductOrderItems = [
                            SELECT Id, ProductId__r.ExternalId__c, Quantity__c, IsAssembled__c, fm_ItemGroupCode__c, Price__c, OrdersId__c
                            FROM ProductOrderItem__c
                            WHERE OrdersId__c = :orderData.Id
                            AND Type__c = 'Tractor'
                    ];
                }
            }

            Orders objOrders = new Orders();
            objOrders.SFDCKey = orderData.Id;
            objOrders.SFDCOrderType = 'Order';
            //테스트용-수정필요
            objOrders.SAPOtype = 'Fin-Product';
            objOrders.BPCode = orderData.Dealership__r.BPCode__c;
            objOrders.Shipto = orderData.ShiptoAddressID__r.ExternalId__c;
            objOrders.Billto = orderData.BilltoAddressID__r.ExternalId__c;
            objOrders.PaymentTerm = orderData.PaymentTermDev__r.ExternalId__c != null? orderData.PaymentTermDev__r.ExternalId__c : ''; 
            objOrders.Remarks = orderData.Notes__c != null? orderData.Notes__c : '';
            objOrders.SalesEmployee = orderData.ResponsibilityID__r.EmployeeNumber != null? orderData.ResponsibilityID__r.EmployeeNumber:'';
            objOrders.DocumentDate = Date.today();
            objOrders.PONumber = orderData.PONumber__c != null? orderData.PONumber__c : '';
            objOrders.Comments = orderData.Comments__c != null? orderData.Comments__c : '';
            objOrders.OrderProducts = new List<OrderProduct>();
            if (listProductOrderItems != null) {
                if (orderSummary != null && orderSummary.FinishedGoodsCode__c == null) {
                    for (ProductOrderItem__c poi : listProductOrderItems) {
                        OrderProduct op = new OrderProduct();
                        op.SFDCKey = poi.Id;
                        // 23.12.15 - SAP 컬럼 추가
                        op.SFDCHeaderKey = poi.OrdersId__c;
                        op.ItemCode = poi.ProductId__r.ExternalId__c;
                        op.ItemGroupCode = poi.fm_ItemGroupCode__c;
                        op.UnitPrice = poi.Price__c != null? poi.Price__c : 0;
                        if (orderSummary != null) {
                            op.Quantity = orderSummary.Quantity__c;
                        }
                        objOrders.OrderProducts.add(op);
                    }
                } else {
                    for (ProductOrderItem__c poi : listProductOrderItems) {
                        OrderProduct op = new OrderProduct();
                        op.SFDCKey = poi.Id;
                        // 23.12.15 - SAP 컬럼 추가
                        op.SFDCHeaderKey = poi.OrdersId__c;
                        op.ItemCode = orderSummary.FinishedGoodsCode__c;
                        op.ItemGroupCode = '101';
                        op.UnitPrice = poi.Price__c != null? poi.Price__c : 0;
                        if (orderSummary != null) {
                            op.Quantity = orderSummary.Quantity__c;
                        }
                        objOrders.OrderProducts.add(op);
                    }
                }
            }
            listOrders.add(objOrders);

            Input objInput = new Input();
            objInput.Orders = listOrders;
            objInput.siteCode = 'TYM';
            objInput.apiPartner = 'SalesForce';
            objInput.apiKey = '9gvz5=UcEu8XTXni274pObEpywTiPcpB73(';

            String requestBody = JSON.serialize(objInput);
            System.debug(requestBody);

            IFUtil objIF = new IFUtil(IFID);
            HttpResponse response = objIF.webCallout(requestBody, true);

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                responseCode = objOutput.ResponseCode;

                if (this.orderSummary != null) {
                    update orderSummary;
                }

                orderData.IsSendtoSAP__c = true;
                orderData.Status__c = 'Accepted';

                update orderData;
            }
        }
        return responseCode;
    }
}