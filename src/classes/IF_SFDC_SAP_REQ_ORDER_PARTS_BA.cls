/*
 * File Name   		: IF_SFDC_SAP_REQ_ORDER_PARTS_BA
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-27
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-27      taekyun.yoon        Initial Version
*************************************************************************************/
/*
    수동 배치 실행 테스트 :
    IF_SFDC_SAP_REQ_ORDER_PARTS_BA ba = new IF_SFDC_SAP_REQ_ORDER_PARTS_BA();
    Database.executeBatch(ba, 100);
 */
public with sharing class IF_SFDC_SAP_REQ_ORDER_PARTS_BA implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    List<PartsOrder__c> listPartsOrder = new List<PartsOrder__c>();

    public List<PartsOrder__c> start(Database.BatchableContext param1){
        System.debug('Start IF_SFDC_SAP_REQ_ORDER_PARTS_BA ');
        //execute로 넘어가기 위해 아무거나 listPartsOrder 설정
        listPartsOrder = [
                SELECT Id, Name
                FROM PartsOrder__c
                WHERE Name = 'PO-0000004'
        ];
        System.debug('listPartsOrder :: ' + listPartsOrder);
        return listPartsOrder;
    }

    public void execute(Database.BatchableContext param1, List<PartsOrder__c> param2){
        System.debug('Execute IF_SFDC_SAP_REQ_ORDER_PARTS_BA ');

        try {
////            IF_SFDC_SAP_REQ_ORDER_PARTS_qu ifSfdcSapReqOrderParts = new IF_SFDC_SAP_REQ_ORDER_PARTS_qu('new',500);
//            IF_SFDC_SAP_REQ_ORDER_PARTS_qu ifSfdcSapReqOrderParts = new IF_SFDC_SAP_REQ_ORDER_PARTS_qu('new');
//            ifSfdcSapReqOrderParts.execute();
        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REQ_ORDER_PARTS_BA ');
    }

}