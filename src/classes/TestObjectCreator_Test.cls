@isTest
public with sharing class TestObjectCreator_Test {
    @isTest
    static void testHandeler() {
        Test.startTest();
        
        TestObjectCreator.createObj();

        Test.stopTest();
    }
}