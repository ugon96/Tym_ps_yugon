/************************************************************************************
 * Description :
 *
 * Ver         Date           Author         Modification
 * ===================================================================================
 * 1.0      2023-10-19      Taejun.Kang         Create
*************************************************************************************/
public with sharing class ClaimApprovalController {

    @AuraEnabled
    public static String doInit(String recordId, String strObjectName){
        System.debug('■생성■생성■생성■생성■생성■생성■생성');
        System.debug('recordId :: ' + recordId);
        System.debug('strObjectName : ' + strObjectName);

        String sQuery = '';
        if('Case'.equals(strObjectName)) {
            sQuery += '      SELECT Id';
            sQuery += '      FROM Case';
            sQuery += '      WHERE Id = :recordId';
        } else if('EngineReplacement__c'.equals(strObjectName)) {
            sQuery += '      SELECT Id';
            sQuery += '      FROM EngineReplacement__c';
            sQuery += '      WHERE Id = :recordId';
        } else { }
        System.debug('sQuery : ' + sQuery);

        List<SObject> objList = Database.query(sQuery);
        System.debug('objList : ' + objList);

        return !objList.isEmpty() ? 'SUCCESS' : 'ERROR';

    }

//    @AuraEnabled
//    public static List<Case> getCurrentApprover(String recordId){
//        List<Case> crntApr = [SELECT Approver1__c, Approver2__c, Approver3__c FROM Case WHERE Id =: 'recordId'];
//        return crntApr;
//    }

    @AuraEnabled
    public static String doSubmit(String strObjectName, String strComments, String sHistoryRecordId, List<String> listApproverId) {

        System.debug('승인 신청 Object : ' + strObjectName);
        System.debug('승인 요청 Comments : ' + strComments);
        System.debug('sHistoryRecordId : ' + sHistoryRecordId);
        System.debug('listApprovedId : ' + listApproverId);

        //user이름 들어있는 리스트 listApprovalLine 으로 칭함.
        String returnValue;

        try {
            String sQuery = '';
            sQuery += '     SELECT  Id, Approver1__c, Approver2__c, Approver3__c';
            sQuery += '     FROM    ' + strObjectName;
            sQuery += '     WHERE   Id =: sHistoryRecordId ';
            SObject obj = Database.query(sQuery);
            String strFieldName = '';
            System.debug('sq :' + sQuery);
            for (Integer i = 0; i < listApproverId.size(); i++) {
                strFieldName = 'Approver' + (i + 1) + '__c';
                obj.put(strFieldName, listApproverId[i]);
            }
            update obj;

            //Approval.ProcessRequest req1 = new Approval.ProcessRequest();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(strComments);
            req1.setObjectId(sHistoryRecordId);
            req1.setSubmitterId(UserInfo.getUserId()); 

            Approval.ProcessResult result = Approval.process(req1);
            returnValue = 'Success ' + sHistoryRecordId;
        }
        catch (Exception e) {
            System.debug('e>>>>>'+e);
            System.debug('getMessage>>>>>'+e.getMessage());
            System.debug('getMessage>>>>>'+e.getMessage().split(',')[0]);
//            if (e.getMessage().contains('Stage is a Closed Won, it cannot be modified')) {
//                throw new AuraHandledException(Label.StageIsAClosedWonItCannotBeModified);
//            }else if (e.getMessage().contains('Data cannot be modified after PI signing')) {
//                throw new AuraHandledException(Label.DataCannotBeModifiedAfterPISigning);
//            }else{
//                throw new AuraHandledException(e.getMessage());
//            }
        }
        return returnValue;
    }

}