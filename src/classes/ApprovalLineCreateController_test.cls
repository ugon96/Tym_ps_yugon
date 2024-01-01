/**
 * Created by 천유정 on 2023-12-26.
 */
@IsTest
private class ApprovalLineCreateController_test {
    @IsTest
    static void doTest() {

        User objUser = TestObjectCreator.objUserTYMUSA;
        insert objUser;
        ApprovalLineCreateController.doSave('ApprovalLine1', '김이박', '김이박', 'ApprovalLine1', objUser);

        Case objCase = TestObjectCreator.objClaim;
        insert objCase;

        List<String> listUserId = new List<String>();
        listUserId.add(objCase.Approver1__c);
        listUserId.add(objCase.Approver2__c);
        listUserId.add(objCase.Approver3__c);

        ApprovalLineCreateController.doSubmit('Case', 'Comments', objCase.Id, listUserId);
        try {
            ApprovalLineCreateController.doSubmit('Case', 'Comments', 'errorRecordId', listUserId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assertEquals(e.getMessage(), 'Script-thrown exception');
        }

    }

}