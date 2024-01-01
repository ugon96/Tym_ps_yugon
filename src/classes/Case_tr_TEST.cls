@isTest
private with sharing class Case_tr_TEST {

    @isTest
    static void testHandeler() {
        Test.startTest();
        Case claim = TestObjectCreator.objClaim;
        claim.ClaimType__c = 'Retailed';

        claim.Status = 'Received';
        insert claim;

        claim.Status = 'Received';
        update claim;

        claim.Status = 'Created';
        update claim;

        claim.Status = 'Submitted';
        update claim;

        claim.Status = 'Received';
        update claim;
        
        claim.Status = 'Rejected';
        update claim;

        claim.Status = 'Under Review';
        update claim;

        claim.Status = 'Submitted';
        update claim;
        
        delete claim;
        
        Test.stopTest();

    }
}