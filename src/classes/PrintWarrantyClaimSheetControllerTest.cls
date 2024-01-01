@isTest
public with sharing class PrintWarrantyClaimSheetControllerTest {

    @isTest
    static void testInitData() {
        Test.startTest();
        
        Case c = TestObjectCreator.objClaim;
        insert c;
        
        Parts__c part = TestObjectCreator.objParts;
        part.ClaimId__c = c.Id;
        insert part;
        
        Test.setCurrentPageReference(new PageReference('/apex/PrintWarrantyClaimSheet?id=' + c.Id));
        PrintWarrantyClaimSheetController controller = new PrintWarrantyClaimSheetController();
    

        Test.stopTest();

    }
    
    @isTest
    static void tesDoGetInitData() {
        Test.startTest();
        PrintWarrantyClaimSheetController.doGetInitData();
        Test.stopTest();
    }

    @isTest
    static void tesDoSavePdf() {
        Test.startTest();
        Case c = TestObjectCreator.objClaim;
        insert c;

        String pdfType = 'PI';

        PrintWarrantyClaimSheetController.doSavePdf(c.Id, pdfType);
        
        Test.stopTest();

    }






}