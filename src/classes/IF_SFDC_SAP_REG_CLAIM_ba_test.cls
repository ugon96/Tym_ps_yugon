/*
 * File Name   		: IF_SFDC_SAP_REG_CLAIM_ba_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-12-26
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REG_CLAIM_ba 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-26       taekyun.yoon           Initial Version
**/

@IsTest
public with sharing class IF_SFDC_SAP_REG_CLAIM_ba_test {

    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REG_CLAIM',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/PostClaim',
                'POST');

    }

    private static HTTPResponse response(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        String responseBody = '{' +
                '"ResponseCode": "S",' +
                '"ErrorMessage": "Success.",' +
                '"ErrorList": [' +
                '{' +
                '}' +
                ']' +
                '}';
        res.setBody(responseBody);

        return res;
    }
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = response(200);
            return res;
        }
    }
    private class HttpCalloutFailMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = response(404);
            return res;
        }
    }

    @IsTest
    static void doTest() {
        Test.startTest();

        Case objCase = TestObjectCreator.objClaim;
        objCase.Account = TestObjectCreator.objAccount;
        objCase.Asset = TestObjectCreator.objAssetTractor;
        insert objCase;

        Parts__c objPart1 = new Parts__c();
        objPart1 = TestObjectCreator.objParts;
        objPart1.ClaimId__c = objCase.Id;
        insert objPart1;

        LaborCode__c objLaborCode = new LaborCode__c();
        objLaborCode = TestObjectCreator.objLaborCode;
        objLaborCode.ClaimId__c = objCase.Id;
        insert objLaborCode;


        List<Case> listCase = new List<Case>();
        listCase = [
                SELECT Id, AssetId,
                        Account.BPCode__c,
                        Asset.RecordTypeId,
                        Asset.SerialNumber,
                        Asset.LoaderId__r.SerialNumber,
                        Asset.BackhoeId__r.SerialNumber,
                        Asset.MidMountMower__r.SerialNumber,
                        Asset.Cabin__r.SerialNumber,
                        Asset.RetailedDate__c,
                        UsageTime__c,
                        ru_TotalApprovedLaborCost__c,
                        ru_TotalApprovedPartsAmount__c,
                        ru_TotalRequestShippnig__c,
                        ru_TotalApprovedShipping__c,
                        fm_TotalApprovedAmount__c,
                        CauseCode__c,
                        CauseCode2__c,
                        CauseCode3__c,
                        Failure_Cause__c,
                        DescriptionOfFailure__c,
                        FailureDate__c,
                        Repair__c,
                        RepairDate__c,
                        ClaimType__c,
                        AdminNotes__c,
                        Asset.EngineSerialNumber__c,
                        Status,
                (SELECT Id, Name, ClaimId__c, PartDescription__c,Quantity__c,fm_Amount__c,ApprovedQuantity__c,
                        ApprovedPartValue__c, fm_ApprovedAmount__c,PartValue__c, InvoiceItem__c,
                        InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c FROM PartsClaim__r),
                (SELECT Id, Name, ClaimId__c, fm_Model__c,fm_LaborGroup__c,fm_Diagram__c,fm_Description__c,LaborHour__c, fm_LaborCode__c,
                        ApprovedLaborHour__c, Remarks__c FROM LaborCodeClaim__r)
                FROM Case
                WHERE Status = 'Accepted' AND IsSendtoSAP__c = FALSE
        ];


        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());


        IF_SFDC_SAP_REG_CLAIM_ba ba = new IF_SFDC_SAP_REG_CLAIM_ba();
        Database.executeBatch(ba, 500);



        Test.stopTest();
    }
}