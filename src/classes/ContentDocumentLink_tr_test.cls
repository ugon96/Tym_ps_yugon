@isTest
public with sharing class ContentDocumentLink_tr_test {
    @isTest
    static void testHandeler() {

        Test.startTest();

        Manuals__c m = new Manuals__c(
            Name = 'test1',
            ProductType__c = 'Cabin',
            Subject__c = 'tt'
        );
        insert m;

        ManualsItem__c mi = new ManualsItem__c(
            Name = 'test',
            ManualsId__c = m.Id,
            ManualType__c = 'Parts Manual',
            Descripton__c = 'testt'
        );
        insert mi;

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'test.txt'
        );
        insert cv;

        ContentVersion css = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdLink = new ContentDocumentLink(
            LinkedEntityId = mi.Id,
            ShareType = 'C',
            Visibility = 'AllUsers',
            ContentDocumentId = css.ContentDocumentId
        );
        insert cdLink;

        cdLink.ShareType = 'I';

        update cdLink;

        Test.stopTest();

    }
}