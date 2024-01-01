/**
 * Created by 천유정 on 2023-12-26.
 */

@IsTest
public with sharing class IF_SFDC_SAP_REQ_FINISHEDGOODS_sc_test {
    @IsTest
    static void doTest() {
        Test.startTest();

        IF_SFDC_SAP_REQ_FINISHEDGOODS_sc sc = new IF_SFDC_SAP_REQ_FINISHEDGOODS_sc('ALL', 5000);
        String sch = '0 1 * * * ?';
        String jobID = system.schedule('FinishedGoods update job', sch, sc);
        System.debug(jobID);
        Test.stopTest();
    }
}