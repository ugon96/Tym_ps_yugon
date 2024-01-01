/********************************************************************
* File Name   : TYM_retailProgramCloneController.cls
* Author      : 최태욱
* Date        : 2023.11.24
* Class       : TYM_retailProgramCloneController.cls
* Description : RetailProgramMaster__c의 정보들을 clone하는 기능
* Modification Log
* ====================================================================
* Ver      Date            Author              Modification
* ====================================================================
1.0      2023.11.24        최태욱               Create
<*********************************************************************/

public with sharing class TYM_retailProgramCloneController {
    
    /**
     * @author 최태욱
     * @description : RetailProgramMaster__c 오브젝트의 정보와 관련 Related List 복제
     * @param recordId
     * @param retailMap
     * @return clonedRecord
     */
    @AuraEnabled
    public static RetailProgramMaster__c retailProgramClone(String recordId, Map<String, String> retailMap){
        try {

            RetailProgramMaster__c objRPM = [SELECT Id, Name, ProgramType2__c, PricingStructure__c, ProgramType__c, Notes__c, Discount__c, DaysFrom__c, DaysTo__c, CriterionDate__c, StartDate__c, EndDate__c, IsActive__c 
                                                FROM RetailProgramMaster__c 
                                                WHERE Id = : recordId];
            System.debug('ObjRPM :::::: ' +  objRPM);

            RetailProgramMaster__c objRetailProgramMaster = [SELECT ProgramType__c, PricingStructure__c, IsActive__c FROM RetailProgramMaster__c WHERE Id =: recordId];

            RetailProgramMaster__c clonedRecord = objRPM.clone(false, true);

            if(objRetailProgramMaster.ProgramType__c == 'Volume Incentive' 
                && objRetailProgramMaster.PricingStructure__c == 'Dynamic' 
                && objRetailProgramMaster.IsActive__c) {
                Date existingStartDate = objRPM.StartDate__c;
                Date existingEndDate = objRPM.EndDate__c;

                Date newStartDate = Date.valueOf(retailMap.get('startDate'));
                Date newEndDate = Date.valueOf(retailMap.get('endDate'));

                if (newStartDate <= existingEndDate && newEndDate >= existingStartDate) {
                    throw new AuraHandledException('It overlaps with an existing date range. Please select a different date.');
                } else {
                    clonedRecord.Name = retailMap.get('name');
                    clonedRecord.StartDate__c = newStartDate;
                    clonedRecord.EndDate__c = newEndDate;
                    System.debug('clonedRecord:::::' + clonedRecord);
                }
                
            } else {

                clonedRecord.Name = retailMap.get('name');
                clonedRecord.StartDate__c = Date.valueOf(retailMap.get('startDate'));
                clonedRecord.EndDate__c = Date.valueOf(retailMap.get('endDate'));
            }

            insert clonedRecord;

            System.debug('clonedRecord:::::' +  clonedRecord);



            List<RetailProgramMasterItem__c> rpMList = [SELECT Id, Name, RetailProgramID__c, ProductID__c, Unit__c, Amount__c, Discount__c, Payout__c 
                                                        FROM RetailProgramMasterItem__c 
                                                        WHERE RetailProgramID__c = : recordId];
            System.debug('rpMList :::::' + rpMList);

            List<RetailProgramMasterItem__c> clonerpMList = new List<RetailProgramMasterItem__c>();

            for(RetailProgramMasterItem__c objR : rpMList) {
                RetailProgramMasterItem__c clonedItem = new RetailProgramMasterItem__c(
                    ProductID__c = objR.ProductID__c,
                    Unit__c = objR.Unit__c,
                    Amount__c = objR.Amount__c,
                    Discount__c = objR.Discount__c,
                    Payout__c = objR.Payout__c,
                    RetailProgramID__c = clonedRecord.Id
                );
                clonerpMList.add(clonedItem);
                System.debug('clonerpMList::::' + clonerpMList);
            }
            insert clonerpMList;

            System.debug('clonerpMList::::' + clonerpMList);

            List<PayoutStructure__c> payList = [SELECT Id, Name, RetailProgramID__c, RetailProgramID__r.Name, Registered__c, Amount__c
                                                FROM PayoutStructure__c 
                                                WHERE RetailProgramID__c = : recordId];

            List<PayoutStructure__c> clonePayList = new List<PayoutStructure__c>();
            
            for(PayoutStructure__c objPay : payList) {
                PayoutStructure__c clonedItem = new PayoutStructure__c(
                    Amount__c = objPay.Amount__c,
                    Registered__c = objPay.Registered__c,
                    RetailProgramID__c = clonedRecord.Id
                );
                clonePayList.add(clonedItem);
                System.debug('clonerpMList::::' + clonePayList);
            }
            insert clonePayList;

            System.debug('clonePayList::::' + clonePayList);


            return clonedRecord;

            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }



}