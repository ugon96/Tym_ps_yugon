/**
 * Created by 천유정 on 2023-12-26.
 */
@IsTest
private class ApprovalLineController_test {

    @IsTest
    static void doTest() {

        Test.startTest();
        Profile p = [select id from Profile where Name='System Administrator'];

        User user1 = TestObjectCreator.objUserTYMUSA;
        user1.ApprovalLine1__c = '';
        user1.ApprovalLine2__c = '';
        user1.ApprovalLine3__c = '';
        user1.ApprovalLine4__c = '';

        User user2 = new User(Alias = 'testUr2'
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

        User user3 = new User(Alias = 'testUr3'
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

        System.runAs(user1){
            ApprovalLineController.getApprovalLines(user1.Id);
        }
        ApprovalLineController.doDelete('sId',user1,'fieldName');
        Test.stopTest();

    }
}