/*************************************************************
 * @author : th.kim
 * @date : 2023-12-28
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-28      th.kim         Initial Version
**************************************************************/
@IsTest
private class TYM_NewsController_test {

    static News__c news;

    static {
        news = new News__c(
                Title__c = 'test',
                Contents__c = 'test',
                Topic__c = 'Press',
                Category__c = 'Others',
                Date__c = Date.today()
        );
        insert news;
    }

    @IsTest
    static void testGetNews() {
        Test.startTest();
        TYM_NewsController.getNews(1, news.Category__c, news.Topic__c, 'Oldest');
        Test.stopTest();
    }
}