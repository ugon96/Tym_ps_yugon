/*************************************************************
 * @author : th.kim
 * @date : 2023-10-10
 * @group : 
 * @group-content :
 * @description : 
==============================================================
 * Ver Date Author Modification
 1.0    Initial Version
**************************************************************/

trigger Case_tr on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Case_tr().run();
}