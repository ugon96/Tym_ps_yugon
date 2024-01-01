/*
 * File Name   		: IF_SFDC_SAP_REG_CLAIM_ba
 * Author	  		: seungyeon.kang
 * Date				: 2023-11-28
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REG_CLAIM_ba implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    List<Case> cases = new List<Case>();

    public List<Case> start(Database.BatchableContext param1){
        System.debug('Start IF_SFDC_SAP_REG_CLAIM_ba ');
        //status가 accepted이고, IsSendtoSAP__c == FALSE
        cases = [
                SELECT Id, AssetId,
                        Account.BPCode__c,
                        Asset.RecordTypeId,
                        Asset.SerialNumber,
                        Asset.LoaderId__r.SerialNumber,
                        Asset.BackhoeId__r.SerialNumber,
                        Asset.MidMountMower__r.SerialNumber,
                        Asset.Cabin__r.SerialNumber,
                        Asset.RetailedDate__c,
                        UsageTime__c,
                        ru_TotalApprovedLaborCost__c,
                        ru_TotalApprovedPartsAmount__c,
                        ru_TotalRequestShippnig__c,
                        ru_TotalApprovedShipping__c,
                        fm_TotalApprovedAmount__c,
                        CauseCode__c,
                        CauseCode2__c,
                        CauseCode3__c,
                        Failure_Cause__c,
                        DescriptionOfFailure__c,
                        FailureDate__c,
                        Repair__c,
                        RepairDate__c,
                        ClaimType__c,
                        AdminNotes__c,
                        Asset.EngineSerialNumber__c,
                        Status,
                (SELECT Id, Name, PartDescription__c,Quantity__c,fm_Amount__c,ApprovedQuantity__c,
                        ApprovedPartValue__c, fm_ApprovedAmount__c,PartValue__c, InvoiceItem__c,
                        InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c FROM PartsClaim__r), 
                (SELECT Id, Name, fm_Model__c,fm_LaborGroup__c,fm_Diagram__c,fm_Description__c,LaborHour__c, fm_LaborCode__c,
                        ApprovedLaborHour__c, Remarks__c FROM LaborCodeClaim__r)
                FROM Case
                WHERE Status = 'Accepted' AND IsSendtoSAP__c = FALSE
        ];
        System.debug('cases :: ' + cases);
        return cases;
    }

    public void execute(Database.BatchableContext param1, List<Case> param2){
        System.debug('Execute IF_SFDC_SAP_REG_CLAIM_ba ');

        try {
              IF_SFDC_SAP_REG_CLAIM ifSfdcSapRegClaim = new IF_SFDC_SAP_REG_CLAIM(param2);
              ifSfdcSapRegClaim.execute();
              System.debug('Try IF_SFDC_SAP_REG_CLAIM_ba ');
        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REG_CLAIM_ba ');

        //배치 완료 후 IsSendtoSAP__c true로 변경
//        List<Case> casesToUpdate = new List<Case>();
//        for (Case c : cases) {
//            c.IsSendtoSAP__c = true;
//            casesToUpdate.add(c);
//        }
//
//        if (!casesToUpdate.isEmpty()) {
//            update casesToUpdate;
//        }
    }
}