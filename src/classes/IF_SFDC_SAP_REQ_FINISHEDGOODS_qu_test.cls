/*************************************************************************************
* File Name   : IF_SFDC_SAP_REQ_FINISHEDGOODS_qu_test.cls
* Author      : sy.Kang
* Date        : 2023.12.20
* Class       : IF_SFDC_SAP_REQ_FINISHEDGOODS_qu_test.cls
* Target      : FINISHEDGOODS
* Description : IF_SFDC_SAP_REQ_FINISHEDGOODS_qu test class
* Modification Log
* ===================================================================================
* Ver      Date            Author              Modification
* ===================================================================================
1.0      2023.12.20      sy.Kang                Create
<**************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_FINISHEDGOODS_qu_test {
    @IsTest
    static void testAll(){

        Product2 objProductTractor = new Product2();
        objProductTractor.ProductName__c = 'Test Product';
        objProductTractor.ProductCode = 'objProductTractor';
        objProductTractor.Name = 'objProductTractor';
        objProductTractor.ItemGroupCode__c = '112';
        objProductTractor.Tractor__c = null;
        objProductTractor.IsActive = true;
        objProductTractor.LP__c = false;
        objProductTractor.ExternalId__c = 'AC00070';
        insert objProductTractor;

        Product2 objProductTractor113 = new Product2();
        objProductTractor113.ProductName__c = 'Test Product113';
        objProductTractor113.ProductCode = 'objProductTractor113';
        objProductTractor113.Name = 'objProductTractor113';
        objProductTractor113.ItemGroupCode__c = '113';
        objProductTractor113.IsActive = true;
        objProductTractor113.LP__c = false;
        objProductTractor113.ExternalId__c = 'BZ00381';
        insert objProductTractor113;

        Product2 objProductTractor114 = new Product2();
        objProductTractor114.ProductName__c = 'Test Product114';
        objProductTractor114.ProductCode = 'objProductTractor114';
        objProductTractor114.Name = 'objProductTractor114';
        objProductTractor114.ItemGroupCode__c = '114';
        objProductTractor114.IsActive = true;
        objProductTractor114.LP__c = false;
        objProductTractor114.ExternalId__c = 'BZ00379';
        insert objProductTractor114;

        Product2 objProductTractor115 = new Product2();
        objProductTractor115.ProductName__c = 'Test Product115';
        objProductTractor115.ProductCode = 'objProductTractor115';
        objProductTractor115.Name = 'objProductTractor115';
        objProductTractor115.ItemGroupCode__c = '115';
        objProductTractor115.IsActive = true;
        objProductTractor115.LP__c = false;
        objProductTractor115.ExternalId__c = 'BZ00370';
        insert objProductTractor115;

        Product2 objProductTractor116 = new Product2();
        objProductTractor116.ProductName__c = 'Test Product116';
        objProductTractor116.ProductCode = 'objProductTractor116';
        objProductTractor116.Name = 'objProductTractor116';
        objProductTractor116.ItemGroupCode__c = '116';
        objProductTractor116.IsActive = true;
        objProductTractor116.LP__c = false;
        objProductTractor116.ExternalId__c = 'BZ00376';
        insert objProductTractor116;

        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_FINISHEDGOODS', 'https://', 'GET');
        insert ifMaster;

        String strId = objProductTractor.ExternalId__c;

        Test.startTest();
        try {
            Map<String, Product2> mapProduct = new Map<String, Product2>();
            mapProduct.put(strId, objProductTractor);

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strId, mapProduct));

            System.enqueueJob(new IF_SFDC_SAP_REQ_FINISHEDGOODS_qu('all',10000)) ;
            System.enqueueJob(new IF_SFDC_SAP_REQ_FINISHEDGOODS_qu('all', 10000, 0)) ;
        } catch (Exception e) {
            System.assertEquals('ExpectedErrorMessage', e.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        private final String strId;
        private final Map<String, Product2> mapProduct;

        public HttpCalloutSuccessMock(String strId, Map<String, Product2> mapProduct) {
            this.strId = strId;
            this.mapProduct = mapProduct;
        }
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{ "ErrorMessage": "Success", "ResponseCode": "S", "isContinue": "N", "BOMList": [ { "ChildNum": 2, "ComponentCode": "AC00070", "ItemGroupCode": "112", "ParentItem": "'+ strId +'", "Quantity": 1, "isContinue": "N" }, { "ChildNum": 3, "ComponentCode": "BZ00381", "ItemGroupCode": "113", "ParentItem": "'+ strId +'", "Quantity": 2, "isContinue": "N" }, { "ChildNum": 4, "ComponentCode": "BZ00379", "ItemGroupCode": "114", "ParentItem": "'+ strId +'", "Quantity": 2, "isContinue": "N" },{ "ChildNum": 4, "ComponentCode": "BZ00370", "ItemGroupCode": "115", "ParentItem": "'+ strId +'", "Quantity": 2, "isContinue": "N" },{ "ChildNum": 4, "ComponentCode": "BZ00376", "ItemGroupCode": "116", "ParentItem": "'+ strId +'", "Quantity": 2, "isContinue": "N" }]}');
            return response;
        }
    }
}