/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REG_PRICELISTETR
 * Author	  		: sy.kang@daeunextier.com
 * Date				: 2023-11-20
 * @Group              : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       sy.kang@daeunextier.com        Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_PRICELISTETR {
    public static final String IFID = 'IF_SFDC_SAP_REQ_PRICELISTETR';

    public String PriceList;
    private Integer Count;
    private Integer i;
    public String  ItemGroupCode;
    public String  ItemCode;
    public String  inputCurrency;

    public IF_SFDC_SAP_REQ_PRICELISTETR(String priceList, Integer Count) {
        this.PRICELIST = priceList;
        this.Count = Count;
    }

    public IF_SFDC_SAP_REQ_PRICELISTETR(String priceList, Integer Count, Integer i) {
        this.PRICELIST = priceList;
        this.Count = Count;
        this.i = i;
    }

    public IF_SFDC_SAP_REQ_PRICELISTETR(String PriceList, Integer Count, String ItemGroupCode, String ItemCode, String inputCurrency, Integer i){
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

    public void execute() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Pricebook 정보를 SFDC에 Upsert한다.';

        Integer successCnt = 0;
        Integer failCnt = 0;
        Id jobId = null;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        Input objInput = new Input();
        List<PriceListEntry> listResult = null;

        objInput.COUNT = 500;
        objInput.inputCurrency = 'USD';

        // PRICELIST valid check
        if (PriceList == null || PriceList == '') {
            this.PriceList = 'new';
        }
        objInput.PriceList = this.PriceList;
        objInput.Count = this.Count;

        String requestBody = '';
        requestBody += '/' + this.PriceList;
        requestBody += this.Count != null? '/' + this.Count : '';
        requestBody += this.ItemGroupCode != null? '/' + this.ItemGroupCode : '';
        requestBody += this.ItemCode != null? '/' + this.ItemCode : '';
        requestBody += this.inputCurrency != null? '/' + this.inputCurrency : '';

        System.debug('requestBody :: ' + requestBody);


        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;
        LogWrapper.requestHeader = requestBody;

        try {
            IFUtil objIF = new IFUtil(IFID);

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
                if (objOutput.PriceListEntryList != null) {
                    listResult = objOutput.PriceListEntryList;
                }
                else {
                    listResult = null;
                }
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
        LogWrapper.enqueueJobId = jobId;
        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);

        System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());
    }
}