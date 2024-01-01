/*
 * File Name   		: IF_SFDC_SAP_REQ_PRICELISTR_qu_sc_test
 * Author	  		: seungyeon.kang
 * Date				: 2023-12-05
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_sc_test {
    @IsTest
    static void doTest() {
        Test.startTest();

        IF_SFDC_SAP_REQ_PRICELISTETR_sc scNoPam = new IF_SFDC_SAP_REQ_PRICELISTETR_sc();
        IF_SFDC_SAP_REQ_PRICELISTETR_sc sc = new IF_SFDC_SAP_REQ_PRICELISTETR_sc('ALL', 5000);
        String sch = '0 1 * * * ?';
        String jobID = system.schedule('Partsivt update job', sch, sc);
        System.debug(jobID);
        Test.stopTest();
    }
}