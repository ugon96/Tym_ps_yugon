/*
* ==================================================================================
*   File Name   : DN_ExecuteAsync.cls
*   Author      : Minje.Kim
*   Date        : 2023.12.07
*   Tester      : DN_ExecuteAsync_Test.cls
*   Description : 비동기 (Batch/Queueable) 클래스 실행 모듈
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.06    Minje.Kim    Create
* ==================================================================================
*/
public with sharing class DN_ExecuteAsync {
    
    /**
     * 주유비 정산 승인 탭 Init (검색 조건 셋팅)
     * 
     * @params 없음
     * @return DataWrapper 
     *         - objUser : 유저 정보
     *         - listSelectStatus : 제출 상태
    **/
    // @AuraEnabled
    // public static Map<String, Object> doInit() {
    //     String strStatus = 'SUCCESS';
    //     String strMessage = '';
    //     List<Map<String,String>> listBatch = new List<Map<String,String>>();
    //     List<Map<String,String>> listQueueable = new List<Map<String,String>>();

    //     try {
    //         List<ApexClass> listBatchClass = new List<ApexClass>();
    //         listBatchClass = [SELECT Id, Name 
    //                           FROM   ApexClass 
    //                           WHERE  Name LIKE '%_ba'
    //                          ];

    //         List<ApexClass> listQueueableClass = new List<ApexClass>();
    //         listQueueableClass = [SELECT Id, Name 
    //                               FROM   ApexClass 
    //                               WHERE  Name LIKE '%_qu'  
    //                              ];

    //         Boolean isFirstBatchClass = true;
    //         for ( ApexClass objBatchClass : listBatchClass){
    //             listBatch.add(new Map<String, String>{
    //                 'label' => objBatchClass.Name,
    //                 'value' => objBatchClass.Name,
    //                 'selected' => isFirstBatchClass ? 'true' : 'false'
    //             });
    //             if (isFirstBatchClass) isFirstBatchClass = false;
    //         }

    //         Boolean isFirstQueueableClass = true;
    //         for ( ApexClass objQueueableClass : listQueueableClass){
    //             listQueueable.add(new Map<String, String>{
    //                 'label' => objQueueableClass.Name,
    //                 'value' => objQueueableClass.Name,
    //                 'selected' => isFirstQueueableClass ? 'true' : 'false'
    //             });
    //             if (isFirstQueueableClass) isFirstQueueableClass = false;
    //         }

    //     }catch (Exception e) {
    //         strStatus = 'ERROR';
    //         strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
    //     }

    //     Map<String, object> mapResult = new Map<String, object>{
    //         'strStatus' => strStatus,
    //         'strMessage' => strMessage,
    //         'listBatch' => listBatch,
    //         'listQueueable' => listQueueable
    //     };
    //     return mapResult;
    // }

    /**
     * 주유비 정산 승인 탭 Init (검색 조건 셋팅)
     * 
     * @params 없음
     * @return DataWrapper 
     *         - objUser : 유저 정보
     *         - listSelectStatus : 제출 상태
    **/
    @AuraEnabled
    public static Map<String, Object> doExecute(String strClassName, String strConstructorNo, String strObject) {
        String strStatus = 'SUCCESS';
        String strMessage = '';


        Map<String,Object> mapParam = new Map<String,Object>(); 
        try {       
            mapParam = (Map<String,Object>) JSON.deserializeUntyped(strObject);
            if ( strClassName == 'IF_SFDC_SAP_REQ_BPACCOUNT'){
                String CARDCD = String.valueOf(mapParam.get('CARDCD'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_BPACCOUNT qu = new IF_SFDC_SAP_REQ_BPACCOUNT(CARDCD, Count);
                // System.enqueueJob(qu);

            } else if ( strClassName == 'IF_SFDC_SAP_REQ_BPADDRESS' ){
                String CARDCD = String.valueOf(mapParam.get('CARDCD'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_BPADDRESS qu = new IF_SFDC_SAP_REQ_BPADDRESS(CARDCD, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_CONTACT' ){
                String CARDCD = String.valueOf(mapParam.get('CARDCD'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_CONTACT qu = new IF_SFDC_SAP_REQ_CONTACT(CARDCD, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_ITEM' ){
                String ItemCode = String.valueOf(mapParam.get('ItemCode'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_ITEM qu = new IF_SFDC_SAP_REQ_ITEM(ItemCode, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_PRICELISTMST' ){
                String PriceList = String.valueOf(mapParam.get('PriceList'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_PRICELISTMST qu = new IF_SFDC_SAP_REQ_PRICELISTMST(PriceList, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_PRICELISTETR'){
                String PriceList = String.valueOf(mapParam.get('PriceList'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                String ItemGroupCode = String.valueOf(mapParam.get('ItemGroupCode'));
                String ItemCode = String.valueOf(mapParam.get('ItemCode'));
                String inputCurrency = String.valueOf(mapParam.get('inputCurrency'));

                if ( strConstructorNo == '1'){
                    // IF_SFDC_SAP_REQ_PRICELISTETR qu = new IF_SFDC_SAP_REQ_PRICELISTETR(PriceList, Count);
                    // System.enqueueJob(qu);
                } else if ( strConstructorNo == '2'){
                    // IF_SFDC_SAP_REQ_PRICELISTETR qu = new IF_SFDC_SAP_REQ_PRICELISTETR(PriceList, Count, ItemGroupCode, ItemCode, inputCurrency);
                    // System.enqueueJob(qu);
                }
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_ORDER_PROD' ){
                String DocNum = String.valueOf(mapParam.get('DocNum'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_ORDER_PROD qu = new IF_SFDC_SAP_REQ_ORDER_PROD(DocNum, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_ORDER_PARTS' ){
                String DocEntry = String.valueOf(mapParam.get('DocEntry'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_ORDER_PARTS qu = new IF_SFDC_SAP_REQ_ORDER_PARTS(DocEntry, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_AR' ){
                String BPCode = String.valueOf(mapParam.get('BPCode'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_AR qu = new IF_SFDC_SAP_REQ_AR(BPCode, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_MASTERDATA' ){
                String Type = String.valueOf(mapParam.get('Type'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_MASTERDATA qu = new IF_SFDC_SAP_REQ_MASTERDATA(Type, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_PARTSIVT' ){
                String ItemCode = String.valueOf(mapParam.get('ItemCode'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_PARTSIVT qu = new IF_SFDC_SAP_REQ_PARTSIVT(ItemCode, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_FINISHEDGOODS' ){
                String ItemCode = String.valueOf(mapParam.get('ItemCode'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_FINISHEDGOODS qu = new IF_SFDC_SAP_REQ_FINISHEDGOODS(ItemCode, Count);
                // System.enqueueJob(qu);
            } else if ( strClassName == 'IF_SFDC_SAP_REQ_CREDITMEMO' ){
                String CARDCD = String.valueOf(mapParam.get('CARDCD'));
                Integer Count = Integer.valueOf(mapParam.get('Count'));
                // IF_SFDC_SAP_REQ_CREDITMEMO qu = new IF_SFDC_SAP_REQ_CREDITMEMO(CARDCD, Count);
                // System.enqueueJob(qu);
            } 
            

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        Map<String, Object> mapResult = new Map<String, object>{
            'strStatus' => strStatus,
            'strMessage' => strMessage,
            'strClassName' => strClassName,
            'strConstructorNo' => strConstructorNo,
            'mapParam' => mapParam
        };
        return mapResult;
    }

}