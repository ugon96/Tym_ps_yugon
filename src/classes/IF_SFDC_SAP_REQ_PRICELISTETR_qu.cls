/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REG_PRICELISTETR_qu
 * Author	  		: sy.kang
 * Date				: 2023-11-20
 * @Group           : Daeunextier
 * Description 		: SAP의 Master Data인 Pricebook 정보를 SFDC에 Upsert한다.
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       sy.kang                Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_PRICELISTETR_qu implements System.Queueable, Database.AllowsCallouts {
    public static final String IFID = 'IF_SFDC_SAP_REQ_PRICELISTETR';

    public String PriceList;
    private Integer Count;
    private Integer i;
    public String  ItemGroupCode;
    public String  ItemCode;
    public String  inputCurrency;

    public IF_SFDC_SAP_REQ_PRICELISTETR_qu(String priceList, Integer Count) {
        this.PriceList = priceList;
        this.Count = Count;
    }

    public IF_SFDC_SAP_REQ_PRICELISTETR_qu(String priceList, Integer Count, Integer i) {
        this.PriceList = priceList;
        this.Count = Count;
        this.i = i;
    }

    public IF_SFDC_SAP_REQ_PRICELISTETR_qu(String PriceList, Integer Count, Integer i, String ItemGroupCode, String ItemCode, String inputCurrency){
        this.PriceList = PriceList;
        this.Count = Count;
        this.ItemGroupCode = ItemGroupCode; //Master-Detail
        this.ItemCode = ItemCode; //Lookup
        this.inputCurrency = inputCurrency;
        this.i = i;
    }
    public class Input {
        String PriceList;
        Integer Count;
        String ItemGroupCode;
        String ItemCode;
        String inputCurrency;
    }

    public class Output {
        String ResponseCode;
        String ErrorMessage;
        List<PriceListEntry> PriceListEntryList;
        String isContinue;
    }

    public class PriceListEntry {
        public String PriceList;
        public String ItemCode;
        public Decimal Price;
        public String inputCurrency = 'USD';
    }

    public String strStatus { get; set; }

    public void execute(QueueableContext context) {

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Pricebook 정보를 SFDC에 Upsert한다.';

        Integer successCnt = 0;
        Integer failCnt = 0;
        Id jobId = null;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;

        Input objInput = new Input();
        List<PriceListEntry> listResult = null;

        objInput.Count = 1000;
        objInput.inputCurrency = 'USD';

        // PRICELIST valid check
        if (PriceList == null || PriceList == '') {
            this.PriceList = 'new';
        }
        objInput.PriceList = this.PriceList;
        objInput.Count = this.Count;

        try {
            IFUtil objIF = new IFUtil(IFID);
            //String requestBody = JSON.serialize(objInput);
            String requestBody = '/' + this.PriceList + '/' + this.Count;

            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                System.debug('response.getStatusCode() :: ' + response.getStatusCode());
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                //SAP에서 받아온 데이터에서 PriceList를 추출하여 Set에 저장
                Set<String> priceLists = new Set<String>();
                // SAP에서 받아온 데이터에서 ItemCode를 추출하여 Set에 저장
                Set<String> itemCodes = new Set<String>();
                for (PriceListEntry objPL : objOutput.PriceListEntryList) {
                    priceLists.add(objPL.PriceList);
                    itemCodes.add(objPL.ItemCode);
                }
                //PriceList 객체에서 필요한 필드들을 가져오기 위한 Map
                Map<String, PriceList__c> priceListMap = new Map<String, PriceList__c>();
                for (PriceList__c priceList : [SELECT Id, ExternalId__c FROM PriceList__c WHERE ExternalId__c IN :priceLists]) {
                    priceListMap.put(priceList.ExternalId__c, priceList);
                }

                // Product2 객체에서 필요한 필드들을 가져오기 위한 Map
                Map<String, Product2> productMap = new Map<String, Product2>();
                for (Product2 product2 : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :itemCodes]) {
                    productMap.put(product2.ExternalId__c, product2);
                }

                // SAP에서 받아온 데이터로 Salesforce의 PriceListEntry__c 레코드 생성
                List<PriceListEntry__c> priceListEntries  = new List<PriceListEntry__c>();
                for (PriceListEntry objPLE : objOutput.PriceListEntryList) {
                    PriceListEntry__c thisPriceList = new PriceListEntry__c();
                    // PriceList(Master-Detail)
                    if(priceListMap.get(objPLE.PriceList) != null) {
                        thisPriceList.PriceListID__c = priceListMap.get(objPLE.PriceList).Id;
                        // Product2 객체에서 가져온 정보 활용
                        if ( productMap.get(objPLE.ItemCode) != null) {
                            thisPriceList.Name = objPLE.ItemCode;
                            thisPriceList.ProductID__c = productMap.get(objPLE.ItemCode).Id;
                            thisPriceList.ExternalId__c = objPLE.ItemCode + '_' + objPLE.PriceList;
                            thisPriceList.ListPrice__c = objPLE.Price;
                            thisPriceList.CurrencyISO__c = objPLE.inputCurrency;
                            priceListEntries.add(thisPriceList);
                        }
                    }
                }

                //List<Database.UpsertResult> listDmlResult = Database.upsert(priceListEntries, false);
                upsert priceListEntries ExternalId__c;

                //isContinue, Count 반영 시 조건 변경 if(objOutput.isContinue == 'Y')
                if(objOutput.isContinue == 'Y') {
                    i++;
                    // Queueable Method 재귀 호출
                    //System.Label.killSwitch
                    if(!Test.isRunningTest()){
                        jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_PRICELISTETR_qu(this.PriceList, this.Count, i));
                    }
                }

            }
            else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        }
        catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        LogWrapper.status = strStatus; 
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.enqueueJobId = jobId;
        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
    }
}