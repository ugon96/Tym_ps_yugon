/**
 * Created by nhkim on 2023-11-30.
 */

public with sharing class IF_SFDC_SAP_REQ_BPACCOUNT_sc implements Schedulable {
    public void execute(SchedulableContext context) {
//        IF_SFDC_SAP_REQ_BPACCOUNT_ba ba = new IF_SFDC_SAP_REQ_BPACCOUNT_ba();
//        Database.executeBatch(ba, 400);

        System.Queueable job = new IF_SFDC_SAP_REQ_BPACCOUNT_qu('all', 500,0);
        System.enqueueJob(job);
    }
}