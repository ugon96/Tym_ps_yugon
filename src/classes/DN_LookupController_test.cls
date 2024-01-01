/**
 * Created by 천유정 on 2022-08-17.
 */

@IsTest
private class DN_LookupController_test {
    @IsTest(SeeAllData=true)
    static void unitTest() {
        String queryString = 'SELECT Id, Name FROM Product2 WHERE IsActive = true LIMIT 1000';
        DN_LookupController.querySalesforceRecord(queryString);
        String queryString1 = 'SELECT Id, Name FROM User LIMIT 1000';
        String queryString2 = 'SELECT Id, Name FROM Asset LIMIT 1000';
        String queryString3 = 'SELECT Id, Name FROM Contact LIMIT 1000';
        DN_LookupController.getLookupDatas(queryString, 'Product2', new List<String>{'Name'}, '', 'Product', null);
        DN_LookupController.getLookupDatas(queryString1, 'User', new List<String>{'Name'}, '', 'User', null);
        DN_LookupController.getLookupDatas(queryString2, 'Asset', new List<String>{'Name'}, '', 'Asset', null);
        DN_LookupController.getLookupDatas(queryString3, 'Contact', new List<String>{'Name'}, '', 'Contact', null);
    }
}