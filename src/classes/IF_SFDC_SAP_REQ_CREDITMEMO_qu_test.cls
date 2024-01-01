/*************************************************************************************
* File Name   : IF_SFDC_SAP_REQ_CREDITMEMO_qu_test.cls
* Author      : sy.Kang
* Date        : 2023.12.19
* Class       : IF_SFDC_SAP_REQ_CREDITMEMO_qu_test.cls
* Target      : CREDIT MEMO Queueable Method
* Description : Claim - A/R Credit Memo I/F
* Modification Log
* ===================================================================================
* Ver      Date            Author              Modification
* ===================================================================================
1.0      2023.12.19      sy.Kang             Create
<**************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_CREDITMEMO_qu_test {
    @IsTest
    static void testAll(){
        Account objAccount = new Account();
        objAccount.Name = 'Test Dealership';
        objAccount.LaborRate__c = 0.1;
        objAccount.Phone = '010-1234-1234';
        objAccount.Email__c = 'TestDealership@tymusa.com';
        objAccount.Active__c = 'Active';
        objAccount.BPCode__c = '000000000';
        insert objAccount;

        Case objClaim = new Case();
        objClaim.AccountId = objAccount.Id;
        objClaim.ClaimType__c = 'Retailed';
        objClaim.CauseCode__c = 'Cabin';
        objClaim.CauseCode2__c = 'Bent';
        objClaim.CauseCode3__c = 'Etc';
        objClaim.Subject = 'Test Claim';
        objClaim.FailureDate__c = Date.newInstance(2017, 12, 9);
        objClaim.RepairDate__c = Date.newInstance(2017, 12, 10);
        objClaim.Failure_Cause__c = 'fail';
        objClaim.Status = 'Accepted';
        objClaim.PhotOf0HourMeter__c = 'photo1';
        objClaim.PhotoOfSerialNumber__c = 'photo2';
        objClaim.PhotoTractoDuringRepair__c = 'photo3';
        insert objClaim;

        String strId = objClaim.Id;
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_CREDITMEMO', 'https://', 'GET');
        insert ifMaster;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock(strId));

        Test.startTest();
        try {
            System.enqueueJob(new IF_SFDC_SAP_REQ_CREDITMEMO_qu('all'));
            System.enqueueJob(new IF_SFDC_SAP_REQ_CREDITMEMO_qu('all', 1000));
            System.enqueueJob(new IF_SFDC_SAP_REQ_CREDITMEMO_qu('all', 1000, 0));
        } catch (Exception e) {
            System.assertEquals('ExpectedErrorMessage', e.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        private String strId;

        public HttpCalloutSuccessMock(String strId) {
            this.strId = strId;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"ResponseCode":"S","ErrorMessage":"","creditMemo":[{"SFDCKey":"' + strId + '","CreditMemo":"CM123","DealerCode":"D123"}],"isContinue":"Y"}');
            return response;
        }
    }
}