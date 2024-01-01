/**
 * Created by nhkim on 2023-11-28.
 */

public with sharing class IF_SFDC_SAP_REQ_CONTACT_ba implements Database.Batchable<IF_SFDC_SAP_REQ_CONTACT.ContactPerson>, Database.Stateful {
    public Integer Count;
    public Boolean isContinue;
    public List<IF_SFDC_SAP_REQ_CONTACT.ContactPerson> listContactData;

    public IF_SFDC_SAP_REQ_CONTACT_ba() {
        IF_SFDC_SAP_REQ_CONTACT contact = new IF_SFDC_SAP_REQ_CONTACT('all');
        listContactData = contact.executeCall();
    }

    public IF_SFDC_SAP_REQ_CONTACT_ba(Integer count) {
        this.Count = count;
    }

    public List<IF_SFDC_SAP_REQ_CONTACT.ContactPerson> start(Database.BatchableContext context) {
        return listContactData;
    }

    public void execute(Database.BatchableContext context, List<IF_SFDC_SAP_REQ_CONTACT.ContactPerson> scope) {
        List<Contact> listContacts = new List<Contact>();
        List<String> listBPCodes = new List<String>();
        Map<String, String> mapBPCodeToAccId = new Map<String, String>();
        List<String> listContExternalIds = new List<String>();
        Map<String, Contact> mapExternalIdToContact = new Map<String, Contact>();

        for (IF_SFDC_SAP_REQ_CONTACT.ContactPerson cp : scope) {
            listBPCodes.add(cp.ParentKey);
            listContExternalIds.add(cp.ParentKey + cp.LineNum);
        }

        for (Account a : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c =: listBPCodes]) {
            mapBPCodeToAccId.put(a.BPCode__c, a.Id);
        }

        for (Contact objCont : [SELECT Id, ExternalId__c FROM Contact WHERE ExternalId__c = :listContExternalIds LIMIT 50000]) {
            mapExternalIdToContact.put(objCont.ExternalId__c, objCont);
        }

        List<RecordType> contactRecordType = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SobjectType = 'Contact'
                AND DeveloperName LIKE '%salesperson%'
        ];

        for (IF_SFDC_SAP_REQ_CONTACT.ContactPerson cp : scope) {
            Contact thisContact = mapExternalIdToContact.get(cp.ParentKey + cp.LineNum);
            if (thisContact == null) {
                thisContact = new Contact();
            }
            thisContact.RecordTypeId = contactRecordType[0].Id;
            thisContact.AccountId = mapBPCodeToAccId.get(cp.ParentKey) != null ? mapBPCodeToAccId.get(cp.ParentKey) : null;
            thisContact.ExternalId__c = cp.ParentKey + cp.LineNum;
            thisContact.FirstName = cp.FirstName;
            thisContact.MiddleName = cp.MiddleName;
            thisContact.LastName = cp.LastName == '' ? cp.ContactId : cp.LastName;
            thisContact.PhoneNumber__c = cp.Phone;
            thisContact.Mobile__c = cp.MobilePhone;
            thisContact.Email = cp.Email;
            thisContact.GenderIdentity = cp.Gender;
            thisContact.UserStatus__c = cp.Active == 'Y' ? 'Active' : 'Inactive';
            thisContact.Address__c = cp.Address;

            listContacts.add(thisContact);
            mapExternalIdToContact.put(thisContact.ExternalId__c, thisContact);
        }

        List<Database.UpsertResult> listDmlResult = Database.upsert(mapExternalIdToContact.values(), false);
    }

    public void finish(Database.BatchableContext context) {
        Boolean isContinue = false;

        // isContinue인지 받아오는 작업

//        if (isContinue) {
//            Datetime thisMoment = System.now();
//            Integer iDelayTime = 30;
//            Datetime delayedTime = thisMoment.addSeconds(iDelayTime);
//            String cronExpr = delayedTime.second() + ' ' + delayedTime.minute() + ' ' + delayedTime.hour() + ' ' + delayedTime.day() + ' ' + delayedTime.month() + ' ? ' + delayedTime.year();
//
//            IF_SFDC_SAP_REQ_CONTACT_sc scheduler = new IF_SFDC_SAP_REQ_CONTACT_sc();
//            System.schedule('upsertContacts', cronExpr, scheduler);
//        }
    }
}