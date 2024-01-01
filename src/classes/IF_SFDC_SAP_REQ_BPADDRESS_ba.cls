/*
 * File Name   		: IF_SFDC_SAP_REQ_BPADDRESS_ba
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       taekyun.yoon        Initial Version
*************************************************************************************/
/*
    수동 배치 실행 테스트 :
    IF_SFDC_SAP_REQ_BPADDRESS_ba ba = new IF_SFDC_SAP_REQ_BPADDRESS_ba();
    Database.executeBatch(ba, 100);
 */
public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_ba implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    List<Address__c> listTargetAddress = new List<Address__c>();
//    IF_SFDC_SAP_REQ_BPADDRESS_qu_test ifSfdcSapReqBpaddressTest = new IF_SFDC_SAP_REQ_BPADDRESS_qu_test('new');
//
    public List<Address__c> start(Database.BatchableContext param1){
//        List<Address__c> listBPAddress = ifSfdcSapReqBpaddressTest.getAddressList();
//        return listBPAddress;


        System.debug('Start IF_SFDC_SAP_REQ_BPADDRESS_ba ');
        //execute로 넘어가기 위해 아무거나 listTargetAddress 설정
        listTargetAddress = [
                SELECT Id, ExternalId__c, Name, Address__Street__s, Address__PostalCode__s, Address__City__s, Address__CountryCode__s, Address__StateCode__s, BillorShip__c
                FROM Address__c
                WHERE Address__City__s = 'Atlanta'
        ];
        System.debug('listTargetAddress :: ' + listTargetAddress);
        return listTargetAddress;
    }

    public void execute(Database.BatchableContext param1, List<Address__c> param2){
        System.debug('Execute IF_SFDC_SAP_REQ_BPADDRESS_ba ');
//        ifSfdcSapReqBpaddressTest.execute(param2);

//
        try {
//            IF_SFDC_SAP_REQ_BPADDRESS_qu ifSfdcSapReqBpaddress = new IF_SFDC_SAP_REQ_BPADDRESS_qu('new',500);
//            IF_SFDC_SAP_REQ_BPADDRESS_qu ifSfdcSapReqBpaddress = new IF_SFDC_SAP_REQ_BPADDRESS_qu('new');
//            System.debug('Set ifSfdcSapReqBpaddress Constructor complete ');
//            ifSfdcSapReqBpaddress.execute();

//            System.Queueable job = new IF_SFDC_SAP_REQ_BPADDRESS_qu('new');
//            System.enqueueJob(job);
        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REQ_BPADDRESS_ba ');
    }

}