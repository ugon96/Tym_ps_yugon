/*
 * File Name   		: IF_SFDC_SAP_REQ_ITEM_sc_test
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-23
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_ITEM_qu 스케줄링 작업
                      //매일 00시마다 IF_SFDC_SAP_REQ_ITEM_qu 실행
                      //IF_SFDC_SAP_REQ_ITEM_sc sc = new sc();
                      //String sch = '0 0 0 * * ?';
                      //String jobID = system.schedule('Item upsert job 00:00 every day', sch, sc);
                      //System.debug(jobID);
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-23       taekyun.yoon        Initial Version
*/

public with sharing class IF_SFDC_SAP_REQ_ITEM_sc implements Schedulable{
    public void execute(SchedulableContext sc) {
        System.Queueable job = new IF_SFDC_SAP_REQ_ITEM_qu('ALL', 1000, 0);
        System.enqueueJob(job);

    }
}