/*
 * File Name   		: IF_SFDC_SAP_REG_CLAIM_sc_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-12-26
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REG_CLAIM_sc 테스트 클래스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-26       taekyun.yoon           Initial Version
**/

@IsTest
public with sharing class IF_SFDC_SAP_REG_CLAIM_sc_test {
    @IsTest
    static void testAll() {
        String cronExpr = '0 0 * * * ?';
        Test.startTest();
        IF_SFDC_SAP_REG_CLAIM_sc regClaimSc = new IF_SFDC_SAP_REG_CLAIM_sc();
        System.schedule('postClaim',cronExpr,regClaimSc);
        Test.stopTest();
    }
}