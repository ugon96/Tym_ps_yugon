/**
 * Created by 천유정 on 2023-10-30.
 */

public with sharing class PartsOrderItemCreateController {
    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId) {

        PartsOrder__c objPartsOrder;
        List<String> listLV1 = new List<String>();
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
                            ShippingMode__c, Memo__c, ShiptoAddressId__c, fm_Country__c, Discount__c, Price__c, Comment__c, Description__c,
                            TotalQuantity__c, TotalAmount__c, BilltoAddressID__c, TrackingNo__c, PaymentTermDev__c, Status__c, Remarks__c,
                            ResponsibilityID__c
                    FROM PartsOrder__c
                    WHERE Id =: recordId
            ];

            for (PartsOrderItem__c objParts : [SELECT Id, ProductId__c, Quantity__c, Price__c, fm_Amount__c
                                                FROM PartsOrderItem__c
                                                WHERE PartsOrderId__c =: recordId]) {
                listPartsOrderItem.add(objParts);
            }

            listLV1.add('TRACTOR');
            for(AggregateResult obj : [SELECT LV1__c FROM PartsHierarchy__c WHERE Lv1__c != 'TRACTOR' GROUP BY Lv1__c ORDER BY Lv1__c]) {
                listLV1.add(obj.get('Lv1__c').toString());
            }

            System.debug('listLV1' + listLV1);


        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('PartsOrderItemCreateController line : ' + e.getLineNumber());
            System.debug('PartsOrderItemCreateController message : ' + e.getMessage());
            System.debug('PartsOrderItemCreateController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'objPartsOrder' => objPartsOrder, 
                'listLV1' => listLV1,
                'listPartsOrderItem' => listPartsOrderItem,
                'isPartnerUser' => isPartnerUser,
                'isAdministratorUser' => isAdministratorUser,
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
    }

    @AuraEnabled
    public static Map<String, Object> getPartsHierarchy(String model, String lv1) {
        Map<String, Map<String,  Map<String, String>>> mapLv3 = new Map<String, Map<String,  Map<String, String>>>();
        Map<String, Map<String, String>> mapSection;
        List<String> listFigNo;
        Map<String, String> mapFigNo;
        List<String> listCodeAll = new List<String>();
        List<AggregateResult> listSearch = new List<AggregateResult>();
        String strStatus = 'SUCCESS';
        String strMessage = '';

        try {
            String strQuery = 'SELECT ';
            strQuery += ' Lv1__c, Lv2__c, Lv3__c, Section__c, SectionName__c, FigNo__c ';
            strQuery += ' FROM PartsHierarchy__c ';
            strQuery += ' WHERE Lv1__c = \'' + lv1 + '\'';
            strQuery += ' AND Lv3__c LIKE \'%' + model + '%\'';
            strQuery += ' GROUP BY  Lv1__c, Lv2__c, Lv3__c, Section__c, SectionName__c, FigNo__c ';
            System.debug('strQuery ==> ' + strQuery);
            listSearch = Database.query(strQuery);
            System.debug('listSearch.length  ==> ' + listSearch.size());

            if(!listSearch.isEmpty()) {
                for (AggregateResult obj : listSearch) {
                    mapFigNo = new Map<String, String>();
                    if(mapSection <> null && mapSection.get(String.valueOf(obj.get('SectionName__c'))) <> null) {
                        mapFigNo = mapSection.get(String.valueOf(obj.get('SectionName__c')));
                    } else {
                        mapSection = new Map<String, Map<String, String>>();
                    }
                    if(mapLv3 <> null && mapLv3.get(String.valueOf(obj.get('Lv3__c'))) <> null) {
                        mapSection = mapLv3.get(String.valueOf(obj.get('Lv3__c')));
                    }
                    mapFigNo.put(String.valueOf(obj.get('FigNo__c')), String.valueOf(obj.get('FigNo__c')));
                    mapSection.put(String.valueOf(obj.get('SectionName__c')), mapFigNo);
                    mapLv3.put(String.valueOf(obj.get('Lv3__c')), mapSection);
                }
            }
            System.debug('mapLv3 ' + mapLv3);
        } catch (Exception e) {
            strStatus = 'ERROR';
            System.debug('PartsOrderItemCreateController line : ' + e.getLineNumber());
            System.debug('PartsOrderItemCreateController message : ' + e.getMessage());
            System.debug('PartsOrderItemCreateController cause : ' + e.getCause());
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'mapLv3' => mapLv3
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
}