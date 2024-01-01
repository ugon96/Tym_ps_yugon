/*************************************************************
 * @author : th.kim
 * @date : 2023-10-13
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver Date Author Modification
 1.0    Initial Version
**************************************************************/

@IsTest
public class TYM_ClaimRichTextPhotoController_TEST {

    static Case caseObj;
    static ContentVersion cv;
    static ContentDistribution cdb;
    static String fileName = 'test';
    static String base64 = 'test';

    static {
        String userId = System.UserInfo.getUserId();
        cv = new ContentVersion(
                Title = 'test',
                FirstPublishLocationId = userId,
                VersionData = Blob.valueOf(base64),
                PathOnClient = 'test.png'
        );
        insert cv;
        cdb = new ContentDistribution(
                ContentVersionId = cv.Id,
                Name = 'test'
        );
        insert cdb;

        caseObj = new Case(
                PhotOf0HourMeter__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                PhotoOfSerialNumber__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                PhotoTractoDuringRepair__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                CauseCode__c = 'Backhoe',
                CauseCode2__c = 'Leakage',
                ClaimType__c = 'In Stock'
        );
        insert caseObj;
    }

    @IsTest
    static void testUploadFiles() {
        Test.startTest();
        Blob blobObj = Blob.valueOf(base64);
        String base64Str = EncodingUtil.base64Encode(blobObj);
        List<TYM_ClaimRichTextPhotoController.FileWrap> listFileWrap = new List<TYM_ClaimRichTextPhotoController.FileWrap>();
        List<String> listStr = new List<String>{'Photo of Hour Meter', 'Photo of Serial Number', 'Photo of Tractor during repair', 'Photo of failure part'};
        for(String fieldLabel : listStr) {
            TYM_ClaimRichTextPhotoController.FileWrap objFileWrap = new TYM_ClaimRichTextPhotoController.FileWrap();
            objFileWrap.fileName = fileName;
            objFileWrap.base64 = base64Str;
            objFileWrap.fieldLabel = fieldLabel;
            listFileWrap.add(objFileWrap);
        }
        TYM_ClaimRichTextPhotoController.uploadFiles(JSON.serialize(listFileWrap), caseObj.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetImageList() {
        Test.startTest();
        TYM_ClaimRichTextPhotoController.getImageList(caseObj.Id);
        Test.stopTest();
    }
}