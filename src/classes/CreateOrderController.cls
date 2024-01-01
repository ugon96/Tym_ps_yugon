/************************************************************************************
 * File Name   		: CreateOrderController
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-11-03
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-03       ugon96@gmail.com         Initial Version
*************************************************************************************/

public without sharing class CreateOrderController {
    @AuraEnabled
    public static String getIsPortalUser() {
        try {
            List<Profile> listProfile = new List<Profile>([SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()]);
            if (listProfile != null && listProfile.size() > 0) {
                if (listProfile.get(0).Name.contains('Dealer') || listProfile.get(0).Name.contains('Partner Community')) {
                    return 'true';
                } else {
                    return 'false';
                }
            }
            return 'true';
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return 'true';
        }
    }
    @AuraEnabled
    public static Map<String, Object> getData(String recordId) {
        Map<String, Object> mapResult = new Map<String, Object>();

        try {
            List<Orders__c> listOrder = [SELECT Id, Dealership__r.PriceListId__c, PaymentTerms__c, Status__c, Discount__c FROM Orders__c WHERE Id = :recordId];
            System.debug('listOrder.get(0).Dealership__r.PriceListId__c :: ' + listOrder.get(0).Dealership__r.PriceListId__c);

            Orders__c objOrder = listOrder.get(0);
            System.debug('objOrder :: ' + objOrder);
            if (objOrder.Dealership__r.PriceListId__c != null) {
                List<PriceList__c> listPriceList = [SELECT Id, BasePriceList__c FROM PriceList__c WHERE Id = :objOrder.Dealership__r.PriceListId__c];
                String priceListId;
                if (listPriceList.get(0).BasePriceList__c == null) {
                    priceListId = listPriceList.get(0).Id;
                } else {
                    priceListId = listPriceList.get(0).BasePriceList__c;
                }

                mapResult.put('priceListId', priceListId);
            } else {
                mapResult.put('priceListId', null);
            }

            mapResult.put('modelOptions', null);
            mapResult.put('paymentTerm', objOrder.PaymentTerms__c);
            mapResult.put('orderStatus', objOrder.Status__c);

            List<AggregateResult> listAG = new List<AggregateResult>([
                    SELECT Parent__r.Name
                    FROM ProductHierarchy__c
                    WHERE Parent__r.ItemGroupCode__c = '112'
                    AND Child__r.ItemGroupCode__c = '112'
                    GROUP BY Parent__r.Name
            ]);

            if (listAG.size() > 0) {
                List<String> listProductCode = new List<String>();
                for (AggregateResult objAG : listAG) {
                    listProductCode.add(String.valueOf(objAG.get('Name')));
                }
                mapResult.put('modelOptions', listProductCode);
            }
            List<ProductOrderSummary__c> listPOS = new List<ProductOrderSummary__c>([
                    SELECT Id, Orders__c, Quantity__c, Note__c, IsRetailed__c, IsAssembled__c, PONumber__c, Subtotal__c, (
                            SELECT Id, OrdersId__c, ProductOrderSummary__c, ProductId__c, ProductId__r.Name, ProductId__r.ConfigurationName__c, IsAssembled__c, Type__c
                            FROM ProductOrderItem__r
                    )
                    FROM ProductOrderSummary__c
                    WHERE Orders__c = :recordId
            ]);
            System.debug('listPOS :: ' + listPOS);

            List<OrderSummaryItemController.OrderSummaryWrapper> listOrderSummary = new List<OrderSummaryItemController.OrderSummaryWrapper>();
            for (ProductOrderSummary__c objPOS : listPOS) {
                OrderSummaryItemController.OrderSummaryWrapper objOSW = new OrderSummaryItemController.OrderSummaryWrapper();
                objOSW.Id = objPOS.Id;
                objOSW.qty = Integer.valueOf(objPOS.Quantity__c);
                objOSW.isAssembled = objPOS.IsAssembled__c;
                objOSW.notes = objPOS.Note__c;
                objOSW.isRetailed = objPOS.IsRetailed__c;
                objOSW.poNumber = objPOS.PONumber__c;
                objOSW.subtotal = objPOS.Subtotal__c;
                objOSW.listOptions = new List<OrderSummaryItemController.ProductOrderItem>();
                OrderSummaryItemController.ProductOrderItem objTirePOIW = new OrderSummaryItemController.ProductOrderItem();
                String fTireName = '';
                String rTireName = '';
                String fTireSummaryId = null;
                String rTireSummaryId = null;
                for (ProductOrderItem__c objPOI : objPOS.ProductOrderItem__r) {
                    OrderSummaryItemController.ProductOrderItem objPOIW = new OrderSummaryItemController.ProductOrderItem();
                    objPOIW.Id = objPOI.Id;
                    objPOIW.value = objPOI.ProductId__c;
                    objPOIW.isAssembled = objPOI.IsAssembled__c;
                    objPOIW.label = objPOI.ProductId__r.Name;
                    objPOIW.checked = true;
                    if (objPOI.Type__c == 'Tractor') {
                        /** TODO
                         * 데이터 잘 들어가는지 확인을 위해 임시로 Name을 넣음.
                         * 원래는 ConfigurationName__c 이 맞음
                         * 20231201 hyg
                        */
//                        objPOIW.configName = objPOI.ProductId__r.ConfigurationName__c;
                        objPOIW.configName = objPOI.ProductId__r.Name;
                        objOSW.objTractor = objPOIW;
                    } else if (objPOI.Type__c == 'F-Tire') {
                        objTirePOIW.isAssembled = objPOI.IsAssembled__c;
                        objTirePOIW.checked = true;
                        objTirePOIW.parent = objPOI.ProductId__c;
                        fTireSummaryId = objPOI.Id;
                        fTireName = objPOI.ProductId__r.Name;
                    } else if (objPOI.Type__c == 'R-Tire') {
                        objTirePOIW.child = objPOI.ProductId__c;
                        rTireSummaryId = objPOI.Id;
                        rTireName = objPOI.ProductId__r.Name;
                    } else if (objPOI.Type__c == 'Loader') {
                        objOSW.objLoader = objPOIW;
                    } else if (objPOI.Type__c == 'Backhoe') {
                        objOSW.objBackhoe = objPOIW;
                    } else if (objPOI.Type__c == 'Mower') {
                        objOSW.objMower = objPOIW;
                    } else {
                        objOSW.listOptions.add(objPOIW);
                    }
                }
                if (fTireSummaryId != '') {
                    System.debug('fTireSummaryId :: ' + fTireSummaryId);
                    System.debug('rTireSummaryId :: ' + rTireSummaryId);
                    objTirePOIW.label = fTireName + ' - ' + rTireName;
                    objTirePOIW.Id = fTireSummaryId + '-' + rTireSummaryId;
                    objTirePOIW.value = objTirePOIW.parent + '-' + objTirePOIW.child;
                    objOSW.objTires = objTirePOIW;
                }

                listOrderSummary.add(objOSW);
            }
            if (listOrderSummary.size() > 0) {
                System.debug('listOrderSummary :: ' + listOrderSummary);
                mapResult.put('listOrderSummary', JSON.serialize(listOrderSummary));
            } else {
                mapResult.put('listOrderSummary', null);
            }
            if (objOrder.Discount__c != null) {
                mapResult.put('discount', objOrder.Discount__c);
            } else {
                mapResult.put('discount', 0);
            }

            mapResult.put('status', 'SUCCESS');
            return mapResult;
            /*else {
                mapResult.put('status', 'ERROR');
                mapResult.put('message', 'Price List is not set in Dealership.');
                return mapResult;
            }*/
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            mapResult.put('status', 'ERROR');
            mapResult.put('message', 'Error :: ' + e.getMessage());
            return mapResult;
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> getConfiguration(String tractorProductCode, String priceListId) {
        try {
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'112\'';
            if (tractorProductCode != 'Implements/Tires') {
                strQuery += ' AND Parent__r.Name = :tractorProductCode';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                System.debug('setProductId :: ' + setProductId);

                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                System.debug('listPLE :: ' + listPLE);
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();
                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    /**
     * Tire의 경우 F-Tire와 R-Tire 가 한 쌍을 이루기 때문에 Value를 PH로 한다.
     * 이때 Parent와 Child 의 ProductId값도 따로 저장해둔다.
     * @return
     */
    @AuraEnabled
    public static List<Map<String, Object>> getTire(String selectModel, String priceListId) {
        try {
            System.debug('selectModel :: ' + selectModel);
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'115\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__r.Name = :selectModel';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);


            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();
                Set<Id> setFTireId = new Set<Id>();

                for (ProductHierarchy__c objPH : listPH) {
                    setFTireId.add(objPH.Child__c);
                }

                strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                        ' FROM ProductHierarchy__c' +
                        ' WHERE Parent__c = :setFTireId ' +
                        ' AND Child__r.ItemGroupCode__c = \'116\'';

                List<ProductHierarchy__c> listTirePH = Database.query(strQuery);

                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listTirePH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                    if (objPH.Parent__c != null) {
                        setProductId.add(objPH.Parent__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listTirePH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Parent__r.Name + ' - ' + objPH.Child__r.Name);
                    objMap.put('parent', objPH.Parent__c);
                    objMap.put('child', objPH.Child__c);
                    objMap.put('value', objPH.Parent__c + '-' + objPH.Child__c);
                    Double price = (mapProductToPrice.get(objPH.Parent__c) != null ? mapProductToPrice.get(objPH.Parent__c) : 0)
                            + (mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    objMap.put('price', price);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }


    @AuraEnabled
    public static List<Map<String, Object>> getLoader(String tractorId, String selectModel, String priceListId) {
        try {
            System.debug('selectModel :: ' + selectModel);
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'113\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__c = :tractorId';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();

                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static List<Map<String, Object>> getBackhoe(String tractorId, String selectModel, String priceListId) {
        try {
            System.debug('selectModel :: ' + selectModel);
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'114\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__c = :tractorId';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();

                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static List<Map<String, Object>> getMower(String tractorId, String selectModel, String priceListId) {
        try {
            System.debug('selectModel :: ' + selectModel);
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'120\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__c = :tractorId';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();
                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> getCabin(String tractorId, String selectModel, String priceListId) {
        try {
            System.debug('selectModel :: ' + selectModel);
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'121\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__c = :tractorId';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();
                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> getOption(String tractorId, String selectModel, String priceListId) {
        try {
            String strQuery = 'SELECT Id, Parent__c, Parent__r.Name, Child__c, Child__r.Name' +
                    ' FROM ProductHierarchy__c' +
                    ' WHERE Child__r.ItemGroupCode__c = \'118\'';
            if (selectModel != 'Implements/Tires') {
                strQuery += ' AND Parent__c = :tractorId';
            }
            List<ProductHierarchy__c> listPH = Database.query(strQuery);

            if (listPH.size() > 0) {
                List<Map<String, Object>> listPicklist = new List<Map<String, Object>>();
                Set<Id> setProductId = new Set<Id>();
                for (ProductHierarchy__c objPH : listPH) {
                    if (objPH.Child__c != null) {
                        setProductId.add(objPH.Child__c);
                    }
                }
                List<PriceListEntry__c> listPLE = [SELECT Id, ProductID__c, ListPrice__c FROM PriceListEntry__c WHERE ProductID__c = :setProductId AND PriceListID__c = :priceListId];
                Map<String, Decimal> mapProductToPrice = new Map<String, Decimal>();
                for (PriceListEntry__c objPLE : listPLE) {
                    mapProductToPrice.put(objPLE.ProductID__c, objPLE.ListPrice__c);
                }

                for (ProductHierarchy__c objPH : listPH) {
                    Map<String, Object> objMap = new Map<String, Object>();
                    objMap.put('label', objPH.Child__r.Name);
                    objMap.put('value', objPH.Child__c);
                    objMap.put('price', mapProductToPrice.get(objPH.Child__c) != null ? mapProductToPrice.get(objPH.Child__c) : 0);
                    listPicklist.add(objMap);
                }
                return listPicklist;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static Map<String, String> doSaveOrderItem(String recordId, String listOrderSummary, Double extendedAmount) {
        try {
            Map<String, String> mapResult = new Map<String, String>();
            System.debug('listOrderSummary :: ' + listOrderSummary);
//            List<Object> listMap = (List<Object>)JSON.deserializeUntyped(listOrderSummary);
//            System.debug('listMap :: '+ listMap);
            List<OrderSummaryItemController.OrderSummaryWrapper> listSummaryWrappers = (List<OrderSummaryItemController.OrderSummaryWrapper>) JSON.deserialize(listOrderSummary, List<OrderSummaryItemController.OrderSummaryWrapper>.class);
            Orders__c objOrder = new Orders__c(
                    Id = recordId,
                    TotalAmount__c = extendedAmount
            );
            update objOrder;
            System.debug('listSummaryWrappers :: ' + listSummaryWrappers);
            List<ProductOrderSummary__c> listUpsertPOS = new List<ProductOrderSummary__c>();
            List<ProductOrderItem__c> listUpsertPOI = new List<ProductOrderItem__c>();
            Map<ProductOrderSummary__c, List<ProductOrderItem__c>> mapPOStoPOI = new Map<ProductOrderSummary__c, List<ProductOrderItem__c>>();
            for (OrderSummaryItemController.OrderSummaryWrapper objWrapper : listSummaryWrappers) {
                ProductOrderSummary__c objPOS = new ProductOrderSummary__c(
                        Id = objWrapper.Id,
                        Orders__c = recordId,
                        Quantity__c = objWrapper.qty,
                        Note__c = objWrapper.notes,
                        IsRetailed__c = objWrapper.isRetailed,
                        PONumber__c = objWrapper.poNumber,
                        Subtotal__c = objWrapper.subtotal
                );
                if (objWrapper.objTractor != null) {
                    objPOS.IsAssembled__c = true;
                }
                listUpsertPOS.add(objPOS);
            }
            if (listUpsertPOS.size() > 0) {
                upsert listUpsertPOS;
                Integer idx = 0;
                for (OrderSummaryItemController.OrderSummaryWrapper objWrapper : listSummaryWrappers) {
                    Id summaryId = listUpsertPOS[idx++].Id;
                    if (objWrapper.objTractor != null) {
                        ProductOrderItem__c objPOI = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = objWrapper.objTractor.value,
                                Id = objWrapper.objTractor.Id,
                                IsAssembled__c = objWrapper.objTractor.isAssembled != null ? objWrapper.objTractor.isAssembled : false,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'Tractor'
                        );
                        listUpsertPOI.add(objPOI);
                    }
                    if (objWrapper.objTires != null) {
                        List<String> listOrderItemId = new List<String>();
                        List<String> listTireProductId = objWrapper.objTires.value.split('-');
                        System.debug('objWrapper.objTires.Id :: ' + objWrapper.objTires.Id);
                        System.debug('objWrapper.objTires.value :: ' + objWrapper.objTires.value);

                        if (objWrapper.objTires.Id == null) {
                            listOrderItemId.add(null);
                            listOrderItemId.add(null);
                        } else {
                            listOrderItemId = objWrapper.objTires.Id.split('-');
                        }

                        ProductOrderItem__c objFTire = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = listTireProductId.get(0),
                                Id = listOrderItemId.get(0),
                                IsAssembled__c = objWrapper.objTires.isAssembled,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'F-Tire'
                        );
                        listUpsertPOI.add(objFTire);
                        ProductOrderItem__c objRTire = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = listTireProductId.get(1),
                                Id = listOrderItemId.get(1),
                                IsAssembled__c = objWrapper.objTires.isAssembled,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'R-Tire'
                        );
                        listUpsertPOI.add(objRTire);
                    }
                    if (objWrapper.objLoader != null) {
                        ProductOrderItem__c objPOI = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = objWrapper.objLoader.value,
                                Id = objWrapper.objLoader.Id,
                                IsAssembled__c = objWrapper.objLoader.isAssembled != null ? objWrapper.objLoader.isAssembled : false,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'Loader'
                        );
                        listUpsertPOI.add(objPOI);
                    }
                    if (objWrapper.objBackhoe != null) {
                        ProductOrderItem__c objPOI = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = objWrapper.objBackhoe.value,
                                Id = objWrapper.objBackhoe.Id,
                                IsAssembled__c = objWrapper.objBackhoe.isAssembled,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'Backhoe'
                        );
                        listUpsertPOI.add(objPOI);
                    }
                    if (objWrapper.objMower != null) {
                        ProductOrderItem__c objPOI = new ProductOrderItem__c(
                                OrdersId__c = recordId,
                                ProductOrderSummary__c = summaryId,
                                ProductId__c = objWrapper.objMower.value,
                                Id = objWrapper.objMower.Id,
                                IsAssembled__c = objWrapper.objMower.isAssembled != null ? objWrapper.objMower.isAssembled : false,
                                Quantity__c = objWrapper.qty,
                                Type__c = 'Mower'
                        );
                        listUpsertPOI.add(objPOI);
                    }
                    if (objWrapper.listOptions != null) {
                        for (OrderSummaryItemController.ProductOrderItem objWrapItem : objWrapper.listOptions) {
                            ProductOrderItem__c objPOI = new ProductOrderItem__c(
                                    OrdersId__c = recordId,
                                    ProductOrderSummary__c = summaryId,
                                    ProductId__c = objWrapItem.value,
                                    Id = objWrapItem.Id,
                                    IsAssembled__c = objWrapItem.isAssembled != null ? objWrapItem.isAssembled : false,
                                    Quantity__c = objWrapper.qty,
                                    Type__c = 'Option'
                            );
                            listUpsertPOI.add(objPOI);
                        }
                    }
                }
                if (listUpsertPOI.size() > 0) {
                    System.debug(listUpsertPOI);
                    upsert listUpsertPOI;
                }
            }
            List<ProductOrderItem__c> listDeletePOI = new List<ProductOrderItem__c>([
                    SELECT Id
                    FROM ProductOrderItem__c
                    WHERE OrdersId__c = :recordId
                    AND Id != :listUpsertPOI
            ]);
            if (listDeletePOI.size() > 0) {
                delete listDeletePOI;
            }

            List<ProductOrderSummary__c> listDeletePOS = new List<ProductOrderSummary__c>([
                    SELECT Id
                    FROM ProductOrderSummary__c
                    WHERE Orders__c = :recordId
                    AND Id != :listUpsertPOS
            ]);
            if (listDeletePOS.size() > 0) {
                delete listDeletePOS;
            }

            return mapResult;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String doCheckOrderStatus(String recordId) {
        try {
            List<Orders__c> listOrder = [SELECT Id, Status__c FROM Orders__c WHERE Id = :recordId];
            if (listOrder.size() > 0) {
                return listOrder.get(0).Status__c;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String doSubmit(String recordId) {
        String result = null;
        try {
            result = 'success';
            Orders__c objOrder = new Orders__c(
                    Id = recordId,
                    Status__c = 'Submitted'
            );
            update objOrder;
            return result;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static String getTractorImage(String productId) {
        System.debug('getTractorImage start');
        try {
            String imgUrl = '';
            List<Product2> listProduct2 = [SELECT Id, ImageUrl__c FROM Product2 WHERE Id = :productId];
            if (listProduct2 != null && listProduct2.size() > 0) {
                if (listProduct2.get(0).ImageUrl__c != null) {
                    imgUrl = listProduct2.get(0).ImageUrl__c;
                }
            }
            return imgUrl;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }

}