@isTest
public with sharing class TYM_retailProgramCloneController_TEST {

    @isTest
    static void testHandeler() {
        Test.startTest();
        Map<String, String> retailMap = new Map<String, String>();
        retailMap.put('name', 'test');
        retailMap.put('startDate', '2023-12-05');
        retailMap.put('endDate', '2023-12-06');
        RetailProgramMaster__c rp = TestObjectCreator.objRetailProgramMaster;
        insert rp;
        RetailProgramMasterItem__c rpmi = TestObjectCreator.objRetailProgramMasterItem;
        insert rpmi;
        PayoutStructure__c ps = TestObjectCreator.objPayoutStructure;
        insert ps;

        TYM_retailProgramCloneController.retailProgramClone(rp.Id, retailMap);


        Test.stopTest();


    }
    
}