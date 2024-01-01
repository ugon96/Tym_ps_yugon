/************************************************************************************
 * File Name   		: OrderSummaryItemController_test
 * Author	  		: jiae.tak@daeunextier.com
 * Date				: 2023-12-27
 * @Group              : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-27    jiae.tak@daeunextier.com     Initial Version
*************************************************************************************/

@IsTest
public with sharing class OrderSummaryItemController_test {
    @IsTest
    static void TestStart(){

        Product2 objProduct2 = TestObjectCreator.objProductTractor;
        objProduct2.ImageUrl__c = 'test';
        insert objProduct2;

        Test.startTest();
        OrderSummaryItemController.getTractorImage(objProduct2.Id);
        Test.stopTest();
    }
}