/*
 * File Name   		: IF_SFDC_SAP_REQ_PRICELISTR_qu_sc
 * Author	  		: seungyeon.kang
 * Date				: 2023-11-28
 * @Group           : Daeunextier
 * Description 		: IF_SFDC_SAP_REQ_PRICELISTR_qu 스케줄링 가능한 작업을 구현
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_sc implements Schedulable{
    public String Type;
    public Integer Count;

    public IF_SFDC_SAP_REQ_PRICELISTETR_sc() {

    }
    public IF_SFDC_SAP_REQ_PRICELISTETR_sc(String Type, Integer Count) {
        this.Type = Type;
        this.Count = Count;
    }

    public void execute(SchedulableContext context) {
        IF_SFDC_SAP_REQ_PRICELISTETR_qu CQ = new IF_SFDC_SAP_REQ_PRICELISTETR_qu(Type, Count, 0);
        System.enqueueJob(CQ);
    }
}