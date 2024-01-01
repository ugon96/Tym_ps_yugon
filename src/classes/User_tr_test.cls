/************************************************************************************
 * File Name   		: User_tr_test
 * Author	  		: jiae.tak@daeunextier.com
 * Date				: 2023-12-27
 * @Group              : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-27       jiae.tak@daeunextier.com         Initial Version
*************************************************************************************/

@IsTest
public with sharing class User_tr_test {
    @IsTest
    static void TestStart(){
        Test.startTest();
        Contact objSalesperson = TestObjectCreator.objSalesperson;
        insert objSalesperson;

        System.runAs(new User(Id = UserInfo.getUserId())){
            User objUser = TestObjectCreator.objUserTYMDealer;
            objUser.ContactId = objSalesperson.Id;
            objUser.UserRoleId= null;
            insert objUser;
        }

        Test.stopTest();
    }
}