/*************************************************************
 * @author : th.kim
 * @date : 2023-12-11
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-11      th.kim         Initial Version
**************************************************************/
public without sharing class TYM_NewsController {

    private class NewsWrap {
        public News__c objNews;
        public String formatDate;
        public ContentDistribution objContents;
    }

    @AuraEnabled
    public static Map<String, Object> getNews(Integer count, String category, String topic, String sortType) {
        try {
            String query = 'SELECT Id, Name, Title__c, Topic__c, Contents__c, Category__c, Date__c FROM News__c ';
            if ((category != 'All' && category != null) || (topic != 'All' && topic != null)) {
                query += ' WHERE ';
                if (category != 'All' && category != null) query += ' Category__c = :category ';
                if(topic != 'All' && topic != null) {
                    if(category != 'All' && category != null) query += ' AND ';
                    query += ' Topic__c = :topic ';
                }
            }
            if (sortType == 'Oldest') query += ' ORDER BY Date__c ASC ';
            else query += ' ORDER BY Date__c DESC ';

            List<News__c> listNews = Database.query(query);
            System.debug('listNews :: ' + listNews);

            Set<Id> setNewsId = new Set<Id>();
            for(News__c news : listNews) {
                setNewsId.add(news.Id);
            }
            List<ContentDistribution> listContents = [SELECT Id, ContentDownloadUrl, RelatedRecordId, ContentVersionId, ContentVersion.Title FROM ContentDistribution WHERE RelatedRecordId IN :setNewsId];
            System.debug('listContents :: ' + listContents);
            Map<Id, ContentDistribution> mapContents = new Map<Id, ContentDistribution>();
            for(ContentDistribution contents : listContents) {
                mapContents.put(contents.RelatedRecordId, contents);
            }

            List<NewsWrap> listNewsWrap = new List<NewsWrap>();
            for(News__c news : listNews) {
                NewsWrap objNewsWrap = new NewsWrap();
                objNewsWrap.objNews = news;
                Datetime dtDate = (Datetime) news.Date__c;
                if(dtDate != null) objNewsWrap.formatDate = dtDate.format('MMMM dd, yyyy');
                if(mapContents.get(news.Id) != null) {
                    objNewsWrap.objContents = mapContents.get(news.Id);
                }
                listNewsWrap.add(objNewsWrap);
            }
            System.debug('listReturn :: ' + listNewsWrap);

            List<NewsWrap> listReturn = new List<NewsWrap>();
            Decimal size = listNews.size();
            Decimal page = size / 12;
            for (Integer i = 0; i < 12; i++) {
                Integer n = 12 * (count - 1);
                if (size > n + i) {
                    listReturn.add(listNewsWrap[n + i]);
                }
            }
            Map<String, Object> mapReturn = new Map<String, Object>{
                    'page' => page,
                    'size' => size,
                    'listReturn' => JSON.serialize(listReturn)
            };

            return mapReturn;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}