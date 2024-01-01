/*
 * File Name   		: IF_SFDC_SAP_REQ_BPADDRESS_sc
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-23
 * @Group           : Daeunextier
 * Description 		: 10분마다 IF_SFDC_SAP_REQ_BPADDRESS_qu 실행하는 스케줄러 클래스 ( count default: 1000 )
                      IF_SFDC_SAP_REQ_BPACCOUNT 스케줄러(0분, 10분, 20분, 30분, 40분, 50분) 다음 실행 :
                      스케줄러 등록 시 사용
                      //IF_SFDC_SAP_REQ_BPADDRESS_SC sc = new IF_SFDC_SAP_REQ_BPADDRESS_SC();
                      //String sch = '0 1 * * * ?';
                      //String jobID = system.schedule('Address update job every 1 min', sch, sc);
                      //sch = '0 11 * * * ?';
                      //jobID = system.schedule('Address update job every 11 min', sch, sc);
                      //sch = '0 21 * * * ?';
                      //jobID = system.schedule('Address update job every 21 min', sch, sc);
                      //sch = '0 31 * * * ?';
                      //jobID = system.schedule('Address update job every 31 min', sch, sc);
                      //sch = '0 41 * * * ?';
                      //jobID = system.schedule('Address update job every 41 min', sch, sc);
                      //sch = '0 51 * * * ?';
                      //jobID = system.schedule('Address update job every 51 min', sch, sc);
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-23       taekyun.yoon           Initial Version
**/
public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_sc implements Schedulable{
    public void execute(SchedulableContext sc) {
        System.Queueable job = new IF_SFDC_SAP_REQ_BPADDRESS_qu('all', 1000,0);
        System.enqueueJob(job);
    }
}