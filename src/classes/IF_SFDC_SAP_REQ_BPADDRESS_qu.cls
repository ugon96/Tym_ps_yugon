/*
 * File Name   		: IF_SFDC_SAP_REQ_BPADDRESS_qu
 * Author	  		: taekyun.yoon
 * Date				: 2023-11-20
 * @Group           : Daeunextier
 * Description 		: SAP의 Master Data인 Business Partner Address 정보를 SFDC에 Upsert하는 인터페이스
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-20       taekyun.yoon           Initial Version
**/

public with sharing class IF_SFDC_SAP_REQ_BPADDRESS_qu implements System.Queueable, Database.AllowsCallouts{
    private static final String IFID = 'IF_SFDC_SAP_REQ_BPADDRESS';

    public String CARDCD;
    public Integer Count;
    public Integer i;

    public IF_SFDC_SAP_REQ_BPADDRESS_qu(String cardCd, Integer count) {
        this.CARDCD = cardCd;
        this.Count = count;
    }
    public IF_SFDC_SAP_REQ_BPADDRESS_qu(String cardCd, Integer count, Integer i) {
        this.CARDCD = cardCd;
        this.Count = count;
        this.i = i;
    }

    private class Input {
        String CARDCD;
        Integer Count;
    }

    private class Output{
        //성공, 실패(S, E)
        String ResponseCode;
        //"SUCCESS" , "ERROR"
        String ErrorMessage;
        List<BPAddress> addressList;
        //Y : 전송해야 할 데이터가 남아 있음
        //N : 모든 데이터가 전송 완료됨
//        String isContinue;
    }

    private class BPAddress{
        String ParentKey;
        Integer LineNum;
        String AddressName;
        String Street;
        String ZipCode;
        String City;
        String Country;
        String State;
        String AddressType;
    }

    public void execute(System.QueueableContext context){
        System.debug('execute');
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Business Partner Address 정보 요청 인터페이스 호출';

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        LogWrapper.requestCount = i;

        IFUtil objIF;
        String requestParam = '';
        String responseBody = '';
        Id jobId = null;

        if (this.CARDCD != null && this.CARDCD != '') {
            requestParam += '/' + this.CARDCD;
            if (this.Count != null && this.Count != 0) {
                requestParam += '/' + String.valueOf(this.Count);
            }
        } else {
            requestParam += '/all';
        }

        try{
            objIF = new IFUtil(IFID);
            HttpResponse response = objIF.webCallout(requestParam, true);

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                Map<String, Address__c> mapNew = new Map<String, Address__c>();
                if (objOutput.addressList.size() > 0 && objOutput.addressList != null) {
                    Set<String> allParentKeys = new Set<String>();
                    for (BPAddress objBPA : objOutput.addressList){
                        if (objBPA.ParentKey != null) {
                            allParentKeys.add(objBPA.ParentKey);
                        }
                    }

                    Map<String, Id> parentKeyToAccountIdMap   = new Map<String, Id>();
                    if (allParentKeys != null){
                        for (Account acc : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN :allParentKeys]){
                            parentKeyToAccountIdMap.put(acc.BPCode__c, acc.Id);
                        }
                    }

                    for (BPAddress objBPA : objOutput.addressList) {
                        Address__c objAddress = new Address__c();

                        if (objBPA.ParentKey != null && parentKeyToAccountIdMap != null){
                            String accountId = parentKeyToAccountIdMap.get(objBPA.ParentKey);

                            if (accountId != null) {
                                objAddress.ExternalId__c = objBPA.ParentKey + String.valueOf(objBPA.LineNum);
                                if (objBPA.AddressName != null) objAddress.Name = objBPA.AddressName;
                                if (objBPA.Country != null) objAddress.Address__CountryCode__s = objBPA.Country;
                                if (objBPA.State != null) objAddress.Address__StateCode__s = objBPA.State;
                                if (objBPA.Street != null) objAddress.Address__Street__s = objBPA.Street;
                                if (objBPA.ZipCode != null) objAddress.Address__PostalCode__s = String.valueOf(objBPA.ZipCode);
                                if (objBPA.City != null) objAddress.Address__City__s = objBPA.City;
                                if (objBPA.AddressType != null) objAddress.BillorShip__c = objBPA.AddressType == 'B' ? 'Billing Address' : 'Shipping Address';
                                objAddress.Dealership__c = parentKeyToAccountIdMap.get(objBPA.ParentKey);

                                if (objBPA.State == 'ON' && objBPA.Country == 'US') {

                                } else if (objBPA.State == 'Ohi') {

                                } else{
                                    mapNew.put(objAddress.ExternalId__c, objAddress);
                                }
                            }
                        }
                    }
                }

                Schema.SObjectField ext = Schema.getGlobalDescribe().get('Address__c').getDescribe().fields.getMap().get('ExternalId__c');
                Database.upsert(mapNew.values(), ext);

                //isContinue, Count 반영 시 조건 변경  if(objOutput.isContinue == 'Y')
                //비동기 처리 무한 처리 방지용 customLabel 방지 killSwitch == N 인 경우 조건 추가 필
                if (this.i < 3) {
                    if (!Test.isRunningTest()) {
                        jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_BPADDRESS_qu(this.CARDCD, this.Count, this.i+1));
                    }
                }
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

        // IF_Log에 기록할 데이터 저장
        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.enqueueJobId = jobId;
        // IF_Log에 데이터 저장
        objIF.setLog(LogWrapper);
        System.debug('execute ==> 힙 크기 사용량: ' + Limits.getHeapSize());
    }
}