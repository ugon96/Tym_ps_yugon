/************************************************************************************
 * File Name   		: DN_TestUtil
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-11-10
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-10       ugon96@gmail.com         Initial Version
*************************************************************************************/

public without sharing class DN_TestUtil {
    public static void createIfMaster() {
        List<IFMaster__c> listIfMaster = new List<IFMaster__c>();
        IFMaster__c objIfMaster1 = new IFMaster__c(
                Name = '',
                Endpoint__c = '',
                Type__c = 'Outbound',
                ContentType__c = 'application/json',
                Method__c = 'GET',
                WebServiceType__c = 'REST'
        );
        listIfMaster.add(objIfMaster1);
    }

    public static IFMaster__c createIFMaster(String name, String endPoint, String method) {
        try {
            IFMaster__c objMaster = new IFMaster__c(
                    Name = name,
                    Endpoint__c = endPoint,
                    Type__c = 'Outbound',
                    Method__c = method,
                    WebServiceType__c = 'REST',
                    ContentType__c = 'application/json',
                    Description__c = ''
            );

            return objMaster;
        } catch (Exception e) {
            return null;
        }
    }

    public static Account createAccount() {
        Account objAccount = new Account(
            Name = 'Test Account'
        );
        return objAccount;
    }

    public static Contact createContactSalesPerson(Account objAccount) {
        Contact objContact = new Contact(
                LastName = 'Test SalesPerson',
                AccountId = objAccount.Id
        );
        return objContact;
    }
    public static Contact createContactEndCustomer(Account objAccount) {
        Contact objContact = new Contact(
                LastName = 'Test EndCustomer',
                AccountId = objAccount.Id
        );
        return objContact;
    }

    public static Asset createAssetTractor(Account objAccount, Product2 objProduct) {
        Id tractorRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Tractor' LIMIT 1].Id;
        Asset objAsset = new Asset(
                Name = 'Test Tractor',
                AccountId = objAccount.Id,
                RecordTypeId = tractorRecordTypeId,
                Product2Id = objProduct.Id
        );

        return objAsset;
    }

    public static Asset createAssetLoader(Account objAccount, Product2 objProduct) {
        Id tractorRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Loader' LIMIT 1].Id;
        Asset objAsset = new Asset(
                Name = 'Test Tractor',
                AccountId = objAccount.Id,
                RecordTypeId = tractorRecordTypeId,
                Product2Id = objProduct.Id
        );

        return objAsset;
    }

    public static Asset createAssetBackhoe(Account objAccount, Product2 objProduct) {
        Id tractorRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Backhoe' LIMIT 1].Id;
        Asset objAsset = new Asset(
                Name = 'Test Tractor',
                AccountId = objAccount.Id,
                RecordTypeId = tractorRecordTypeId,
                Product2Id = objProduct.Id
        );

        return objAsset;
    }

    public static Asset createAssetMower(Account objAccount, Product2 objProduct) {
        Id tractorRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND DeveloperName = 'Mower' LIMIT 1].Id;
        Asset objAsset = new Asset(
                Name = 'Test Tractor',
                AccountId = objAccount.Id,
                RecordTypeId = tractorRecordTypeId,
                Product2Id = objProduct.Id
        );

        return objAsset;
    }
}