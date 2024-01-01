/************************************************************************************
 * Description :
 *
 * Ver         Date           Author         Modification
 * ===================================================================================
 * 1.0      2023-11-13      Taejun.Kang         Create
*************************************************************************************/

public with sharing class ApprovalLineController {

    @AuraEnabled
    public static Map<String, Object> getApprovalLines(Id recordId) {
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
        Map<String, String> mapColumns = new Map<String, String>();
        for(String key : mapFields.keySet()) {
            Schema.DescribeFieldResult describe = mapFields.get(key).getDescribe();
            mapColumns.put(describe.getName(), describe.getLabel());
        }
        System.debug('mapColumns => ' +mapColumns);
        System.debug('recordId => ' +recordId);
//        System.debug('sObject Name => ' +sObjectName);
        User objUser = new User();
        List<String> ApprovalLine1 = new List<String>();
        List<String> ApprovalLine2 = new List<String>();
        List<String> ApprovalLine3 = new List<String>();
        List<String> ApprovalLine4 = new List<String>();
        List<String> ApprovalLine1Title = new List<String>();
        List<String> ApprovalLine2Title = new List<String>();
        List<String> ApprovalLine3Title = new List<String>();
        List<String> ApprovalLine4Title = new List<String>();

        //임시
        String strUserId = UserInfo.getUserId();
        System.debug('strUserId >> ' +strUserId);

        objUser =  [ SELECT Id, Name,
                            ApprovalLine1__c, ApprovalLine2__c,
                            ApprovalLine3__c, ApprovalLine4__c,
                            ApprovalLine1Title__c, ApprovalLine2Title__c,
                            ApprovalLine3Title__c, ApprovalLine4Title__c
                     FROM User
                     WHERE Id =: strUserId];

        //각 필드별 데이터를 리스트화
        if(objUser.ApprovalLine1__c != null) ApprovalLine1 = objUser.ApprovalLine1__c.split('/');
        if(objUser.ApprovalLine2__c != null) ApprovalLine2 = objUser.ApprovalLine2__c.split('/');
        if(objUser.ApprovalLine3__c != null) ApprovalLine3 = objUser.ApprovalLine3__c.split('/');
        if(objUser.ApprovalLine4__c != null) ApprovalLine4 = objUser.ApprovalLine4__c.split('/');

        //중복 아이디 제거
        Set<String> setApprover = new Set<String>();
        if(!ApprovalLine1.isEmpty()) setApprover.addAll(ApprovalLine1);
        if(!ApprovalLine2.isEmpty()) setApprover.addAll(ApprovalLine2);
        if(!ApprovalLine3.isEmpty()) setApprover.addAll(ApprovalLine3);
        if(!ApprovalLine4.isEmpty()) setApprover.addAll(ApprovalLine4);


        Map<Id, User> mapUser = new Map<Id, User>([SELECT Id, Name
        FROM User
        WHERE Id IN :setApprover]);
        List<User> user1 = new List<User>();
        List<User> user2 = new List<User>();
        List<User> user3 = new List<User>();
        List<User> user4 = new List<User>();

        List<Map<String, Object>> listLabel  = new List<Map<String, Object>>();
        Map<String, Object> data = new Map<String, Object>();
        Integer cnt = 0;
        for(String s : ApprovalLine1){
            if(cnt == 0) {
                cnt++;
                continue;
            }
            else if(mapColumns.containsKey('ApprovalLine1__c') && cnt == 1 ){
                data.put('label', mapColumns.get('ApprovalLine1__c'));
                data.put('title', objUser.ApprovalLine1Title__c);
                data.put('fieldName', s);
            }else{
                user1.add(mapUser.get(s));
            }
            cnt++;
        }
        if(cnt > 0){
            data.put('userDatas', user1);
            listLabel.add(data);
        }

        data = new Map<String, Object>();
        cnt = 0;
        for(String s : ApprovalLine2){
            if(cnt == 0) {
                cnt++;
                continue;
            }
            else if(mapColumns.containsKey('ApprovalLine2__c') && cnt == 1 ){
                data.put('label', mapColumns.get('ApprovalLine2__c'));
                data.put('title', objUser.ApprovalLine2Title__c);
                data.put('fieldName', s);
            }else{
                user2.add(mapUser.get(s));
            }
            cnt++;
        }
        if(cnt > 0){
            data.put('userDatas', user2);
            listLabel.add(data);
        }


        data = new Map<String, Object>();
        cnt = 0;
        for(String s : ApprovalLine3){
            if(cnt == 0) {
                cnt++;
                continue;
            }
            else if(mapColumns.containsKey('ApprovalLine3__c') && cnt == 1 ){
                data.put('label', mapColumns.get('ApprovalLine3__c'));
                data.put('title', objUser.ApprovalLine3Title__c);
                data.put('fieldName', s);
            }else{
                user3.add(mapUser.get(s));
            }
            cnt++;
        }
        if(cnt > 0){
            data.put('userDatas', user3);
            listLabel.add(data);
        }


        data = new Map<String, Object>();
        cnt = 0;
        for(String s : ApprovalLine4){
            if(cnt == 0) {
                cnt++;
                continue;
            }
            else if(mapColumns.containsKey('ApprovalLine4__c') && cnt == 1 ){
                data.put('label', mapColumns.get('ApprovalLine4__c'));
                data.put('title', objUser.ApprovalLine4Title__c);
                data.put('fieldName', s);
            }else{
                user4.add(mapUser.get(s));
            }
            cnt++;
        }
        if(cnt > 0){
            data.put('userDatas', user4);
            listLabel.add(data);
        }


        //커스텀세팅으로 라인제한 수 컨트롤 custom setting controll
        ApprovalLine__c objCustomSet =  ApprovalLine__c.getOrgDefaults();
        Decimal iLineLimit 	   = objCustomSet.LineLimit__c; 	//ApprovalLine 제한
        Decimal iApproverLimit = objCustomSet.ApproverLimit__c; //Approver 수 제한



        Map<String, Object> mapReturnValue = new Map<String, Object>{
                'listLabel' 	 => listLabel,
                'objUser'		 => objUser,
                'iLineLimit' 	 => iLineLimit,
                'iApproverLimit' => iApproverLimit

        };
        System.debug('LIMITTTT >> ' + mapReturnValue);
        return mapReturnValue;

    }

    @AuraEnabled
    public static String doDelete(String sId, User objUser, String fieldName){
        Savepoint sp = Database.setSavepoint();
        String returnValue;

        try {

            objUser.put(fieldName+'__c', null);
            update objUser;

            returnValue = 'success/Successfully Deleted./'+objUser.Id;
        } catch(Exception e) {
            returnValue = 'error/' + e.getMessage();
        }
        return returnValue;
    }

}