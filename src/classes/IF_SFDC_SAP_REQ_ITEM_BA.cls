/**
 * Created by DAEU on 2023-11-23.
 */

/*수동 배치 실행 테스트 :
IF_SFDC_SAP_REQ_ITEM_BA ba = new IF_SFDC_SAP_REQ_ITEM_BA();
Database.executeBatch(ba, 100);
*/
public with sharing class IF_SFDC_SAP_REQ_ITEM_BA implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    List<Product2> listTargetProduct2 = new List<Product2>();

    public List<Product2> start(Database.BatchableContext param1){
        System.debug('Start IF_SFDC_SAP_REQ_ITEM_BA ');

        listTargetProduct2 = [
                SELECT Id, Name
                FROM Product2
                WHERE ProductCode = '0000-0001'
        ];
        System.debug('listTargetProduct2 ::' + listTargetProduct2);
        return listTargetProduct2;
    }

    public void execute(Database.BatchableContext param1, List<Product2> param2){
        System.debug('Execute IF_SFDC_SAP_REQ_ITEM_BA ');
        try {
//            System.Queueable job = new IF_SFDC_SAP_REQ_ITEM_qu('new', 500);
//            System.Queueable job = new IF_SFDC_SAP_REQ_ITEM_qu('new');
//            System.enqueueJob(job);

        } catch (Exception e){
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext param1){
        System.debug('Finish IF_SFDC_SAP_REQ_ITEM_BA ');
    }
}