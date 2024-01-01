/************************************************************************************
 * File Name   		: CreateRegistrationController_test
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-11-17
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-17       ugon96@gmail.com         Initial Version
*************************************************************************************/

@IsTest
private class CreateRegistrationController_test {
    @TestSetup
    static void testSetup() {

    }
    @IsTest
    static void testGetDealerDate() {
        CreateRegistrationController.getDealerData();
    }
    @IsTest
    static void testDoCreateRegistration() {
        CreateRegistrationController.doCreateRegistration('','','', Date.today().addDays(-7), 'Stock');
        CreateRegistrationController.doCreateRegistration('','','', Date.today().addDays(-7), 'Commercial');
    }
    @IsTest
    static void testGetConnectedAssetInformation() {
        CreateRegistrationController.getConnectedAssetInformation('');
    }
}