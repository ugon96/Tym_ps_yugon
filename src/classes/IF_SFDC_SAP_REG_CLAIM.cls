/**
 * Created by ally6 on 2023-11-22.
 */

global with sharing class IF_SFDC_SAP_REG_CLAIM {

    private static final String IFID = 'IF_SFDC_SAP_REG_CLAIM';
    private static String TractorRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId();
    private static String LoaderRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Loader').getRecordTypeId();
    private static String BackhoeRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Backhoe').getRecordTypeId();
    private static String MMMRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('MidMountMower').getRecordTypeId();
    private static String CabinRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Cabin').getRecordTypeId();

    private final List<Case> cases;

    public IF_SFDC_SAP_REG_CLAIM(List<Case> listCases) {
        cases = listCases;
        System.debug('set IF_SFDC_SAP_REG_CLAIM :' + cases);
    }

    private class Input {
        String siteCode;
        String apiPartner;
        String apiKey;
        List<Claim> Claims;

    }
    private class Output {
        String ResponseCode;
        String ErrorMessage;
        List<String> ErrorList;
    }
    public class Claim {
        String SFDCKey;
        String TractorSN;
        String LoaderSN;
        String BackhoeSN;
        String MidmountMowerSN;
        String CabinSN;
        String EngineSN;
        Decimal UsingHours;
        String DealerCode;
        Decimal LaborSubtotal;
        Decimal PartsSubtotal;
        Decimal ReqShippingAmt;
        Decimal AppShippingAmt;
        Decimal Total;
        String CauseCode1;
        String CauseCode2;
        String CauseCode3;
        String FailureCause;
        String FailureDescription;
        String FailureDate;
        String Repair;
        List<Parts> Parts;
        List<Repairs> Repairs;
        String RetailDate;
        String RepairDate;
        String ClaimType;
        String AdminNote;
        String Status;
        public Claim() {
            Parts = new List<Parts>();
            Repairs = new List<Repairs>();
        }
    }
    private class Parts {
        String SFDCKey;
        String SFDCHeaderKey;
        String ItemCode;
        String Description;
        Decimal RequestQuantity;
        Decimal ReqeustPartsValue;
        Decimal RequestAmount;
        Decimal ApprovedQuantity;
        Decimal ApprovedPartsValue;
        String InvoiceNumber;
        Decimal ApprovedAmount;
    }
    private class Repairs {
        String SFDCKey;
        String SFDCHeaderKey;
        String Model;
        String LaborCode;
        String LaborGroup;
        String Diagram;
        String Description;
        Decimal LaborHour;
        Decimal ApprovedLaborHour;
        String Remarks;
    }
    public void execute() {
        System.debug('execute');
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'SFDC에서 Claim 정보 생성 시 SAP API 호출하여 SAP에 Order 생성';

        Integer outputCnt = 0;
        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorDealerCode = new List<String>();
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        System.debug('LogWrapper' + LogWrapper);

        List<Claim> listClaimsList = new List<Claim>();
        List<Parts> SAPListParts = new List<Parts>();
        List<Repairs> SAPListRepairs = new List<Repairs>();

        if (cases != null && !cases.isEmpty()) {
            for (Case objCase : cases) {
                Claim listClaims = new Claim();
                listClaims.SFDCKey = objCase.Id;
                if (objCase.Asset != null) {
                    if (objCase.Asset.RecordTypeId == TractorRT) {
                        listClaims.TractorSN = objCase.Asset.SerialNumber != null ? objCase.Asset.SerialNumber : '';
                        listClaims.LoaderSN = objCase.Asset.LoaderId__r != null ? objCase.Asset.LoaderId__r.SerialNumber : '';
                        listClaims.BackhoeSN = objCase.Asset.BackhoeId__r.SerialNumber != null ? objCase.Asset.BackhoeId__r.SerialNumber : '';
                        listClaims.MidmountMowerSN = objCase.Asset.MidMountMower__r.SerialNumber != null ? objCase.Asset.MidMountMower__r.SerialNumber : '';
                        listClaims.CabinSN = objCase.Asset.Cabin__r.SerialNumber != null ? objCase.Asset.Cabin__r.SerialNumber : '';
                    } else {
                        listClaims.LoaderSN = objCase.Asset.SerialNumber != null ? objCase.Asset.SerialNumber : '';
                    }
                    listClaims.EngineSN = objCase.Asset.EngineSerialNumber__c != null? objCase.Asset.EngineSerialNumber__c : '';
                    listClaims.RetailDate = String.valueOf(objCase.Asset.RetailedDate__c);
                }

                if (objCase.Account != null) {
                    listClaims.DealerCode = objCase.Account.BPCode__c != null? objCase.Account.BPCode__c : '';
                }
                listClaims.UsingHours = objCase.UsageTime__c != null? objCase.UsageTime__c : 0;
                listClaims.LaborSubtotal = objCase.ru_TotalApprovedLaborCost__c;
                listClaims.PartsSubtotal = objCase.ru_TotalApprovedPartsAmount__c;
                listClaims.ReqShippingAmt = objCase.ru_TotalRequestShippnig__c;
                listClaims.AppShippingAmt = objCase.ru_TotalApprovedShipping__c;
                listClaims.Total = objCase.fm_TotalApprovedAmount__c;
                listClaims.CauseCode1 = objCase.CauseCode__c != null? objCase.CauseCode__c : '';
                listClaims.CauseCode2 = objCase.CauseCode2__c != null? objCase.CauseCode2__c : '';
                listClaims.CauseCode3 = objCase.CauseCode3__c != null? objCase.CauseCode3__c : '';
                listClaims.FailureCause = objCase.CauseCode3__c != null? objCase.Failure_Cause__c : '';
                listClaims.FailureDescription = objCase.DescriptionOfFailure__c != null? objCase.DescriptionOfFailure__c : '';
                listClaims.FailureDate = objCase.FailureDate__c != null? String.valueOf(objCase.FailureDate__c) : '';
                listClaims.Repair = objCase.Repair__c != null? objCase.Repair__c : '';
                listClaims.RepairDate = objCase.RepairDate__c != null? String.valueOf(objCase.RepairDate__c) : '';
                listClaims.ClaimType = objCase.ClaimType__c != null? objCase.ClaimType__c : '';
                listClaims.AdminNote = objCase.AdminNotes__c != null? objCase.AdminNotes__c : '';
                listClaims.Status = objCase.Status != null? objCase.Status : '';
                System.debug('objCase.PartsClaim :::;  '+objCase.PartsClaim__r);
                if (objCase.PartsClaim__r != null) {
                    for (Parts__c parts : objCase.PartsClaim__r) {
                        Parts parts2 = new Parts();
                        parts2.SFDCKey = parts.Id;
                        // 23.12.15 - SAP 컬럼 추가
                        parts2.SFDCHeaderKey = parts.ClaimId__c;
                        parts2.ItemCode = parts.Name;
                        parts2.Description = parts.PartDescription__c != null? parts.PartDescription__c : '';
                        parts2.RequestQuantity = parts.Quantity__c != null? parts.Quantity__c : 0;
                        parts2.ReqeustPartsValue = parts.PartValue__c != null? parts.PartValue__c : 0;
                        parts2.RequestAmount = parts.fm_Amount__c;
                        parts2.ApprovedQuantity = parts.ApprovedQuantity__c != null? parts.ApprovedQuantity__c : 0;
                        parts2.ApprovedPartsValue = parts.ApprovedPartValue__c != null? parts.ApprovedPartValue__c : 0;
                        parts2.ApprovedAmount = parts.fm_ApprovedAmount__c;
                        if (parts.InvoiceItem__c != null) {
                            parts2.InvoiceNumber = parts.InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c != null? parts.InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c : '';
                        } else {
                            parts2.InvoiceNumber = '';
                        }
                        if (objCase.PartsClaim__r != null) {
                            SAPListParts.add(parts2);
                        }
                    }
                    listClaims.Parts.addAll(SAPListParts);
                }
                if (objCase.LaborCodeClaim__r != null) {
                    for (LaborCode__c laborCode : objCase.LaborCodeClaim__r) {
                        Repairs repairs = new Repairs();
                        repairs.SFDCKey = laborCode.Id;
                        // 23.12.15 - SAP 컬럼 추가
                        repairs.SFDCHeaderKey = laborCode.ClaimId__c;
                        repairs.Model = laborCode.fm_Model__c != null? laborCode.fm_Model__c : '';
                        repairs.LaborCode = laborCode.fm_LaborCode__c != null? laborCode.fm_LaborCode__c : '';
                        repairs.LaborGroup = laborCode.fm_LaborGroup__c != null? laborCode.fm_LaborGroup__c : '';
                        repairs.Diagram = laborCode.fm_Diagram__c != null? laborCode.fm_Diagram__c : '';
                        repairs.Description = laborCode.fm_Description__c != null? laborCode.fm_Description__c : '';
                        repairs.LaborHour = laborCode.LaborHour__c != null? laborCode.LaborHour__c : 0;
                        repairs.ApprovedLaborHour = laborCode.ApprovedLaborHour__c != null? laborCode.ApprovedLaborHour__c : 0;
                        repairs.Remarks = laborCode.Remarks__c != null?  laborCode.Remarks__c : '';
                        SAPListRepairs.add(repairs);
                    }
                    listClaims.Repairs.addAll(SAPListRepairs);
                }
                listClaimsList.add(listClaims);
            }

        }
        System.debug('listClaimsList :: ' + listClaimsList);
        Input objInput = new Input();
        objInput.Claims = listClaimsList;
        objInput.siteCode = 'TYM';
        objInput.apiPartner = 'SalesForce';
        objInput.apiKey = '9gvz5=UcEu8XTXni274pObEpywTiPcpB73('; 

        try {
            System.debug('try objInput.Claims :: ' + objInput.Claims);
            IFUtil objIF = new IFUtil(IFID);
            String requestBody = JSON.serialize(objInput);
            System.debug('requestBody :: ' + requestBody);

            HttpResponse response = objIF.webCallout(requestBody, true);
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                System.debug('response.getStatusCode() :: ' + response.getStatusCode());
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

            }
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        if (outputCnt == successCnt + failCnt && outputCnt != 0) {
            strMessage += '\n Total : ' + outputCnt + '. Success : ' + successCnt + '. Fail : ' + failCnt + '.';
            if (failCnt > 0) {
                strMessage += ' Fail List : ' + listErrorDealerCode.toString();
                strMessage += ' Fail Reason : ' + listErrorMessage.toString();
            }
        }

        // IF_Log에 기록할 데이터 저장
        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;

        System.debug('LogWrapper :: ' + LogWrapper);
        // IF_Log에 데이터 저장
        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);

    }
}