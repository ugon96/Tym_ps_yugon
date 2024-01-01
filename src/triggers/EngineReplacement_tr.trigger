trigger EngineReplacement_tr on EngineReplacement__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new EngineReplacement_tr().run();

}