/*************************************************************
 * @author : sy.Kang
 * @date : 2023-12-19
 * @group :
 * @group-content :
 * @description :
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-12-19      sy.Kang         Initial Version
**************************************************************/
@IsTest
public class PartsOrderItem_tr_TEST {

    @IsTest
    static void testHandler() {
        Test.startTest();

        PartsOrderItem__c partsOrderItem = TestObjectCreator.objPartsOrderItem;
        partsOrderItem.Status__c = 'Closed';
        insert partsOrderItem;
        update partsOrderItem;

        Test.stopTest();
    }
}