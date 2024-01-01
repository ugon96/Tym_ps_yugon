/*
 * File Name   		: IFUtil
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-20
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-20       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class IFUtil {
    public IFMaster__c objMaster;
    public Boolean isTest = false;
    public Integer recordCount;

    public IFUtil(String ifId) {
        IFMaster__c objIFMaster = new IFMaster__c();

        objIFMaster = [
                SELECT Id, Name, Type__c, WebServiceType__c, Endpoint__c, Method__c, ContentType__c, IsSendParameter__c
                FROM IFMaster__c
                WHERE Name = :ifId
        ];

        this.objMaster = objIFMaster;
    }

    public IFUtil(String ifId, Integer fRecordCount) {
        IFMaster__c objIFMaster = new IFMaster__c();

        objIFMaster = [
                SELECT Id, Name, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c, IsSendParameter__c
                FROM IFMaster__c
                WHERE Name = :ifId
        ];

        this.objMaster = objIFMaster;
        this.recordCount = fRecordCount;
    }

    public void setLog(LogWrapper LogWrapper) {
        IFLog__c objLog = new IFLog__c();

        objLog.IFMaster__c = this.objMaster.Id;
        objLog.Status__c = LogWrapper.status;

        objLog.ErrorCode__c = LogWrapper.errorCode;

        objLog.RequestTime__c = LogWrapper.requestTime;
        objLog.RequestHeader__c = LogWrapper.requestHeader <> null && LogWrapper.requestHeader.length() > 130000 ? LogWrapper.requestHeader.substring(0, 130000) : LogWrapper.requestHeader;
        objLog.RequestBody__c = LogWrapper.requestBody <> null && LogWrapper.requestBody.length() > 130000 ? LogWrapper.requestBody.substring(0, 130000) : LogWrapper.requestBody;
        objLog.RequestCount__c = LogWrapper.requestCount;  
        objLog.enqueueJobId__c = LogWrapper.enqueueJobId; 
        objLog.Description__c = LogWrapper.errorMessage;  

        objLog.ResponseTime__c = LogWrapper.responseTime;
        objLog.ResponseHeader__c = LogWrapper.responseHeader <> null && LogWrapper.responseHeader.length() > 130000 ? LogWrapper.responseHeader.substring(0, 130000) : LogWrapper.responseHeader;
        objLog.ResponseBody__c = LogWrapper.responseBody <> null && LogWrapper.responseBody.length() > 130000 ? LogWrapper.responseBody.substring(0, 130000) : LogWrapper.responseBody;

        /*
        if (recordCount != null) {
            // 배치에서 실행된 레코드 갯수 파악 위함 (06.02 sy.jung)
            objLog.RecordCount__c = recordCount;
        }*/

        insert objLog;
    }

    public HttpResponse webCallout(String body, Boolean isLogInsert) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        String status = 'SUCCESS';
        String responseBody;
        String errorCode = '0';
        String errorMessage = '';
        LogWrapper objWrapper = new LogWrapper();

        try {

            objWrapper.requestTime = Datetime.now();

            // setheader 부분 삽입
            request.setMethod(this.objMaster.Method__c);
            request.setEndpoint(this.objMaster.Endpoint__c);
            request.setTimeout(110000);
            String contentType = this.objMaster.ContentType__c;

            request.setHeader('Content-Type', contentType);

            // gzip 압축으로 오는 response 해제를 위한 부분.
//            request.setHeader('Accept-Encoding','gzip');

            // tym Header 공통부 설정.
            request.setHeader('siteCode', 'TYM');
            request.setHeader('apiPartner', 'SalesForce');

            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertToHex(b);

            request.setHeader('apiKey', h);


            if (contentType.contains('multipart')) {
                //request.setHeader('Content-Length', body.length());
                /*
                request.setBodyAsBlob(EncodingUtil.base64Decode(body));
                contentType = contentType+' charset=utf-8; boundary='+System.label.Code_boundary;
				*/
            }
            //request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            objWrapper.requestBody = body;

            if (this.objMaster.IsSendParameter__c) {
                request.setEndpoint(this.objMaster.Endpoint__c + body);
//                System.debug('this.objMaster.Endpoin__c :' + this.objMaster.Endpoint__c);
            } else {
//                System.debug('IsSendParameter__c :'+this.objMaster.IsSendParameter__c);
                request.setBody(body);
            }
            response = http.send(request);
            System.debug('response.getStatusCode() :: ' + response.getStatusCode());
            System.debug('response.getBody() :: ' + response.getBody());

            responseBody = response.getBody();

//            Boolean redirect;

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
//                if (responseBody <> null && responseBody != '' && objMaster.Name != 'IF_RELAY_CMS_EVIDENCE_REG') {
//                    Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
//
//                    if (mapResponse.get('code') <> null && String.valueOf(mapResponse.get('code')) != '0') {
//                        status = 'ERROR';
//                        errorCode = String.valueOf(mapResponse.get('code'));
//                        errorMessage = String.valueOf(mapResponse.get('message'));
//                    }
//                } else {
//                    responseBody = 'Not ResponseBody';
//                }

//                objWrapper.responseTime = Datetime.now();
//                objWrapper.responseBody = responseBody;
            }
            else {
//                String loc = response.getHeader('Location'); // get location of the redirect

                status = 'ERROR';
                errorCode = String.valueOf(response.getStatusCode());
                errorMessage = responseBody;
            }

        } catch (Exception e) {
            status = 'ERROR';
            errorCode = '-1';
            errorMessage = e.getMessage() + ' Line : ' + e.getLineNumber();
            System.debug('errorMessage :: ' + errorMessage);
        }
        objWrapper.responseTime = Datetime.now();
        objWrapper.responseBody = responseBody;
        objWrapper.status = status;
        objWrapper.errorCode = errorCode;
        objWrapper.errorMessage = errorMessage;

        if (isLogInsert) {
            setLog(objWrapper);
        }

        return response;
    }

    @future(callout=true)
    public static void webCalloutFuture(String strJson) {
        IFMaster__c objIFMaster = new IFMaster__c();

        Map<String, Object> mapParam = new Map<String, Object>();

        mapParam = (Map<String, Object>) JSON.deserializeUntyped(strJson);

        Datetime requestTime = Datetime.now();
        Datetime responseTime;

        objIFMaster = [
                SELECT Id, Name, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c, IsSendParameter__c
                FROM IFMaster__c
                WHERE Name = :String.valueOf(mapParam.get('if_id'))
        ];

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        String status = 'SUCCESS';
        String responseBody;
        String errorCode = '0';
        String errorMessage = '';

        String requestBody = '';

        try {
            requestBody = JSON.serialize(mapParam.get('body'));
            /*
            System.debug('=============> requestBody : '+requestBody);

            if(requestBody.contains('\\\\n')) {
                requestBody = requestBody.replaceAll('\\\\n', '\\n');
            }

            if(requestBody.contains('\\\\\\\\n')) {
                requestBody = requestBody.replaceAll('\\\\\\\\n', '\\n');
            }
            */

            System.debug('=============> requestBody : ' + requestBody);

            request.setMethod(objIFMaster.Method__c);
            request.setEndpoint(objIFMaster.Endpoint__c);
            request.setTimeout(110000);
            request.setHeader('Content-Type', objIFMaster.ContentType__c);
            request.setHeader('Content-Length', String.valueOf(requestBody.length()));

            if (objIFMaster.ContentType__c.contains('multipart')) {
                //request.setHeader('Content-Length', body.length());
                /*
                request.setBodyAsBlob(EncodingUtil.base64Decode(body));
                contentType = contentType+' charset=utf-8; boundary='+System.label.Code_boundary;
				*/
            }

            //request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            if (objIFMaster.Method__c == 'POST') {
                request.setBody(requestBody);
            } else if (objIFMaster.Method__c == 'GET') {
                request.setEndpoint(objIFMaster.Endpoint__c + '?' + requestBody);
            }


            response = http.send(request);

            responseTime = Datetime.now();
            responseBody = response.getBody();

            System.debug(response);
            if (response.getStatusCode() == 200) {
                /*
                Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                if (mapResponse.get('code') <> null && String.valueOf(mapResponse.get('code')) != '0') {
                    status = 'ERROR';
                    errorCode = String.valueOf(mapResponse.get('code'));
                    errorMessage = String.valueOf(mapResponse.get('message'));
                }
                */

            } else {
                errorCode = String.valueOf(response.getStatusCode());
                errorMessage = responseBody;
            }

        } catch (Exception e) {
            status = 'ERROR';
            errorCode = '-1';
            errorMessage = e.getMessage() + ' Line : ' + e.getLineNumber();
        }

        IFLog__c objLog = new IFLog__c();

        objLog.IFMaster__c = objIFMaster.Id;
        objLog.Status__c = status;
        objLog.ErrorCode__c = errorCode;
//        objLog.ErrorMessage__c = errorMessage <> null && errorMessage.length() > 130000 ? errorMessage.substring(0, 130000) : errorMessage;
        objLog.RequestTime__c = requestTime;
        objLog.RequestBody__c = requestBody <> null && requestBody.length() > 130000 ? requestBody.substring(0, 130000) : requestBody;
        objLog.ResponseTime__c = responseTime;
        objLog.ResponseBody__c = responseBody <> null && responseBody.length() > 130000 ? responseBody.substring(0, 130000) : responseBody;

        insert objLog;
    }

    public static Date conversionDate(String sDate){
        if(sDate == '0') return null;
        else return date.newInstance(Integer.valueOf(sDate.substring(0,4)), Integer.valueOf(sDate.substring(4,6)), Integer.valueOf(sDate.substring(6,8)));
    }

    public static Integer getRandomNumber() {
        List<Integer> numberList = new List<Integer>();
        List<Integer> rNumberList = new List<Integer>();

        Integer MaxSize = 999;

        for(Integer i=100; i<MaxSize; i++) {
            numberList.add(i+1);
        }

        for(Integer i=100; i<MaxSize; i++){
            Integer random = (Integer)(Math.random()*numberList.size());
            rNumberList.add(numberList.get(random));
            numberList.remove(random);
        }

        System.debug('getRandomNumber ==========> rNumberList : '+rNumberList.get(0));

        return rNumberList.get(0);
    }

    public static String setEncrypt(String strText) {
        String strResult = '';

        Blob cryptoKey = Blob.valueOf('abcabcabc1abca16');
        Blob cryptoIv = Blob.valueOf('abcabcabc1abca16');

        Blob bStrText = Blob.valueOf(strText);

        Blob bEnText = Crypto.encrypt('AES128', cryptoKey, cryptoIv, bStrText);

        strResult = EncodingUtil.base64Encode(bEnText);

        System.debug('========================> strResult : '+strResult);

        return strResult;
    }

    public static String setDecrypt(String strText) {
        String strResult = '';

        Blob cryptoKey = Blob.valueOf('abcabcabc1abca16');
        Blob cryptoIv = Blob.valueOf('abcabcabc1abca16');

        //String decode = EncodingUtil.urlDecode(strText,'UTF-8');

        Blob bRes = EncodingUtil.base64Decode(strText);

        Blob decryptedData = Crypto.decrypt('AES128', cryptoKey, cryptoIv, bRes);

        strResult = EncodingUtil.urlDecode(decryptedData.toString(),'UTF-8');

        System.debug('========================> strResult : '+strResult);

        return strResult;
    }

    /**
 * I/F 오늘날짜 조회(format)
 * @author 김영민
 * @deprecated
 * @exception
 * @param String format Ex) yyyyMMdd
 * @return String
 * @see
 * @throws
 * @version
 */

    public static String getToday(String strFormat) {
        String strReturn = Datetime.now().format('yyyy-MM-dd');

        if(strFormat <> null && strFormat != '') {
            strReturn = Datetime.now().format(strFormat);
        }
        return strReturn;
    }

    public static String getToday(String strFormat, Integer intAddDays) {
        String strReturn = Datetime.now().addDays(intAddDays).format('yyyy-MM-dd');

        if(strFormat <> null && strFormat != '') {
            strReturn = Datetime.now().addDays(intAddDays).format(strFormat);
        }
        return strReturn;
    }

    /**
     * I/F 최근 로그 생성일자 가져오기
     * @author 김영민
     * @deprecated
     * @exception
     * @param String I/F Name
     * @return String
     * @see
     * @throws
     * @version
     */
    public static String getLastLogDate(String strIFName) {

        String strReturn = '';

        List<IFLog__c> listIFLog = [
                SELECT  Id, CreatedDate
                FROM    IFLog__c
                WHERE   IFMaster__r.Name =:strIFName
                ORDER BY CreatedDate DESC LIMIT 1
        ];

        System.debug('===================> IFUtil getLastLogDate listIFLog.size : '+listIFLog.size());
        System.debug('===================> IFUtil getLastLogDate listIFLog : '+listIFLog);

        if(listIFLog <> null && listIFLog.size() > 0) {
            strReturn = listIFLog[0].CreatedDate.format('yyyyMMdd');
        }

        if(strReturn == '' || strReturn == null) {
            strReturn = Datetime.now().format('yyyyMMdd');
        }

        return strReturn;
    }
}