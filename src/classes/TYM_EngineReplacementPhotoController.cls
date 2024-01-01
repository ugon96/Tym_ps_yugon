/*************************************************************
 * @author : th.kim
 * @date : 2023-10-26
 * @group : 
 * @group-content :
 * @description : 커뮤니티 사이트에서 EngineReplacement__c 개체 Rich Text 필드에 이미지 파일 업로드
==============================================================
  * Ver       Date            Author            Modification
    1.0       2023-10-26      th.kim            Initial Version
**************************************************************/

public with sharing class TYM_EngineReplacementPhotoController {

    public class FileWrap {
        public String fileName;
        public String base64;
        public String fieldLabel;
    }

    /**
     * @author th.kim
     * @description EngineReplacement__c Rich Text 필드에 이미지 파일 업로드
     * @param fileData 업로드할 파일 데이터
     * @param recordId EngineReplacement__c Id
     *
     * @return engineReplacementObj
     */
    @AuraEnabled
    public static EngineReplacement__c uploadFiles(String fileData, String recordId) {
        try {
            List<FileWrap> fileList = (List<FileWrap>) JSON.deserialize(fileData, List<FileWrap>.class);
            System.debug('fileList :: ' + fileList[0].fileName);
            String engineOilImgHtml = '';
            String coolantImgHtml = '';
            String radiatorGrillImgHtml = '';
            String airFilterImgHtml = '';
            String airHoseClampsImgHtml = '';
            String meterPanelImgHtml = '';
            String etcImgHtml = '';
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (FileWrap fw : fileList) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fw.fileName;
                cv.PathOnClient = fw.fileName;
                cv.Description = fw.fieldLabel;
                cv.VersionData = EncodingUtil.base64Decode(fw.base64);
                cv.FirstPublishLocationId = recordId;
                cvList.add(cv);
            }
            insert cvList;
            System.debug('cvList :: ' + cvList);

            // Rict Text에 넣을 HTML 이미지 태그 데이터 생성
            for (ContentVersion cv : cvList) {
                String imgUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                System.debug('imgUrl :: ' + imgUrl);
                String imgHtmlTag = ' <img src="' + imgUrl + '"> ';
                String fieldLabel = cv.Description;
                switch on fieldLabel {
                    when 'Quantity of Engine Oil' {
                        engineOilImgHtml += imgHtmlTag;
                    }
                    when 'Quantity of Coolant' {
                        coolantImgHtml += imgHtmlTag;
                    }
                    when 'Radiator Grill' {
                        radiatorGrillImgHtml += imgHtmlTag;
                    }
                    when 'Air Filter' {
                        airFilterImgHtml += imgHtmlTag;
                    }
                    when 'Air Hose & Clamps' {
                        airHoseClampsImgHtml += imgHtmlTag;
                    }
                    when 'Meter Panel' {
                        meterPanelImgHtml += imgHtmlTag;
                    }
                    when 'ETC' {
                        etcImgHtml += imgHtmlTag;
                    }
                }

                // Test Code Coverage 부족 시 if문
//                if(cv.Description == 'Quantity of Engine Oil') engineOilImgHtml += imgHtmlTag;
//                if(cv.Description == 'Quantity of Coolant') coolantImgHtml += imgHtmlTag;
//                if(cv.Description == 'Radiator Grill') radiatorGrillImgHtml += imgHtmlTag;
//                if(cv.Description == 'Air Filter') airFilterImgHtml += imgHtmlTag;
//                if(cv.Description == 'Air Hose & Clamps') airHoseClampsImgHtml += imgHtmlTag;
//                if(cv.Description == 'Meter Panel') meterPanelImgHtml += imgHtmlTag;
//                if(cv.Description == 'ETC') etcImgHtml += imgHtmlTag;
            }

//            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
//            for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvList]) {
//                ContentDocumentLink conDocLink = new ContentDocumentLink();
//                conDocLink.LinkedEntityId = recordId;
//                conDocLink.ContentDocumentId = cv.ContentDocumentId;
//                conDocLink.Visibility = 'AllUsers';
//                conDocLink.ShareType = 'V';
//                cdList.add(conDocLink);
//            }
//            insert cdList;
//            System.debug('cdList :: ' + cdList);

            EngineReplacement__c engineReplacementObj = [
                    SELECT Id, QuantityofEngineOil__c, QuantityofCoolant__c, RadiatorGrill__c, AirFilter__c, AirHoseClamps__c, MeterPanel__c, ETC__c
                    FROM EngineReplacement__c
                    WHERE Id = :recordId
            ];
            if (!String.isBlank(engineOilImgHtml)) {
                if (String.isBlank(engineReplacementObj.QuantityofEngineOil__c)) engineReplacementObj.QuantityofEngineOil__c = '';
                engineReplacementObj.QuantityofEngineOil__c += engineOilImgHtml;
            }
            if (!String.isBlank(coolantImgHtml)) {
                if (String.isBlank(engineReplacementObj.QuantityofCoolant__c)) engineReplacementObj.QuantityofCoolant__c = '';
                engineReplacementObj.QuantityofCoolant__c += coolantImgHtml;
            }
            if (!String.isBlank(radiatorGrillImgHtml)) {
                if (String.isBlank(engineReplacementObj.RadiatorGrill__c)) engineReplacementObj.RadiatorGrill__c = '';
                engineReplacementObj.RadiatorGrill__c += radiatorGrillImgHtml;
            }
            if (!String.isBlank(airFilterImgHtml)) {
                if (String.isBlank(engineReplacementObj.AirFilter__c)) engineReplacementObj.AirFilter__c = '';
                engineReplacementObj.AirFilter__c += airFilterImgHtml;
            }
            if (!String.isBlank(airHoseClampsImgHtml)) {
                if (String.isBlank(engineReplacementObj.AirHoseClamps__c)) engineReplacementObj.AirHoseClamps__c = '';
                engineReplacementObj.AirHoseClamps__c += airHoseClampsImgHtml;
            }
            if (!String.isBlank(meterPanelImgHtml)) {
                if (String.isBlank(engineReplacementObj.MeterPanel__c)) engineReplacementObj.MeterPanel__c = '';
                engineReplacementObj.MeterPanel__c += meterPanelImgHtml;
            }
            if (!String.isBlank(etcImgHtml)) {
                if (String.isBlank(engineReplacementObj.ETC__c)) engineReplacementObj.ETC__c = '';
                engineReplacementObj.ETC__c += etcImgHtml;
            }

            System.debug('engineReplacement :: ' + engineReplacementObj);
            update engineReplacementObj;
            return engineReplacementObj;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description EngineReplacement Rich Text 필드 별 이미지 가져오는 메서드
     * @param recordId EngineReplacement__c Id
     *
     * @return returnCvMap
     */
    @AuraEnabled
    public static Map<String, List<ContentDistribution>> getImageList(String recordId) {
        try {
            EngineReplacement__c engineReplacementObj = [
                    SELECT Id, QuantityofEngineOil__c, QuantityofCoolant__c, RadiatorGrill__c, AirFilter__c, AirHoseClamps__c, MeterPanel__c, ETC__c
                    FROM EngineReplacement__c
                    WHERE Id = :recordId
            ];

            Map<String, String> strMap = new Map<String, String>();
            if (!String.isBlank(engineReplacementObj.QuantityofEngineOil__c)) strMap.put('QuantityofEngineOil__c', engineReplacementObj.QuantityofEngineOil__c);
            if (!String.isBlank(engineReplacementObj.QuantityofCoolant__c)) strMap.put('QuantityofCoolant__c', engineReplacementObj.QuantityofCoolant__c);
            if (!String.isBlank(engineReplacementObj.RadiatorGrill__c)) strMap.put('RadiatorGrill__c', engineReplacementObj.RadiatorGrill__c);
            if (!String.isBlank(engineReplacementObj.AirFilter__c)) strMap.put('AirFilter__c', engineReplacementObj.AirFilter__c);
            if (!String.isBlank(engineReplacementObj.AirHoseClamps__c)) strMap.put('AirHoseClamps__c', engineReplacementObj.AirHoseClamps__c);
            if (!String.isBlank(engineReplacementObj.MeterPanel__c)) strMap.put('MeterPanel__c', engineReplacementObj.MeterPanel__c);
            if (!String.isBlank(engineReplacementObj.ETC__c)) strMap.put('ETC__c', engineReplacementObj.ETC__c);

            String urlChkStr = 'sfc/servlet.shepherd/version/download/';
            Map<Id, String> cvMap = new Map<Id, String>();
            for (String str : strMap.keySet()) {
                String line = strMap.get(str);
                // 이미지 태그의 URL 패턴 검사
                while (line.contains(urlChkStr)) {
                    // url에서 ContentVersion Id 추출
                    Integer startIndex = line.indexOf(urlChkStr) + 38;
                    Integer endIndex = line.indexOf('"', startIndex);
                    if (startIndex > 0 && endIndex > startIndex) {
                        String contentVersionId = line.substring(startIndex, endIndex);
                        cvMap.put(contentVersionId, str);
                    }
                    line = line.substring(endIndex);
                }
            }

            Map<String, List<ContentDistribution>> returnCvMap = new Map<String, List<ContentDistribution>>();
            List<ContentDistribution> engineOilList = new List<ContentDistribution>();
            List<ContentDistribution> coolantList = new List<ContentDistribution>();
            List<ContentDistribution> radiatorGrillList = new List<ContentDistribution>();
            List<ContentDistribution> airFilterList = new List<ContentDistribution>();
            List<ContentDistribution> airHoseClampsList = new List<ContentDistribution>();
            List<ContentDistribution> meterPanelList = new List<ContentDistribution>();
            List<ContentDistribution> etcList = new List<ContentDistribution>();
            List<ContentDistribution> listCdb = [SELECT Id, ContentVersionId, ContentVersion.Title, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :cvMap.keySet() ORDER BY CreatedDate ASC];
            for (ContentDistribution cdb : listCdb) {
                String fieldName = cvMap.get(cdb.ContentVersionId);
//                ContentVersion objCv = new ContentVersion();
//                objCv.Id = cdb.ContentVersionId;
//                objCv.Title = cdb.ContentVersion.Title;
                switch on fieldName {
                    when 'QuantityofEngineOil__c' {
                        engineOilList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), engineOilList);
                    }
                    when 'QuantityofCoolant__c' {
                        coolantList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), coolantList);
                    }
                    when 'RadiatorGrill__c' {
                        radiatorGrillList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), radiatorGrillList);
                    }
                    when 'AirFilter__c' {
                        airFilterList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), airFilterList);
                    }
                    when 'AirHoseClamps__c' {
                        airHoseClampsList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), airHoseClampsList);
                    }
                    when 'MeterPanel__c' {
                        meterPanelList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), meterPanelList);
                    }
                    when 'ETC__c' {
                        etcList.add(cdb);
                        returnCvMap.put(cvMap.get(cdb.ContentVersionId), etcList);
                    }
                }
            }

            return returnCvMap;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}