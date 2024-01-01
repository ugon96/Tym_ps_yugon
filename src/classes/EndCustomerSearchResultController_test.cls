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
private class EndCustomerSearchResultController_test {
    @IsTest
    static void TestStart() {
        Contact objContact = TestObjectCreator.objEndCustomer;
        insert objContact;

        Contact objSalesperson = TestObjectCreator.objSalesperson;
        insert objSalesperson;

        User objUser = new User();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            objUser = TestObjectCreator.objUserTYMDealer;
            objUser.ContactId = objSalesperson.Id;
            objUser.UserRoleId = null;
            insert objUser;
        }

        Test.startTest();
        System.runAs(objUser) {
            EndCustomerSearchResultController.getDealerData();
        }
        EndCustomerSearchResultController.doSearchCustomer('EndCustomer');
        Test.stopTest();
    }
}