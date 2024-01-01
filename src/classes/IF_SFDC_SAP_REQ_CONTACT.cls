/************************************************************************************
 * File Name   		: IF_SFDC_SAP_REQ_CONTACT
 * Author	  		: nh.kim@daeunextier.com
 * Date				: 2023-11-20
 * @Group           : Daeunextier
 * Description 		:
 * Modification Log
 * Ver       Date            Author      		         Modification
 * 1.0     2023-11-20        nh.kim@daeunextier.com      Initial Version
 * 1.1     2023-12-14        yujeong.chun@daeunextier.com      
*************************************************************************************/

global with sharing class IF_SFDC_SAP_REQ_CONTACT {
    private static final String IFID = 'IF_SFDC_SAP_REQ_CONTACT';

    private String CARDCD;
    private Integer Count;
    private Integer QueueCount;
    private String jobId;

    public IF_SFDC_SAP_REQ_CONTACT(String CardCd) {
        this.CARDCD = CardCd;
    }

    public IF_SFDC_SAP_REQ_CONTACT(String cardCd, Integer count) {
        this.CARDCD = cardCd;
        this.Count = count;
    }

    public IF_SFDC_SAP_REQ_CONTACT(String cardCd, Integer count, Integer QueueCount) {
        this.CARDCD = cardCd;
        this.Count = count;
        this.QueueCount = QueueCount;
    }

    private class Input { 
        String CARDCD;
        Integer Count;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        List<ContactPerson> contactList;
        String isContinue;
    }

    public class ContactPerson {
        public String ParentKey;
        public String LineNum;
        public String FirstName;
        public String MiddleName;
        public String LastName;
        public String Phone;
        public String MobilePhone;
        public String Email;
        public String Gender;
        public String Active;
        public String Address;
        public String ContactId;
    }

    public void execute() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Contact Person 정보를 SFDC에 Upsert한다.';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        List<Contact> listContacts = new List<Contact>();
        List<String> listBPCodes = new List<String>();
        Map<String, String> mapBPCodeToAccId = new Map<String, String>();
        List<String> listContExternalIds = new List<String>();
        Map<String, Contact> mapExternalIdToContact = new Map<String, Contact>();

        String requestParam = '';
        String responseBody = '';
        Id jobId = null;

        if (this.CARDCD != null && this.CARDCD != '') {
            requestParam += '/' + this.CARDCD;
            if (this.Count != null && this.Count != 0) {
                requestParam += '/' + String.valueOf(this.Count);
            }
        } else {
            requestParam += '/all/500';
        }

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        Input objInput = new Input();

        // CARDCD valid check
        if (CARDCD == null || CARDCD == '') {
            this.CARDCD = 'new';
        }
        objInput.CARDCD = this.CARDCD;

        try {
            IFUtil objIF = new IFUtil(IFID);
            // LogWrapper INSERT
            HttpResponse response = objIF.webCallout(requestParam, true);
            responseBody = response.getBody();


            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                for (ContactPerson cp : objOutput.contactList) {
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

                for (ContactPerson cp : objOutput.contactList) {
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
                    thisContact.UserGroup__c = 'Owner';

                    listContacts.add(thisContact);
                    mapExternalIdToContact.put(thisContact.ExternalId__c, thisContact);

                    System.debug('listContacts ::::::' + listContacts);
                    System.debug('mapExternalIdToContact ::::::' + mapExternalIdToContact);
                }

                upsert mapExternalIdToContact.values() ExternalId__c;

//                List<Database.UpsertResult> listDmlResult = Database.upsert(mapExternalIdToContact.values(), false);
//                System.debug('listDmlResult :: ' + listDmlResult);
            }
            else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        }
        catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;
        LogWrapper.requestCount = QueueCount;
        LogWrapper.enqueueJobId = jobId;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
        System.debug('LogWrapper : ' + LogWrapper);

    }
}