/*
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PROD_qu_test
 * Author            : seungyeon.kang
 * Date              : 2023-12-01
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_ORDER_PROD_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-12-01       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ORDER_PROD_qu_test {

    @IsTest
    static void testExecute() {
        try {
            // 테스트 데이터 생성
            //Account testAccount = TestObjectCreator.objAccount;
            Account objAccount = new Account();
            objAccount.Name = 'Test Dealership';
            objAccount.LaborRate__c = 0.1;
            objAccount.Phone = '010-1234-1234';
            objAccount.Email__c = 'TestDealership@tymusa.com';
            objAccount.Active__c = 'Active';
            objAccount.BPCode__c = '000000000';
            insert objAccount;

            Orders__c objOrders = new Orders__c();
            objOrders.Dealership__c = objAccount.Id;
            objOrders.ExternalId__c = 'ExternalId';
            objOrders.Status__c = 'Created';
            objOrders.ApprovalNumber__c = '8f';
            objOrders.PONumber__c = '123';
            objOrders.FloorPlanCode__c = 'g456';
            insert objOrders;

            ProductOrderItem__c objProductOrderItem = new ProductOrderItem__c();
            objProductOrderItem.ExternalId__c = 'ExternalId';
            objProductOrderItem.Type__c = 'Tractor';
            objProductOrderItem.Quantity__c = 1;
            objProductOrderItem.Price__c = 1.0;
            //insert objProductOrderItem;

            String strId = objOrders.Id;
            IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_ORDER_PROD', 'https://', 'GET');
            insert ifMaster;

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strId));

            // 테스트 실행
            Test.startTest();
            IF_SFDC_SAP_REQ_ORDER_PROD_qu job = new IF_SFDC_SAP_REQ_ORDER_PROD_qu('all', 0, 1000);
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

            response.setBody('{"ResponseCode":"200", "ErrorMessage": "", "Data": [{"SFDCKey": "' + strId + '", "SFDCOrderType": "Type1", "SAPOtype": "OType1", "BPCode": "BP1", "ContactPerson": "strSalesPerson", "Shipto": "Shipto1", "Billto": "Billto1", "SalesEmployee": "SalesEmployee", "PaymentTerm": "PaymentTerm1", "Remarks": "Remark1", "OrderProducts": [{"SFDCKey": "'+ strId +'", "SAPKey": "SAP1", "LineNum": "1", "ItemCode": "Item1", "ItemGroupCode": "Group1", "UnitPrice": 50.0, "Quantity": 2.0, "TotalPrice": 90.0}], "Discount": 0.05, "DocumentDate": "2023-01-01", "SAPKey": "SAP1", "TotalPrice": 200.0}]}');

            return response;
        }
    }
}