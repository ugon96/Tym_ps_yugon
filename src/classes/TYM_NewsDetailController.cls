/*************************************************************
 * @author : th.kim
 * @date : 2023-12-22
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-22      th.kim         Initial Version
**************************************************************/
public with sharing class TYM_NewsDetailController {

//    private class NewsWrap {
//        public News__c news;
//        public String formatDate;
//    }

    @AuraEnabled
    public static Map<String, Object> getNewsInfo(String recordId) {
        News__c objNews = [SELECT Id, Name, Title__c, Topic__c, Category__c, Contents__c, Date__c FROM News__c WHERE Id = :recordId];
        Datetime dtDate = (Datetime) objNews.Date__c;
        String formatDate;
        if (dtDate != null) formatDate = dtDate.format('MMMM dd, yyyy');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'news' => objNews,
                'formatDate' => formatDate
        };
        return mapReturn;
    }
}