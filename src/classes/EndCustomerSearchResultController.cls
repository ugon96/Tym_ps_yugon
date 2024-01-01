/************************************************************************************
 * File Name   		: EndCustomerSearchResultController
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-05
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-05       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class EndCustomerSearchResultController {
    @AuraEnabled
    public static List<Contact> doSearchCustomer(String keyword) {
        List<Contact> listContact = null;
        keyword = '%' + keyword + '%';
        try {
            listContact = [
                    SELECT Id, Name, Mobile__c, PhoneNumber__c, Address__c, Email
                    FROM Contact
                    WHERE RecordType.DeveloperName = 'EndCustomer'
                    AND (Name LIKE :keyword
                    OR Email LIKE :keyword
                    OR Mobile__c LIKE :keyword
                    OR PhoneNumber__c LIKE :keyword
                    OR Address__c LIKE :keyword)
            ];
            return listContact;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Contact> getDealerData() {
        List<Contact> listDealer = null;
        try {
            User objUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (objUser != null && objUser.ContactId != null) {
//                Contact objContact = [SELECT Id, AccountId FROM Contact WHERE Id =:objUser.ContactId LIMIT 1];
                Contact objContact = [SELECT Id, AccountId FROM Contact WHERE Id = '0031m00000WpGeVAAV' LIMIT 1];
                if (objContact != null && objContact.AccountId != null) {
                    listDealer = new List<Contact>([
                            SELECT Id, Name
                            FROM Contact
                            WHERE AccountId = :objContact.AccountId
                            AND RecordType.Name = 'Salesperson'
                    ]);
                }
            }
            return listDealer;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
}