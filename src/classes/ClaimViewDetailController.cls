/**
 * Created by 천유정 on 2023-09-19.
 */

public with sharing class ClaimViewDetailController {

    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId) {
        Case objClaim;
        String priceList;
        List<LaborCode__c> listDataLabor;
        List<Parts__c> listDataParts = new List<Parts__c>();

        Set<Id> setProductIds = new Set<Id>();
        Map<String, Map<String, ARInvoiceItem__c>> mapARInvoiceByProducts = new Map<String, Map<String, ARInvoiceItem__c>>();
        Map<String, ARInvoiceItem__c> mapARInvoice = null;
        Decimal mapARInvoiceSize = 0;

        //Edit 권한 설정
        Boolean isPartnerUser;
        Boolean isAdministratorUser;

        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            //Custom Setting : System Administrator Id값
            UtilObject__c utilObject = UtilObject__c.getOrgDefaults();

            isPartnerUser = UserInfo.getUserType().contains('Partner')? true : false;
            isAdministratorUser = UserInfo.getProfileId().equalsIgnoreCase(utilObject.AdminProfileId__c)? true : false;

            objClaim = [
                    SELECT Id, CaseNumber, ContactId, AccountId, AssetId, ProductId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany,
                            Type, Status, Reason, Origin, Language, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId,
                            IsClosedOnCreate, SlaStartDate, SlaExitDate, IsStopped, StopStartDate, CreatedDate, ContactPhone, ContactMobile, ContactEmail,
                            ContactFax, Comments, LastViewedDate, LastReferencedDate, ServiceContractId, MilestoneStatus, AdminNotes__c, CauseCode__c,
                            FailureDate__c, RepairDate__c, EndCustomer_ID__c,
                            ru_PartsTotal__c, ru_TotalApprovedLaborHour__c, ru_TotalRequestLaborHour__c, ru_TotalApprovedPartsAmount__c, ru_TotalApprovedLaborCost__c,
                            fm_TotalApprovedAmount__c, Account.LaborRate__c, ru_TotalRequestLaborCost__c, ru_TotalApprovedOthers__c, ru_TotalApprovedShipping__c ,
                            Asset.Product2.Name, Account.PriceListParts__c, Account.PriceListParts__r.Factor__c, Account.PriceListParts__r.BasePriceList__c, ApprovalStatus__c,
                            ru_TotalRequestShippnig__c, ru_TotalRequestOthers__c, fm_TotalRequestAmount__c, Asset.Product2.ProductName__c
                    FROM Case
                    WHERE Id =: recordId
            ];

            if (objClaim.Account.PriceListParts__c == null) {
                priceList = null;
            } else {
                priceList = objClaim.Account.PriceListParts__r.BasePriceList__c == null? objClaim.Account.PriceListParts__c : objClaim.Account.PriceListParts__r.BasePriceList__c;
            }

            listDataLabor = [
                    SELECT Id, ClaimId__c, LaborCodeMasterId__c, LaborHour__c, Remarks__c, fm_LaborGroup__c, fm_Diagram__c, fm_LaborCode__c,
                            ApprovedLaborHour__c, fm_Description__c, fm_TotalRequestLaborCost__c, fm_TotalApprovedLaborCost__c, LaborCost__c
                    FROM LaborCode__c
                    WHERE ClaimId__c =: recordId
            ];

            for(Parts__c obj :[
                    SELECT Id, Name, ProductId__c, ClaimId__c, LP__c, PartDescription__c, Quantity__c, PartValue__c, CausalPart__c,
                            fm_PartsName__c, fm_Description__c, fm_PartsNo__c, fm_Amount__c, ProductId__r.Name, ProductId__r.ProductName__c, LocalParts__c,
                            fm_ApprovedAmount__c, ApprovedPartValue__c, ApprovedQuantity__c, InvoiceItem__c, InvoiceItem__r.ARInvoiceMaster__r.ExternalId__c
                    FROM Parts__c
                    WHERE ClaimId__c =: recordId
            ]) {
                listDataParts.add(obj);
                setProductIds.add(obj.ProductId__c);
            }
            for (ARInvoiceItem__c obj : [SELECT Id, ARInvoiceMaster__r.ExternalId__c, UnitPrice__c, Product__c
                                            FROM ARInvoiceItem__c
                                            WHERE Product__c IN: setProductIds]) {
                if (mapARInvoiceByProducts.get(obj.Product__c) == null) {
                    mapARInvoice = new Map<String, ARInvoiceItem__c>();
                } else {
                    mapARInvoice = mapARInvoiceByProducts.get(obj.Product__c);
                }
                mapARInvoice.put(obj.ARInvoiceMaster__r.ExternalId__c, obj);
                mapARInvoiceByProducts.put(obj.Product__c, mapARInvoice);
            }
            System.debug('mapARInvoiceByProducts => ' + mapARInvoiceByProducts);
            System.debug('priceList => ' + priceList); 

        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('ClaimViewDetailController line : ' + e.getLineNumber());
            System.debug('ClaimViewDetailController message : ' + e.getMessage());
            System.debug('ClaimViewDetailController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'objClaim' => objClaim,
                'model' => objClaim.Asset.Product2.ProductName__c,
                'factor' => objClaim.Account.PriceListParts__r.Factor__c,
                'priceList' => priceList,
                'listDataLabor' => listDataLabor,
                'listDataParts' => listDataParts,
                'mapARInvoiceByProducts' => mapARInvoiceByProducts,
                'isPartnerUser' => isPartnerUser,
                'isAdministratorUser' => isAdministratorUser, 
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    /**
     * @description 레코드 저장
     * @author yj.chun
     * @param listDataLabor
     * @param listDataLaborDeleted
     * @param listDataParts
     * @param listDataPartsDeleted
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> saveRecord(String listDataLabor, String listDataLaborDeleted, String listDataParts, String listDataPartsDeleted) {

        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            System.debug('saveRecord ===> listDataLabor ::: ' + listDataLabor);
            System.debug('saveRecord ===> listDataLaborDeleted ::: ' + listDataLaborDeleted);
            System.debug('saveRecord ===> listDataParts ::: ' + listDataParts);
            System.debug('saveRecord ===> listDataPartsDeleted ::: ' + listDataPartsDeleted);


            // Upsert : Labor Code
            List<LaborCode__c> listObj = (List<LaborCode__c>) JSON.deserialize(listDataLabor, List<LaborCode__c>.class);
            System.debug('saveRecord ===> Upserted Labor ::: ' + listObj);
            upsert listObj;

            // Upsert : Parts
            List<Parts__c> listObjParts = (List<Parts__c>) JSON.deserialize(listDataParts, List<Parts__c>.class);
            System.debug('saveRecord ===> Upserted Parts ::: ' + listObjParts);
            upsert listObjParts;

            // Delete : Labor Code
            List<LaborCode__c> listDeleteTargetId = new List<LaborCode__c>();
            if (listDataLaborDeleted.length() > 0) {
                listDeleteTargetId = (List<LaborCode__c>) JSON.deserialize(listDataLaborDeleted, List<LaborCode__c>.class);
            }
            System.debug('saveRecord ===> Deleted Labor ::: ' + listDeleteTargetId);
            if (listDeleteTargetId.size() > 0) {
                delete (List<SObject>) listDeleteTargetId;
            }

            // Delete : Parts
            List<Parts__c> listDeleteTargetIdParts = new List<Parts__c>();
            if (listDataPartsDeleted.length() > 0) {
                listDeleteTargetIdParts = (List<Parts__c>) JSON.deserialize(listDataPartsDeleted, List<Parts__c>.class);
            }
            System.debug('saveRecord ===> Deleted Parts ::: ' + listDeleteTargetIdParts);
            if (listDeleteTargetIdParts.size() > 0) {
                delete (List<SObject>) listDeleteTargetIdParts;
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('ClaimViewDetailController line : ' + e.getLineNumber());
            System.debug('ClaimViewDetailController message : ' + e.getMessage());
            System.debug('ClaimViewDetailController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    /**
     * @description ClaimViewDetail_Addmodal 컴포넌트 Init
     * @param model
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getInitAddModal(String model) {
        Map<String, Map<String, List<String>>> mapSRT = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> mapDiagramCode;
        List<String> listCode;
        List<String> listCodeAll = new List<String>();
        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            System.debug('model => ' + model);
            for(LaborCodeMaster__c obj : [
                    SELECT  Id, LaborGroup__c, Diagram__c, LaborCode__c, Description__c
                    FROM    LaborCodeMaster__c
                    WHERE   Model__c =: model
                    AND     IsActive__c = TRUE
                    ORDER BY LaborGroup__c, Diagram__c, LaborCode__c, Description__c
            ]) {
                listCodeAll.add(obj.LaborCode__c);
                listCode = new List<String>();
                if(mapDiagramCode <> null && mapDiagramCode.get(obj.Diagram__c) <> null) {
                    listCode = mapDiagramCode.get(obj.Diagram__c);
                } else {
                    mapDiagramCode = new Map<String, List<String>>();
                }
                if(mapSRT <> null && mapSRT.get(obj.LaborGroup__c) <> null) {
                    mapDiagramCode = mapSRT.get(obj.LaborGroup__c);
                }
                listCode.add(obj.LaborCode__c);
                mapDiagramCode.put(obj.Diagram__c, listCode);
                mapSRT.put(obj.LaborGroup__c, mapDiagramCode);
            }

            System.debug('mapDiagramCode ==> ' +mapDiagramCode);
            System.debug('mapSRT ==> ' +mapSRT);

        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('ClaimViewDetailController line : ' + e.getLineNumber());
            System.debug('ClaimViewDetailController message : ' + e.getMessage());
            System.debug('ClaimViewDetailController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'mapSRT' => mapSRT,
                'listCodeAll' => listCodeAll,
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    /**
     * @description ClaimViewDetail_Addmodal 컴포넌트에서 'Search' 버튼 클릭 시
     * @param model
     * @param laborGroup
     * @param diagram
     * @param laborCode
     * @param description
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> searchLaborMaster (String model, String laborGroup, String diagram, String laborCode, String searchKey) {

        String strQuery = 'SELECT Id,';
        List<Object> listMasterData;

        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            strQuery += ' Name, Model__c, LaborGroup__c, Diagram__c, LaborCode__c, Description__c, LaborHour__c, IsActive__c ';
            strQuery += ' FROM LaborCodeMaster__c ';
            strQuery += ' WHERE IsActive__c = TRUE ';
            strQuery += ' AND Model__c = \'' + model + '\'';
            if (laborGroup != null) strQuery += ' AND LaborGroup__c = \'' + laborGroup + '\'';
            if (diagram != null) strQuery += ' AND Diagram__c = \'' + diagram + '\'';
            if (laborCode != null) strQuery += ' AND LaborCode__c = \'' + laborCode + '\'';
            if (searchKey != null) strQuery += ' AND LaborCode__c LIKE \'%' + searchKey + '%\'';
            strQuery += ' ORDER BY LaborGroup__c, Diagram__c, LaborCode__c, Description__c ';
            System.debug('strQuery ==> ' + strQuery);
            listMasterData = Database.query(strQuery);
            System.debug('listMasterData.length  ==> ' + listMasterData.size());

        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('ClaimViewDetailController line : ' + e.getLineNumber());
            System.debug('ClaimViewDetailController message : ' + e.getMessage());
            System.debug('ClaimViewDetailController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'listMasterData' => listMasterData,
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    /**
     * @description DN_Lookup 컴포넌트에서 Product2 선택 시, Price 가져오기
     * @param productId
     * @param priceListId
     * @param factor
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getPartsValue (String productId, String priceListId, Decimal factor) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        Decimal price = 0.0;
        String description = '';
        try {
            System.debug('getPartsValue :: ProductId ======> ' + productId);
            System.debug('getPartsValue :: PriceListId ======> ' + priceListId);
            System.debug('getPartsValue :: Factor ======> ' + factor);
            List<PriceListEntry__c> listPriceListEntry = [
                    SELECT Id, ListPrice__c, ProductID__r.Name, ProductID__r.ProductName__c
                    FROM PriceListEntry__c
                    WHERE ProductID__c =: productId
                    AND PriceListID__c =: priceListId 
            ];

            if (!listPriceListEntry.isEmpty()) {
                System.debug('getPartsValue :: ListPrice__c ======> ' + listPriceListEntry.get(0).ListPrice__c);
                price = (listPriceListEntry.get(0).ListPrice__c * factor).setScale(0, RoundingMode.HALF_UP);
                description = listPriceListEntry.get(0).ProductID__r.ProductName__c;
                System.debug('getPartsValue :: price ======> ' + price);
            } else {
                strStatus = 'ERROR';
                strMessage = 'Prices could not be retrieved. Please contact your territory manager.';
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('ClaimViewDetailController line : ' + e.getLineNumber());
            System.debug('ClaimViewDetailController message : ' + e.getMessage());
            System.debug('ClaimViewDetailController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'price' => price,
                'description' => description,
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    /**
     * @description ClaimViewDetail : Invoice Number 조회
     * @param model
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getInvoiceNumber(String productId, String dealershipId) {
        System.debug('getInvoiceNumber ==== Start!');

        Map<String, ARInvoiceItem__c> mapARInvoice;
        String strStatus = 'SUCCESS';
        String strMessage = '';
        Decimal mapARInvoiceSize = 0;
        try {
            mapARInvoice = new Map<String, ARInvoiceItem__c>();
            for (ARInvoiceItem__c obj : [SELECT Id, ARInvoiceMaster__r.ExternalId__c, UnitPrice__c
                                            FROM ARInvoiceItem__c
                                            WHERE Product__c =: productId
                                            AND ARInvoiceMaster__r.Dealership__c =: DealershipId]) {
                mapARInvoice.put(obj.ARInvoiceMaster__r.ExternalId__c, obj); 
            }
            mapARInvoiceSize = mapARInvoice.size();
            System.debug('mapARInvoice => ' + mapARInvoice);
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }
        System.debug('getInvoiceNumber ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'mapARInvoice' => mapARInvoice,
                'mapARInvoiceSize' => mapARInvoiceSize
        };
        return mapReturn;
    }
}