/************************************************************************************
 * Description :
 *
 * Ver         Date           Author         Modification
 * ===================================================================================
 * 1.0      2023-11-13      Taejun.Kang         Create
*************************************************************************************/
public without sharing class ApprovalLineCreateController {

    // DN LOOKUP 사용으로 인해 주석 처리 (InputField 사용 시 활성화)
    /*@AuraEnabled
    public static String doInit(String recordId, String strObjectName) {
        System.debug('>>doInit>>recordId : ' + recordId);
        System.debug('>>doInit>>strObjectName : ' + strObjectName);

        String sQuery = '';
        if('Opportunity'.equals(strObjectName)) {
            sQuery += '      SELECT Id, Name, Opportunity.Name';
            sQuery += '      FROM OpportunityLineItem';
            sQuery += '      WHERE OpportunityId = :recordId';
        } else if('Order'.equals(strObjectName)) {
            sQuery += '      SELECT Id, Order.Name';
            sQuery += '      FROM OrderItem';
            sQuery += '      WHERE OrderId = :recordId';
        } else { }
        System.debug('sQuery : ' + sQuery);

        List<SObject> objList = Database.query(sQuery);
        System.debug('objList : ' + objList);

        return !objList.isEmpty() ? 'SUCCESS' : 'ERROR';
    }*/


    @AuraEnabled
    public static String doSave(String titleField, String strLineTitle, String insertValue, String fieldName, User objUser){
        String returnValue;

        try {
            System.debug('titleField : ' + titleField);
            System.debug('strLineTitle : ' + strLineTitle);
            System.debug('insertValue : ' + insertValue);
            System.debug('fieldName : ' + fieldName);

            fieldName = fieldName + '__c';
            titleField = titleField + '__c';

            System.debug('objUser ↓↓↓↓↓');
            System.debug(objUser);

            objUser.put( fieldName , insertValue);
            objUser.put( titleField , strLineTitle);

            System.debug('objUser ↓↓↓↓↓');
            System.debug(objUser);
            update objUser;

            returnValue = 'success/성공적으로 저장되었습니다./' + objUser.Id ;

        } catch(Exception e) {
            returnValue = 'error/' + e.getMessage();
            System.debug('에러메세지 :::  ' + e);
        }

        return returnValue;

    }


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
                strFieldName = 'Approver' + (i+1) + '__c';
                obj.put(strFieldName, listApproverId[i]);
            }
            update obj;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(strComments);
            req1.setObjectId(sHistoryRecordId);
            Approval.ProcessResult result = Approval.process(req1);
            returnValue = 'SUCCESS' + ' / ' + 'SavedSuccessfully' + sHistoryRecordId ;
        }
        catch (Exception e) {
            System.debug('e>>>>>'+e);
            System.debug('getMessage>>>>>'+e.getMessage());
            System.debug('getMessage>>>>>'+e.getMessage().split(',')[0]);
            if (e.getMessage().contains('Stage is a Closed Won, it cannot be modified')) {
                throw new AuraHandledException('StageIsAClosedWonItCannotBeModified');
            }else if (e.getMessage().contains('Data cannot be modified after PI signing')) {
                throw new AuraHandledException('DataCannotBeModifiedAfterPISigning');
            }else{
                throw new AuraHandledException(e.getMessage());
            }
        }
        return returnValue;
    }
}