/**
 * Created by 천유정 on 2023-10-04.
 */

public with sharing class DN_Util {
    // PickList Return Value
    public static List<Map<String, String>> getPickListValues(String objectType, String selectedField, Boolean isNone) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        if(isNone) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => '---none---', 
                    'value' => 'none'
            });
        }

        for(Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(new Map<String, String>{
                    'label' => pickListVal.getLabel(),
                    'value' => pickListVal.getValue()
            });
        }
        return pickListValuesList;
    }

    // 설명 : Field Set 을 이용하여 Dynamic 하게 화면 구성할 시 사용 (Table, 등등)
    public static List<Map<String, Object>> getFieldSet(String strObjectAPIName, String strFieldSetAPIName) {
        List<Map<String, Object>> listReturnFieldSet = new List<Map<String, Object>>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(strObjectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetAPIName);

        if(fieldSetObj != null) {
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                listReturnFieldSet.add(new Map<String, Object>{
                        'apiName' => fieldSetMemberObj.getFieldPath()
                        , 'type' => String.valueOf(fieldSetMemberObj.getType())
                        , 'label' => fieldSetMemberObj.getLabel()
                        , 'required' => fieldSetMemberObj.getRequired()
                });
            }
        }
        return listReturnFieldSet;
    }
    // 설명 : Field Set 으로 Query 생성하기
    public static String createSOQLQuery(List<Map<String, Object>> fieldSet, Boolean IsNeedsSubstring, String FromObj) {
        String strQuery = '';
        String finalQuery = '';
        for (Map<String, Object> obj : fieldSet) {
            strQuery += obj.get('apiName') + ', ';
        }
        if (FromObj != null && IsNeedsSubstring == true) {
            finalQuery = ' (SELECT Id, ' + strQuery.substring(0, strQuery.length()-2) + ' FROM ' + FromObj + ')';
        } else {
            finalQuery = IsNeedsSubstring? strQuery.substring(0, strQuery.length()-2) : strQuery;
        }
        return finalQuery;
    }
}