/************************************************************************************
 * File Name   		: CreateNewCustomerController
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-10
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-10       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class CreateNewCustomerController {

    @AuraEnabled
    public static Contact doCreateCustomer(String fName, String lName, String phone, String mobile, String email, String address) {
        System.debug('======= doCreateCustomer ======= ');
        try {
            RecordType objRT = [
                    SELECT Id
                    FROM RecordType
                    WHERE Name LIKE '%End Customer%'
                    AND SobjectType = 'Contact'
                    LIMIT 1
            ];
            User objUser = [
                    SELECT Id, AccountId
                    FROM User
                    WHERE Id =: UserInfo.getUserId()
            ];
            Contact objCont = new Contact(
                    AccountId = objUser.AccountId,
                    RecordTypeId = objRT.Id
            );

            if (String.isNotBlank(fName)) {
                objCont.FirstName = fName;
            }
            if (String.isNotBlank(lName)) {
                objCont.LastName = lName;
            }
            if (String.isNotBlank(phone)) {
                objCont.PhoneNumber__c = phone;
            }
            if (String.isNotBlank(mobile)) {
                objCont.Mobile__c = mobile;
            }
            if (String.isNotBlank(email)) {
                objCont.Email = email;
            }
            if (String.isNotBlank(address)) {
                objCont.Address__c = address;
            }
            insert objCont;

            objCont = [
                    SELECT Id, Name, Email, Mobile__c, PhoneNumber__c, Address__c
                    FROM Contact
                    WHERE Id = :objCont.Id
                    LIMIT 1
            ];

            return objCont;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
}