/************************************************************************************
 * Description :
 *
 * Ver         Date           Author         Modification
 * ===================================================================================
 * 1.0      2023-10-31      Taejun.Kang         Create
*************************************************************************************/
@isTest
private class ApprovalLinesController_Test {

    /*@isTest
    static void doTest() {
        //필요한 Obj  ----->  User_tr
        Test.startTest();
        Profile p = [select id from Profile where Name='System Administrator'];

        User_tr user1 = TestObjectCreator.objUser;
        user1.ApprovalLine1__c = '';
        user1.ApprovalLine2__c = '';
        user1.ApprovalLine3__c = '';
        user1.ApprovalLine4__c = '';

        User_tr user2 = new User_tr(Alias = 'testUr2'
                , Email='SysAdminTestuser@earth.org2'
                , EmailEncodingKey='UTF-8'
                , LastName='Testing'
                , LanguageLocaleKey='en_US'
                , LocaleSidKey='en_US'
                , ProfileId = p.Id
                , EmployeeNumber='AC100000'
                , TimeZoneSidKey='Asia/Seoul'
                , UserName='SysAdminTestuser@earth.org2'
                , ApprovalLine1__c = ''
                , ApprovalLine2__c = ''
                , ApprovalLine3__c = ''
                , ApprovalLine4__c = '');

        User_tr user3 = new User_tr(Alias = 'testUr3'
                , Email='SysAdminTestuser@earth.org3'
                , EmailEncodingKey='UTF-8'
                , LastName='Testing'
                , LanguageLocaleKey='en_US'
                , LocaleSidKey='en_US'
                , ProfileId = p.Id
                , EmployeeNumber='AC100000'
                , TimeZoneSidKey='Asia/Seoul'
                , UserName='SysAdminTestuser@earth.org3'
                , ApprovalLine1__c = ''
                , ApprovalLine2__c = ''
                , ApprovalLine3__c = ''
                , ApprovalLine4__c = '' );

        insert user1;
        insert user2;
        insert user3;

        user1.ApprovalLine1__c = 'ApprovalLine1__c/ApprovalLine1__c/'+ user2.Id;
        user1.ApprovalLine2__c = 'ApprovalLine2__c/ApprovalLine2__c/'+ user2.Id+ '/' +user3.Id;
        user1.ApprovalLine3__c = 'ApprovalLine3__c/ApprovalLine3__c/'+ user3.Id;
        user1.ApprovalLine4__c = 'ApprovalLine4__c/ApprovalLine4__c/'+ user2.Id;
        update user1;


        ApprovalLinesController.getApprovalLines(user1.Id);
        ApprovalLinesController.getApprovalLines(user2.Id);
        ApprovalLinesController.doDelete(user2.Id, user2, 'ApprovalLine1__c');

        Test.stopTest();

    }*/
}