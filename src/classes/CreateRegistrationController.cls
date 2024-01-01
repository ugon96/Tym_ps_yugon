/************************************************************************************
 * File Name   		: CreateRegistrationController
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-06
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-06       ugon96@gmail.com         Initial Version
*************************************************************************************/

public without sharing class CreateRegistrationController {
    @AuraEnabled
    public static List<Contact> getDealerData() {
        List<Contact> listDealer = null;
        try {
            User objUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            System.debug('objUser :: ' + objUser);
            System.debug('objUser.ContactId :: ' + objUser.ContactId);
            System.debug('objUser.Contact.AccountId :: ' + objUser.Contact.AccountId);
            if (objUser.ContactId != null && objUser.Contact.AccountId != null) {
                listDealer = new List<Contact>([
                        SELECT Id, Name
                        FROM Contact
                        WHERE AccountId = :objUser.Contact.AccountId
                        AND RecordType.Name = 'Salesperson'
                ]);
                System.debug('listDealer :: ' + listDealer);
            } else {
                ExceptionClass.OtherException e = new ExceptionClass.OtherException();
                e.setMessage('There is no Contact or Account Id in this user');
                throw e;
            }
            return listDealer;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    // Save시 Asset의 Approval Process 를 실행시킴
    @AuraEnabled
    public static String doCreateRegistration(Id searchedAssetRecordId, Id selectedDealerId, Id selectedCustomerId, Date dateOfSales, String warrantyType) {
        System.debug('doCreateRegistration().run()');
        Savepoint sp = Database.setSavepoint();
        try {
            List<Asset> listSelectedAsset = [
                    SELECT Id, SalespersonId__c, RetailedDate__c, EndCustomerId__c, Status,
                            LoaderId__c, BackhoeId__c, MidMountMower__c, Cabin__c, RecordType.Name
                    FROM Asset
                    WHERE Id = :searchedAssetRecordId
                    LIMIT 1
            ];
            List<Id> listAttachmentId = new List<Id>();

            if (listSelectedAsset.size() == 0) {
                ExceptionClass.OtherException e = new ExceptionClass.OtherException();
                e.setMessage('Cannot found searched asset');
                throw e;
            }
            Asset selectedAsset = listSelectedAsset.get(0);


            // 선택된 Asset 이 트랙터 인 경우 트랙터의 부착물을 조회하기 위해 리스트에 담는다
            if (selectedAsset.RecordType.Name == 'Tractor') {
                if (selectedAsset.LoaderId__c != null) {
                    listAttachmentId.add(selectedAsset.LoaderId__c);
                }
                if (selectedAsset.BackhoeId__c != null) {
                    listAttachmentId.add(selectedAsset.BackhoeId__c);
                }
                if (selectedAsset.MidMountMower__c != null) {
                    listAttachmentId.add(selectedAsset.MidMountMower__c);
                }
                if (selectedAsset.Cabin__c != null) {
                    listAttachmentId.add(selectedAsset.Cabin__c);
                }
            }

            System.debug('listAttachmentId :: ' + listAttachmentId);
            List<Asset> listAttachment = new List<Asset>();
            if (listAttachmentId.size() > 0) {
                listAttachment = [
                        SELECT Id, EndCustomerId__c, SalespersonId__c, RetailedDate__c, RegisteredDate__c, Status, WarrantyType__c
                        FROM Asset
                        WHERE Id = :listAttachmentId
                        AND (Status = 'New'
                        OR Status = 'In Stock')
                ];
            }

            // 해당 트랙터와 Attachment의 Status 가 'New'인 경우에만 데이터 업데이트 및 승인 프로세스 실행.
            // Warranty Type 이 Commercial, Non-Commercial 인 경우만, RetailedDate 업데이트
            List<Asset> listAssetForRegistration = new List<Asset>();
            if (warrantyType == 'Stock') {
                if (selectedAsset.Status == 'New' || selectedAsset.Status == 'In Stock') {
                    selectedAsset.RegisteredDate__c = Date.today();
                    selectedAsset.SalespersonId__c = selectedDealerId;
                    selectedAsset.WarrantyType__c = warrantyType;
                    listAssetForRegistration.add(selectedAsset);
                }
                for (Asset objAttach : listAttachment) {
                    objAttach.RegisteredDate__c = Date.today();
                    objAttach.SalespersonId__c = selectedDealerId;
                    objAttach.WarrantyType__c = warrantyType;
                    listAssetForRegistration.add(objAttach);
                }
            } else {
                if (selectedAsset.Status == 'New' || selectedAsset.Status == 'In Stock') {
                    selectedAsset.retailedDate__c = dateOfSales;
                    selectedAsset.RegisteredDate__c = Date.today();
                    selectedAsset.EndCustomerId__c = selectedCustomerId;
                    selectedAsset.SalespersonId__c = selectedDealerId;
                    selectedAsset.WarrantyType__c = warrantyType;
                    listAssetForRegistration.add(selectedAsset);
                }
                for (Asset objAttach : listAttachment) {
                    objAttach.retailedDate__c = dateOfSales;
                    objAttach.RegisteredDate__c = Date.today();
                    objAttach.EndCustomerId__c = selectedCustomerId;
                    objAttach.SalespersonId__c = selectedDealerId;
                    objAttach.WarrantyType__c = warrantyType;
                    listAssetForRegistration.add(objAttach);
                }
            }
            if (listAssetForRegistration.size() > 0) {
                update listAssetForRegistration;

                // 20231115 트랙터를 등록하는 경우에는 트랙터만, 부착물을 등록하는 경우에는 부착물만 승인 프로세스 태움.
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(selectedAsset.Id);
                req.setSubmitterId(UserInfo.getUserId());
                System.debug('selectedAsset.WarrantyType__c :: ' + selectedAsset.WarrantyType__c);
                req.setSkipEntryCriteria(true);
//                if (selectedAsset.WarrantyType__c == 'Stock') {
//                    req.setProcessDefinitionNameOrId('AssetApprovalProcess');
//                } else {
//                    req.setProcessDefinitionNameOrId('AssetApprovalProcess2');
//                }
                Approval.ProcessResult result = Approval.process(req);
                if (!result.success) {
                    ExceptionClass.OtherException e = new ExceptionClass.OtherException();
                    e.setMessage(String.valueOf(result.errors));
                    throw e;
                }

                /*List<Approval.ProcessSubmitRequest> listReq = new List<Approval.ProcessSubmitRequest>();
                for (Asset objAsset : listAssetForRegistration) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(objAsset.Id);
                    req.setSubmitterId(UserInfo.getUserId());
                    System.debug('objAsset.WarrantyType__c :: ' + objAsset.WarrantyType__c);
                    req.setSkipEntryCriteria(true);
                    if (objAsset.WarrantyType__c == 'Stock') {
                        req.setProcessDefinitionNameOrId('AssetApprovalProcess');
                        listReq.add(req);
                    } else {
                        req.setProcessDefinitionNameOrId('AssetApprovalProcess2');
                        listReq.add(req);
                    }
                }
                if (listReq.size() > 0) {
                    List<Approval.ProcessResult> listResult = Approval.process(listReq);
                    System.debug(listResult);
                } else {
                    ExceptionClass.OtherException e = new ExceptionClass.OtherException();
                    e.setMessage('No applicable approval process was found.');
                    throw e;
                }*/
            } else {
                ExceptionClass.OtherException e = new ExceptionClass.OtherException();
                e.setMessage('No applicable approval process was found.');
                throw e;
            }

            return null;
        } catch (Exception e) {
            String errMsg = 'Error :: ' + e.getMessage();
            if (errMsg.contains('No applicable approval process was found.')) {
                errMsg += '(Check serial number and warranty type.)';
            }
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            Database.rollback(sp);
            return errMsg;
        }
    }

    @AuraEnabled
    public static String getConnectedAssetInformation(String recordId) {
        RegistrationWrapper regiWrapper = new RegistrationWrapper();
        try {
            List<Asset> listTractorAsset = [
                    SELECT Id, SerialNumber, ProductCode, LoaderId__c, LoaderId__r.SerialNumber, LoaderId__r.ProductCode, LoaderId__r.Id,
                            BackhoeId__c, BackhoeId__r.SerialNumber, BackhoeId__r.ProductCode, BackhoeId__r.Id,
                            Cabin__c, Cabin__r.SerialNumber, Cabin__r.ProductCode, Cabin__r.Id, MidMountMower__r.Id,
                            MidMountMower__c, MidMountMower__r.SerialNumber, MidMountMower__r.ProductCode,
                            LoaderId__r.Product2.ProductName__c, BackhoeId__r.Product2.ProductName__c, MidMountMower__r.Product2.ProductName__c, Cabin__r.Product2.ProductName__c, Product2.ProductName__c,
                            RegisteredDate__c
                    FROM Asset
                    WHERE RecordType.DeveloperName = 'Tractor'
                    AND (Id = :recordId
                    OR LoaderId__c = :recordId
                    OR BackhoeId__c = :recordId
                    OR MidMountMower__c = :recordId
                    OR Cabin__c = :recordId)
                    LIMIT 1
            ];

            // 입력한 Serial Number를 조회했을 때 트랙터인 경우.
            if (listTractorAsset.size() > 0) {
                Asset oTractorAsset = listTractorAsset.get(0);
                AssetWrapper wrapTractor = new AssetWrapper();
                wrapTractor.SerialNumber = oTractorAsset.SerialNumber;
                wrapTractor.Id = oTractorAsset.Id;
                //wrapTractor.ProductCode = oTractorAsset.ProductCode;
                wrapTractor.ProductCode = oTractorAsset.Product2.ProductName__c;
                regiWrapper.wrapTractor = wrapTractor;

                if (oTractorAsset.LoaderId__c != null) {
                    AssetWrapper wrapLoader = new AssetWrapper();
                    wrapLoader.SerialNumber = oTractorAsset.LoaderId__r.SerialNumber;
                    wrapLoader.Id = oTractorAsset.LoaderId__r.Id;
                    //wrapLoader.ProductCode = oTractorAsset.LoaderId__r.ProductCode;
                    wrapLoader.ProductCode = oTractorAsset.LoaderId__r.Product2.ProductName__c;
                    regiWrapper.wrapLoader = wrapLoader;
                }
                if (oTractorAsset.BackhoeId__c != null) {
                    AssetWrapper wrapBackhoe = new AssetWrapper();
                    wrapBackhoe.SerialNumber = oTractorAsset.BackhoeId__r.SerialNumber;
                    wrapBackhoe.Id = oTractorAsset.BackhoeId__r.Id;
                    //wrapBackhoe.ProductCode = oTractorAsset.BackhoeId__r.ProductCode;
                    wrapBackhoe.ProductCode = oTractorAsset.BackhoeId__r.Product2.ProductName__c;
                    regiWrapper.wrapBackhoe = wrapBackhoe;
                }
                if (oTractorAsset.Cabin__c != null) {
                    AssetWrapper wrapCabin = new AssetWrapper();
                    wrapCabin.SerialNumber = oTractorAsset.Cabin__r.SerialNumber;
                    wrapCabin.Id = oTractorAsset.Cabin__r.Id;
                    //wrapCabin.ProductCode = oTractorAsset.Cabin__r.ProductCode;
                    wrapCabin.ProductCode = oTractorAsset.Cabin__r.Product2.ProductName__c;
                    regiWrapper.wrapCabin = wrapCabin;
                }
                if (oTractorAsset.MidMountMower__c != null) {
                    AssetWrapper wrapMMM = new AssetWrapper();
                    wrapMMM.SerialNumber = oTractorAsset.MidMountMower__r.SerialNumber;
                    wrapMMM.Id = oTractorAsset.MidMountMower__r.Id;
                    //wrapMMM.ProductCode = oTractorAsset.MidMountMower__r.ProductCode;
                    wrapMMM.ProductCode = oTractorAsset.MidMountMower__r.Product2.ProductName__c;
                    regiWrapper.wrapMMM = wrapMMM;
                }

            } else {
                // 입력한 Serial Number를 조회했을 때 트랙터가 아닌경우
                listTractorAsset = [
                        SELECT Id, ProductCode, SerialNumber, Name, RecordType.DeveloperName, Product2.ItemGroupCode__c
                        FROM Asset
                        WHERE Id = :recordID
                ];
                if (listTractorAsset.size() > 0) {
                    Asset oTractorAsset = listTractorAsset.get(0);
                    AssetWrapper AssetWrapper = new AssetWrapper();
                    AssetWrapper.SerialNumber = oTractorAsset.SerialNumber;
                    AssetWrapper.Id = oTractorAsset.Id;
                    //AssetWrapper.ProductCode = oTractorAsset.ProductCode;
                    AssetWrapper.ProductCode = oTractorAsset.Product2.ProductName__c;
                    System.debug('oTractorAsset :: ' + oTractorAsset);
                    if (oTractorAsset.Product2.ItemGroupCode__c == '113') {
                        regiWrapper.wrapLoader = AssetWrapper;
                    } else if (oTractorAsset.Product2.ItemGroupCode__c == '114') {
                        regiWrapper.wrapBackhoe = AssetWrapper;
                    } else if (oTractorAsset.Product2.ItemGroupCode__c == '117') {
                        regiWrapper.wrapMMM = AssetWrapper;
                    }
                } else {
                    regiWrapper.errMsg = 'Wrong Asset Record Id / Serial Number';
                    regiWrapper.state = false;
                    return JSON.serialize(regiWrapper);
                }
            }

            System.debug('regiWrapper :: ' + regiWrapper);
            return JSON.serialize(regiWrapper);
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            regiWrapper.errMsg = 'Wrong Asset Record Id / Serial Number';
            regiWrapper.state = false;
            return JSON.serialize(regiWrapper);
        }
    }

    private class RegistrationWrapper {
        Boolean state;
        AssetWrapper wrapTractor;
        AssetWrapper wrapLoader;
        AssetWrapper wrapBackhoe;
        AssetWrapper wrapMMM;
        AssetWrapper wrapCabin;
        String errMsg;
        RegistrationWrapper() {
            this.state = true;
            this.wrapTractor = new AssetWrapper();
            this.wrapLoader = new AssetWrapper();
            this.wrapBackhoe = new AssetWrapper();
            this.wrapMMM = new AssetWrapper();
            this.wrapCabin = new AssetWrapper();
            this.errMsg = null;
        }
    }
    private class AssetWrapper {
        String SerialNumber;
        String Id;
        String ProductCode;
        AssetWrapper() {
            this.SerialNumber = null;
            this.Id = null;
            this.ProductCode = null;
        }
    }

}