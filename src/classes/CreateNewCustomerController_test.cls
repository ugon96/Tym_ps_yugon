/************************************************************************************
 * Description :
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2023-12-26       DAEU          Create
*************************************************************************************/

@IsTest
private class CreateNewCustomerController_test {
    @IsTest
    static void testBehavior() {

        CreateNewCustomerController.doCreateCustomer('fName','lName','phone','mobile','email','address');

        Contact objContact = TestObjectCreator.objEndCustomer;
        objContact.Email = 'Email@gmail.com';
        objContact.Mobile__c = 'Mobile';
        objContact.PhoneNumber__c = 'Phone';
        objContact.Address__c = 'Address';
        insert objContact;

    }
}