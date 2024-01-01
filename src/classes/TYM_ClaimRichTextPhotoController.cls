/*************************************************************
 * @author : th.kim
 * @date : 2023-10-11
 * @group : 
 * @group-content :
 * @description : 커뮤니티 사이트에서 Case 개체의 Rich Text 필드에 이미지 파일 업로드
==============================================================
  * Ver       Date            Author            Modification
    1.0       2023-10-11      th.kim            Initial Version
**************************************************************/

public with sharing class TYM_ClaimRichTextPhotoController {

    public class FileWrap {
        public String fileName;
        public String base64;
        public String fieldLabel;
    }

    /**
     * @author th.kim
     * @description Case Rich Text 필드에 이미지 파일 업로드
     * @param fileData 업로드할 파일 데이터
     * @param recordId Case Id
     *
     * @return caseObj
     */
    @AuraEnabled
    public static Case uploadFiles(String fileData, String recordId) {
        try {
            List<FileWrap> fileList = (List<FileWrap>) JSON.deserialize(fileData, List<FileWrap>.class);
            System.debug('fileList :: ' + fileList);
            String Photo_of_Hour_Meter;
            String Photo_of_Serial_Number;
            String Photo_of_Tractor_during_repair = '';
            String Photo_of_failure_part = '';
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
                    when 'Photo of Hour Meter' {
                        Photo_of_Hour_Meter = imgHtmlTag;
                    }
                    when 'Photo of Serial Number' {
                        Photo_of_Serial_Number = imgHtmlTag;
                    }
                    when 'Photo of Tractor during repair' {
                        Photo_of_Tractor_during_repair += imgHtmlTag;
                    }
                    when 'Photo of failure part' {
                        Photo_of_failure_part += imgHtmlTag;
                    }
                }
//                if (fieldLabel == 'Photo of Hour Meter') Photo_of_Hour_Meter = imgHtmlTag;
//                if (fieldLabel == 'Photo of Serial Number') Photo_of_Serial_Number = imgHtmlTag;
//                if (fieldLabel == 'Photo of Tractor during repair') Photo_of_Tractor_during_repair += imgHtmlTag;
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

            Case caseObj = [
                    SELECT Id, PhotOf0HourMeter__c, PhotoOfSerialNumber__c, PhotoTractoDuringRepair__c, PhotoFailurePart__c
                    FROM Case
                    WHERE Id = :recordId
            ];
            if (!String.isBlank(Photo_of_Hour_Meter)) caseObj.PhotOf0HourMeter__c = Photo_of_Hour_Meter;
            if (!String.isBlank(Photo_of_Serial_Number)) caseObj.PhotoOfSerialNumber__c = Photo_of_Serial_Number;
            if (!String.isBlank(Photo_of_Tractor_during_repair)) {
                if (String.isBlank(caseObj.PhotoTractoDuringRepair__c)) caseObj.PhotoTractoDuringRepair__c = '';
                caseObj.PhotoTractoDuringRepair__c += Photo_of_Tractor_during_repair;
            }
            if (!String.isBlank(Photo_of_failure_part)) {
                if (String.isBlank(caseObj.PhotoFailurePart__c)) caseObj.PhotoFailurePart__c = '';
                caseObj.PhotoFailurePart__c += Photo_of_failure_part;
            }
            System.debug('Photo_of_Tractor_during_repair :: ' + Photo_of_Tractor_during_repair);
            System.debug('case :: ' + caseObj);
            update caseObj;

            return caseObj;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Case Rich Text 필드 별 이미지 가져오는 메서드
     * @param recordId Case Id
     *
     * @return returnCvMap
     */
    @AuraEnabled
    public static Map<String, List<Object>> getImageList(String recordId) {
        Map<String, List<Object>> returnCvMap = new Map<String, List<Object>>();
        try {
            Case caseObj = [
                    SELECT Id, PhotOf0HourMeter__c, PhotoOfSerialNumber__c, PhotoTractoDuringRepair__c, PhotoFailurePart__c, Status
                    FROM Case
                    WHERE Id = :recordId
            ];
            returnCvMap.put('case', new List<Case>{caseObj});

            Map<String, String> strMap = new Map<String, String>();
            if (!String.isBlank(caseObj.PhotOf0HourMeter__c)) strMap.put('PhotOf0HourMeter__c', caseObj.PhotOf0HourMeter__c);
            if (!String.isBlank(caseObj.PhotoOfSerialNumber__c)) strMap.put('PhotoOfSerialNumber__c', caseObj.PhotoOfSerialNumber__c);
            if (!String.isBlank(caseObj.PhotoTractoDuringRepair__c)) strMap.put('PhotoTractoDuringRepair__c', caseObj.PhotoTractoDuringRepair__c);
            if (!String.isBlank(caseObj.PhotoFailurePart__c)) strMap.put('PhotoFailurePart__c', caseObj.PhotoFailurePart__c);

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

            List<ContentDistribution> listCdb = [SELECT Id, ContentVersionId, ContentVersion.Title, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :cvMap.keySet() ORDER BY CreatedDate ASC];
            List<ContentDistribution> cvList = new List<ContentDistribution>();
            List<ContentDistribution> cvFailureList = new List<ContentDistribution>();
            for (ContentDistribution cdb : listCdb) {
//                ContentVersion objCv = new ContentVersion();
//                objCv.Id = cdb.ContentVersionId;
//                objCv.Title = cdb.ContentVersion.Title;
                // PhotoTractoDuringRepair__c, PhotoFailurePart__c 필드를 제외한 데이터는 한개씩 넣기 위한 초기화 리스트
                List<ContentDistribution> initCvList = new List<ContentDistribution>();
                if (cvMap.get(cdb.ContentVersionId) == 'PhotoTractoDuringRepair__c') {
                    cvList.add(cdb);
                    returnCvMap.put(cvMap.get(cdb.ContentVersionId), cvList);
                } else if (cvMap.get(cdb.ContentVersionId) == 'PhotoFailurePart__c') {
                    cvFailureList.add(cdb);
                    returnCvMap.put(cvMap.get(cdb.ContentVersionId), cvFailureList);
                } else {
                    initCvList.add(cdb);
                    returnCvMap.put(cvMap.get(cdb.ContentVersionId), initCvList);
                }
            }

            return returnCvMap;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}