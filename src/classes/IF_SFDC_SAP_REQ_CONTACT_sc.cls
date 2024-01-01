/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_CONTACT_sc
 * Author	  		: nh.kim@daeunextier.com
 * Date				: 2023-11-27
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-27       nh.kim@daeunextier.com  Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_CONTACT_sc implements Schedulable {
    public void execute(SchedulableContext context) {
        // test: 100
        IF_SFDC_SAP_REQ_CONTACT_ba contactBa = new IF_SFDC_SAP_REQ_CONTACT_ba();
        Database.executeBatch(contactBa, 400);
    }
}