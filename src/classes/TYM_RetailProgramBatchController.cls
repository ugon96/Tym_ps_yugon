/*************************************************************
 * @author : th.kim
 * @date : 2023-11-20
 * @group : 
 * @group-content : 
 * @description : RetailProgramMaster 디테일 페이지에서 마감 버튼으로 배치 실행
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-20      th.kim         Initial Version
**************************************************************/

public with sharing class TYM_RetailProgramBatchController {

    @AuraEnabled
    public static void callBatch(String recordId) {
        Database.executeBatch(new TYM_RetailProgram_Batch(recordId));
    }
}