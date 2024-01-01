/**
 * Created by nhkim on 2023-12-08.
 */

public with sharing class IF_SFDC_SAP_REG_BPACCOUNT_qu implements Queueable, Database.AllowsCallouts {
    private static final String IFID = 'IF_SFDC_SAP_REQ_BPACCOUNT';

    private String CARDCD;
    private Integer Count;
    private Integer queueCount;
    private String jobId;

    private class Input {
        String CARDCD;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        List<BPMaster> customerList;
        String isContinue;
    }

    public class BPMaster {
        public String BPCode;
        public String Dealership;
        public String PhoneNumber;
        public List<BPAddress> BPAddrress;
        public List<ContactPerson> ContactPerson;
        public String PaymentTerm;
        public String PriceList;
        public String IsActive;
        public String TerritoryManager;
        public String WebsiteAddress;
        public String FederalTaxID;
        public Decimal LaborRate;
        public String Remarks;
        public String Email;
        public String Mobile;
        public String Fax;
    }

    public class BPAddress {
        public String ParentKey;
        public String LineNum;
        public String AddressName;
        public String Street;
        public String ZipCode;
        public String City;
        public String Country;
        public String State;
        public String AddressType;
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

    public IF_SFDC_SAP_REG_BPACCOUNT_qu(String cardCd, Integer queueCount) {
        this.CARDCD = cardCd;
        this.queueCount = queueCount;
    }
    public IF_SFDC_SAP_REG_BPACCOUNT_qu(String cardCd, Integer count, Integer queueCount) {
        this.CARDCD = cardCd;
        this.Count = count;
        this.queueCount = queueCount;
    }

    public void execute(QueueableContext queueableContext) {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '딜러십 정보 요청 인터페이스 호출';

        // 결과 기록용 변수
        Integer outputCnt = 0;
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorDealerCode = new List<String>();
        List<String> listErrorMessage = new List<String>();

        List<String> listDealerCode = new List<String>();
        List<String> listAdrsExternalIds = new List<String>();
        List<String> listContExternalIds = new List<String>();
        List<String> listPriceListCode = new List<String>();
        List<String> listUserCode = new List<String>();

        List<Account> listAcct;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        // CARDCD valid check
        if (CARDCD == null || CARDCD == '') {
            CARDCD = 'new';
        }

        //String requestBody = '/' + this.CARDCD;
        String requestBody = '/' + this.CARDCD + '/' + this.Count;
        System.debug('requestBody : ' + requestBody);
        String responseBody;

        try {
            IFUtil objIF = new IFUtil(IFID);

            HttpResponse response = objIF.webCallout(requestBody, true);

            strCode = String.valueOf(response.getStatusCode());
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                // SAP PK 딜러코드 리스트에 담기
                for (BPMaster objBPM : objOutput.customerList) {
                    outputCnt++;
                    listDealerCode.add(objBPM.BPCode);
                    listPriceListCode.add(objBPM.PriceList);
                    listUserCode.add(objBPM.TerritoryManager);
                    if (objBPM.BPAddrress != null) {
                        for (BPAddress address : objBPM.BPAddrress) {
                            listAdrsExternalIds.add(address.ParentKey + address.LineNum);
                        }
                    }
                    if (objBPM.ContactPerson != null) {
                        for (ContactPerson cont : objBPM.ContactPerson) {
                            listContExternalIds.add(cont.ParentKey + cont.LineNum);
                        }
                    }
                }

                if (listDealerCode.size() > 0) {
                    // 리스트에 담긴 딜러코드로 기존 생성된 Account 있는지 조회
                    listAcct = new List<Account>([SELECT Id, BPCode__c FROM Account WHERE BPCode__c IN :listDealerCode]);
                    Map<String, Account> mapDealerCDToAccount = new Map<String, Account>();
                    Map<String, Address__c> mapExternalIdToAddress = new Map<String, Address__c>();
                    Map<String, Address__c> mapAccIdAndAdrsTypeToAddress = new Map<String, Address__c>();
                    Map<String, Contact> mapExternalIdToContact = new Map<String, Contact>();
                    Map<String, PriceList__c> mapExternalIdToPL = new Map<String, PriceList__c>();
                    Map<String, String> mapEmployeeNumToUserId = new Map<String, String>();

                    // 딜러코드와 Account 맵핑
                    for (Account objAcct : listAcct) {
                        mapDealerCDToAccount.put(objAcct.BPCode__c, objAcct);
                    }

                    // Account의 쿼리에 Address와 Contact를 합치는 방향으로 해야 할 듯
                    for (Address__c objAdrs : [SELECT Id, ExternalId__c, BillorShip__c, Dealership__c FROM Address__c WHERE ExternalId__c = :listAdrsExternalIds LIMIT 50000]) {
                        mapExternalIdToAddress.put(objAdrs.ExternalId__c, objAdrs);
                        if (objAdrs.BillorShip__c == 'Billing Address') {
                            mapAccIdAndAdrsTypeToAddress.put(objAdrs.Dealership__c + '-' + 'B', objAdrs);
                        }
                        else if (objAdrs.BillorShip__c == 'Shipping address') {
                            mapAccIdAndAdrsTypeToAddress.put(objAdrs.Dealership__c + '-' + 'S', objAdrs);
                        }
                    }

                    for (Contact objCont : [SELECT Id, ExternalId__c FROM Contact WHERE ExternalId__c = :listContExternalIds LIMIT 50000]) {
                        mapExternalIdToContact.put(objCont.ExternalId__c, objCont);
                    }

                    for (PriceList__c pl : [SELECT Id, ExternalId__c FROM PriceList__c WHERE ExternalId__c = :listPriceListCode LIMIT 50000]) {
                        mapExternalIdToPL.put(pl.ExternalId__c, pl);
                    }

                    for (User u : [SELECT Id, EmployeeNumber__c FROM User WHERE EmployeeNumber__c = :listUserCode LIMIT 50000]) {
                        mapEmployeeNumToUserId.put(u.EmployeeNumber__c, u.Id);
                    }

                    // Upsert 할 Account 데이터 생성
                    for (BPMaster objBPM : objOutput.customerList) {
                        Account objAcct = mapDealerCDToAccount.get(objBPM.BPCode);
                        if (objAcct == null) {
                            objAcct = new Account();
                            objAcct.BPCode__c = objBPM.BPCode;
                        }
                        else {
                            if (mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'B') != null && mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'B').BillorShip__c == 'Billing Address') {
                                objAcct.BillingAddress__c = mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'B').Id;
                            }
                            if (mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'S') != null && mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'S').BillorShip__c == 'Shipping address') {
                                objAcct.ShippingAddress__c = mapAccIdAndAdrsTypeToAddress.get(objAcct.Id + '-' + 'S').Id;
                            }
                        }

                        objAcct.Name = objBPM.Dealership;
                        objAcct.PhoneNumber__c = objBPM.PhoneNumber;
                        if (objBPM.BPAddrress != null) {
                            for (BPAddress address : objBPM.BPAddrress) {
                                Address__c adrs = mapExternalIdToAddress.get(objBPM.BPCode + address.LineNum);
                                if (adrs == null) {
                                    adrs = new Address__c();
                                }
                                adrs.ExternalId__c = address.ParentKey + address.LineNum;
                                adrs.Dealership__c = mapDealerCDToAccount.get(address.ParentKey) == null ? null : mapDealerCDToAccount.get(address.ParentKey).Id;
                                adrs.Name = address.AddressName;
                                adrs.Address__Street__s = address.Street;
                                adrs.Address__PostalCode__s = address.ZipCode;
                                adrs.Address__City__s = address.City;
                                adrs.Address__CountryCode__s = address.Country;
                                adrs.Address__StateCode__s = address.State;
                                adrs.BillorShip__c = address.AddressType == 'B' ? 'Billing Address' : 'Shipping address';

                                mapExternalIdToAddress.put(adrs.ExternalId__c, adrs);
                            }
                        }
                        if (objBPM.ContactPerson != null) {
                            for (ContactPerson cont : objBPM.ContactPerson) {
                                Contact contact = mapExternalIdToContact.get(objBPM.BPCode + cont.LineNum);
                                if (contact == null) {
                                    contact = new Contact();
                                }
                                contact.ExternalId__c = cont.ParentKey + cont.LineNum;
                                contact.AccountId = mapDealerCDToAccount.get(cont.ParentKey) == null ? null : mapDealerCDToAccount.get(cont.ParentKey).Id;
                                contact.FirstName = cont.FirstName;
                                contact.MiddleName = cont.MiddleName;
                                contact.LastName = cont.LastName == '' ? cont.ContactId : cont.LastName;
                                contact.PhoneNumber__c = cont.Phone;
                                contact.Mobile__c = cont.MobilePhone;
                                contact.Email = cont.Email;
                                contact.GenderIdentity = cont.Gender;
                                contact.UserStatus__c = cont.Active == 'Y' ? 'Active' : 'Inactive';
                                contact.Address__c = cont.Address;
                                contact.UserGroup__c = 'Owner';

                                mapExternalIdToContact.put(contact.ExternalId__c, contact);
                            }
                        }

                        objAcct.PriceListId__c = mapExternalIdToPL.get(objBPM.PaymentTerm) == null ? null : mapExternalIdToPL.get(objBPM.PaymentTerm).Id;
                        objAcct.PriceListParts__c = mapExternalIdToPL.get(objBPM.PriceList) == null ? null : mapExternalIdToPL.get(objBPM.PriceList).Id;
                        objAcct.Active__c = objBPM.IsActive == 'Y' ? 'Active' : 'Inactive';
                        objAcct.TerritoryManagerID__c = mapEmployeeNumToUserId.get(objBPM.TerritoryManager) == null ? null : mapEmployeeNumToUserId.get(objBPM.TerritoryManager);
                        objAcct.Website = objBPM.WebsiteAddress;
                        objAcct.FederalTaxID__c = objBPM.FederalTaxID;
                        objAcct.LaborRate__c = objBPM.LaborRate;
                        objAcct.Remarks__c = objBPM.Remarks;
                        objAcct.Email__c = objBPM.Email;
                        objAcct.Mobile__c = objBPM.Mobile;
                        objAcct.Fax__c = objBPM.Fax;

                        mapDealerCDToAccount.put(objAcct.BPCode__c, objAcct);
                    }

                    List<Database.UpsertResult> listDmlResult = Database.upsert(mapDealerCDToAccount.values(), false);

                    for (Account a : [SELECT Id, BPCode__c FROM Account WHERE BPCode__c =: mapDealerCDToAccount.keySet()]) {
                        mapDealerCDToAccount.put(a.BPCode__c, a);
                    }
                    for (Address__c adrs : mapExternalIdToAddress.values()) {
                        adrs.Dealership__c = mapDealerCDToAccount.get(adrs.ExternalId__c.substring(0,6)) != null ? mapDealerCDToAccount.get(adrs.ExternalId__c.substring(0,6)).Id : null;
                        mapExternalIdToAddress.put(adrs.ExternalId__c, adrs);
                    }
                    for (Contact cont : mapExternalIdToContact.values()) {
                        cont.AccountId = mapDealerCDToAccount.get(cont.ExternalId__c.substring(0,6)) != null ? mapDealerCDToAccount.get(cont.ExternalId__c.substring(0,6)).Id : null;
                        mapExternalIdToContact.put(cont.ExternalId__c, cont);
                    }
                    List<Database.UpsertResult> listAddressDmlResult = Database.upsert(mapExternalIdToAddress.values(), false);
                    List<Database.UpsertResult> listContDmlResult = Database.upsert(mapExternalIdToContact.values(), false);
                    Integer cnt = 0;
                    for (Database.UpsertResult objResult : listDmlResult) {
                        if (objResult.success) {
                            successCnt++;
                        } else {
                            failCnt++;
                            listErrorDealerCode.add(mapDealerCDToAccount.values().get(cnt).BPCode__c);
                            if (objResult.getErrors().toString().contains('required field missing')) {
                                listErrorMessage.add('Required field missing');
                            } else {
                                listErrorMessage.add(objResult.getErrors().toString());
                            }
                        }
                        cnt++;
                    }
                }

                if (objOutput.isContinue == 'Y') {
                    queueCount++;
                    //Queueable Method 재귀 호출
                    if (objOutput.isContinue == 'Y') {
                        jobId = System.enqueueJob(new IF_SFDC_SAP_REG_BPACCOUNT_qu('ALL', 500, queueCount));
                    }
                }
            } else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            } 

        } catch (Exception e) {
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
        LogWrapper.requestCount = queueCount;
        LogWrapper.enqueueJobId = jobId;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);
    }
}