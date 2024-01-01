/**
 * Created by nhkim on 2023-12-05.
 */

public with sharing class IF_SFDC_SAP_REQ_FINISHEDGOODS_qu implements Queueable, Database.AllowsCallouts{
    private static final String IFID = 'IF_SFDC_SAP_REQ_FINISHEDGOODS';

    private String ItemCode;
    private Integer Count;
    private Integer i;      //Queue Count
    private String jobId;

    public IF_SFDC_SAP_REQ_FINISHEDGOODS_qu(String itemCode, Integer Count) {
        this.ItemCode = itemCode;
        this.Count = Count;
    }

    public IF_SFDC_SAP_REQ_FINISHEDGOODS_qu(String itemCode, Integer Count, Integer i) {
        this.ItemCode = itemCode;
        this.Count = Count;
        this.i = i;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        // Data라는 명칭은 받아오는 결과에 따라 수정되어야 함
        List<FinishedGoods> BOMList;
        String isContinue;
    }

    public class FinishedGoods {
        public String ParentItem;
        public String ChildNum;
        public String ComponentCode;
        public String Quantity;
        public String ItemGroupCode;
    }

    public void execute(QueueableContext context) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '완제품 레코드를 SFDC에 생성';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = this.i;

        if (ItemCode == null || ItemCode == '') {
            ItemCode = 'new';
        }

        try {
            IFUtil objIF = new IFUtil(IFID);
            HttpResponse response = objIF.webCallout('/' + this.ItemCode + '/' + this.Count, true);
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                if (objOutput.BOMList != null) {
                    Set<String> setParentItemCode = new Set<String>();
                    Set<String> setChildItemCode = new Set<String>();
                    Map<String,String> mapItemCode = new Map<String, String>();
                    for (FinishedGoods fg : objOutput.BOMList) {
                        setParentItemCode.add(fg.ParentItem);
                        setChildItemCode.add(fg.ComponentCode);
                    }

                    for (Product2 obj : [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN: setParentItemCode OR ExternalId__c IN: setChildItemCode]) {
                        mapItemCode.put(obj.ExternalId__c, obj.Id);
                    }

                    if(!mapItemCode.isEmpty()) {
                        Map<String, Product2> mapProduct = new Map<String, Product2>();
                        Product2 objProduct;
                        for (FinishedGoods fg : objOutput.BOMList) {
                            if (mapProduct.get(fg.ParentItem) <> null) {
                                objProduct = mapProduct.get(fg.ParentItem);
                            } else {
                                objProduct = new Product2();
                                objProduct.Id = mapItemCode.get(fg.ParentItem);
                            }
                            if (mapItemCode.get(fg.ComponentCode) <> null) {
                                if (fg.ItemGroupCode == '112') { //Tractor
                                    objProduct.Tractor__c = mapItemCode.get(fg.ComponentCode);
                                } else if (fg.ItemGroupCode == '113') { //Loader
                                    objProduct.Loader__c = mapItemCode.get(fg.ComponentCode);
                                } else if (fg.ItemGroupCode == '114') { //Backhoe
                                    objProduct.Backhoe__c = mapItemCode.get(fg.ComponentCode);
                                } else if (fg.ItemGroupCode == '115') { //F-Tire
                                    objProduct.FTire__c = mapItemCode.get(fg.ComponentCode);
                                } else if (fg.ItemGroupCode == '116') { //R-Tire
                                    objProduct.RTire__c = mapItemCode.get(fg.ComponentCode);
                                }
                            }
                            mapProduct.put(fg.ParentItem, objProduct);
                        }

                        if(!mapProduct.isEmpty()) {
                            System.debug('mapProduct ==> ' + mapProduct);
                            System.debug('mapProduct.values() ==> ' + mapProduct.values());
                            List<Database.SaveResult> listDmlResult = Database.update(mapProduct.values(), false);
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
                                i++;
                                jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_FINISHEDGOODS_qu(this.ItemCode, this.Count, i));
                            }
                        }
                    }

                }
                else {
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