/*************************************************************
 * @author : th.kim
 * @date : 2023-12-04
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-04      th.kim         Initial Version
**************************************************************/
trigger ARInvoice_tr on ARInvoice__c (before insert, before update, before delete, after insert, after update, after delete) {
    new ARInvoice_tr().run();
}