/**
 * Created by 천유정 on 2023-09-20.
 */

trigger LaborCode_tr on LaborCode__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new LaborCode_tr().run();
}