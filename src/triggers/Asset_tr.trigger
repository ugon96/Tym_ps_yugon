/*************************************************************
 * @author : th.kim
 * @date : 2023-11-17
 * @group : 
 * @group-content : 
 * @description : 
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-11-17      th.kim         Initial Version
**************************************************************/

trigger Asset_tr on Asset (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Asset_tr().run();
}