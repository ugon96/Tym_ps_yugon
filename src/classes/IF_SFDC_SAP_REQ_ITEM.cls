/*
 * File Name   		: IF_SFDC_SAP_REQ_ITEM
 * Author	  		: taekyun.yoon@daeunextier.com
 * Date				: 2023-11-20
 * @Group           : Daeunextier
 * Description 		: SAP의 Master Data인 Product 정보를 SFDC Upsert
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       taekyun.yoon        Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_ITEM {

    private static final String IFID = 'IF_SFDC_SAP_REQ_ITEM';

    public IF_SFDC_SAP_REQ_ITEM(){}
    public IF_SFDC_SAP_REQ_ITEM(String itemCode){
        ItemCode = itemCode;
    }
    public IF_SFDC_SAP_REQ_ITEM(String itemCode, Integer count){
        ItemCode = itemCode;
        Count = count;
    }

    private class Input{
        String ItemCode;
        Integer Count;
    }

    public class Output{
        String ResponseCode;
        String ErrorMessage;
        List<SAPProduct> item;
        String isContinue;
    }

    public class SAPProduct{
        String ItemCode;
        String ItemName;
        String ItemGroupCode;
        String Model;
        String Description;
        String CountryofOrigin;
        String Remarks;
        Decimal Weight;
        String LP;
        String IsActive;
        String Tier;
        String Series; 
    }

//    @Future(Callout = true)
//    public static void execute(String ItemCode, Integer Count, Integer requestCount) {
    public void execute(String ItemCode, Integer Count) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Product 정보 요청 인터페이스 호출';

        String requestBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        if (ItemCode != null || ItemCode != '') {
            requestBody = '/'+ItemCode;
        } else {
            requestBody = '/all';
        }

        if (Count != null || Count > 0) {
            requestBody += '/'+ Count;
        } else {}


        try {
            IFUtil objIF = new IFUtil(IFID);

            HttpResponse response = objIF.webCallout(requestBody, true);

//            strCode = String.valueOf(response.getStatusCode());
//            responseBody = response.getBody();
            System.debug('response.body' + response.getBody());
            Output objOutput;

            if (response.getStatusCode() == 200) {
                objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
            }
            System.debug('objOutput : ' + objOutput);

            //while (objOutput.isContinue != 'N') {
                if (objOutput.item != null && objOutput.item.size() > 0) {
                    //upsert 할 Product 데이터 생성
                    Map<String, Product2> mapNew = new Map<String, Product2>();
                    for (SAPProduct objSAPProduct : objOutput.item) {
                        Product2 objProduct = new Product2();

                        objProduct.ExternalId__c = objSAPProduct.ItemCode;
                        objProduct.Name = objSAPProduct.ItemCode;
                        objProduct.ProductName__c = objSAPProduct.ItemName.replace(',', '\\,');
                        objProduct.ItemGroupCode__c = objSAPProduct.ItemGroupCode;
                        objProduct.Model__c = objSAPProduct.Model;
                        objProduct.Description = objSAPProduct.Description;
                        objProduct.CountryOfOrigin__c = objSAPProduct.CountryofOrigin;
                        objProduct.Remarks__c = objSAPProduct.Remarks;
                        objProduct.Weight__c = objSAPProduct.Weight;
                        objProduct.LP__c = (objSAPProduct.LP == 'Y') ? true : false;
                        objProduct.IsActive = (objSAPProduct.IsActive == 'Y') ? true : false;
                        objProduct.Tier__c = objSAPProduct.Tier;
                        objProduct.Series__c = objSAPProduct.Series;

                        mapNew.put(objProduct.ExternalId__c, objProduct);
                    }
                    objOutput = null;

                    Schema.SObjectField ext = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().get('ExternalId__c');
                    Database.upsert(mapNew.values(), ext);
                    mapNew.clear();

                    // IF_Log에 기록할 데이터 저장
                    LogWrapper.status = strStatus;
                    LogWrapper.errorCode = strCode;
                    LogWrapper.errorMessage = strMessage;
                    LogWrapper.responseTime = Datetime.now();
                    LogWrapper.responseBody = response.getBody();
//                    LogWrapper.requestCount = requestCount + log1;

                    // IF_Log에 데이터 저장
                    objIF.setLog(LogWrapper);


//                    IF_SFDC_SAP_REQ_ITEM.execute('new', 50, LogWrapper.requestCount);
//                    IF_SFDC_SAP_REQ_ITEM.execute('new', 50, LogWrapper.requestCount);
                    //IF_SFDC_SAP_REQ_ITEM.execute('new', 50);
                } else {
                    System.debug('objOutput.item :: null || size() < 0 : 넘어온 item이 없습니다');
                }
            //}
            System.debug('모든 데이터 전송 완료 :::');
            System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());

        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }
    }
}