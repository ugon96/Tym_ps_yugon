/*************************************************************************************
* File Name   : IF_SFDC_SAP_REQ_PARTSIVT_sc.cls
* Author      : yj.Chun
* Date        : 2023.12.26
* Class       : IF_SFDC_SAP_REQ_PARTSIVT_sc.cls
* Target      : Parts Inventory Queueable Method 실행 스케줄러
* Description : Product - Inventory(on Hand) I/F
* Modification Log
* ===================================================================================
* Ver      Date            Author              Modification
* ===================================================================================
1.0      2023.12.26      yj.Chun             Create
<**************************************************************************************/

// 1. 매일 10:30 Setting 필요 (0시 ~ 23시 59분 생성 건).
// 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.
// String CRON_EXP = '0 30 10 * * ? *';
// System.schedule('IF_SFDC_SAP_REQ_PARTSIVT_sc', CRON_EXP, new IF_SFDC_SAP_REQ_PARTSIVT_sc());

public with sharing class IF_SFDC_SAP_REQ_PARTSIVT_sc implements Schedulable{
    public String Type;
    public Integer Count;

    public IF_SFDC_SAP_REQ_PARTSIVT_sc() {

    }
    public IF_SFDC_SAP_REQ_PARTSIVT_sc(String Type, Integer Count) {
        this.Type = Type;
        this.Count = Count;
    }

    public void execute(SchedulableContext context) {
        IF_SFDC_SAP_REQ_PARTSIVT_qu CQ = new IF_SFDC_SAP_REQ_PARTSIVT_qu(Type, Count, 0);
        System.enqueueJob(CQ);
    }
}