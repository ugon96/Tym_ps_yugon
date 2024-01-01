/*
 * File Name   		: IF_SFDC_SAP_REQ_ITEM_qu
 * Author	  		: taekyun.yoon@daeunextier.com
 * Date				: 2023-11-20
 * @Group           : Daeunextier
 * Description 		: SAP의 Master Data인 Product 정보를 SFDC Upsert하는 인터페이스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       taekyun.yoon        Initial Version
*/
public with sharing class IF_SFDC_SAP_REQ_ITEM_qu implements System.Queueable, Database.AllowsCallouts {
    private static String FinishedGoodsRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('FinishedGoods').getRecordTypeId();
    private static String ProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
    private static final String IFID = 'IF_SFDC_SAP_REQ_ITEM';

    private String ItemCode;
    private Integer i;
    private Integer Count;

    public IF_SFDC_SAP_REQ_ITEM_qu(String itemCode, Integer count, Integer i){
        this.ItemCode = itemCode;
        this.Count = count;
        this.i = i;
    }
//    public IF_SFDC_SAP_REQ_ITEM_qu(String itemCode, Integer count){
//        this.ItemCode = itemCode;
//        this.Count = count;
//    }

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

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Product 정보 요청 인터페이스 호출';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;

        IFUtil objIF;
        String requestParam = '';
        String responseBody = '';
        Id jobId = null;

        if (this.ItemCode != null && this.ItemCode != '') {
            requestParam += '/' + this.ItemCode;
            if (this.Count != null && this.Count != 0) {
                requestParam += '/' + String.valueOf(this.Count);
            }
        }

        try {
            objIF = new IFUtil(IFID);
            HttpResponse response = objIF.webCallout(requestParam, true);

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                if (objOutput.item != null && objOutput.item.size() > 0) {
                    System.debug('item.size ::::;;' + objOutput.item.size());
                    Map<String, Product2> mapNew = new Map<String, Product2>();
                    for (SAPProduct objSAPProduct : objOutput.item) {
                        Product2 objProduct = new Product2();

                        objProduct.RecordTypeId = objSAPProduct.ItemGroupCode == '101'? FinishedGoodsRT : ProductRT;
                        if(objSAPProduct.ItemCode != null)objProduct.ExternalId__c = objSAPProduct.ItemCode;
                        if(objSAPProduct.ItemCode != null)objProduct.Name = objSAPProduct.ItemCode;
                        if(objSAPProduct.ItemName != null)objProduct.ProductName__c = objSAPProduct.ItemName;
                        if(objSAPProduct.ItemGroupCode != null)objProduct.ItemGroupCode__c = objSAPProduct.ItemGroupCode;
                        if(objSAPProduct.Model != null)objProduct.Model__c = objSAPProduct.Model;
                        if(objSAPProduct.Description != null)objProduct.Description = objSAPProduct.Description;
                        if(objSAPProduct.CountryofOrigin != null)objProduct.CountryOfOrigin__c = objSAPProduct.CountryofOrigin;
                        if(objSAPProduct.Remarks != null)objProduct.Remarks__c = objSAPProduct.Remarks;
                        if(objSAPProduct.Weight != null)objProduct.Weight__c = objSAPProduct.Weight;
                        if(objSAPProduct.LP != null)objProduct.LP__c = (objSAPProduct.LP == 'Y') ? true : false;
                        if(objSAPProduct.IsActive != null)objProduct.IsActive = (objSAPProduct.IsActive == 'Y') ? true : false;
                        if(objSAPProduct.Tier != null) objProduct.Tier__c = objSAPProduct.Tier;
                        if(objSAPProduct.Series != null) objProduct.Series__c = objSAPProduct.Series;

                        mapNew.put(objProduct.ExternalId__c, objProduct);
                    }
                    System.debug('mapNew ::::::' + mapNew.size());
//                    objOutput = null;

                    Schema.SObjectField ext = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap().get('ExternalId__c');
                    Database.upsert(mapNew.values(), ext);
                    mapNew.clear();

                    System.debug('objOutput.isContinue ::' + objOutput.isContinue);
                    if (objOutput.isContinue == 'Y') {
                            jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_ITEM_qu(ItemCode, Count, i + 1));

                    } 
                }
            } else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }
        // IF_Log에 기록할 데이터 저장
        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestHeader =requestParam;
        LogWrapper.responseBody =responseBody; 
        LogWrapper.enqueueJobId = jobId;

        // IF_Log에 데이터 저장
        objIF.setLog(LogWrapper);
        System.debug('LogWrapper : ' + LogWrapper);
    }
}