/*************************************************************
 * @author : th.kim
 * @date : 2023-12-27
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-27      th.kim         Initial Version
**************************************************************/
public with sharing class TYM_NewsHomeController {

    private class NewsWrap {
        public News__c news;
        public String formatDate;
    }
    @AuraEnabled
    public static String getNews() {
        List<News__c> listNews = [SELECT Id, Name, Topic__c, Category__c, Title__c, Date__c FROM News__c ORDER BY Date__c DESC LIMIT 4];
        List<NewsWrap> listNewsWrap = new List<NewsWrap>();
        for(News__c obj : listNews) {
            NewsWrap objNewsWrap = new NewsWrap();
            objNewsWrap.news = obj;
            Datetime dtDate = (Datetime) obj.Date__c;
            if(dtDate != null) objNewsWrap.formatDate = dtDate.format('MMMM dd, yyyy');
            listNewsWrap.add(objNewsWrap);
        }
        return JSON.serialize(listNewsWrap);
    }
}