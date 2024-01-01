/*************************************************************************************
* File Name   : IF_SFDC_SAP_REQ_CREDITMEMO_qu.cls
* Author      : yj.Chun
* Date        : 2023.12.18
* Class       : IF_SFDC_SAP_REQ_CREDITMEMO_qu.cls
* Target      : CREDIT MEMO Queueable Method
* Description : Claim - A/R Credit Memo I/F
* Modification Log
* ===================================================================================
* Ver      Date            Author              Modification
* ===================================================================================
1.0      2023.12.18      yj.Chun             Create
<**************************************************************************************/
public with sharing class IF_SFDC_SAP_REQ_CREDITMEMO_qu implements Queueable, Database.AllowsCallouts {
    private static final String IFID = 'IF_SFDC_SAP_REQ_CREDITMEMO';

    private String CARDCD;
    private Integer Count;
    private Integer QueueCount;
    private String jobId;

    public IF_SFDC_SAP_REQ_CREDITMEMO_qu(String itemCode) {
        this.CARDCD = itemCode;
    }

    public IF_SFDC_SAP_REQ_CREDITMEMO_qu(String itemCode, Integer count) {
        this.CARDCD = itemCode;
        this.Count = count;
    }

    public IF_SFDC_SAP_REQ_CREDITMEMO_qu(String itemCode, Integer count, Integer queueCount) {
        this.CARDCD = itemCode;
        this.Count = count;
        this.QueueCount = queueCount;
    }

    private class Input {
        Integer Count;
        String CARDCD;
    }

    private class Output {
        String ResponseCode;
        String ErrorMessage;
        List<creditMemo> creditMemo;
        String isContinue;
    }

    private class creditMemo {
        String SFDCKey;
        String CreditMemo;
        Date CreateDate;
        Integer Total;
        String DealerCode;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'A/R Credit Memo 정보 받아오기';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = this.QueueCount;

        Input objInput = new Input();

        // CARDCD valid check
        if (CARDCD == null || CARDCD == '') {
            CARDCD = 'new';
        }
        objInput.CARDCD = this.CARDCD;

        try {
            IFUtil objIF = new IFUtil(IFID);
            String requestBody = '/' + this.CARDCD + '/' + this.Count;
            System.debug('requestBody : ' + requestBody);
            // LogWrapper INSERT
            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();


            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                List<Case> listUpdateCase = new List<Case>();

                for (creditMemo cm : objOutput.creditMemo) {
                    Case newCase = new Case();
                    if (cm.SFDCKey != null) {
                        System.debug('cm.SFDCKey :: ' + cm.SFDCKey);
                        newCase.Id = cm.SFDCKey;
                        newCase.CreditMemo__c = cm.CreditMemo;
                        newCase.CreditMemoAmount__c = cm.Total;
                        listUpdateCase.add(newCase);
                    }
                }

                if (!listUpdateCase.isEmpty()) {
                    List<Database.SaveResult> listDmlResult = Database.update(listUpdateCase, false);
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
                }

                //Queueable Method 재귀 호출
                if (objOutput.isContinue == 'Y') {
                    QueueCount++;
                    jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_CREDITMEMO_qu(this.CARDCD, this.Count, QueueCount));
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
    }
}