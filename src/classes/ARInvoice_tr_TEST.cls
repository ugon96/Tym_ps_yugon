/*************************************************************
 * @author : th.kim
 * @date : 2023-12-05
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-05      th.kim         Initial Version
**************************************************************/
@IsTest
public with sharing class ARInvoice_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();

        PartsOrder__c partsOrder = TestObjectCreator.objPartsOrder;
        insert partsOrder;

        ARInvoice__c arInvoice = TestObjectCreator.objARInvoice;
        arInvoice.PartsOrderId__c = partsOrder.Id;
        insert arInvoice;

        Asset asset = TestObjectCreator.objAssetLoader;
        insert asset;
        asset.InvoiceDate__c = Date.today();
        update asset;

        Test.stopTest();
    }
}

//Asset asset = [SELECT Id, InvoiceDate__c FROM Asset WHERE OrdersId__c = :partsOrder.Id LIMIT 1];
//System.assertEquals(Date.today(), asset.InvoiceDate__c, 'Invoice Date should be updated to today');