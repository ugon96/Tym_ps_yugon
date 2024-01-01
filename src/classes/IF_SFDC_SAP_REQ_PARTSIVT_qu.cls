/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_PARTSIVT
 * Author	  		: nh.kim@daeunextier.com
 * Date				: 2023-11-22
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-22       nh.kim@daeuxtier.com    Initial Version
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_PARTSIVT_qu implements Queueable, Database.AllowsCallouts {
    private static final String IFID = 'IF_SFDC_SAP_REQ_PARTSIVT';

    private String ITEMCODE;
    private Integer Count;
    private Integer QueueCount;
    private String jobId;

    public IF_SFDC_SAP_REQ_PARTSIVT_qu(String itemCode) {
        this.ITEMCODE = itemCode;
    }

    public IF_SFDC_SAP_REQ_PARTSIVT_qu(String itemCode, Integer count) {
        this.ITEMCODE = itemCode;
        this.Count = count;
    }

    public IF_SFDC_SAP_REQ_PARTSIVT_qu(String itemCode, Integer count, Integer queueCount) {
        this.ITEMCODE = itemCode;
        this.Count = count;
        this.QueueCount = queueCount;
    }

    private class Input {
        Integer Count;
        String ItemCode;
    }

    private class Output {
        String ResponseCode;
        String ErrorMessage;
        List<PartsStock> InventoryList;
        String isContinue;
    }

    private class PartsStock {
        String ItemCode;
        Integer OnHand;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '부품재고 레코드를 SFDC에 생성';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = QueueCount;

        Input objInput = new Input();

        // CARDCD valid check
        if (ITEMCODE == null || ITEMCODE == '') {
            ITEMCODE = 'new';
        }
        objInput.ITEMCODE = this.ITEMCODE;

        try {
            IFUtil objIF = new IFUtil(IFID);
            String requestBody = '/' + this.ITEMCODE + '/' + this.Count;
            System.debug('requestBody : ' + requestBody);
            // LogWrapper INSERT
            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();


            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                List<Product2> listProducts = new List<Product2>();
                List<String> listItemCodes = new List<String>();
                Map<String, String> mapItemCodeToProductId = new Map<String, String>();

                for (PartsStock ps : objOutput.InventoryList) {
                    listItemCodes.add(ps.ItemCode);
                }

                for (Product2 prod : [SELECT Id, ExternalId__c, ProductCode FROM Product2 WHERE ExternalId__c = :listItemCodes]) {
                    mapItemCodeToProductId.put(prod.ExternalId__c, prod.Id);
                }

                for (PartsStock ps : objOutput.InventoryList) {
                    Product2 product = new Product2();
                    if (mapItemCodeToProductId.get(ps.ItemCode) != null) {
                        product.Id = mapItemCodeToProductId.get(ps.ItemCode);
                        product.onHand__c = ps.OnHand;

                        listProducts.add(product);
                    }

                }

                List<Database.SaveResult> listDmlResult = Database.update(listProducts, false);
                Integer cnt = 0;
                for (Database.SaveResult objResult : listDmlResult) {
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

                //Queueable Method 재귀 호출
                if (objOutput.isContinue == 'Y') {
                    QueueCount++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_PARTSIVT_qu(ITEMCODE, Count, QueueCount));
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
        LogWrapper.errorMessage = JSON.serialize(listErrorMessage);  
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.enqueueJobId = jobId;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
    }
}