/*************************************************************
 * @author : th.kim
 * @date : 2023-11-03
 * @group : 
 * @group-content :
 * @description : RetailProgram 등록, 수정 ,삭제
==============================================================
  * Ver       Date            Author            Modification
    1.0       2023-11-03      th.kim            Initial Version
**************************************************************/

public without sharing class TYM_RetailProgramRegController {

    public static String currentId;
    public static String currentAssetId;

    public class FileWrap {
        public String fileName;
        public String base64;
    }

    public class DataWrap {
        public String productId;
        public String programId;
        public String description;
        public Decimal amount;
        public Decimal manager;
        public Decimal unit;
        public String status;
        public String salesperson;
        public Boolean payToDealer;
        public String issueType;
        public FileWrap fileData;
    }

    public class DeleteWrap {
        public String programId;
        public String productId;
    }

    public class ReturnWrap {
        public RetailProgramMasterItem__c objRPMasterItem;
        public RetailProgramItem__c objRPItem;
        public ContentDistribution objCdb;
    }

    /**
     * @author th.kim
     * @description 현재 사용자 프로필명 가져오기
     * @return Profile.Name
     */
    @AuraEnabled
    public static String getProfileName() {
        return [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }

    /**
     * @author th.kim
     * @param recordId 현재 RetailProgram의 Id 값
     * @description 현재 레코드의 Dealership의 salesperson 가져오기
     * @return listSalesperson
     */
    @AuraEnabled
    public static List<Contact> getSalesperson(String recordId) {
        String strDealershipId = [SELECT AccountId__c FROM RetailProgram__c WHERE Id = :recordId].AccountId__c;
        List<Contact> listSalesperson = [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Salesperson' AND AccountId = :strDealershipId];
        return listSalesperson;
    }

    /**
     * @author th.kim
     * @description tym_RetailProgramReg 컴포넌트에서 해당 RetailProgram__c 데이터와 RetailProgram Master의 날짜가 포함되어 있는 타입 별 RetailProgramMasterItem__c 데이터 가져오기
     * @param recordId RetailProgram Id
     *
     * @return returnMap
     */
    @AuraEnabled
    public static Map<String, Object> getRetailProgram(String recordId) {
        try {
            currentId = recordId;
            RetailProgram__c retailProgramObj = [
                    SELECT Id,
                            Name,
                            AccountId__c,
                            SalespersonId__c,
                            Description__c,
                            IsPayToDealer__c,
                            Status__c,
                            AssetID__c,
                            AssetID__r.Name,
                            AssetID__r.RetailedDate__c,
                            AssetID__r.RegisteredDate__c,
                            AssetID__r.Product2Id,
                            AssetID__r.Status,
                            AssetID__r.SerialNumber,
                            AssetID__r.OrdersId__c,
                            AssetID__r.InvoiceDate__c,
                            AssetID__r.LoaderId__r.Product2Id,
                            AssetID__r.LoaderId__r.RetailedDate__c,
                            AssetID__r.LoaderId__r.RegisteredDate__c,
                            AssetID__r.LoaderId__r.SerialNumber,
                            AssetID__r.LoaderId__r.OrdersId__c,
                            AssetID__r.LoaderId__r.InvoiceDate__c,
                            AssetID__r.BackhoeId__r.Product2Id,
                            AssetID__r.BackhoeId__r.RetailedDate__c,
                            AssetID__r.BackhoeId__r.RegisteredDate__c,
                            AssetID__r.BackhoeId__r.OrdersId__c,
                            AssetID__r.BackhoeId__r.SerialNumber,
                            AssetID__r.BackhoeId__r.InvoiceDate__c,
                            AssetID__r.RecordType.Name, (SELECT RetailProgramMasterID__c, ProductID__c FROM Retail_Program_Item__r)
                    FROM RetailProgram__c
                    WHERE Id = :currentId
            ];
            currentAssetId = retailProgramObj.AssetID__c;

            Set<Id> masterIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();
            for (RetailProgramItem__c item : retailProgramObj.Retail_Program_Item__r) {
                masterIdSet.add(item.RetailProgramMasterID__c);
                productIdSet.add(item.ProductID__c);
            }

            Set<Id> nullSet = new Set<Id>();

            // Rebate 타입 드롭다운 옵션으로 넣기 위한 모든 리스트(AllList)와 바로 행 추가를 위한 이미 생성된(MasterItemList) 리스트 가져오기
            List<RetailProgramMasterItem__c> rebateAllList = queryMasterItemList(retailProgramObj.AssetID__r, 'Rebate', nullSet, nullSet);
            rebateAllList = getFlatRateAmount(rebateAllList, retailProgramObj.AssetID__r);
            List<RetailProgramMasterItem__c> rebateMasterItemList = new List<RetailProgramMasterItem__c>();
            List<ReturnWrap> listRebate = new List<ReturnWrap>();
            if (!masterIdSet.isEmpty()) {
                rebateMasterItemList = queryMasterItemList(retailProgramObj.AssetID__r, 'Rebate', masterIdSet, productIdSet);
                rebateMasterItemList = getFlatRateAmount(rebateMasterItemList, retailProgramObj.AssetID__r);
            }

            List<RetailProgramMasterItem__c> volumeAllList = new List<RetailProgramMasterItem__c>();
            List<RetailProgramMasterItem__c> volumeMasterItemList = new List<RetailProgramMasterItem__c>();
            List<RetailProgramMasterItem__c> bonusAllList = new List<RetailProgramMasterItem__c>();
            List<RetailProgramMasterItem__c> bonusMasterItemList = new List<RetailProgramMasterItem__c>();
            List<ReturnWrap> listVolume = new List<ReturnWrap>();
            List<ReturnWrap> listBonus = new List<ReturnWrap>();
            // Volume Incentive, Bonus 타입 드롭다운 옵션으로 넣기 위한 모든 리스트(AllList)와 바로 행 추가를 위한 이미 생성된(MasterItemList) 리스트 가져오기
            if (retailProgramObj.AssetID__r.Status == 'In Stock' || retailProgramObj.AssetID__r.Status == 'Registered') {

                // 드롭다운 모든 옵션 리스트 Get
                volumeAllList = queryMasterItemList(retailProgramObj.AssetID__r, 'Volume Incentive', nullSet, nullSet);
                volumeAllList = getMinimumAmount(volumeAllList);
                if(retailProgramObj.AssetID__r.Status == 'Registered') {
                    bonusAllList = queryMasterItemList(retailProgramObj.AssetID__r, 'Salesperson Bonus', nullSet, nullSet);
                    bonusAllList = getMinimumAmount(bonusAllList);
                }

                // 이미 생성된 리스트 Get
                if (!masterIdSet.isEmpty()) {
                    volumeMasterItemList = queryMasterItemList(retailProgramObj.AssetID__r, 'Volume Incentive', masterIdSet, productIdSet);
                    volumeMasterItemList = getMinimumAmount(volumeMasterItemList);
                    listVolume = getReturnWrap(volumeMasterItemList);

                    if(retailProgramObj.AssetID__r.Status == 'Registered') {
                        bonusMasterItemList = queryMasterItemList(retailProgramObj.AssetID__r, 'Salesperson Bonus', masterIdSet, productIdSet);
                        bonusMasterItemList = getMinimumAmount(bonusMasterItemList);
                        listBonus = getReturnWrap(bonusMasterItemList);
                    }
                }
            }

            // RetailProgram의 Asset의 레코드 타입이 Tractor일 경우 해당 Asset의 Loader와 Backhoe의 데이터 가져오기
            if (retailProgramObj.AssetID__r.RecordType.Name == 'Tractor') {

                // Rebate 타입 드롭다운 옵션 리스트 가져오기
                List<RetailProgramMasterItem__c> loaderNullList = queryMasterItemList(retailProgramObj.AssetID__r.LoaderId__r, 'Rebate', nullSet, nullSet);
                loaderNullList = getFlatRateAmount(loaderNullList, retailProgramObj.AssetID__r.LoaderId__r);
                if (!loaderNullList.isEmpty()) rebateAllList.addAll(loaderNullList);

                List<RetailProgramMasterItem__c> backhoeNullList = queryMasterItemList(retailProgramObj.AssetID__r.BackhoeId__r, 'Rebate', nullSet, nullSet);
                backhoeNullList = getFlatRateAmount(backhoeNullList, retailProgramObj.AssetID__r.BackhoeId__r);
                if (!backhoeNullList.isEmpty()) rebateAllList.addAll(backhoeNullList);

                // Rebate 타입 이미 생성된 리스트 가져오기
                List<RetailProgramMasterItem__c> loaderList = new List<RetailProgramMasterItem__c>();
                if (!masterIdSet.isEmpty()) loaderList = queryMasterItemList(retailProgramObj.AssetID__r.LoaderId__r, 'Rebate', masterIdSet, productIdSet);
                loaderList = getFlatRateAmount(loaderList, retailProgramObj.AssetID__r.LoaderId__r);
                if (!loaderList.isEmpty()) rebateMasterItemList.addAll(loaderList);

                List<RetailProgramMasterItem__c> backhoeList = new List<RetailProgramMasterItem__c>();
                if (!masterIdSet.isEmpty()) backhoeList = queryMasterItemList(retailProgramObj.AssetID__r.BackhoeId__r, 'Rebate', masterIdSet, productIdSet);
                backhoeList = getFlatRateAmount(backhoeList, retailProgramObj.AssetID__r.BackhoeId__r);
                if (!backhoeList.isEmpty()) rebateMasterItemList.addAll(backhoeList);

                listRebate = getReturnWrap(rebateMasterItemList);
            }

            Map<String, Object> returnMap = new Map<String, Object>{
                    'rebateAllList' => rebateAllList,
                    'rebateMasterItemList' => JSON.serialize(listRebate),
                    'volumeAllList' => volumeAllList,
                    'volumeMasterItemList' => JSON.serialize(listVolume),
                    'bonusAllList' => bonusAllList,
                    'bonusMasterItemList' => JSON.serialize(listBonus),
                    'retailProgram' => retailProgramObj
            };
            return returnMap;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description tym_RetailProgramReg 컴포넌트에서 등록한 데이터 Insert, Update, Delete
     * @param dataMap recordId, productId, payToDealer, rebateRadioValue, volumeRadioValue 데이터맵
     * @param deleteList 삭제 데이터 리스트
     * @param jsonData 등록할 RetailProgramItem json 데이터
     * @param deleteFileList 삭제 파일 Id 리스트
     */
    @AuraEnabled
    public static void upsertRetailProgramItem(Map<String, String> dataMap, String deleteList, String jsonData, List<String> deleteFileList) {
        try {
            List<DataWrap> dataWrapList = (List<DataWrap>) JSON.deserialize(jsonData, List<DataWrap>.class);

//            RetailProgram__c retailProgramObj = [SELECT Id, SalespersonId__c FROM RetailProgram__c WHERE Id = :dataMap.get('recordId')];
//            String salesPersonId = retailProgramObj.SalespersonId__c;

            Map<String, FileWrap> programIdMap = new Map<String, FileWrap>();
            Set<Id> programIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();
            for (DataWrap data : dataWrapList) {
                programIdMap.put(data.programId + data.productId, data.fileData);
                programIdSet.add(data.programId);
                productIdSet.add(data.productId);
            }

            // 이미 생성된 리스트 체크
            List<RetailProgramItem__c> programItemList = [
                    SELECT Id, RetailProgramID__c, Description__c, ProductID__c, Claimed__c, Adjusted__c, RetailProgramMasterID__c
                    FROM RetailProgramItem__c
                    WHERE RetailProgramID__c = :dataMap.get('recordId')
                    AND ProductID__c IN :productIdSet
                    AND RetailProgramMasterID__c IN :programIdSet
            ];
            Map<String, RetailProgramItem__c> programItemMap = new Map<String, RetailProgramItem__c>();
            for (RetailProgramItem__c item : programItemList) {
                programItemMap.put((String) item.RetailProgramMasterID__c + (String) item.ProductID__c, item);
            }

            String strAssetId = [SELECT AssetID__c FROM RetailProgram__c WHERE Id = :dataMap.get('recordId')].AssetID__c;
            System.debug('strAssetId :: ' + strAssetId);

            // RetailProgramItem__c Upsert 작업
            List<RetailProgramItem__c> createList = new List<RetailProgramItem__c>();
            List<RetailProgramItem__c> updateList = new List<RetailProgramItem__c>();
            for (DataWrap data : dataWrapList) {
                RetailProgramItem__c programItemObj = new RetailProgramItem__c();
//                Boolean isPayToDealer;
//                if (dataMap.get('payToDealer') == 'true') {
//                    isPayToDealer = true;
//                } else {
//                    isPayToDealer = false;
//                }
//                System.debug('data.payToDealer :: ' + data.payToDealer);
                Boolean isPayToDealer = data.payToDealer != null ? data.payToDealer : false;
                programItemObj.PayToDealer__c = isPayToDealer;
                programItemObj.RetailProgramID__c = dataMap.get('recordId');
                programItemObj.Asset__c = strAssetId;
                programItemObj.RetailProgramMasterID__c = data.programId;
                programItemObj.ProductID__c = data.productId;
                programItemObj.Description__c = data.description;
                if(!String.isBlank(data.salesperson)) programItemObj.SalespersonId__c = data.salesperson;
                programItemObj.IssueType__c = data.issueType;
//                programItemObj.SalespersonId__c = data.salesperson;
                programItemObj.Claimed__c = data.amount;
                programItemObj.Adjusted__c = data.manager;
                programItemObj.Unit__c = data.unit;
                programItemObj.Status__c = data.status;
                if (programItemMap.get(data.programId + data.productId) == null) {
                    createList.add(programItemObj);
                } else {
                    programItemObj.Id = programItemMap.get(data.programId + data.productId).Id;
                    updateList.add(programItemObj);
                }
                System.debug('programItemObj :: ' + programItemObj);
            }
            if (!createList.isEmpty()) insert createList;
            if (!updateList.isEmpty()) update updateList;
            List<RetailProgramItem__c> dmlList = new List<RetailProgramItem__c>();
            dmlList.addAll(createList);
            dmlList.addAll(updateList);

            // 파일 데이터 Upsert, RetailProgramMaster Update 작업
            List<RetailProgramItem__c> listAfterRPItem = [
                    SELECT Id, ProductID__c, RetailProgramMasterID__c, RetailProgramMasterID__r.IsAllowMultipleTimes__c, RetailProgramMasterID__r.IsActive__c
                    FROM RetailProgramItem__c
                    WHERE Id IN :dmlList
            ];
            Set<Id> itemIdSet = new Set<Id>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (RetailProgramItem__c item : listAfterRPItem) {
                ContentVersion cv = new ContentVersion();
                FileWrap file = programIdMap.get((String) item.RetailProgramMasterID__c + (String) item.ProductID__c);
                if (file != null) {
                    cv.Title = file.fileName;
                    cv.PathOnClient = file.fileName;
                    cv.FirstPublishLocationId = item.Id;
                    cv.VersionData = EncodingUtil.base64Decode(file.base64);
                    cvList.add(cv);
                    itemIdSet.add(item.Id);
                }
            }
            List<ContentVersion> cvChkList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId IN :itemIdSet OR Id IN :deleteFileList];
            if (!cvChkList.isEmpty()) {
                Set<Id> cdIdSet = new Set<Id>();
                for (ContentVersion cv : cvChkList) {
                    cdIdSet.add(cv.ContentDocumentId);
                }
                List<ContentDocument> deleteCvList = [SELECT Id FROM ContentDocument WHERE Id IN :cdIdSet];
                delete deleteCvList;
            }
            if (!cvList.isEmpty()) insert cvList;

            List<ContentVersion> listAfterCv = [SELECT Id, Title, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id IN :cvList];

            // File Contents 권한 문제로 ContentDistribution 생성
            List<ContentDistribution> listCdb = new List<ContentDistribution>();
            for (ContentVersion cv : listAfterCv) {
                ContentDistribution cdb = new ContentDistribution();
                cdb.ContentVersionId = cv.Id;
                cdb.Name = cv.Title;
                cdb.PreferencesAllowViewInBrowser = true;
                cdb.PreferencesLinkLatestVersion = true;
                cdb.PreferencesNotifyOnVisit = false;
                cdb.PreferencesPasswordRequired = false;
                cdb.PreferencesAllowOriginalDownload = true;
                cdb.RelatedRecordId = cv.FirstPublishLocationId;
                listCdb.add(cdb);
            }
            insert listCdb;

            // RetailProgram__c 데이터 Update 작업
            RetailProgram__c program = new RetailProgram__c();
            program.Id = dataMap.get('recordId');
            program.Status__c = 'Submitted';
            program.RebateIssueType__c = dataMap.get('rebateRadioValue');
            program.VolumeIssueType__c = dataMap.get('volumeRadioValue');

            update program;

            // 삭제할 데이터 Delete 작업
            List<DeleteWrap> deleteWrapList = (List<DeleteWrap>) JSON.deserialize(deleteList, List<DeleteWrap>.class);
            Set<Id> delProgramIdSet = new Set<Id>();
            Set<Id> delProductIdSet = new Set<Id>();
            for (DeleteWrap data : deleteWrapList) {
                delProgramIdSet.add(data.programId);
                delProductIdSet.add(data.productId);
            }
            List<RetailProgramItem__c> deleteProgramIdList = [
                    SELECT Id
                    FROM RetailProgramItem__c
                    WHERE RetailProgramID__c = :dataMap.get('recordId')
                    AND RetailProgramMasterID__c IN :delProgramIdSet
            ];
            List<RetailProgramItem__c> deleteProductIdList = [
                    SELECT Id
                    FROM RetailProgramItem__c
                    WHERE RetailProgramID__c = :dataMap.get('recordId')
                    AND ProductID__c IN :delProductIdSet
            ];
            Set<Id> chkIdSet = new Set<Id>();
            for (RetailProgramItem__c item : deleteProductIdList) {
                chkIdSet.add(item.Id);
            }
            List<RetailProgramItem__c> deleteProgramItemList = new List<RetailProgramItem__c>();
            for (RetailProgramItem__c item : deleteProgramIdList) {
                if (chkIdSet.contains(item.Id)) deleteProgramItemList.add(item);
            }
            delete deleteProgramItemList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description 조건별 RetailProgramMasterItem__c 가져오기 위한 Dynamic Query
     * @param asset RetailProgram의 Asset
     * @param type Rebate, Volume Incentive, Bonus 타입
     * @param masterIdSet 생성된 데이터 체크를 위한 RetailProgramMaster Id Set
     * @param productIdSet 생성된 데이터 체크를 위한 Product Id Set
     *
     * @return returnQuery
     */
    private static List<RetailProgramMasterItem__c> queryMasterItemList(Asset asset, String type, Set<Id> masterIdSet, Set<Id> productIdSet) {
        try {
            Id productId = asset != null ? asset.Product2Id : null;
//            if (registeredDate == null) return new List<RetailProgramMasterItem__c>();

            // 공통 쿼리문
            String query = ' SELECT Id, Amount__c, Unit__c, Discount__c, ProductID__c, ProductID__r.Name, ';
            query += ' RetailProgramID__r.Name, RetailProgramID__r.StartDate__c, RetailProgramID__r.EndDate__c, RetailProgramID__r.PricingStructure__c, RetailProgramID__r.IsAllowMultipleTimes__c, ';
            query += ' RetailProgramID__r.CriterionDate__c, RetailProgramID__r.IsFile__c, RetailProgramID__r.IsDealerCanEditClaimed__c, RetailProgramID__r.DaysFrom__c, RetailProgramID__r.DaysTo__c ';
            query += ' FROM RetailProgramMasterItem__c ';
            query += ' WHERE ProductID__c = :productId ';
            query += ' AND RetailProgramID__r.ProgramType__c = :type ';
//            query += ' AND RetailProgramID__r.StartDate__c <= :registeredDate ';
//            query += ' AND RetailProgramID__r.EndDate__c >= :registeredDate ';

            // 생성된 데이터 쿼리
            if (!masterIdSet.isEmpty() && !productIdSet.isEmpty()) {
                query += ' AND RetailProgramID__c IN :masterIdSet ';
                query += ' AND ProductID__c IN :productIdSet ';
            } else {
                query += ' AND RetailProgramID__r.IsActive__c = true ';
            }

            List<RetailProgramMasterItem__c> returnQuery = Database.query(query);

            List<RetailProgramItem__c> listRPItem = [SELECT Id, RetailProgramID__c, Asset__c, RetailProgramMasterID__c, ProductID__c FROM RetailProgramItem__c WHERE RetailProgramMasterID__r.IsActive__c = TRUE];
            Map<String, RetailProgramItem__c> mapRPItem = new Map<String, RetailProgramItem__c>();
            for (RetailProgramItem__c item : listRPItem) {
                mapRPItem.put((String) item.RetailProgramMasterID__c + (String) item.ProductID__c + (String) item.Asset__c, item);
            }

            Date retailedDate = asset != null ? asset.RetailedDate__c : null;
            Date registeredDate = asset != null ? asset.RegisteredDate__c : null;
            Date invoiceDate = asset != null ? asset.InvoiceDate__c : null;
            List<RetailProgramMasterItem__c> listReturn = new List<RetailProgramMasterItem__c>();
            // RetailProgramMaster의 기준 날짜로 가져오기
            for (RetailProgramMasterItem__c item : returnQuery) {
                RetailProgramItem__c objRPItem = mapRPItem.get((String) item.RetailProgramID__c + (String) item.ProductID__c + currentAssetId);
                if (objRPItem != null) {
                    if (objRPItem.RetailProgramID__c != currentId) {
                        if (!item.RetailProgramID__r.IsAllowMultipleTimes__c) continue;
                    }
                }
                String strCriterion = item.RetailProgramID__r.CriterionDate__c;
                Date criterionDate;
                if (strCriterion == 'Retail Date') {
                    criterionDate = retailedDate;
                } else if (strCriterion == 'Invoice Date') {
                    criterionDate = invoiceDate;
                } else if (strCriterion == 'Registered Date') {
                    criterionDate = registeredDate;
                }
                if (criterionDate == null) continue;

                if (item.RetailProgramID__r.StartDate__c <= criterionDate && criterionDate <= item.RetailProgramID__r.EndDate__c) {
                    listReturn.add(item);
                }
            }

            return listReturn;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description Volume Incentive 타입의 RetailProgramMasterItem__c 리스트들의 Payout Amount 최솟값 계산
     * @param masterItemList RetailProgramMasterItem__c 리스트
     *
     * @return masterItemList
     */
    private static List<RetailProgramMasterItem__c> getMinimumAmount(List<RetailProgramMasterItem__c> masterItemList) {
        try {
            Set<Id> itemIdSet = new Set<Id>();
            for (RetailProgramMasterItem__c item : masterItemList) {
                itemIdSet.add(item.RetailProgramID__c);
            }

            // RetailProgramID를 키로 하고 해당 RetailProgram에 대한 최소 Amount__c 값을 Value에 저장
            Map<Id, Decimal> RetailProgramAmountMap = new Map<Id, Decimal>();
            for (PayoutStructure__c payout : [SELECT RetailProgramID__c, Amount__c FROM PayoutStructure__c WHERE RetailProgramID__c IN :itemIdSet ORDER BY Amount__c ASC]) {
                if (!RetailProgramAmountMap.containsKey(payout.RetailProgramID__c) || RetailProgramAmountMap.get(payout.RetailProgramID__c) > payout.Amount__c) {
                    RetailProgramAmountMap.put(payout.RetailProgramID__c, payout.Amount__c);
                }
            }

            // 각 RetailProgram에 대한 최소 Amount__c 값 설정
            for (RetailProgramMasterItem__c item : masterItemList) {
                if (RetailProgramAmountMap.containsKey(item.RetailProgramID__c)) {
                    item.Amount__c = RetailProgramAmountMap.get(item.RetailProgramID__c) * item.Unit__c;
                }
            }
            return masterItemList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description 생성된 RetailProgramItem__c과 관련된 RetailProgramMasterItem__c 데이터로 RetailProgramItem__c 데이터와 관련 파일 데이터 가져오기
     * @param listItem 생성된 RetailProgramMasterItem__c 리스트
     *
     * @return listReturnWrap
     */
    private static List<ReturnWrap> getReturnWrap(List<RetailProgramMasterItem__c> listItem) {
        try {
            List<String> masterId = new List<String>();
            List<String> productId = new List<String>();
            Map<String, RetailProgramMasterItem__c> mapRPMasterItem = new Map<String, RetailProgramMasterItem__c>();
            for (RetailProgramMasterItem__c item : listItem) {
                masterId.add(item.RetailProgramID__c);
                productId.add(item.ProductID__c);
                mapRPMasterItem.put((String) item.RetailProgramID__c + (String) item.ProductID__c, item);
            }
            List<RetailProgramItem__c> listRPItem = [
                    SELECT Id, RetailProgramMasterID__c, ProductID__c, Status__c, Description__c, PayToDealer__c, IssueType__c,
                            SalespersonId__c, Claimed__c, Adjusted__c
                    FROM RetailProgramItem__c
                    WHERE RetailProgramMasterID__c IN :masterId
                    AND ProductID__c IN :productId
                    AND RetailProgramID__c = :currentId
            ];

            List<ContentDistribution> listCdb = [SELECT Id, Name, ContentVersionId, RelatedRecordId FROM ContentDistribution WHERE RelatedRecordId IN :listRPItem];
            Map<Id, ContentDistribution> mapContentVersion = new Map<Id, ContentDistribution>();
            for (ContentDistribution cdb : listCdb) {
                mapContentVersion.put(cdb.RelatedRecordId, cdb);
            }
            List<ReturnWrap> listReturnWrap = new List<ReturnWrap>();
            for (RetailProgramItem__c item : listRPItem) {
                ReturnWrap returnWrap = new ReturnWrap();
                returnWrap.objRPMasterItem = mapRPMasterItem.get((String) item.RetailProgramMasterID__c + (String) item.ProductID__c);
                returnWrap.objRPItem = item;
                returnWrap.objCdb = mapContentVersion.get(item.Id);
                listReturnWrap.add(returnWrap);
            }
            return listReturnWrap;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description RetailProgramMaster의 Pricing Structure 타입이 Flat Rate일 때 ARInvoiceItem의 Price를 가져오고 Discount 계산
     * @param listRPMasterItem RetailProgramMasterItem 리스트
     * @param objAsset 레코드 타입별 Asset
     *
     * @return listRPMasterItem
     */
    private static List<RetailProgramMasterItem__c> getFlatRateAmount(List<RetailProgramMasterItem__c> listRPMasterItem, Asset objAsset) {
        try {
            Map<String, Decimal> mapSNumPrice = new Map<String, Decimal>();
//            Set<Id> setOrdersId = new Set<Id>();
            List<RetailProgramMasterItem__c> listReturn = new List<RetailProgramMasterItem__c>();

            // Flat Rate 타입 Aged Inventory 포함되면 S/N 가져오기
            for (RetailProgramMasterItem__c masterItem : listRPMasterItem) {
                if (masterItem.RetailProgramID__r.PricingStructure__c == 'Flat Rate') {
                    String strCriterion = masterItem.RetailProgramID__r.CriterionDate__c;
                    Date criterionDate;
                    if (strCriterion == 'Retail Date') {
                        criterionDate = objAsset.RetailedDate__c;
                    } else if (strCriterion == 'Invoice Date') {
                        criterionDate = objAsset.InvoiceDate__c;
                    } else if (strCriterion == 'Registered Date') {
                        criterionDate = objAsset.RegisteredDate__c;
                    }
                    Integer daysBetween = 0;
                    if (criterionDate != null && objAsset.InvoiceDate__c != null) {
                        daysBetween = criterionDate.daysBetween(objAsset.InvoiceDate__c);
                    }
                    if (masterItem.RetailProgramID__r.DaysFrom__c <= daysBetween && daysBetween <= masterItem.RetailProgramID__r.DaysTo__c) {
                        mapSNumPrice.put(objAsset.SerialNumber, 0);
//                        setOrdersId.add(objAsset.OrdersId__c);
                        listReturn.add(masterItem);
                    }
                } else {
                    listReturn.add(masterItem);
                }
            }

            // Flat Rate 타입인 Master S/N로 ARInvoiceItem 조회
            List<ARInvoiceItem__c> listArItem = [
                    SELECT Id, SerialNumber__c, UnitPrice__c, ARInvoiceMaster__r.OrdersId__c
                    FROM ARInvoiceItem__c
                    WHERE SerialNumber__c IN :mapSNumPrice.keySet()
//                    AND ARInvoiceMaster__r.OrdersId__c IN :setOrdersId
            ];
            for (ARInvoiceItem__c item : listArItem) {
                if (item.SerialNumber__c == objAsset.SerialNumber/* && item.ARInvoiceMaster__r.OrdersId__c == objAsset.OrdersId__c*/) {
                    mapSNumPrice.put(item.SerialNumber__c, item.UnitPrice__c);
                }
            }

            // Flat Rate 타입인 Master Item 가격 계산
            for (RetailProgramMasterItem__c masterItem : listReturn) {
                if (masterItem.RetailProgramID__r.PricingStructure__c == 'Flat Rate') {
                    Decimal unitPrice = mapSNumPrice.get(objAsset.SerialNumber);
                    Decimal discount = masterItem.Discount__c * 0.01;
                    masterItem.Amount__c = unitPrice != null && discount != null ? unitPrice * discount : 0;
                }
            }

            return listReturn;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}