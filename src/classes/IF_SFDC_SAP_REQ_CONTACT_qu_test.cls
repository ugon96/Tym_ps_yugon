/*
 * File Name         : IF_SFDC_SAP_REQ_CONTACT_qu_test
 * Author            : nhKim
 * Date              : 2023-12-01
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_CONTACT_qu test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-12-01        nhKim                Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_CONTACT_qu_test {
    @IsTest
    static void testAll() {
        try {
            Account objAccount = new Account();
            objAccount.Name = 'Test Dealership';
            objAccount.LaborRate__c = 0.1;
            objAccount.Phone = '010-1234-1234';
            objAccount.Email__c = 'TestDealership@tymusa.com';
            objAccount.Active__c = 'Active';
            objAccount.BPCode__c = '000000000';
            insert objAccount;

            Contact objSalesperson = new Contact();
            objSalesperson.LastName = 'Test Salesperson';
            objSalesperson.AccountId = objAccount.Id;
            objSalesperson.UserStatus__c = 'Active';
            insert objSalesperson;

            IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_CONTACT', 'https://', 'GET');
            insert ifMaster;

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            Test.startTest();
            IF_SFDC_SAP_REQ_CONTACT_qu job = new IF_SFDC_SAP_REQ_CONTACT_qu('all', 1000, 0);
            System.enqueueJob(job);
            Test.stopTest();
        }catch (Exception e) {
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
        }
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"responseCode":"S","ErrorMessage":"","contactList":[{"ParentKey":"","LineNum":"","FirstName":"","MiddleName":"","LastName":"","Phone":"","MobilePhone":"","Email":"","Gender":"F","Active":"","Address":"","ContactId":""}]}');
            return response;
        }
    }
}