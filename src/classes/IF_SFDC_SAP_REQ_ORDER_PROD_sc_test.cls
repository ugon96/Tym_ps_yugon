/**
 * Created by sy.kang on 2023-12-28.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_ORDER_PROD_sc_test {
    @IsTest
    static void doTest() {
        Test.startTest();

        IF_SFDC_SAP_REQ_ORDER_PROD_sc sc = new IF_SFDC_SAP_REQ_ORDER_PROD_sc('ALL', 5000);
        String sch = '0 1 * * * ?';
        String jobID = system.schedule('order_prod update job', sch, sc);
        System.debug(jobID);
        Test.stopTest();
    }
}