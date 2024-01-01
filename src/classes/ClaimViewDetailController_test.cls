/*************************************************************
 * @author : jiae.tak
 * @date : 2023-12-26
 * @group : daeunextier
 * @group-content :
 * @description : ClaimViewDetailController 테스트 클래스
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-26      jiae.tak       Initial Version
**************************************************************/
@IsTest
public with sharing class ClaimViewDetailController_test {
    @IsTest
    static void TestStart(){
        Case objCase = TestObjectCreator.objClaim;
        insert objCase;

        LaborCode__c objLaborCode = TestObjectCreator.objLaborCode;
        insert objLaborCode;

        LaborCode__c objLaborCode2 = objLaborCode.clone();
        insert objLaborCode2;

        Parts__c objParts = TestObjectCreator.objParts;
        insert objParts;

        Parts__c objParts2 = objParts.clone();
        insert objParts2;

        ARInvoiceItem__c objArInvoiceItem = TestObjectCreator.objARInvoiceItem;
        insert objArInvoiceItem;

        List<LaborCode__c> listLaborCode = new List<LaborCode__c>();
        listLaborCode.add(objLaborCode);

        List<LaborCode__c> listLaborCode2 = new List<LaborCode__c>();
        listLaborCode2.add(objLaborCode2);

        List<Parts__c> listParts = new List<Parts__c>();
        listParts.add(objParts);

        List<Parts__c> listParts2 = new List<Parts__c>();
        listParts2.add(objParts2);


        String listLaborCodeToStr = JSON.serialize(listLaborCode);
        String listLaborCodeToStr2 = JSON.serialize(listLaborCode2);
        String listPartsToStr = JSON.serialize(listParts);
        String listPartsToStr2 = JSON.serialize(listParts2);

        Test.startTest();
        ClaimViewDetailController.getInitData(objCase.Id);
        ClaimViewDetailController.saveRecord(listLaborCodeToStr, listLaborCodeToStr2, listPartsToStr, listPartsToStr2);
        ClaimViewDetailController.getInvoiceNumber(objArInvoiceItem.Product__c, objArInvoiceItem.ARInvoiceMaster__r.Dealership__c);

        Test.stopTest();
    }

    @IsTest
    static void TestStart2(){
        LaborCodeMaster__c objLaborCodeMaster = TestObjectCreator.objLaborCodeMaster;
        objLaborCodeMaster.Diagram__c = '1905H_TM';
        insert objLaborCodeMaster;

        Product2 objProduct = TestObjectCreator.objProductTractor;
        insert objProduct;

        PriceList__c objPriceList = TestObjectCreator.objPriceList;
        insert objPriceList;

        PriceListEntry__c objPriceListEntry = TestObjectCreator.objPriceListEntry;
        insert objPriceListEntry;


        Test.startTest();
        ClaimViewDetailController.getInitAddModal('1905H');
        ClaimViewDetailController.searchLaborMaster('1905H','1905H_TM', '1905H_TM', '1905H_TM', '1905H_TM');
        ClaimViewDetailController.getPartsValue(objProduct.Id, objPriceList.Id, 1.0);

        Test.stopTest();

    }
}