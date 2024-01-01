/*************************************************************
 * @author : th.kim
 * @date : 2023-11-24
 * @group : 
 * @group-content : 
 * @description : 동적으로 해당 오브젝트의 커스텀 Path 데이터 가져오는 Controller
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-24      th.kim         Initial Version
**************************************************************/

public with sharing class TYM_CustomPathController {

    private class PicklistOption {
        public String label;
        public String value;
    }

    /**
     * @author th.kim
     * @description 동적으로 Object의 Status, Key Fields 필드 데이터 가져오기
     * @param recordId 현재 레코드 Id
     *
     * @return mapReturn
     */
    @AuraEnabled
    public static Map<String, Object> getPathStatus(String recordId) {
        try {
            // 현재 Object Api Name 가져오기
            Id idRecordId = (Id) recordId;
            String objName = idRecordId.getSobjectType().getDescribe().getName();
            System.debug('objName :: ' + objName);

            Case objCase = new Case();
            // 현재 오브젝트가 Case일 때 Key Fields 데이터 가져오기
            if (objName == 'Case') {
                objCase = [SELECT Id, IsPhotoHourMeter__c, IsPhotoSerialNo__c, IsPhotoRepair__c, IsPhotoFailurePart__c FROM Case WHERE Id = :recordId];
            }
            System.debug('objCase :: ' + objCase);

            // 현재 Object별로 Status의 Api Name이 달라서 (Status || Stats__c) Status의 Label로 Field Api Name 가져오기
            String fieldApiName = [
                    SELECT QualifiedApiName
                    FROM FieldDefinition
                    WHERE EntityDefinition.QualifiedApiName = :objName
                    AND Label = 'Status'
            ].QualifiedApiName;

            // 현재 Object와 Field 데이터로 쿼리
            SObject listSObject = Database.query('SELECT ' + fieldApiName + ' FROM ' + objName + ' WHERE Id = :recordId ');
            System.debug('listSObject :: ' + listSObject);
            String status = (String) listSObject.get(fieldApiName);

            // 현재 Object와 Field 데이터로 Picklist 데이터 가져오기
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objName).getDescribe().getSObjectType().getDescribe().fields.getMap().get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            System.debug('picklistValues :: ' + picklistValues);

            List<PicklistOption> listPicklistOption = new List<PicklistOption>();
            // Picklist 데이터 넣기
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                PicklistOption objPicklist = new PicklistOption();
                objPicklist.label = picklistEntry.getLabel();
                objPicklist.value = picklistEntry.getValue();
                listPicklistOption.add(objPicklist);
            }
            System.debug('listPicklistOption :: ' + listPicklistOption);

            Map<String, Object> mapReturn = new Map<String, Object>{
                    'pickList' => JSON.serialize(listPicklistOption),
                    'status' => status,
                    'case' => objCase
            };
            return mapReturn;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}