/**
 * Created by nhkim on 2023-11-28.
 */

public with sharing class IF_SFDC_SAP_REQ_AR_sc implements Schedulable {

    public void execute(SchedulableContext context) {
        IF_SFDC_SAP_REQ_AR_ba ba = new IF_SFDC_SAP_REQ_AR_ba();
        Database.executeBatch(ba, 400);
    }
}