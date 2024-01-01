/**
 * Created by nhkim on 2023-12-01.
 */

public with sharing class PostSalesOrderButtonController {

    @AuraEnabled
    public static Boolean doInit(String recordId) {
        try {
            Orders__c objOrder = [SELECT Id, IsConfirmedOrder__c FROM Orders__c WHERE Id = :recordId LIMIT 1];
            return objOrder.isConfirmedOrder__c;
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static Map<String, String> doConfirmationOrder(String recordId) {
        System.debug('recordId :: ' + recordId);

        Map<String, String> mapResult = new Map<String, String>();
        mapResult.put('status', 'success');
        try {
            // Additional Option 이 장착되지 않는 Finished Goods 제품의 코드별 수량.
            Map<String, Integer> mapQuantityByFinishedGoodsIdWithoutAdditionOption = new Map<String, Integer>();
            // Additional Option 이 장착되는 Finished Goods 제품의 코드별 수량.
            Map<String, Integer> mapQuantityByFinishedGoodsIdWithAdditionalOption = new Map<String, Integer>();
            // Finished Goods 에 조립되는 Additional Option 의 product Id 리스트(List)
            Map<String, Set<Id>> mapSetProductIdByFinishedGoodsCode = new Map<String, Set<Id>>();

            // 조립되지 않는 Attachment(Loader,Backhoe,Tire)의 Product Id별 수량
            Map<Id, Integer> mapQuantityByDisAssembledAttachmentProductId = new Map<Id, Integer>();
            // 조립되지 않는 Additional Option 들의 Product Id별 수량
            Map<Id, Integer> mapQuantityByDisAssembledOptionProductId = new Map<Id, Integer>();

            Map<Id, String> mapProductTypeById = new Map<Id, String>();

            List<Orders__c> listParentOrders = new List<Orders__c>([
                    SELECT Id, Dealership__c, PaymentTerms__c, ShiptoAddressID__c, Salesperson__c, BilltoAddressID__c,
                            Status__c, Dealership__r.PriceListParts__c
                    FROM Orders__c
                    WHERE Id = :recordId
            ]);
            Orders__c parentOrder = listParentOrders.get(0);

            List<ProductOrderSummary__c> listPOS = new List<ProductOrderSummary__c>(
            [
                    SELECT Id, Orders__r.Discount__c, IsAssembled__c, Quantity__c, (
                            SELECT Id, ProductId__c, ProductId__r.ProductName__c, ProductOrderSummary__c, OrdersId__c,
                                    IsAssembled__c, Quantity__c, Type__c
                            FROM ProductOrderItem__r
                    )
                    FROM ProductOrderSummary__c
                    WHERE Orders__c = :recordId
            ]);
            System.debug(listPOS);

            List<String> listFinGoodsId = new List<String>();
            for (ProductOrderSummary__c objPOS : listPOS) {
                System.debug(objPOS.ProductOrderItem__r);
                // 트랙터를 주문하는 경우
                if (objPOS.IsAssembled__c) {
                    // 각 제품들의 product code 를 저장해두고 조립해 finished goods 를 찾는다.
                    String tractorProdId;
                    String loaderProdId;
                    String backhoeProdId;
                    String fTireProdId;
                    String rTireProdId;
                    Set<Id> setAdditionalOptionProductId = new Set<Id>();
                    for (ProductOrderItem__c objPOI : objPOS.ProductOrderItem__r) {
                        mapProductTypeById.put(objPOI.Id, objPOI.Type__c);
                        if (objPOI.Type__c == 'Tractor') {
                            tractorProdId = objPOI.ProductId__c;
                        } else if (objPOI.Type__c == 'Loader') {
                            if (objPOI.IsAssembled__c) {
                                loaderProdId = objPOI.ProductId__c;
                                System.debug('objPOI.ProductId__c :: ' + objPOI.ProductId__c);
                            } else {
                                Integer qty = mapQuantityByDisAssembledAttachmentProductId.get(objPOI.ProductId__c);
                                if (qty == null) {
                                    qty = 0;
                                }
                                qty += Integer.valueOf(objPOI.Quantity__c);
                                mapQuantityByDisAssembledAttachmentProductId.put(objPOI.ProductId__c, qty);
                            }
                        } else if (objPOI.Type__c == 'Backhoe') {
                            if (objPOI.IsAssembled__c) {
                                backhoeProdId = objPOI.ProductId__c;
                            } else {
                                Integer qty = mapQuantityByDisAssembledAttachmentProductId.get(objPOI.ProductId__c);
                                if (qty == null) {
                                    qty = 0;
                                }
                                qty += Integer.valueOf(objPOI.Quantity__c);
                                mapQuantityByDisAssembledAttachmentProductId.put(objPOI.ProductId__c, qty);
                            }
                        } else if (objPOI.Type__c == 'F-Tire') {
                            // 트랙터 주문시 타이어는 무조건 조립
                            fTireProdId = objPOI.ProductId__c;
                        } else if (objPOI.Type__c == 'R-Tire') {
                            // 트랙터 주문시 타이어는 무조건 조립
                            rTireProdId = objPOI.ProductId__c;
                        } else if (objPOI.Type__c == 'Option') {
                            // Option의 경우는 여러개가 조립되는 경우가 있어 Set에 넣어준다.
                            if (objPOI.IsAssembled__c) {
                                setAdditionalOptionProductId.add(objPOI.ProductId__c);
                            } else {
                                Integer qty = mapQuantityByDisAssembledOptionProductId.get(objPOI.ProductId__c);
                                if (qty == null) {
                                    qty = 0;
                                }
                                qty += Integer.valueOf(objPOI.Quantity__c);
                                mapQuantityByDisAssembledOptionProductId.put(objPOI.ProductId__c, qty);
                            }
                        } else if (objPOI.Type__c == 'Mower') {
                            // Mower가 Serial Number가 없을경우 (Addition Option 처럼 취급)
                            // 없을 경우 아래 코드 사용
                            if (objPOI.IsAssembled__c) {
                                setAdditionalOptionProductId.add(objPOI.ProductId__c);
                            } else {
                                Integer qty = mapQuantityByDisAssembledOptionProductId.get(objPOI.ProductId__c);
                                if (qty == null) {
                                    qty = 0;
                                }
                                qty += Integer.valueOf(objPOI.Quantity__c);
                                mapQuantityByDisAssembledOptionProductId.put(objPOI.ProductId__c, qty);
                            }
                            // Mower 가 Serial Number 가 있을 경우 (Loader, Backhoe와 동일 취급. 단, Finished Goods 영향 x)
                            /* start
                            Integer qty = mapQuantityByDisAssembledAttachmentProductId.get(objPOI.ProductId__c);
                            if (qty == null) {
                                qty = 0;
                            }
                            qty += Integer.valueOf(objPOI.Quantity__c);
                            mapQuantityByDisAssembledAttachmentProductId.put(objPOI.ProductId__c, qty);
                            end */
                        } else {
                            // order type 이 없는경우 에러 발생
                            throw new AuraHandledException('Please check this record order type. (recordId : ' + objPOI.Id + ')');
                        }
                    }
                    String finGoodsId = '';
                    if (tractorProdId != null) {
                        finGoodsId += tractorProdId;
                    }
                    finGoodsId += '-';
                    if (loaderProdId != null) {
                        finGoodsId += loaderProdId;
                    }
                    finGoodsId += '-';
                    if (backhoeProdId != null) {
                        finGoodsId += backhoeProdId;
                    }
                    finGoodsId += '-';
                    if (fTireProdId != null) {
                        finGoodsId += fTireProdId;
                    }
                    finGoodsId += '-';
                    if (rTireProdId != null) {
                        finGoodsId += rTireProdId;
                    }
                    System.debug(finGoodsId);
                    if (finGoodsId != '-----') {
                        listFinGoodsId.add(finGoodsId);
                        // 함께 조립되어야하는 Option 이 1개 이상 있는 경우 분기처리. Option 을 각각 Child Order 에 넣어줘야하기 때문.
                        if (setAdditionalOptionProductId.size() > 0) {
                            // 해당 Fin Goods Code(Id)로 몇개를 주문했는지 저장
                            mapQuantityByFinishedGoodsIdWithAdditionalOption.put(finGoodsId, Integer.valueOf(objPOS.Quantity__c));

                            // 함께 조립되어야 하는 Option들은 무엇이 있는지 저장. 주문 수량은 위에 저장된 fin goods 주문 수량과 동일.
                            mapSetProductIdByFinishedGoodsCode.put(finGoodsId, setAdditionalOptionProductId);
                        } else {
                            // 추가될 Option 이 필요 없는 Fin Goods 주문 제품.
                            mapQuantityByFinishedGoodsIdWithoutAdditionOption.put(finGoodsId, Integer.valueOf(objPOS.Quantity__c));
                        }
                    }
                } else {
                    // Implements/tire 로 개별 부품이나 타이어를 주문하는 경우
                    for (ProductOrderItem__c objPOI : objPOS.ProductOrderItem__r) {
                        if (objPOI.Type__c == 'Tractor' || objPOI.Type__c == 'Loader' || objPOI.Type__c == 'Backhoe' || objPOI.Type__c == 'Mower') {
                            Integer qty = mapQuantityByDisAssembledAttachmentProductId.get(objPOI.ProductId__c);
                            if (qty == null) {
                                qty = 0;
                            }
                            qty += Integer.valueOf(objPOI.Quantity__c);
                            mapQuantityByDisAssembledAttachmentProductId.put(objPOI.ProductId__c, qty);
                        } else if (objPOI.Type__c == 'Option' || objPOI.Type__c == 'F-Tire' || objPOI.Type__c == 'R-Tire') {
                            Integer qty = mapQuantityByDisAssembledOptionProductId.get(objPOI.ProductId__c);
                            if (qty == null) {
                                qty = 0;
                            }
                            qty += Integer.valueOf(objPOI.Quantity__c);
                            mapQuantityByDisAssembledOptionProductId.put(objPOI.ProductId__c, qty);
                        } else {
                            // order type 이 없거나 Finished Goods 인 경우 에러 발생.
                            throw new AuraHandledException('Please check this record order type. (recordId : ' + objPOI.Id + ')');
                        }
                    }
                }
            }
            List<Product2> listFinishedGoods = new List<Product2>([
                    SELECT Id, ProductName__c, Name, fm_FinishedGoodsId__c
                    FROM Product2
                    WHERE fm_FinishedGoodsId__c IN :listFinGoodsId
                    AND ItemGroupCode__c = '101'
            ]);
            Map<String, product2> mapFinGoodsProductIdByFinGoodsId = new Map<String, Product2>();
            List<Id> listProductIdForGetPrice = new List<Id>();
            for (Product2 objProd : listFinishedGoods) {
                mapFinGoodsProductIdByFinGoodsId.put(objProd.fm_FinishedGoodsId__c, objProd);
                listProductIdForGetPrice.add(objProd.Id);
            }
            if (mapQuantityByDisAssembledOptionProductId.values().size() > 0) {
                listProductIdForGetPrice.addAll(mapQuantityByDisAssembledOptionProductId.keySet());
            }
            if (mapQuantityByDisAssembledAttachmentProductId.values().size() > 0) {
                listProductIdForGetPrice.addAll(mapQuantityByDisAssembledAttachmentProductId.keySet());
            }

            Map<Id, PriceListEntry__c> mapPriceListEntriesByIds = new Map<Id, PriceListEntry__c>();
            // 가격 가져오기
            List<PriceListEntry__c> listPLE = [
                    SELECT Id, ProductID__c, ListPrice__c
                    FROM PriceListEntry__c
                    WHERE PriceListID__c = :parentOrder.Dealership__r.PriceListParts__c
            ];
            for (PriceListEntry__c objPLE : listPLE) {
                mapPriceListEntriesByIds.put(objPLE.ProductID__c, objPLE);
            }

            List<Orders__c> listChildOrders = new List<Orders__c>();
            List<List<ProductOrderItem__c>> listListProductOrderItem = new List<List<ProductOrderItem__c>>();
            // Child Order 생성 부분 시작
            System.debug(mapQuantityByFinishedGoodsIdWithoutAdditionOption);
            System.debug(mapQuantityByFinishedGoodsIdWithAdditionalOption);
            System.debug(mapSetProductIdByFinishedGoodsCode);
            System.debug(mapQuantityByDisAssembledAttachmentProductId);
            System.debug(mapQuantityByDisAssembledOptionProductId);


            // 1. Additional Option이 장착되지 않는 Finished Goods 하나당. 하나의 Child Order 및 Product Order Item 생성.
            for (String finGoodsId : mapQuantityByFinishedGoodsIdWithoutAdditionOption.keySet()) {
                for (Integer i = 0; i < mapQuantityByFinishedGoodsIdWithoutAdditionOption.get(finGoodsId); i++) {
                    List<ProductOrderItem__c> listNewPOI = new List<ProductOrderItem__c>();

                    Orders__c objChildOrder = new Orders__c();
                    objChildOrder.PaymentTerms__c = parentOrder.PaymentTerms__c;
                    objChildOrder.Dealership__c = parentOrder.Dealership__c;
                    objChildOrder.ShiptoAddressID__c = parentOrder.ShiptoAddressID__c;
                    objChildOrder.Salesperson__c = parentOrder.Salesperson__c;
                    objChildOrder.BilltoAddressID__c = parentOrder.BilltoAddressID__c;
                    objChildOrder.Status__c = parentOrder.Status__c;
                    objChildOrder.ParentOrder__c = parentOrder.Id;

                    ProductOrderItem__c objPOI = new ProductOrderItem__c();
                    objPOI.Type__c = 'Finished Goods';
                    objPOI.Quantity__c = 1;
                    objPOI.Status__c = 'Opened';
                    Product2 finGoodsProduct = mapFinGoodsProductIdByFinGoodsId.get(finGoodsId);
                    if (finGoodsProduct != null) {
                        objPOI.ProductId__c = finGoodsProduct.Id;
                        // TODO : 가격이 없는경우 어떤식을 처리할 지 정하기 0원 or 에러(현재는 에러), 트래터 3개를 주문해서 3프로 할인한 가격과 3프로 할인 후 3개를 곱한 가격이 다르다. Child Order 의 가격의 합과 Parent Order 의 가격이 다를 수 있음.
                        Double dbPrice = mapPriceListEntriesByIds.get(finGoodsProduct.Id).ListPrice__c - (mapPriceListEntriesByIds.get(finGoodsProduct.Id).ListPrice__c) / 100 * parentOrder.Discount__c;
                        objPOI.Price__c = dbPrice;
                    } else {
                        throw new AuraHandledException('Cannot found finished goods code.(code : ' + finGoodsId + ')');
                    }
                    listNewPOI.add(objPOI);
                    if (listNewPOI.size() > 0) {
                        listChildOrders.add(objChildOrder);
                        listListProductOrderItem.add(listNewPOI);
                    }
                }
            }
            System.debug('listListProductOrderItem :: ' + listListProductOrderItem);

            // 2. Additional Option이 장착되어야 하는 Finished Goods 하나당. 하나의 Child Order 및 Product Order Item + 같이 조립될 Option 들의 Product Order Item 생성.
            for (String finGoodsId : mapQuantityByFinishedGoodsIdWithAdditionalOption.keySet()) {
                for (Integer i = 0; i < mapQuantityByFinishedGoodsIdWithAdditionalOption.get(finGoodsId); i++) {
                    List<ProductOrderItem__c> listNewPOI = new List<ProductOrderItem__c>();

                    Orders__c objChildOrder = new Orders__c();
                    objChildOrder.PaymentTerms__c = parentOrder.PaymentTerms__c;
                    objChildOrder.Dealership__c = parentOrder.Dealership__c;
                    objChildOrder.ShiptoAddressID__c = parentOrder.ShiptoAddressID__c;
                    objChildOrder.Salesperson__c = parentOrder.Salesperson__c;
                    objChildOrder.BilltoAddressID__c = parentOrder.BilltoAddressID__c;
                    objChildOrder.Status__c = parentOrder.Status__c;
                    objChildOrder.ParentOrder__c = parentOrder.Id;

                    ProductOrderItem__c objPOI = new ProductOrderItem__c();
                    objPOI.Type__c = 'Finished Goods';
                    objPOI.Quantity__c = 1;
                    objPOI.Status__c = 'Opened';
                    // fin goods product order item
                    Product2 finGoodsProduct = mapFinGoodsProductIdByFinGoodsId.get(finGoodsId);
                    if (finGoodsProduct != null) {
                        objPOI.ProductId__c = finGoodsProduct.Id;
                        // TODO : 가격이 없는경우 어떤식을 처리할 지 정하기 0원 or 에러(현재는 에러), 트래터 3개를 주문해서 3프로 할인한 가격과 3프로 할인 후 3개를 곱한 가격이 다르다. Child Order 의 가격의 합과 Parent Order 의 가격이 다를 수 있음.
                        Double dbPrice = mapPriceListEntriesByIds.get(finGoodsProduct.Id).ListPrice__c - (mapPriceListEntriesByIds.get(finGoodsProduct.Id).ListPrice__c) / 100 * parentOrder.Discount__c;
                        objPOI.Price__c = dbPrice;
                    } else {
                        throw new AuraHandledException('Cannot found finished goods code.(code : ' + finGoodsId + ')');
                    }
                    listNewPOI.add(objPOI);

                    Set<Id> setOptionProductId = mapSetProductIdByFinishedGoodsCode.get(finGoodsId);
                    if (setOptionProductId != null) {
                        for (Id optionId : setOptionProductId) {
                            ProductOrderItem__c objOptionProductOrderItem = new ProductOrderItem__c();
                            objOptionProductOrderItem.Type__c = 'Finished Goods';
                            objOptionProductOrderItem.Quantity__c = 1;
                            objOptionProductOrderItem.Status__c = 'Opened';
                            objOptionProductOrderItem.ProductId__c = optionId;
                            listNewPOI.add(objOptionProductOrderItem);
                        }
                    }
                    if (listNewPOI.size() > 0) {
                        listChildOrders.add(objChildOrder);
                        listListProductOrderItem.add(listNewPOI);
                    }
                }
            }
            System.debug('listListProductOrderItem :: ' + listListProductOrderItem);

            // 3. 조립되지 않는 Attachment(Loader, Backhoe, Tire)를 각각의 Child Order 및 Product Order Item 생성.
            for (String productId : mapQuantityByDisAssembledAttachmentProductId.keySet()) {
                for (Integer i = 0; i < mapQuantityByDisAssembledAttachmentProductId.get(productId); i++) {
                    List<ProductOrderItem__c> listNewPOI = new List<ProductOrderItem__c>();

                    Orders__c objChildOrder = new Orders__c();
                    objChildOrder.PaymentTerms__c = parentOrder.PaymentTerms__c;
                    objChildOrder.Dealership__c = parentOrder.Dealership__c;
                    objChildOrder.ShiptoAddressID__c = parentOrder.ShiptoAddressID__c;
                    objChildOrder.Salesperson__c = parentOrder.Salesperson__c;
                    objChildOrder.BilltoAddressID__c = parentOrder.BilltoAddressID__c;
                    objChildOrder.Status__c = parentOrder.Status__c;
                    objChildOrder.ParentOrder__c = parentOrder.Id;

                    ProductOrderItem__c objPOI = new ProductOrderItem__c();
                    objPOI.Type__c = mapProductTypeById.get(productId);
                    objPOI.Quantity__c = 1;
                    objPOI.Status__c = 'Opened';
                    objPOI.ProductId__c = productId;
                    // TODO : 가격이 없는경우 어떤식을 처리할 지 정하기 0원 or 에러(현재는 에러), 트래터 3개를 주문해서 3프로 할인한 가격과 3프로 할인 후 3개를 곱한 가격이 다르다. Child Order 의 가격의 합과 Parent Order 의 가격이 다를 수 있음.
                    Double dbPrice = mapPriceListEntriesByIds.get(productId).ListPrice__c - (mapPriceListEntriesByIds.get(productId).ListPrice__c) / 100 * parentOrder.Discount__c;
                    objPOI.Price__c = dbPrice;

                    listNewPOI.add(objPOI);
                    if (listNewPOI.size() > 0) {
                        listChildOrders.add(objChildOrder);
                        listListProductOrderItem.add(listNewPOI);
                    }
                }
            }
            System.debug('listListProductOrderItem :: ' + listListProductOrderItem);

            // 4. 조립되지 않는 Additional Option(Option + Mower)를 하나의 Child Order 에 다수의 Product Order Item 생성.
            Orders__c objChildOrder = new Orders__c();
            objChildOrder.PaymentTerms__c = parentOrder.PaymentTerms__c;
            objChildOrder.Dealership__c = parentOrder.Dealership__c;
            objChildOrder.ShiptoAddressID__c = parentOrder.ShiptoAddressID__c;
            objChildOrder.Salesperson__c = parentOrder.Salesperson__c;
            objChildOrder.BilltoAddressID__c = parentOrder.BilltoAddressID__c;
            objChildOrder.Status__c = parentOrder.Status__c;
            objChildOrder.ParentOrder__c = parentOrder.Id;
            List<ProductOrderItem__c> listNewPOI = new List<ProductOrderItem__c>();
            for (String productId : mapQuantityByDisAssembledOptionProductId.keySet()) {

                ProductOrderItem__c objPOI = new ProductOrderItem__c();
                objPOI.Type__c = mapProductTypeById.get(productId);
                objPOI.Quantity__c = mapQuantityByDisAssembledOptionProductId.get(productId);
                objPOI.Status__c = 'Opened';
                objPOI.ProductId__c = productId;
                // TODO : 가격이 없는경우 어떤식을 처리할 지 정하기 0원 or 에러(현재는 에러), 트래터 3개를 주문해서 3프로 할인한 가격과 3프로 할인 후 3개를 곱한 가격이 다르다. Child Order 의 가격의 합과 Parent Order 의 가격이 다를 수 있음.
                Double dbPrice = mapPriceListEntriesByIds.get(productId).ListPrice__c - (mapPriceListEntriesByIds.get(productId).ListPrice__c) / 100 * parentOrder.Discount__c;
                objPOI.Price__c = dbPrice;
                listNewPOI.add(objPOI);
            }
            if (listNewPOI.size() > 0) {
                listChildOrders.add(objChildOrder);
                listListProductOrderItem.add(listNewPOI);
            }
            System.debug('listListProductOrderItem :: ' + listListProductOrderItem);

            if (listChildOrders.size() > 0 && listListProductOrderItem.size() > 0) {
                insert listChildOrders;

                Integer i = 0;
                List<ProductOrderItem__c> listNewOrderItem = new List<ProductOrderItem__c>();
                for (List<ProductOrderItem__c> objList : listListProductOrderItem) {
                    Orders__c objOrders = listChildOrders.get(0);
                    System.debug('objList :: ' + objList);
                    for (ProductOrderItem__c objPOI : objList) {
                        objPOI.OrdersId__c = objOrders.Id;
                    }
                    listNewOrderItem.addAll(objList);
                    i++;
                }
                System.debug('listNewOrderItem :: ' + listNewOrderItem);
                if (listNewOrderItem.size() > 0) {
                    insert listNewOrderItem;
                    parentOrder.IsConfirmedOrder__c = true;
                    update parentOrder;
                } else {
                    mapResult.put('status', 'error');
                    mapResult.put('msg', 'There is no item can confirm.');
                }
            } else {
                mapResult.put('status', 'error');
                mapResult.put('msg', 'There is no item can confirm.');
            }
        } catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            mapResult.put('status', 'error');
            mapResult.put('msg', e.getMessage());
            return mapResult;
        }

        return mapResult;
    }

    @AuraEnabled
    public static String doPost(String recordId) {
        String resultMessage = 'success';
        String status;

        Orders__c thisOrder = [
                SELECT Id, IsAssembled__c, Dealership__r.BPCode__c, ShiptoAddressID__r.ExternalId__c,
                        BilltoAddressID__r.ExternalId__c, PaymentTermDev__r.ExternalId__c, Notes__c, PONumber__c
                FROM Orders__c
                WHERE Id = :recordId
                LIMIT 1
        ];

        List<ProductOrderSummary__c> listPOS = [
                SELECT FinishedGoodsCode__c, Quantity__c
                FROM ProductOrderSummary__c
                WHERE Orders__c = :recordId
        ];

        if (listPOS[0].IsAssembled__c) {
            List<String> listPartsCode = new List<String>();

            for (ProductOrderItem__c poi : [
                    SELECT Id, Type__c, IsAssembled__c, fm_ItemGroupCode__c, ProductId__r.ProductCode, ProductId__r.ProductName__c
                    FROM ProductOrderItem__c
                    WHERE OrdersId__c = :recordId
                    ORDER BY fm_ItemGroupCode__c ASC
            ]) {
                if (poi.IsAssembled__c) {
                    if (poi.Type__c == 'Tractor') {
                        listPartsCode.set(0, poi.ProductId__r.ProductName__c);
                    } else if (poi.Type__c == 'Loader') {
                        listPartsCode.set(1, poi.ProductId__r.ProductName__c);
                    } else if (poi.Type__c == 'Backhoe') {
                        listPartsCode.set(2, poi.ProductId__r.ProductName__c);
                    } else if (poi.Type__c == 'F-Tire') {
                        listPartsCode.set(3, poi.ProductId__r.ProductName__c);
                    } else if (poi.Type__c == 'R-Tire') {
                        listPartsCode.set(4, poi.ProductId__r.ProductName__c);
                    }
                    listPartsCode.add(poi.ProductId__r.ProductName__c);
                }
            }

            String finishedGoodsCode = String.join(listPartsCode, ' ');
            System.debug(finishedGoodsCode);

            Product2 finishedGoods = [
                    SELECT Id, ItemGroupCode__c
                    FROM Product2
                    WHERE ItemGroupCode__c = '101'
//                    AND ProductId__r.ProductCode = :finishedGoodsCode
                    AND ProductName__c = :finishedGoodsCode
                    LIMIT 1
            ];

            if (finishedGoods != null) {
                listPOS[0].FinishedGoodsCode__c = finishedGoods.Id;
                update listPOS[0];

                IF_SFDC_SAP_REG_ORDER_PROD orderProd = new IF_SFDC_SAP_REG_ORDER_PROD(thisOrder, listPOS[0]);
                status = orderProd.executeCall();

                if (status == 'S') {
                    thisOrder.IsSendtoSAP__c = true;
                    thisOrder.Status__c = 'Accepted';

                    update thisOrder;
                    resultMessage = 'success';
                }
            } else {
                resultMessage = '주문에 대한 Finished Goods가 존재하지 않습니다.';
            }
        } else if (listPOS[0].IsAssembled__c == false) {
            IF_SFDC_SAP_REG_ORDER_PROD orderProd = new IF_SFDC_SAP_REG_ORDER_PROD(thisOrder, listPOS[0]);
            status = orderProd.executeCall();

            if (status == 'S') {
                resultMessage = 'success';
            }
        }

        return resultMessage;
    }

}