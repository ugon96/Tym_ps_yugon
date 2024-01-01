/**
 * Created by DAEU on 2023-11-27.
 */
/*
//  10분마다 N건 IF_SFDC_SAP_REQ_BPADDRESS_ba 배치 실행
IF_SFDC_SAP_REQ_ORDER_PARTS_sc sc = new IF_SFDC_SAP_REQ_ORDER_PARTS_sc();
String sch = '0 0/10 * * * ?';
String sch = '0 36 11 * * * ?';
String jobID = system.schedule('PartsOrder update job', sch, sc);
System.debug(jobID);
*/
public with sharing class IF_SFDC_SAP_REQ_ORDER_PARTS_sc implements Schedulable{
    public void execute(SchedulableContext sc) {
        System.debug('Start || IF_SFDC_SAP_REQ_ORDER_PARTS_sc');
        IF_SFDC_SAP_REQ_ORDER_PARTS_BA ba = new IF_SFDC_SAP_REQ_ORDER_PARTS_BA();
        Database.executeBatch(ba, 200);
    }
}