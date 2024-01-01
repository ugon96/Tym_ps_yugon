/**
 * Created by nhkim on 2023-12-06.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_sc_test {
    @IsTest
    static void testAll() {
        IFMaster__c ifMaster = DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_PRICELISTMST', 'https://wcf.tymerpcloud.com:9447/Service1.svc/GetPriceListMasterList/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(', 'GET');
        insert ifMaster;

        String cronExpr = '0 0 * * * ?';
        Test.startTest();
        IF_SFDC_SAP_REQ_PRICELISTMST_sc priceListMstSc = new IF_SFDC_SAP_REQ_PRICELISTMST_sc();
        System.schedule('getPriceListMst',cronExpr,priceListMstSc);
        Test.stopTest();
    }
}