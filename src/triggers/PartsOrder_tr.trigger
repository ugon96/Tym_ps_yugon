/*************************************************************
 * @author : th.kim
 * @date : 2023-11-28
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-28      th.kim         Initial Version
**************************************************************/
trigger PartsOrder_tr on PartsOrder__c (before insert, before update, before delete, after insert, after update, after delete) {
    new PartsOrder_tr().run();
}