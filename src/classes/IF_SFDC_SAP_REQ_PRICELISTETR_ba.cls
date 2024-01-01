/*
 * File Name   		: IF_SFDC_SAP_REQ_PRICELISTR_BA
 * Author	  		: seungyeon.kang
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       seungyeon.kang        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_PRICELISTETR_ba implements Database.Batchable<IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry>,Database.Stateful {
    public integer Count;
    public Boolean isContinue;
    public List<IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry> listEntries;

    public IF_SFDC_SAP_REQ_PRICELISTETR_ba(){
        System.Queueable job = new IF_SFDC_SAP_REQ_PRICELISTETR('ALL', 0);
        System.enqueueJob(job);
    }

    public List<IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry> start(Database.BatchableContext param1){
        System.debug('Start IF_SFDC_SAP_REQ_PRICELISTETR_ba ');
        //execute로 넘어가기 위해 아무거나 설정
        return listEntries;
    }

    public void execute(Database.BatchableContext param1, List<IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry> param2){
        System.debug('Execute IF_SFDC_SAP_REQ_PRICELISTETR_ba ');
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry> listResult = null;

        List<String> listErrorMessage = new List<String>();
        Set<String> priceLists = new Set<String>();
        for (IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry objPL : param2) {
            priceLists.add(objPL.PriceList);
        }
        //PriceList 객체에서 필요한 필드들을 가져오기 위한 Map
        Map<String, PriceList__c> priceListMap = new Map<String, PriceList__c>();
        for (PriceList__c priceList : [SELECT Id, ExternalId__c FROM PriceList__c WHERE ExternalId__c IN :priceLists]) {
            priceListMap.put(priceList.ExternalId__c, priceList);
        }


        // SAP에서 받아온 데이터에서 ItemCode를 추출하여 Set에 저장
        Set<String> itemCodes = new Set<String>();
        for (IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry objPLE : param2) {
            itemCodes.add(objPLE.ItemCode);
        }
        // Product2 객체에서 필요한 필드들을 가져오기 위한 Map
        Map<String, Product2> productMap = new Map<String, Product2>();
        for (Product2 product2 : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :itemCodes]) {
            productMap.put(product2.ExternalId__c, product2);
        }

        // SAP에서 받아온 데이터로 Salesforce의 PriceListEntry__c 레코드 생성
        List<PriceListEntry__c> priceListEntries  = new List<PriceListEntry__c>();
        for (IF_SFDC_SAP_REQ_PRICELISTETR.PriceListEntry objPLE : param2) {
            PriceListEntry__c thisPriceList = new PriceListEntry__c();

            // PriceList(Master-Detail)
            if(priceListMap.containsKey(objPLE.PriceList)) {
                thisPriceList.PriceListID__c = priceListMap.get(objPLE.PriceList).Id;
                System.debug('thisPriceList.PriceListID__c :: ' + thisPriceList.PriceListID__c);

            }

            // Product2 객체에서 가져온 정보 활용
            if (productMap.containsKey(objPLE.ItemCode)) {
                thisPriceList.ProductID__c = productMap.get(objPLE.ItemCode).Id;
                System.debug('thisPriceList.ProductID__c :: ' + thisPriceList.ProductID__c);
            }

            thisPriceList.ListPrice__c = objPLE.Price;
            thisPriceList.CurrencyISO__c = objPLE.inputCurrency;

            priceListEntries.add(thisPriceList);

            System.debug('priceListEntries :: ' + priceListEntries);
        }
        List<Database.UpsertResult> listDmlResult = Database.upsert(priceListEntries , false);
        System.debug('listDmlResult :: ' + listDmlResult);

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

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REQ_PRICELISTETR_ba ');
        Boolean isContinue = false;

        // isContinue인지 받아오는 작업

//        if (isContinue) {
//            Datetime thisMoment = System.now();
//            Integer iDelayTime = 30;
//            Datetime delayedTime = thisMoment.addSeconds(iDelayTime);
//            String cronExpr = delayedTime.second() + ' ' + delayedTime.minute() + ' ' + delayedTime.hour() + ' ' + delayedTime.day() + ' ' + delayedTime.month() + ' ? ' + delayedTime.year();
//
//            IF_SFDC_SAP_REQ_PRICELISTETR_sc scheduler = new IF_SFDC_SAP_REQ_PRICELISTETR_sc();
//            System.schedule('upsertContacts', cronExpr, scheduler);
//        }
    }

}