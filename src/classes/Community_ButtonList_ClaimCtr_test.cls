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
public with sharing class Community_ButtonList_ClaimCtr_test {
    @IsTest
    static void TestStart(){
        Case objCase = TestObjectCreator.objClaim;
        insert objCase;

        Test.startTest();
        Community_ButtonList_ClaimController.doInit(objCase.Id);

        Test.stopTest();
    }
}