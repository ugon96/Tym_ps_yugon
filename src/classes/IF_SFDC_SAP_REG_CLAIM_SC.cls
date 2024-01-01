/*
 * File Name   		: IF_SFDC_SAP_REG_CLAIM_sc
 * Author	  		: seungyeon.kang
 * Date				: 2023-11-28
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
 * */

public with sharing class IF_SFDC_SAP_REG_CLAIM_sc implements Schedulable{
    public void execute(SchedulableContext sc) {
        IF_SFDC_SAP_REG_CLAIM_ba ba = new IF_SFDC_SAP_REG_CLAIM_ba();
        Database.executeBatch(ba, 400);
    }
}