/*************************************************************
 * @author : th.kim
 * @date : 2023-11-24
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-24      th.kim         Initial Version
**************************************************************/
trigger Orders_tr on Orders__c (before insert, before update, before delete, after insert, after update, after delete) {
    new Orders_tr().run();
}