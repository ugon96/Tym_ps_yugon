/************************************************************************************
 * File Name   		: DN_ExecuteAsync_test
 * Author	  		: jiae.tak@daeunexiter.com
 * Date				: 2023-12-27
 * @Group              : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-27       jiae.tak@daeunexiter.com         Initial Version
*************************************************************************************/

@IsTest
public with sharing class DN_ExecuteAsync_test {
    @IsTest
    static void TestStart(){
 /*       String strObject = '{"CARDCD": "123", "Count": 5}';
        String strObject1 = '{"ItemCode": "123", "Count": 5}';
        String strObject2 = '{"PriceList": "123", "Count": 5}';
        String strObject3 = '{"PriceList": "123", "Count": 5, "ItemGroupCode": 5, "ItemCode": 5, "inputCurrency": 5}';
        String strObject4 = '{"DocNum": "123", "Count": 5}';
        String strObject5 = '{"DocEntry": "123", "Count": 5}';
        String strObject6 = '{"BPCode": "123", "Count": 5}';
        String strObject7 = '{"Type": "123", "Count": 5}';

        Test.startTest();
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_BPACCOUNT','1' , strObject);
//        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_BPADDRESS','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_CONTACT','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_ITEM','1' , strObject1);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_PRICELISTMST','1' , strObject2);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_PRICELISTETR','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_PRICELISTETR','2' , strObject3);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_ORDER_PROD','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_ORDER_PARTS','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_AR','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_MASTERDATA','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_PARTSIVT','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_FINISHEDGOODS_qu','1' , strObject);
        DN_ExecuteAsync.doExecute('IF_SFDC_SAP_REQ_CREDITMEMO','1' , strObject);
        Test.stopTest();*/
    }
}