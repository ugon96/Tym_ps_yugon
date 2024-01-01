/*************************************************************
 * @author : th.kim
 * @date : 2023-11-29
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-29      th.kim         Initial Version
**************************************************************/
trigger RetailProgram_tr on RetailProgram__c (before insert, before update, before delete, after insert, after update, after delete) {
    new RetailProgram_tr().run();
}