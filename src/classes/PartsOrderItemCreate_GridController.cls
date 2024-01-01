/**
 * Created by 천유정 on 2023-12-01.
 */

public with sharing class PartsOrderItemCreate_GridController {
    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId) {

        PartsOrder__c objPartsOrder;
        String priceList = '';
        Integer orderTypeRate = 0;
        Integer discountRate = 0;
        List<PartsOrderItem__c> listPartsOrderItem = new List<PartsOrderItem__c>();
        String strStatus = 'SUCCESS';
        String strMessage = '';

        //Edit 권한 설정
        Boolean isPartnerUser;
        Boolean isAdministratorUser;

        try {
            //Custom Setting : System Administrator Id값
            UtilObject__c utilObject = UtilObject__c.getOrgDefaults();

            isPartnerUser = UserInfo.getUserType().contains('Partner')? true : false;
            isAdministratorUser = UserInfo.getProfileId().equalsIgnoreCase(utilObject.AdminProfileId__c)? true : false;

            objPartsOrder = [
                    SELECT Id, Name, CreatedDate, DealershipId__c, SalespersonId__c, fm_CompanyCode__c, OrderType__c, PartialShipment__c,
                            ShippingMode__c, Memo__c, ShiptoAddressId__c, fm_Country__c, Discount__c, Comment__c, Description__c,
                            TotalQuantity__c, TotalAmount__c, BilltoAddressID__c, TrackingNo__c, PaymentTermDev__c, Status__c, Remarks__c,
                            ResponsibilityID__c, DealershipId__r.PriceListParts__c, DealershipId__r.PriceListParts__r.BasePriceList__c,
                            DealershipId__r.PriceListParts__r.Factor__c, ru_TotalAmount__c
                    FROM PartsOrder__c
                    WHERE Id =: recordId
            ];

            if (objPartsOrder.DealershipId__r.PriceListParts__c == null) {
                priceList = null;
            } else {
                priceList = objPartsOrder.DealershipId__r.PriceListParts__r.BasePriceList__c == null? objPartsOrder.DealershipId__r.PriceListParts__c : objPartsOrder.DealershipId__r.PriceListParts__r.BasePriceList__c;
            }

            switch on (objPartsOrder.OrderType__c) {
                when 'Level 1 Stock order' {
                    orderTypeRate = 5;
                }
                when 'Level 2 Stock order' {
                    orderTypeRate = 10;
                }
                when 'Level 3 Stock order' {
                    orderTypeRate = 15;
                }
            }

            switch on (objPartsOrder.Discount__c) {
                when 'Within 7 Days' {
                    discountRate = 7;
                }
                when 'Within 30 Days' {
                    discountRate = 17;
                }
            }
            for (PartsOrderItem__c objParts : [SELECT Id, ProductId__c, Quantity__c, Price__c, fm_Amount__c, ProductId__r.Name, ProductId__r.ProductCode,
                                                Replacement__c, Replacement__r.Name, Replacement__r.ProductCode, fm_PartsDescription__c, fm_OnHand__c
                                            FROM PartsOrderItem__c
                                            WHERE PartsOrderId__c =: recordId]) {
                listPartsOrderItem.add(objParts);
            }

            System.debug('Pricelist => ' + priceList);
        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('PartsOrderItemCreateController line : ' + e.getLineNumber());
            System.debug('PartsOrderItemCreateController message : ' + e.getMessage());
            System.debug('PartsOrderItemCreateController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'objPartsOrder' => objPartsOrder,
                'factor' => objPartsOrder.DealershipId__r.PriceListParts__r.Factor__c,
                'listPartsOrderItem' => listPartsOrderItem,
                'isPartnerUser' => isPartnerUser,
                'isAdministratorUser' => isAdministratorUser,
                'priceList' => priceList,
                'orderType' => objPartsOrder.OrderType__c,
                'orderTypeRate' => orderTypeRate,
                'discount' => objPartsOrder.Discount__c,
                'discountRate' => discountRate,
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    @AuraEnabled
    public static Map<String, Object> doSearchParts(String lv3, String section, String figNo){
        System.debug('doSearchParts ==== Start!');

        String strStatus = 'SUCCESS';
        String strMessage = '';
        List<PartsHierarchy__c> listParts = new List<PartsHierarchy__c>();
        try {
            System.debug('lv3 => ' + lv3);
            System.debug('section => ' + section);
            System.debug('figNo => ' + figNo);
            for (PartsHierarchy__c obj : [
                    SELECT Id, No1__c, ProductId__c, SupplyPartId__c, fm_PartName__c, fm_ohHand__c, fm_PartNo__c, fm_suppliedPartNo__c
                    FROM PartsHierarchy__c
                    WHERE Lv3__c =: lv3
                    AND SectionName__c =: section
                    AND FigNo__c =: figNo
            ]) {
                listParts.add(obj);
            }

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }
        System.debug('doSearchParts ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'listParts' => listParts
        };
        return mapReturn;
    }

    /**
     * @description Product 선택 시, Price List의 Factor를 곱한 Dealer Price 가져오기
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
        Decimal onHand = 0.0;
        String description = '';
        try {
            System.debug('getPartsValue :: ProductId ======> ' + productId);
            System.debug('getPartsValue :: PriceListId ======> ' + priceListId);
            System.debug('getPartsValue :: Factor ======> ' + factor);
            List<PriceListEntry__c> listPriceListEntry = [
                    SELECT Id, ListPrice__c, ProductID__r.Name, ProductID__r.ProductName__c, ProductID__r.onHand__c
                    FROM PriceListEntry__c
                    WHERE ProductID__c =: productId
                    AND PriceListID__c =: priceListId
            ];

            if (!listPriceListEntry.isEmpty()) {
                System.debug('getPartsValue :: ListPrice__c ======> ' + listPriceListEntry.get(0).ListPrice__c);
                price = (listPriceListEntry.get(0).ListPrice__c * factor).setScale(0, RoundingMode.HALF_UP);
                description = listPriceListEntry.get(0).ProductID__r.ProductName__c;
                onHand = listPriceListEntry.get(0).ProductID__r.onHand__c;
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
                'onHand' => onHand,
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
    public static Map<String, Object> saveRecord(String listPartsOrderItem, String listPartsOrderItemDeleted) {

        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            System.debug('saveRecord ===> listPartsOrderItem ::: ' + listPartsOrderItem);
            System.debug('saveRecord ===> listPartsOrderItemDeleted ::: ' + listPartsOrderItemDeleted); 

            // Upsert : Parts
            List<PartsOrderItem__c> listObjParts = (List<PartsOrderItem__c>) JSON.deserialize(listPartsOrderItem, List<PartsOrderItem__c>.class);
            System.debug('saveRecord ===> Upserted Parts ::: ' + listObjParts);
            upsert listObjParts;

            // Delete : Parts
            List<PartsOrderItem__c> listDeleteTargetIdParts = new List<PartsOrderItem__c>();
            if (listPartsOrderItemDeleted.length() > 0) {
                listDeleteTargetIdParts = (List<PartsOrderItem__c>) JSON.deserialize(listPartsOrderItemDeleted, List<PartsOrderItem__c>.class);
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
     * @description Product 선택 시, Price List의 Factor를 곱한 Dealer Price 가져오기
     * @param productId
     * @param priceListId
     * @param factor
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> doCheckout (String recordId, String param, Decimal totalPrice) {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        try {
            PartsOrder__c objPartsOrder;
            objPartsOrder = new PartsOrder__c(Id=recordId, Status__c='Submitted', TotalAmount__c=totalPrice);
//            if (param == 'warning') {
//                objPartsOrder = new PartsOrder__c(Id=recordId, Status__c='Submitted', OrderType__c='Daily', TotalAmount__c=totalPrice);
//            } else {
//                objPartsOrder = new PartsOrder__c(Id=recordId, Status__c='Submitted', TotalAmount__c=totalPrice);
//            }
            update objPartsOrder;
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

}