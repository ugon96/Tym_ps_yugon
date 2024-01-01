/**
 * Created by nhkim on 2023-12-08.
 */

public with sharing class IF_SFDC_SAP_REQ_PRICELISTMST_qu implements Queueable, Database.AllowsCallouts {
    private static final String IFID = 'IF_SFDC_SAP_REQ_PRICELISTMST';

    private String PriceList;
    private Integer Count;
    private Integer QueueCount;
    private String jobId;

    public IF_SFDC_SAP_REQ_PRICELISTMST_qu(String priceList) {
        this.PriceList = priceList;
    }

    public IF_SFDC_SAP_REQ_PRICELISTMST_qu(String priceList, Integer count) {
        this.PriceList = priceList;
        this.Count = count;
    }

    public IF_SFDC_SAP_REQ_PRICELISTMST_qu(String priceList, Integer count, Integer queueCount) {
        this.PriceList = priceList;
        this.Count = count;
        this.QueueCount = queueCount;
    }

    private class Input {
        String PriceList;
        Integer Count;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        List<PriceList> PriceListMasterList;
        String isContinue;
    }

    public class PriceList {
        public String PriceList;
        public String Name;
        public String BasePriceList;
        public Decimal Factor;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Pricebook 정보를 SFDC에 Upsert한다.';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        List<PriceList__c> listPriceLists = new List<PriceList__c>();

        //String requestBody = '/' + this.PriceList;
        String requestBody = '/' + this.PriceList + '/' + this.Count;
        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        Input objInput = new Input();

        if (PriceList == null || PriceList == '') {
            this.PriceList = 'new';
        }
        objInput.PriceList = this.PriceList; 
        objInput.Count = this.Count;

        try {
            IFUtil objIF = new IFUtil(IFID);
            // LogWrapper INSERT
            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();


            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                PriceList__c thisPriceList;
                for (PriceList pl : objOutput.PriceListMasterList) {
                    thisPriceList = new PriceList__c();
                    thisPriceList.ExternalId__c = pl.PriceList;
                    thisPriceList.Name = pl.Name;
                    thisPriceList.Factor__c = pl.Factor;
                    listPriceLists.add(thisPriceList);
                }
                System.debug('listPriceLists + '+listPriceLists);
                System.debug('listPriceLists.size() + '+listPriceLists.size());

                upsert listPriceLists ExternalId__c;

                Map<String, PriceList__c> mapExternalIdToPL = new Map<String, PriceList__c>();
                for (PriceList__c pl : [SELECT Id, ExternalId__c, BasePriceList__c FROM PriceList__c LIMIT 50000]) {
                    mapExternalIdToPL.put(pl.ExternalId__c, pl);
                }

                List<PriceList__c> listPriceListFinal = new List<PriceList__c>();

                for (PriceList pl : objOutput.PriceListMasterList) {
                    thisPriceList = new PriceList__c();
                    thisPriceList.ExternalId__c = pl.PriceList;
                    thisPriceList.Name = pl.Name;
                    if (mapExternalIdToPL.get(pl.BasePriceList) != null && mapExternalIdToPL.get(pl.BasePriceList) != mapExternalIdToPL.get(pl.PriceList)) {
                        thisPriceList.BasePriceList__c = mapExternalIdToPL.get(pl.BasePriceList).Id;
                    }
                    thisPriceList.Factor__c = pl.Factor;

                    listPriceListFinal.add(thisPriceList);
                }

                upsert listPriceListFinal ExternalId__c;

                if (objOutput.isContinue == 'Y') {
                    QueueCount++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_PRICELISTMST_qu('ALL', 500, QueueCount));
                }

//                List<Database.UpsertResult> listDmlResult = Database.upsert(listPriceLists, false);
//                Integer cnt = 0;
//                for (Database.UpsertResult objResult : listDmlResult) {
//                    if (objResult.success) {
//                        successCnt++;
//                    } else {
//                        failCnt++;
//                        if (objResult.getErrors().toString().contains('required field missing')) {
//                            listErrorMessage.add('Required field missing');
//                        } else {
//                            listErrorMessage.add(objResult.getErrors().toString());
//                        }
//                    }
//                    cnt++;
//                }
            }
            else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        }
        catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.requestCount = QueueCount;
        LogWrapper.enqueueJobId = jobId;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
    }
}