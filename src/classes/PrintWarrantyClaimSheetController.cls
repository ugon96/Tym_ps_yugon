/**
 * Created by 천유정 on 2023-09-11.
 */

 public with sharing class PrintWarrantyClaimSheetController {
    
    @AuraEnabled public static List<Case> caseList {get; set;}
    @AuraEnabled public static List<ContentDocumentLink> contentList {get; set;}
    @AuraEnabled public static Case laborCodeInfo {get; set;}
    @AuraEnabled public static Case partInfo {get; set;}
    @AuraEnabled public static Case claimInfo {get; set;}
    @AuraEnabled public static String str {get; set;}
    @AuraEnabled public static String repair {get; set;}
    @AuraEnabled public static String retailDate {get; set;}
    @AuraEnabled public static String approvedDate {get; set;}
    @AuraEnabled public static String BillingAddress {get; set;}
    @AuraEnabled public static String partsNo {get; set;}
    @AuraEnabled public static String partsDes {get; set;}
    @AuraEnabled public static String imageUrl {get; set;}
    
    public PrintWarrantyClaimSheetController() {
        String strRecordId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('strRecordId : ' + strRecordId);
        InitData(strRecordId);
    }
    
    public static void InitData(String strRecordId){
        try {
            caseList = [SELECT 
                                Id, 
                                FailureDate__c,
                                RepairDate__c,
                                Asset.name,
                                CauseCode__c,
                                CauseCode2__c,
                                CauseCode3__c,
                                Repair__c,
                                ClaimType__c, 
                                Subject,
                                Failure_Cause__c,
                                DescriptionOfFailure__c,
                                Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode,
                                ru_TotalRequestShippnig__c, ru_TotalRequestOthers__c, ru_TotalRequestLaborHour__c, ru_TotalRequestLaborCost__c, ru_TotalApprovedShipping__c,
                                ru_TotalApprovedPartsAmount__c, ru_TotalApprovedOthers__c, ru_TotalApprovedLaborHour__c, ru_TotalApprovedLaborCost__c, ru_PartsTotal__c,
                                fm_TotalApprovedAmount__c, fm_TotalRequestAmount__c
                        FROM Case 
                        WHERE Id =: strRecordId ];

            claimInfo = [SELECT FailureDate__c, Account.Name, RepairDate__c, Asset.fm_Warranty_Expiration_Date__c, Asset.OrdersId__r.PONumber__c,  
                            EndCustomer_id__r.Name, EndCustomer_id__r.Address__c, CaseNumber, Approver1__c, Approver2__c, Approver3__c, UsageTime__c, Asset.RecordType.Name, Asset.RecordType.DeveloperName,
                            Asset.ProductCode, Asset.SerialNumber, Asset.EngineSerialNumber__c, Asset.BackhoeId__r.Name, Asset.BackhoeId__r.SerialNumber, Asset.OrdersId__r.Name,
                            Asset.LoaderId__r.Name, Asset.LoaderId__r.SerialNumber, Status, Asset.RetailedDate__c, ApprovedDate__c, Contact.Address__c, Contact.Name 
                        FROM Case 
                        WHERE Id =: strRecordId];
            
            System.debug('claimInfo!!!!!!!!' + claimInfo);

            
            laborCodeInfo = [SELECT Id, (SELECT Id, Name, fm_Description__c, ApprovedLaborHour__c, fm_LaborCode__c,fm_LaborGroup__c, fm_Diagram__c, LaborHour__c, Remarks__c FROM LaborCodeClaim__r) FROM Case WHERE Id =: strRecordId];
            
            partInfo = [SELECT Id, (SELECT Id, Name, LP__c, LocalParts__c, CausalPart__c, fm_PartsName__c, ApprovedQuantity__c, ApprovedPartValue__c, fm_ApprovedAmount__c, fm_PartsNo__c, PartDescription__c, Quantity__c, PartValue__c, fm_Description__c, ProductId__r.ProductName__c, fm_Amount__c  FROM PartsClaim__r ORDER BY Name) FROM Case WHERE Id =: strRecordId ];
            System.debug('partInfo.PartsClaim__r :: ' + partInfo.PartsClaim__r);
            for (Parts__c part : partInfo.PartsClaim__r) {
                if (part.CausalPart__c) {
                    partsNo = part.fm_PartsNo__c;
                    partsDes = part.fm_PartsName__c;
                }
            }
            System.debug('partsNo ::::::' + partsNo);
            System.debug('partsDes::::::' + partsDes);

            String approverId;

            if(claimInfo.Approver3__c != null) {
                approverId = claimInfo.Approver3__c; 
            } else if(claimInfo.Approver2__c != null) {
                approverId = claimInfo.Approver2__c;
            } else {
                approverId = claimInfo.Approver1__c;
            }

            System.debug('approverId::::::::::' + approverId);

            contentList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM User WHERE Id =: approverId )];

            System.debug('contentList:::::::::'+  contentList);

            Set<Id> cdIdSet = new Set<Id>();

            for (ContentDocumentLink clink : contentList) {
                cdIdSet.add(clink.ContentDocumentId);
            }
            
            List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: cdIdSet AND Title = 'Signiture'];
            System.debug('cvs:::::::::'+  cvs);
            
            if (!cvs.isEmpty()) {
                imageUrl = '/sfc/servlet.shepherd/version/download/' + cvs[0].Id;
            }
            System.debug('imageUrl:::::::::'+  imageUrl);

            BillingAddress = (caseList[0].Account.BillingStreet != null ? caseList[0].Account.BillingStreet : '')
            + (caseList[0].Account.BillingCity != null ? ', ' + caseList[0].Account.BillingCity : '')
            + (caseList[0].Account.BillingState != null ? ', ' + caseList[0].Account.BillingState : '')
            + (caseList[0].Account.BillingCountry != null ? ', ' + caseList[0].Account.BillingCountry : '')
            + (caseList[0].Account.BillingPostalCode != null ? ', ' + caseList[0].Account.BillingPostalCode : '');
            System.debug('BillingAddress::::' + BillingAddress);


            Datetime claimDate = Date.Valueof(caseList[0].FailureDate__c);
            Datetime repairDate = Date.Valueof(caseList[0].RepairDate__c);
            Datetime retailDatetime = Date.Valueof(claimInfo.Asset.RetailedDate__c);
            Datetime approvedDatetime = Date.Valueof(claimInfo.ApprovedDate__c);
            str = claimDate.format('yyyy-MM-dd');
            repair = repairDate.format('yyyy-MM-dd');
            retailDate = retailDatetime.format('yyyy-MM-dd');
            approvedDate = approvedDatetime.format('yyyy-MM-dd');
            System.debug('str ::::::: ' + str);
            System.debug('retailDate ::::::: ' + retailDate);
            System.debug('approvedDate ::::::: ' + approvedDate);

        } catch (Exception e) {
            System.debug('Error PrintWarrantyClaimSheetController : ' + e.getMessage());
            System.debug('Error PrintWarrantyClaimSheetController Line : ' + e.getLineNumber());
            System.debug('Error PrintWarrantyClaimSheetController Cause : ' + e.getCause());
        }
    } 

    @AuraEnabled
    public static String doGetInitData() {
        Network objNetwork = new Network();
        Id networkId = Network.getNetworkId();
        if (networkId != null) {
            objNetwork = (Network) [
                    SELECT  Id, Name, UrlPathPrefix
                    FROM    Network
                    WHERE   Id = :networkId
            ];
        }
        System.debug('doGetInitData ==>' + objNetwork.UrlPathPrefix);
        return objNetwork.UrlPathPrefix;
    }

    @AuraEnabled
    public static String doSavePdf(String strRecordId, String pdfType) {

        String result = '';
        String vfPageUrl = '';

        try{
            vfPageUrl = '/apex/PrintWarrantyClaimSheet?Id=' + strRecordId + '&pdfType='+pdfType;
            System.debug('vfPageUrl:::::::' + vfPageUrl);
            PageReference templatePageReference = new PageReference(vfPageUrl);

            Blob templateBLOB;
            if (Test.isRunningTest()){
                templateBLOB = Blob.valueOf('Unit test');
            } else {
                //templateBLOB = templatePageReference.getContent();
                templateBLOB = templatePageReference.getContentAsPDF();
            }

            List<Case> serialNum = [
                    SELECT CaseNumber
                    FROM Case
                    WHERE Id = :strRecordId
            ];

            List<AggregateResult> cntDocument = new List<AggregateResult>();
            cntDocument = [
                    SELECT id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :strRecordId
                    AND ContentDocument.Title LIKE '%Warranty Claim Sheet-%'
                    GROUP BY Id
            ];
            System.debug('PrfPDFGenerator_ba --------- cntDocument ::::' + cntDocument);
            Integer intCnt = cntDocument.size() + 1;
            String strCnt = String.valueOf(cntDocument.size() + 1);
            strCnt = intCnt < 10 ? '0' + strCnt : strCnt;

            ContentVersion objContentVersion = new ContentVersion();
            objContentVersion.Title                     = 'Warranty Claim Sheet-' + serialNum.get(0).CaseNumber + '_' + strCnt;
            objContentVersion.VersionData               = templateBLOB;
            objContentVersion.PathOnClient              = 'Warranty Claim Sheet-' + serialNum.get(0).CaseNumber + '_' + strCnt + '.pdf';
            objContentVersion.FirstPublishLocationId    = strRecordId;

            insert objContentVersion;

            objContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:objContentVersion.Id];

            List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>([
                    SELECT Id, ShareType, Visibility
                    from ContentDocumentLink
                    where LinkedEntityId = :strRecordId
                    and ContentDocumentId = :objContentVersion.ContentDocumentId
            ]);
            if (!listCdl.isEmpty()) {
                ContentDocumentLink cdl = listCdl.get(0);
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                update cdl;
            } else {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = strRecordId;
                cdl.ContentDocumentId = objContentVersion.ContentDocumentId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
            }
            result = 'success';

        } catch(Exception e){
            System.debug('Error PrintWarrantyClaimSheetController : ' + e.getMessage());
            System.debug('Error PrintWarrantyClaimSheetController Line : ' + e.getLineNumber());
            System.debug('Error PrintWarrantyClaimSheetController Cause : ' + e.getCause());
            result = 'error';
        }

        return result;
    }

}