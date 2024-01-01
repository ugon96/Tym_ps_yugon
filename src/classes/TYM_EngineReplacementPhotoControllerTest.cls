/*************************************************************
 * @author : th.kim
 * @date : 2023-10-26
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-10-26      th.kim          Initial Version
**************************************************************/

@IsTest
public with sharing class TYM_EngineReplacementPhotoControllerTest {

    static EngineReplacement__c engineReplacement;
    static ContentVersion cv;
    static ContentDistribution cdb;
    static String fileName = 'test';
    static String base64 = 'test';
    static List<String> fieldLabel = new List<String>{
            'Quantity of Engine Oil',
            'Quantity of Coolant',
            'Radiator Grill',
            'Air Filter',
            'Air Hose & Clamps',
            'Meter Panel',
            'ETC'
    };

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

        engineReplacement = new EngineReplacement__c(
                QuantityofEngineOil__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                QuantityofCoolant__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                RadiatorGrill__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                AirFilter__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                AirHoseClamps__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                MeterPanel__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> ',
                ETC__c = ' <img src="/sfc/servlet.shepherd/version/download/' + cv.Id + '"> '
        );
        insert engineReplacement;
    }

    @IsTest
    static void testUploadFiles() {
        Test.startTest();
        Blob blobObj = Blob.valueOf(base64);
        String base64Str = EncodingUtil.base64Encode(blobObj);
        List<TYM_EngineReplacementPhotoController.FileWrap> listFileWrap = new List<TYM_EngineReplacementPhotoController.FileWrap>();
        for(String str : fieldLabel) {
            TYM_EngineReplacementPhotoController.FileWrap fileWrap = new TYM_EngineReplacementPhotoController.FileWrap();
            fileWrap.fileName = fileName;
            fileWrap.base64 = base64Str;
            fileWrap.fieldLabel = str;
            listFileWrap.add(fileWrap);
        }
        TYM_EngineReplacementPhotoController.uploadFiles(JSON.serialize(listFileWrap), engineReplacement.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetImageList() {
        Test.startTest();
        TYM_EngineReplacementPhotoController.getImageList(engineReplacement.Id);
        Test.stopTest();
    }
}