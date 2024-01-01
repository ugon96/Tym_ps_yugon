/************************************************************************************
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PARTS_qu_test
 * Author            : taekyun.yoon@daeunextier.com
 * Date              : 2023-11-21
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_ORDER_PARTS_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       taekyun.yoon        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ORDER_PARTS_qu_test {

    @IsTest
    static void testExecute() {
        try {
            Account objAccount = new Account();
            objAccount.Name = 'Test Dealership';
            objAccount.LaborRate__c = 0.1;
            objAccount.Phone = '010-1234-1234';
            objAccount.Email__c = 'TestDealership@tymusa.com';
            objAccount.Active__c = 'Active';
            objAccount.BPCode__c = '000000000';
            insert objAccount;

            PartsOrder__c objPartsOrder = new PartsOrder__c();
            objPartsOrder.DealershipId__c = objAccount.Id;
            objPartsOrder.OrderType__c = 'Daily';
            objPartsOrder.PartialShipment__c = 'Allowed';
            objPartsOrder.ShippingMode__c = 'Truck';
            objPartsOrder.Status__c = 'Created';
            objPartsOrder.ApprovalDate__c = null;
            objPartsOrder.ApprovalStatus__c = null;
            insert objPartsOrder;

            PartsOrderItem__c objPartsOrderItem = new PartsOrderItem__c();
            objPartsOrderItem.PartsOrderId__c = objPartsOrder.Id;
            objPartsOrderItem.Quantity__c = 1;
            objPartsOrderItem.Price__c = 1;
            insert objPartsOrderItem;

            Address__c objAddressBillTo = new Address__c();
            objAddressBillTo.ExternalId__c = 'Billto';

            Address__c objAddressShipTo = new Address__c();
            objAddressShipTo.ExternalId__c = 'Shipto';

            insert objAddressShipTo;
            insert objAddressBillTo;

            String strId = objPartsOrder.Id;
            IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_ORDER_PARTS', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPartSalesOrder/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(/', 'GET');
            insert ifMaster;

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strId));

            // 테스트 실행
            Test.startTest();
            IF_SFDC_SAP_REQ_ORDER_PARTS_qu job = new IF_SFDC_SAP_REQ_ORDER_PARTS_qu('all', 1000, 0);
            System.enqueueJob(job);
            Test.stopTest();

        } catch (Exception e) {
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
        }
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {

        private String strId;

        public HttpCalloutSuccessMock(String strId) {
            this.strId = strId;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);

            response.setBody('{"ResponseCode":"S", "ErrorMessage": "Success.", "PartOrders": [{"SFDCKey": "' + strId + '", "SFDCOrderType": "B", "BPCode": "000000000", "Shipto": "Shipto", "Billto": "Billto", "Remarks": "testRemarks", "SalesEmployee": "000000", "OrderType": "MO", "ShippingMode": "8113 Hwy 24 West", "DiscountMode": "65259", "PartialShipment": "65259", "OrderParts": [{"SFDCKey": "' + strId + '", "SAPKey": "000000", "LineNum": "01", "ItemCode": "18-011", "UnitPrice": 20, "Quantity": 10, "TotalPrice": 200}], "SAPKey": "65259", "TotalPrice": 1000, "DocumentDate": "2023-12-11", "DiscountRate": 20}]}');

            return response;
        }
    }
}