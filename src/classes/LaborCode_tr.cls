/**
 * Created by 천유정 on 2023-09-20.
 */

public with sharing class LaborCode_tr extends TriggerHandler {

    public LaborCode_tr() {
        listNew = (List<Object>) trigger.new;
        mapOld = (Map<Id, Object>) trigger.oldMap;
        listOld = (List<Object>) trigger.old;
    }
    /** TriggerHandler */
    private List<Object> listNew { get; set; }
    private List<Object> listOld { get; set; }
    private Map<Id, Object> mapOld { get; set; }

    public override void beforeInsert() {

    }
    public override void beforeUpdate() {

    }
    public override void beforeDelete() {

    }
    public override void afterInsert() {

    }
    public override void afterUpdate() {

    }
    public override void afterDelete() {

    } 


}