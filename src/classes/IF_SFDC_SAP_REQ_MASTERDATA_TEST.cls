/************************************************************************************
 * File Name         : IF_SFDC_SAP_REQ_MASTERDATA_test
 * Author            : taekyun.yoon@daeunextier.com
 * Date              : 2023-12-06
 * @Group            : Daeunextier
 * Description       : IF_SFDC_SAP_REQ_MASTERDATA test class
 * Modification Log
 * Ver       Date            Author                Modification
 * 1.0     2023-12-06       taekyun.yoon        Initial Version
*************************************************************************************/

@IsTest
public with sharing class IF_SFDC_SAP_REQ_MASTERDATA_test {
    @TestSetup
    static void setData() {
        insert DN_TestUtil.createIFMaster('IF_SFDC_SAP_REQ_MASTERDATA',
                'https://wcf.tymerpcloud.com:9447/Service1.svc/GetMasterData/TYM/Salesforce/9gvz5=UcEu8XTXni274pObEpywTiPcpB73(',
                'GET');
    }

    private class MultiStaticResourceCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String url = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            //SAP 호출 엔드포인트 설정 (state 인 경우)
            if (url.contains('/TYM')) {
                String responseBody = '{' +
                        '"ErrorMessage": "Success.",' +
                        '"ResponseCode": "S",' +
                        '"isContinue": "Y",' +
                        '"MasterDataList": [' +
                        '{' +
                        '"isContinue": "Y",' +
                        '"label": "인천광역시",' +
                        '"value": "11"' +
                        '},' +
                        '{' +
                        '"isContinue": "Y",' +
                        '"label": "강원도",' +
                        '"value": "01"' +
                        '},' +
                        '{' +
                        '"isContinue": "Y",' +
                        '"label": "Alberta",' +
                        '"value": "AL"' +
                        '}' +
                        ']' +
                        '}';
                res.setBody(responseBody);
            }
            //getCustomFieldID 호출 엔드포인트 설정
            else if (url.contains('/services/data/v59.0/tooling/query')) {
                String responseBody = '{' +
                        '"size": 1,' +
                        '"totalSize": 1,' +
                        '"done": true,' +
                        '"queryLocator": null,' +
                        '"entityTypeName": "GlobalValueSet",' +
                        '"records": [' +
                        '{' +
                        '"attributes": {' +
                        '"type": "GlobalValueSet",' +
                        '"url": "/services/data/v59.0/tooling/sobjects/GlobalValueSet/0Nt1m000000AKWBCA4"' +
                        '},' +
                        '"Id": "0Nt1m000000AKWBCA4",' +
                        '"MasterLabel": "State"' +
                        '}' +
                        ']' +
                        '}';
                res.setBody(responseBody);
                res.setStatusCode(200);
            }
            // tooling API 호출 엔드포인트 설정
            else if (url.contains('/services/data/v59.0/tooling/sobjects/GlobalValueSet')) {
                String responseBody = ' {' +
                        '"attributes":{' +
                        '"type":"GlobalValueSet",' +
                        '"url":"/services/data/v59.0/tooling/sobjects/GlobalValueSet/0Nt1m000000AKWBCA4"' +
                        '},' +
                        '"Metadata":{' +
                        '"customValue":[' +
                        '{"color":null,' +
                        '"default":false,' +
                        '"description":null,' +
                        '"isActive":null,' +
                        '"label":"1",' +
                        '"urls":null,' +
                        '"valueName":"1"' +
                        '},' +
                        '{"color":null,' +
                        '"default":false,' +
                        '"description":null,' +
                        '"isActive":null,' +
                        '"label":"Alberta",' +
                        '"urls":null,' +
                        '"valueName":"AL"' +
                        '}' +
                        '],' +
                        '"description":null,' +
                        '"masterLabel":"State",' +
                        '"sorted":false,' +
                        '"urls":null' +
                        '},' +
                        '"FullName":"State",' +
                        '"Id":"0Nt1m000000AKWBCA4",' +
                        '"DeveloperName":"State",' +
                        '"MasterLabel":"State",' +
                        '"Description":null,' +
                        '"NamespacePrefix":null,' +
                        '"ManageableState":"unmanaged"' +
                        '}';

                res.setBody(responseBody);
                res.setStatusCode(200);
            }

            return res;
        }
    }


    @IsTest
    static void doTest() {
        Test.setMock(HttpCalloutMock.class, new MultiStaticResourceCalloutMock());
        Test.startTest();

        List<String> listStringMasterData = new List<String>{'Value1', 'Value2'};
        IF_SFDC_SAP_REQ_MASTERDATA.getCustomFieldID(listStringMasterData, 'all');
        IF_SFDC_SAP_REQ_MASTERDATA.getStringCustomFieldID('all');
        IF_SFDC_SAP_REQ_MASTERDATA.convertToSAPMasterDataList(listStringMasterData);
        IF_SFDC_SAP_REQ_MASTERDATA.ToolingAPI(listStringMasterData,'asdasd');

        IF_SFDC_SAP_REQ_MASTERDATA ifSfdcSapReqMasterdata = new IF_SFDC_SAP_REQ_MASTERDATA('state', 100, 0);
        ifSfdcSapReqMasterdata.execute();

        Test.stopTest();
    }
}