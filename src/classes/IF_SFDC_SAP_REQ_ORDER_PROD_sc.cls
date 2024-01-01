/*
 * File Name         : IF_SFDC_SAP_REQ_ORDER_PROD_sc
 * Author           : seungyeon.kang
 * Date            : 2023-12-01
 * @Group           : Daeunextier
 * Description       :
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_ORDER_PROD_sc implements Schedulable{
    public String Type;
    public Integer Count;

    public IF_SFDC_SAP_REQ_ORDER_PROD_sc() {

    }
    public IF_SFDC_SAP_REQ_ORDER_PROD_sc(String Type, Integer Count) {
        this.Type = Type;
        this.Count = Count;
    }

    public void execute(SchedulableContext context) {
        IF_SFDC_SAP_REQ_ORDER_PROD_qu CQ = new IF_SFDC_SAP_REQ_ORDER_PROD_qu(Type, Count, 0);
        System.enqueueJob(CQ);
    }
}