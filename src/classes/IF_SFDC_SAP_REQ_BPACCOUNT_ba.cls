/**
 * Created by nhkim on 2023-12-01.
 */

public with sharing class IF_SFDC_SAP_REQ_BPACCOUNT_ba implements Database.Batchable<IF_SFDC_SAP_REG_BPACCOUNT.BPMaster> {
    public List<IF_SFDC_SAP_REG_BPACCOUNT.BPMaster> listBPMasterData;

    public IF_SFDC_SAP_REQ_BPACCOUNT_ba() {
        IF_SFDC_SAP_REG_BPACCOUNT account = new IF_SFDC_SAP_REG_BPACCOUNT('all');
        listBPMasterData = account.execute();
    }

    public List<IF_SFDC_SAP_REG_BPACCOUNT.BPMaster> start(Database.BatchableContext context) {
        return listBPMasterData;
    }

    public void execute(Database.BatchableContext context, List<IF_SFDC_SAP_REG_BPACCOUNT.BPMaster> scope) {
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

        // SAP PK 딜러코드 리스트에 담기
        for (IF_SFDC_SAP_REG_BPACCOUNT.BPMaster objBPM : scope) {
            outputCnt++;
            listDealerCode.add(objBPM.BPCode);
            listPriceListCode.add(objBPM.PriceList);
            listUserCode.add(objBPM.TerritoryManager);
            if (objBPM.BPAddrress != null) {
                for (IF_SFDC_SAP_REG_BPACCOUNT.BPAddress address : objBPM.BPAddrress) {
                    listAdrsExternalIds.add(address.ParentKey + address.LineNum);
                }
            }
            if (objBPM.ContactPerson != null) {
                for (IF_SFDC_SAP_REG_BPACCOUNT.ContactPerson cont : objBPM.ContactPerson) {
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
            for (IF_SFDC_SAP_REG_BPACCOUNT.BPMaster objBPM : scope) {
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

                // TODO:: 나중에 Null 체크 해야할 값 있는지 확인하기. 필수값은 알아서 Upsert시 에러날 것.
                objAcct.Name = objBPM.Dealership;
                objAcct.PhoneNumber__c = objBPM.PhoneNumber;
                // TODO:: BP Address 랑 ContactPerson (1)CardCD로 줄지 (2)데이터 전체를 줘서 새로 만들지 확인. 아마 2안
                if (objBPM.BPAddrress != null) {
                    for (IF_SFDC_SAP_REG_BPACCOUNT.BPAddress address : objBPM.BPAddrress) {
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
                    for (IF_SFDC_SAP_REG_BPACCOUNT.ContactPerson cont : objBPM.ContactPerson) {
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
    }

    public void finish(Database.BatchableContext context) {

    }
}