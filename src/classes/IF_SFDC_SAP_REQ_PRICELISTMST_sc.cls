/**
 * Created by nhkim on 2023-11-30.
 */

public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_sc implements Schedulable {
    public void execute(SchedulableContext context) {
        IF_SFDC_SAP_REQ_PRICELISTMST_qu priceListMst = new IF_SFDC_SAP_REQ_PRICELISTMST_qu('ALL', 500, 0);
        System.enqueueJob(priceListMst);
    } 
}