/**
 * Created by nhkim on 2023-12-05.
 */

public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_ba implements Database.Batchable<IF_SFDC_SAP_REQ_PRICELISTMST.PriceList>, Database.Stateful {
    public List<IF_SFDC_SAP_REQ_PRICELISTMST.PriceList> listPriceList;

    public IF_SFDC_SAP_REQ_PRICELISTMST_ba() {
        IF_SFDC_SAP_REQ_PRICELISTMST priceList = new IF_SFDC_SAP_REQ_PRICELISTMST('all');
        listPriceList = priceList.executeCall();
    }

    public List<IF_SFDC_SAP_REQ_PRICELISTMST.PriceList> start(Database.BatchableContext context) {
        return listPriceList;
    }

    public void execute(Database.BatchableContext context, List<IF_SFDC_SAP_REQ_PRICELISTMST.PriceList> scope) {
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        List<PriceList__c> listPriceLists = new List<PriceList__c>();
        Map<String, PriceList__c> mapExternalIdToPL = new Map<String, PriceList__c>();

        for (PriceList__c pl : [SELECT Id, ExternalId__c, BasePriceList__c FROM PriceList__c LIMIT 50000]) {
            mapExternalIdToPL.put(pl.ExternalId__c, pl);
        }

        for (IF_SFDC_SAP_REQ_PRICELISTMST.PriceList pl : scope) {
            PriceList__c thisPriceList = new PriceList__c();

            if (mapExternalIdToPL.get(pl.PriceList) != null) {
                thisPriceList = mapExternalIdToPL.get(pl.PriceList);
            }
            thisPriceList.ExternalId__c = pl.PriceList;
            thisPriceList.Name = pl.Name;
            if (mapExternalIdToPL.get(pl.BasePriceList) != null) {
                thisPriceList.BasePriceList__c = mapExternalIdToPL.get(pl.BasePriceList).Id;
            }
            thisPriceList.Factor__c = pl.Factor;

            listPriceLists.add(thisPriceList);
        }

        List<Database.UpsertResult> listDmlResult = Database.upsert(listPriceLists, false);
        Integer cnt = 0;
        for (Database.UpsertResult objResult : listDmlResult) {
            if (objResult.success) {
                successCnt++;
            } else {
                failCnt++;
                if (objResult.getErrors().toString().contains('required field missing')) {
                    listErrorMessage.add('Required field missing');
                } else {
                    listErrorMessage.add(objResult.getErrors().toString());
                }
            }
            cnt++;
        }
    }

    public void finish(Database.BatchableContext context) {

    }
}