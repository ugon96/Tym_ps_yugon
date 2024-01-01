/**
 * Created by 천유정 on 2023-11-08.
 */

public with sharing class Community_ButtonList_ClaimController {
    @AuraEnabled
    public static DataWrapper doInit(String recordId) {
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';
        Boolean isShowBtnPrint = false;

        try {
            System.debug('================> recordId : ' + recordId);
            Case objCase = [
                    SELECT Id
                    FROM Case
                    WHERE Id = :recordId
            ];
            // Filtering 해야할 내용을 조건문으로 판별하여 True 변경
            if (objCase != null) {
                if (objCase.Status == 'Closed') {
                    isShowBtnPrint = true;
                } else { }
            } else {
                System.debug('>>ERROR<< Community_OpportunityButtonList : doInit : No objCase');
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ': ' + e.getLineNumber();
        }
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        objWrapper.isShowBtnPrint = isShowBtnPrint;
        System.debug('Oppty Button LIst : objWrapper : ' + objWrapper);
        return objWrapper;
    }
    public class DataWrapper {
        @AuraEnabled
        public String strStatus { get; set; }
        @AuraEnabled
        public String strMessage { get; set; }
        @AuraEnabled
        public Boolean isShowBtnPrint { get; set; } 
    }
}