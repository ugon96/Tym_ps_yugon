/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_ORDER_PARTS
 * Author	  		: taekyun.yoon@daeunextier.com
 * Date				: 2023-11-21
 * @Group           : Daeunextier
 * Description 		: SAP에서 변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-21       taekyun.yoon        Initial Version
*************************************************************************************/

global without sharing class IF_SFDC_SAP_REQ_ORDER_PARTS implements System.Queueable, Database.AllowsCallouts{
    private static final String IFID = 'IF_SFDC_SAP_REQ_ORDER_PARTS';
    private String SFDCKey;
    private Integer Count;
    private Integer i;

    public IF_SFDC_SAP_REQ_ORDER_PARTS(String sfdcKey,Integer i){
        System.debug('Set ifSfdcSapReqOrderParts Constructor without count :: complete ');
        this.SFDCKey = sfdcKey;
        this.i = i;
    }
    public IF_SFDC_SAP_REQ_ORDER_PARTS(String sfdcKey, Integer count, Integer i) {
        System.debug('Set ifSfdcSapReqOrderParts Constructor with count :: complete ');
        this.SFDCKey = sfdcKey;
        this.Count = count;
        this.i = i;
    }

    private class Input {
        String SFDCKey;
        //요청 개수
        Integer Count;
    }

    private class Output{
        //성공, 실패(S, E)
        String ResponseCode;

        String ErrorMessage;
        List<SAPPartsOrders> Data;

        //Y : 전송해야 할 데이터가 남아 있음
        //N : 모든 데이터가 전송 완료됨
        String isContinue;
    }

    private class SAPPartsOrders{
        String SFDCKey;
        String SFDCOrderType = 'PartsOrder';
        String BPCode;
        String Shipto;
        String Billto;
        String Remarks;
        String SalesEmployee;
        String OrderType;
        String ShippingMode;
        String DiscountMode;
        String PartialShipment;
        List<SAPPartsOrderItem> PartsOrderItems;
        String SAPKey;
        Integer TotalPrice;
        //Date(yyyy-mm-dd)
        Date DocumentDate;
        Integer DiscountRate;
    }

    private class SAPPartsOrderItem{
        String SFDCKey;
        String SAPKey;
        String LineNum;
        String ItemCode;
        Integer UnitPrice;
        Integer Quantity;
//        Decimal DiscountRate; 삭제
        Integer TotalPrice;
    }

    public void execute(QueueableContext context){
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'SAP에서 변경한 Order의 내용을 SFDC API 호출하여 SFDC에 반영 (Update)';

        // 결과 기록용 변수
        Integer outputCnt = 0;
        Integer successCnt = 0;
        Integer failCnt = 0;
        Id jobId = null;
        List<String> listErrorDealerCode = new List<String>();
        List<String> listErrorMessage = new List<String>();

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;

        Input objInput = new Input();
        IFUtil objIF;

        if (this.SFDCKey == null || this.SFDCKey == '') {
            this.SFDCKey = 'new';
        }

        String requestBody;
        if (this.Count != null && this.Count > 0) {
            requestBody = '/' + this.SFDCKey + '/' + this.Count;
        }else {
            requestBody += '/' + this.SFDCKey;
        }

        System.debug('requestBody : ' + requestBody);
        String responseBody;

        try{
            objIF = new IFUtil(IFID);

            HttpResponse response = objIF.webCallout(requestBody, true);
            System.debug(response);
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            System.debug(response.getStatus());

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                List<String> listSAPPartsOrder = new List<String>();
                List<PartsOrder__c> listPartsOrder = new List<PartsOrder__c>();

                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

//                if (objOutput.isContinue == 'N') {
                if (objOutput.Data.size() > 0) {
                    for (SAPPartsOrders objSAPPartsOrder : objOutput.Data) {
                        outputCnt++;
                        listSAPPartsOrder.add(objSAPPartsOrder.SFDCKey);
                    }

                    if (listSAPPartsOrder.size() > 0) {
                        //기존의 PartsOrder__c 조회
                        listPartsOrder = new List<PartsOrder__c>(
                        [
                                SELECT Id, DealershipId__c
                                FROM PartsOrder__c
                                WHERE Id = :listSAPPartsOrder
                        ]);

                        Map<String, PartsOrder__c> mapSAPPartsOrderToPartsOrder = new Map<String, PartsOrder__c>();
                        for (PartsOrder__c objPartsOrder : listPartsOrder) {
                            mapSAPPartsOrderToPartsOrder.put(objPartsOrder.Id, objPartsOrder);
                        }

                        //update 할 PartsOrder 데이터 생성
                        for (SAPPartsOrders objSAPPartsOrder : objOutput.Data) {
                            PartsOrder__c objPartsOrder = mapSAPPartsOrderToPartsOrder.get(objSAPPartsOrder.SFDCKey);
                            if (objPartsOrder == null) {
                                // null 이면 업데이트 x
                                System.debug('objPartsOrder is null!!');
                            } else {
                                objPartsOrder.Id = objSAPPartsOrder.SFDCKey;
                                //인터페이스 정의서의 필드 SFDC 에서 확인 불가
//                               objPartsOrder.sObjectName = objSAPPartsOrder.SFDCOrderType;

                                objPartsOrder.DealershipId__c = objSAPPartsOrder.BPCode;
                                objPartsOrder.ShiptoAddressId__r.ExternalId__c = objSAPPartsOrder.Shipto;
                                objPartsOrder.BilltoAddressID__r.ExternalId__c = objSAPPartsOrder.Billto;
                                objPartsOrder.Remarks__c = objSAPPartsOrder.Remarks;
                                objPartsOrder.OrderType__c = objSAPPartsOrder.OrderType;
                                objPartsOrder.ShippingMode__c = objSAPPartsOrder.ShippingMode;
                                objPartsOrder.Discount__c = objSAPPartsOrder.DiscountMode;
                                objPartsOrder.PartialShipment__c = objSAPPartsOrder.PartialShipment;

                                mapSAPPartsOrderToPartsOrder.put(objPartsOrder.Id, objPartsOrder);
                            }
                        }

                        List<Database.UpsertResult> listDmlResult = Database.upsert(mapSAPPartsOrderToPartsOrder.values(), false);
                        System.debug('execute ==> i = > ' + i);
                        //isContinue, Count 반영 시 조건 변경 if(objOutput.isContinue == 'Y')
                        if (i < 3) {
                            i++;
                            //Queueable Method 재귀 출
                            jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_PRICELISTMST('ALL', i));
                        }

                        Integer cnt = 0;
                        for (Database.UpsertResult objResult : listDmlResult) {
                            if (objResult.success) {
                                successCnt++;
                            } else {
                                failCnt++;
                                listErrorDealerCode.add(mapSAPPartsOrderToPartsOrder.values().get(cnt).Id);
                                if (objResult.getErrors().toString().contains('required field missing')) {
                                    listErrorMessage.add('Required field missing');
                                } else {
                                    listErrorMessage.add(objResult.getErrors().toString());
                                }
                            }
                            cnt++;
                        }
                    }
                }
//                }
            } else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }
        if (outputCnt == successCnt + failCnt && outputCnt != 0) {
            strMessage += '\n Total : ' + outputCnt + '. Success : ' + successCnt + '. Fail : ' + failCnt + '.';
            if (failCnt > 0) {
                strMessage += ' Fail List : ' + listErrorDealerCode.toString();
                strMessage += ' Fail Reason : ' + listErrorMessage.toString();
            }
        }

        // IF_Log에 기록할 데이터 저장
        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;

        LogWrapper.enqueueJobId = jobId;

        System.debug(LogWrapper);
        // IF_Log에 데이터 저장
        objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
        System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());
    }
}