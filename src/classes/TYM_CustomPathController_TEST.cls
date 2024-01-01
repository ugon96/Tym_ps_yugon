/*************************************************************
 * @author : th.kim
 * @date : 2023-11-27
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-27      th.kim         Initial Version
**************************************************************/

@IsTest
public with sharing class TYM_CustomPathController_TEST {

    static Case claim;

    static {
        claim = new Case(
                Status = 'Created',
                IsPhotoHourMeter__c = false,
                IsPhotoSerialNo__c = false,
                IsPhotoRepair__c = false,
                IsPhotoFailurePart__c = false,
                CauseCode__c = 'Backhoe',
                CauseCode2__c = 'Leakage',
                ClaimType__c = 'In Stock'
        );
        insert claim;
    }

    @IsTest
    static void testGetPathStatus() {
        Test.startTest();
        TYM_CustomPathController.getPathStatus(claim.Id);
        Test.stopTest();
    }
}