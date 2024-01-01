@isTest
public with sharing class AssetSignatureFormController_TEST {
    @isTest
    static void testHandeler() {
        Test.startTest();

        String signatureBody = '1414';
        // User user = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];


        ContentVersion cv = new ContentVersion();
        cv.Title = 'Signiture';
        cv.VersionData = EncodingUtil.base64Decode(signatureBody);
        cv.FirstPublishLocationId = UserInfo.getUserId();
        cv.PathOnClient = 'Signiture.png';
        insert cv;

        AssetSignatureFormController.saveSignature(signatureBody, UserInfo.getUserId());

        Test.stopTest();
    }
}