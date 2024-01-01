/************************************************************************************
 * File Name   		: ContentVersion_tr_test
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-12-15
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-15       ugon96@gmail.com         Initial Version
*************************************************************************************/

@IsTest
private class ContentVersion_tr_test {
    @IsTest
    static void testBehavior() {
        Product2 objProd = TestObjectCreator.objProductTractor;
        insert objProd;

        ContentVersion objContentVersion = TestObjectCreator.objContentVersion;
        insert objContentVersion;
    }
}