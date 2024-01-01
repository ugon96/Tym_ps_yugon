/*
 * File Name   		: IF_SFDC_SAP_REQ_ORDER_PROD_ba
 * Author	  		: seungyeon.kang
 * Date				: 2023-11-28
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_ORDER_PROD_ba implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    List<Orders__c> listOrder = new List<Orders__c>();

    public List<Orders__c> start(Database.BatchableContext param1){
        System.debug('Start IF_SFDC_SAP_REQ_ORDER_PROD_ba ');
        //execute로 넘어가기 위해 아무거나 listOrder 설정
        listOrder = [
                SELECT Name
                FROM Orders__c
                WHERE Name = '00000010'
        ];
        System.debug('listOrder :: ' + listOrder);
        return listOrder;
    }

    public void execute(Database.BatchableContext param1, List<Orders__c> param2){
        System.debug('Execute IF_SFDC_SAP_REQ_ORDER_PROD_ba ');

        try {
//            IF_SFDC_SAP_REQ_ORDER_PROD ifSfdcSapReqOrderProd = new IF_SFDC_SAP_REQ_ORDER_PROD('new',500);
//            IF_SFDC_SAP_REQ_ORDER_PROD ifSfdcSapReqOrderProd = new IF_SFDC_SAP_REQ_ORDER_PROD('new');
//            ifSfdcSapReqOrderProd.execute();
            System.Queueable job = new IF_SFDC_SAP_REQ_ORDER_PROD('ALL', 0);
            System.enqueueJob(job);

        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REQ_ORDER_PROD_ba ');
    }

}