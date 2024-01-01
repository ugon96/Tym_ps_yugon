/************************************************************************************
 * Description :
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2023-12-27       mw.jung          Create
*************************************************************************************/

@IsTest
private class DN_TestUtil_test {
    @IsTest
    static void testBehavior() {

        List<IFMaster__c> listIfMaster = new List<IFMaster__c>();
        IFMaster__c objIfMaster1 = new IFMaster__c(
                Name = '',
                Endpoint__c = '',
                Type__c = 'Outbound',
                ContentType__c = 'application/json',
                Method__c = 'GET',
                WebServiceType__c = 'REST'
        );
        listIfMaster.add(objIfMaster1);


        Account objAccount = TestObjectCreator.objAccount;
        Product2 objProduct = TestObjectCreator.objProductBackhoe;
        Product2 objProduct3 = TestObjectCreator.objProductTractor;
        Product2 objProduct4 = TestObjectCreator.objProductLoader;
        Contact objContact = TestObjectCreator.objSalesperson;
        Contact objContact2 = TestObjectCreator.objEndCustomer;

        insert objProduct;
        insert objProduct3;
        insert objProduct4;
        insert objContact;
        insert objContact2;

        DN_TestUtil.createIfMaster();
        DN_TestUtil.createIFMaster('name','endPoint','method');
        DN_TestUtil.createAccount();
        DN_TestUtil.createContactSalesPerson(objAccount);
        DN_TestUtil.createContactEndCustomer(objAccount);
        DN_TestUtil.createAssetTractor(objAccount,objProduct3);
        DN_TestUtil.createAssetLoader(objAccount,objProduct4);
        DN_TestUtil.createAssetBackhoe(objAccount,objProduct);

    }
}