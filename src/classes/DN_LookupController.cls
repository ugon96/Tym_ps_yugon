/**
 * Created by 천유정 on 2022-08-17.
 */

public with sharing class DN_LookupController {

    @AuraEnabled
    public static List<SObject> querySalesforceRecord(String queryString) {
        System.debug('querySalesforceRecord');
        return Database.query(queryString);
    }

    @AuraEnabled
    public static Map<String, Object> getLookupDatas(String query, String sObjectName, String[] fieldSet, String searchKey, String viewObjectName, Id viewObjectId) {
        System.debug('query : ' + query);
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

        // Order Item Grid > Columns List
        List<Map<String, String>> listColumns = new List<Map<String, String>>();
        for(String field : fieldSet) {
            Schema.DescribeFieldResult describe = mapFields.get(field).getDescribe();
            if(describe.getName() == 'ProductGroup__c') continue;
            listColumns.add(new Map<String, String> {
                    'label' => describe.getLabel(),
                    'fieldName' => describe.getName(),
                    'type' => String.valueOf(describe.getType())
            });
        }
        List<SObject> listDatas;
        if(sObjectName == 'Asset'){
            listDatas = (List<Asset>)Database.query(query);
        } else if (sObjectName == 'Product'){
            listDatas = (List<Product2>)Database.query(query);
        } else if (sObjectName == 'User') { 
            listDatas = (List<User>)Database.query (query);
        }

        System.debug('### listDatas : ' + listDatas);
        System.debug('### searchKey : \'' + searchKey + '\'');
        System.debug('### viewObjectName : ' + viewObjectName);

        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'listColumns' => listColumns
        };
        
        if(mapReturnValue.get('listDatas') == null) {
            mapReturnValue.put('listDatas', listDatas);
        }
        System.debug('mapReturnValue : ' + mapReturnValue);

        return mapReturnValue;
    }
}