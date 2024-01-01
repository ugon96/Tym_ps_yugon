/*************************************************************
 * @author : th.kim
 * @date : 2023-11-30
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-30      th.kim         Initial Version
**************************************************************/
@IsTest
private with sharing class TYM_VideoPlayerController_TEST {

    static SupportsVideo__c video;

    static {
        video = new SupportsVideo__c(
                Name = 'test',
                URL__c = 'https://tym--dev.sandbox.my.site.com/dealerportal'
        );
        insert video;
    }

    @IsTest
    static void testGetUrl() {
        Test.startTest();
        TYM_VideoPlayerController.getUrl(video.Id);
        Test.stopTest();
    }
}