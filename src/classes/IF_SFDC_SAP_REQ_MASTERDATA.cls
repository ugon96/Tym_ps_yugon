/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_MASTERDATA
 * Author	  		: nh.kim@daeunextier.com
 * Date				: 2023-11-22
 * @Group           : Daeunextier
 * Description 		: Upsert 국가코드, Street Code, Item Group Code
 * Modification Log
 * Ver       Date            Author      		               Modification
 * 1.0     2023-11-22        nh.kim@daeunextier.com            Initial Version
 * 1.1     2023-12-          taekyun.yoon
*************************************************************************************/

public with sharing class IF_SFDC_SAP_REQ_MASTERDATA {
    private static final String IFID = 'IF_SFDC_SAP_REQ_MASTERDATA';
    private String Type;
    private Integer Count;
    private Integer i;
    static Output objOutput;

    public IF_SFDC_SAP_REQ_MASTERDATA() {}

    public IF_SFDC_SAP_REQ_MASTERDATA(String type1, Integer count){
        this.Type = type1;
        this.Count = count;
    }
    public IF_SFDC_SAP_REQ_MASTERDATA(String type1, Integer count, Integer i){
        this.Type = type1;
        this.Count = count;
        this.i = i;
    }

    private class Input{}
    private class Output{
        String ErrorMessage;
        String ResponseCode;
        List<SAPMasterData> MasterDataList;
        String isContinue;
    }

    private class SAPMasterData{
        String value;
        String label;
        String isContinue;
    }

    public class RootObjectMeta{
//        Attributes attributes;
        public Metadata Metadata;
        public String FullName;
//        String Id;
//        String DeveloperName;
//        String MasterLabel;
//        String Description;
//        String NamespacePrefix;
//        String ManageableState;
//        String CreatedDate;
//        String CreatedById;
//        String LastModifiedDate;
//        String LastModifiedById;
    }
    public class Attributes{
        public String type;
        public String url;
    }

    public class Metadata {
        public List<CustomValue> customValue;
        public String description;
        public String masterLabel;
//        public Boolean sorted;
//        public String urls;
    }

    public class CustomValue {
        public String color;
//        public Boolean default;
        public String description;
        public Boolean isActive;
        public String label;
//        public String urls;
        public String valueName;
    }

    public class CustomField {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public String queryLocator;
        public String entityTypeName;
        public List<Record> records;
    }


    public class Record {
        public Attributes attributes;
        public String Id;
        public String MasterLabel;
    }


    public void execute(){
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Master Data 정보 요청 인터페이스 호출';

        String requestBody;

        if (this.Type != null && this.Type !='') {
            requestBody = '/' + this.Type;
            if (this.Count != null && this.Count != 0) {
                requestBody += '/' + this.Count;
            }
        }

        try {
            IFUtil objIf = new IFUtil(IFID);
            HttpResponse response = objIf.webCallout(requestBody, true);

            if (response.getStatusCode() == 200) {
                objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);
                if (objOutput.MasterDataList != null && objOutput.MasterDataList.size() > 0) {
                    List<SAPMasterData> listSAPMasterData = objOutput.MasterDataList;
                    List<String> listStringMasterData= transformData(listSAPMasterData);
                    getCustomFieldID(listStringMasterData, this.Type);
                }
                if (objOutput.isContinue == 'Y') {
                    if (!Test.isRunningTest()) {
                        Id jobId = System.enqueueJob(new IF_SFDC_SAP_REQ_MASTERDATA(this.Type, this.Count, this.i+1));
                    }
                }
            }

        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }
    }

    //비동기 처리 함수
    @Future(Callout = true)
    public static void getCustomFieldID(List<String> listStringMasterData, String type) {

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();

        try {
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v59.0/tooling/query/?q=Select+Id,MasterLabel+FROM+GlobalValueSet+WHERE+developername=\''+ type +'\'');

            req.setMethod('GET');
            req.setTimeout(110000);
//sss
            res = h.send(req);
            System.debug(res);

            CustomField customField = (CustomField) JSON.deserialize((res.getBody()), CustomField.class);

            String targetPoint = customField.records[0].attributes.url;

            ToolingAPI(listStringMasterData, targetPoint);

        } catch (Exception e) {
            System.debug('Error :: getCustomFieldID :' + e.getMessage() + 'Line : ' + e.getLineNumber());
        }
    }

    //동기 처리 함수(customFieldID return func)
    public static String getStringCustomFieldID(String type){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();

        String customFieldID;

        try {
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v59.0/tooling/query/?q=Select+Id,MasterLabel+FROM+GlobalValueSet+WHERE+developername=\''+ type +'\'');

            req.setMethod('GET');
            req.setTimeout(110000);

            res = h.send(req);
            System.debug(res);

            CustomField customField = (CustomField) JSON.deserialize((res.getBody()), CustomField.class);

            customFieldID = customField.records[0].attributes.url;


        } catch (Exception e) {
            System.debug('Error :: getCustomFieldID :' + e.getMessage() + 'Line : ' + e.getLineNumber());
        }

        return customFieldID;
    }



    public static HttpResponse ToolingAPI(List<String> listStringMasterData, String targetPoint) {
        try {
            HttpResponse res = getPickList(targetPoint);

            RootObjectMeta objRoot = (RootObjectMeta) JSON.deserialize(res.getBody(), RootObjectMeta.class);

            List<SAPMasterData> listSAPMasterData = convertToSAPMasterDataList(listStringMasterData);

            for (SAPMasterData objSAPMasterData : listSAPMasterData) {
                if (objSAPMasterData.value == 'SA' ||
                        objSAPMasterData.value == 'WA' ||
                        objSAPMasterData.value == 'AL' ||
                        objSAPMasterData.value == 'MA' ||
                        objSAPMasterData.value == 'CO' ||
                        objSAPMasterData.label == '안길라' ||
                        objSAPMasterData.label == '말티니크' ||
                        objSAPMasterData.label == '그리스') {
                    //value 값이 중복되어 picklist value 넣을 때 에러나서 제외
                    //label 값이 중복 (country)
                    // 안티구아 바부다  안티구아 바부다  안티구아 바부다 label 명이 이상함 (Country 일때)
                } else {
                    CustomValue objCV = new CustomValue();
                    objCV.isActive = true;
                    objCV.label = objSAPMasterData.label;
                    objCV.valueName = objSAPMasterData.value;

                    objRoot.Metadata.customValue.add(objCV);
                }

            }
            objRoot.FullName += '__gvs';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + targetPoint);
            req.setMethod('PATCH');

            String strBody = JSON.serialize(objRoot);
            req.setBody(strBody);

            Http h = new Http();
            res = h.send(req);
            System.debug(res);

            return res;
        }catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    //SFDC의 pickList 가져오기(state, country, itemgroupcode ..etc)
    public static HttpResponse getPickList(STring targetPoint) {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + targetPoint);

        req.setMethod('GET');

        Http h = new Http();
        HttpResponse res = h.send(req);

        return res;
    }


    // SAPMasterData 인스턴스를 문자열 목록으로 변환
    public static List<String> transformData(List<SAPMasterData> dataList) {
        List<String> transformedData = new List<String>();

        for (SAPMasterData data : dataList) {
            // SAPMasterData를 문자열 표현으로 변환
            String transformed = 'Value: ' + data.value + ', Label: ' + data.label;
            transformedData.add(transformed);
        }

        return transformedData;
    }

    // List<String> 형태의 문자열을 SAPMasterData 객체 리스트로 변환
    public static List<SAPMasterData> convertToSAPMasterDataList(List<String> stringList) {
        List<SAPMasterData> dataList = new List<SAPMasterData>();

        for (String str : stringList) {
            SAPMasterData data = new SAPMasterData();

            // 각 문자열에서 label과 value를 추출하여 SAPMasterData 객체로 변환
            String[] parts = str.split(', ');

            for (String part : parts) {

                String[] keyValue = part.split(': ');
                if (keyValue.size() == 2) {
                    String key = keyValue[0].trim();
                    String value = keyValue[1].trim().replaceAll('Value: |Label: ', '');

                    if (key == 'Value') {
                        data.value = value;
                    } else if (key == 'Label') {
                        data.label = value;
                    }
                }
            }

            dataList.add(data);
        }

        return dataList;
    }
}