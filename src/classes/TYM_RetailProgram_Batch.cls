/*************************************************************
 * @author : th.kim
 * @date : 2023-11-20
 * @group : 
 * @group-content : 
 * @description : Volume Incentive 분기별 가격 계산 후 업데이트 배치
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-20      th.kim         Initial Version
**************************************************************/

public with sharing class TYM_RetailProgram_Batch implements Database.Batchable<SObject> {

    private final String recordId;
    private static Date startDate;
    private static final Date endDate = Date.today();

    private class RetailWrapper {
        public String retailProgramMasterId;
        public String accountId;
        public String productId;
        public Decimal registered;
        public Decimal point;
        public Decimal payout;
        public Decimal amount;
    }

    public TYM_RetailProgram_Batch(String recordId) {
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = ' SELECT Id, StartDate__c, EndDate__c FROM RetailProgramMaster__c ';
        query += ' WHERE Id = :recordId';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<RetailProgramMaster__c> listRecord) {
        try {
            startDate = listRecord[0].StartDate__c;
            List<RetailProgramMaster__c> listRPMaster = [
                    SELECT Id
                    FROM RetailProgramMaster__c
                    WHERE Id = :recordId
                    AND StartDate__c <= :startDate
                    AND EndDate__c >= :endDate
            ];
            System.debug('listRPMaster :: ' + listRPMaster);

            Set<Id> setRPMasterId = new Set<Id>();
            for (RetailProgramMaster__c master : listRPMaster) {
                setRPMasterId.add(master.Id);
            }
            List<RetailProgramMasterItem__c> listRPMasterItem = [
                    SELECT Id, RetailProgramID__c, ProductID__c, Unit__c, Amount__c, Payout__c
                    FROM RetailProgramMasterItem__c
                    WHERE RetailProgramID__c IN :setRPMasterId
            ];
            System.debug('listRPMasterItem :: ' + listRPMasterItem);

            List<AggregateResult> listGrpRPItem = Database.query(getRPItemQuery(true));
            System.debug('listGrpRPItem :: ' + listGrpRPItem);
            Map<String, Integer> mapIdCnt = new Map<String, Integer>();
            // Account별 Item 합계 가져오기
            for (AggregateResult data : listGrpRPItem) {
                mapIdCnt.put((String) data.get('AccountId__c'), (Integer) data.get('idCnt'));
            }
            System.debug('mapIdCnt :: ' + mapIdCnt);

            List<RetailProgramItem__c> listRPItem = Database.query(getRPItemQuery(false));
            List<RetailWrapper> listRetailWrapper = new List<RetailWrapper>();
            // wrapper에 RetailProgramItem 그룹화한 데이터 넣기
            for (RetailProgramItem__c item : listRPItem) {
                RetailWrapper wrapper = new RetailWrapper();
                wrapper.retailProgramMasterId = item.RetailProgramMasterID__c;
                wrapper.productId = item.ProductID__c;
                wrapper.accountId = item.RetailProgramID__r.AccountId__c;
                wrapper.registered = mapIdCnt.get(item.RetailProgramID__r.AccountId__c);
                listRetailWrapper.add(wrapper);
            }
            System.debug('listRetailWrapper1 :: ' + listRetailWrapper);

            for (RetailProgramMasterItem__c masterItem : listRPMasterItem) {
                for (RetailWrapper wrapper : listRetailWrapper) {
                    // wrapper에 해당 레코드와 관련된 MasterItem의 Unit과 Payout 넣기
                    if (masterItem.RetailProgramID__c == wrapper.retailProgramMasterId && masterItem.ProductID__c == wrapper.productId) {
                        wrapper.point = masterItem.Unit__c;
                        wrapper.payout = masterItem.Payout__c;
                    }
                }
            }
            System.debug('listRetailWrapper2 :: ' + listRetailWrapper);

            for (PayoutStructure__c payout : [SELECT RetailProgramID__c, Amount__c, Registered__c FROM PayoutStructure__c WHERE RetailProgramID__c = :recordId]) {
                for (RetailWrapper wrapper : listRetailWrapper) {
                    // Payout과 Wrapper의 RetailProgramMasterId가 같고 ProgramItem이 Payout의 Register보다 Item의 수량이 많으면 payout의 Register에 해당하는 Amount 계산
                    if (payout.RetailProgramID__c == wrapper.retailProgramMasterId) {
                        if (payout.Registered__c <= wrapper.registered) {
                            if (payout.Amount__c != null && wrapper.point != null) {
                                wrapper.amount = payout.Amount__c * wrapper.point;
                            }
                        }
                    }
                }
            }
            System.debug('listRetailWrapper3 :: ' + listRetailWrapper);

            Map<String, RetailWrapper> mapWrapper = new Map<String, RetailWrapper>();
            for (RetailWrapper wrapper : listRetailWrapper) {
                mapWrapper.put(wrapper.retailProgramMasterId + wrapper.productId + wrapper.accountId, wrapper);
            }

            List<RetailProgramItem__c> listUpdateRPItem = new List<RetailProgramItem__c>();
            Set<Id> setUpdatedRPMasterId = new Set<Id>();
            // RetailProgramMasterItem의 payout을 계산하고 업데이트 리스트에 추가
            for (RetailProgramItem__c item : listRPItem) {
                RetailWrapper wrapper = mapWrapper.get((String) item.RetailProgramMasterID__c + (String) item.ProductID__c + (String) item.RetailProgramID__r.AccountId__c);
                if (wrapper.amount != null && wrapper.payout != null) {
                    item.Claimed__c = wrapper.amount * wrapper.payout;
                    item.Adjusted__c = wrapper.amount * wrapper.payout;
                    listUpdateRPItem.add(item);
                    setUpdatedRPMasterId.add(item.RetailProgramMasterID__c);
                }
            }
            System.debug('listUpdateRPItem :: ' + listUpdateRPItem);
            List<Database.SaveResult> resultRPItem = new List<Database.SaveResult>();
            if (!listUpdateRPItem.isEmpty()) resultRPItem = Database.update(listUpdateRPItem, false);
            System.debug('resultRPItem :: ' + resultRPItem);

            // Update된 RetailProgramMaster__c 더이상 띄위지 않기 위한 IsActive 상태 False 처리
            List<RetailProgramMaster__c> listUpdateRPMaster = [SELECT Id, IsActive__c FROM RetailProgramMaster__c WHERE Id IN :setUpdatedRPMasterId AND IsActive__c != FALSE];
            for (RetailProgramMaster__c master : listUpdateRPMaster) {
                master.IsActive__c = false;
            }
            System.debug('listUpdateRPMaster :: ' + listUpdateRPMaster);
            List<Database.SaveResult> resultRPMaster = new List<Database.SaveResult>();
            if (!listUpdateRPMaster.isEmpty()) resultRPMaster = Database.update(listUpdateRPMaster, false);

            System.debug('resultRPMaster :: ' + resultRPMaster);

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
//            throw new AuraHandledException(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context) {

    }

    /**
     * @author th.kim
     * @description RetailProgramItem__c 조건별 Dynamic Query 가져오기
     * @param isGroup Group By 체크
     *
     * @return query
     */
    private static String getRPItemQuery(Boolean isGroup) {
        try {
            String query = 'SELECT ';
            if (isGroup) query += ' COUNT(Id) idCnt, RetailProgramID__r.AccountId__c ';
            else query += ' Id, RetailProgramMasterID__c, ProductID__c, RetailProgramID__r.AccountId__c, Adjusted__c ';
            query += ' FROM RetailProgramItem__c ';
            query += ' WHERE RetailProgramMasterID__r.StartDate__c <= :startDate';
            query += ' AND RetailProgramMasterID__r.EndDate__c >= :endDate';
            query += ' AND RetailProgramMasterID__c = :recordId ';
            if (isGroup) query += ' GROUP BY RetailProgramID__r.AccountId__c ';

            return query;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
//            throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

}