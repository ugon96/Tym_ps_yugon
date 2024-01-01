/************************************************************************************
 * File Name   		: CreateOrderController_test
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-12-15
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-12-15       ugon96@gmail.com         Initial Version
*************************************************************************************/

@IsTest
private class CreateOrderController_test {
    @IsTest
    static void testBehavior() {
        Product2 objProductTractor = TestObjectCreator.objProductTractor;
        insert objProductTractor;

        Product2 objProductLoader = TestObjectCreator.objProductLoader;
        insert objProductLoader;

        Product2 objProductFTire = TestObjectCreator.objProductFTire;
        insert objProductFTire;

        Product2 objProductRTire = TestObjectCreator.objProductRTire;
        insert objProductRTire;

        Product2 objProductBackhoe = TestObjectCreator.objProductBackhoe;
        insert objProductBackhoe;

        Product2 objProductMower = TestObjectCreator.objProductBackhoe.clone();
        objProductMower.ProductName__c = 'objProductMower';
        objProductMower.Name = 'objProductMower';
        objProductMower.ProductCode = 'objProductMower';
        objProductMower.ItemGroupCode__c = '120';
        objProductMower.ExternalId__c = 'objProductMower';
        insert objProductMower;

        Product2 objProductCabin = TestObjectCreator.objProductBackhoe.clone();
        objProductCabin.ProductName__c = 'objProductCabin';
        objProductCabin.Name = 'objProductCabin';
        objProductCabin.ProductCode = 'objProductCabin';
        objProductCabin.ItemGroupCode__c = '121';
        objProductCabin.ExternalId__c = 'objProductCabin';
        insert objProductCabin;

        Product2 objProductOption = TestObjectCreator.objProductBackhoe.clone();
        objProductOption.ProductName__c = 'objProductOption';
        objProductOption.Name = 'objProductOption';
        objProductOption.ProductCode = 'objProductOption';
        objProductOption.ItemGroupCode__c = '118';
        objProductOption.ExternalId__c = 'objProductOption';
        insert objProductOption;

        ProductHierarchy__c objProductHierarchyTractor = TestObjectCreator.objProductHierarchy;
        insert objProductHierarchyTractor;

        ProductHierarchy__c objProductHierarchyFTire = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyFTire.Child__c = objProductFTire.Id;
        insert objProductHierarchyFTire;

        ProductHierarchy__c objProductHierarchyRTire = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyRTire.Parent__c = objProductFTire.Id;
        objProductHierarchyRTire.Child__c = objProductRTire.Id;
        insert objProductHierarchyRTire;

        ProductHierarchy__c objProductHierarchyLoader = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyLoader.Child__c = objProductLoader.Id;
        insert objProductHierarchyLoader;

        ProductHierarchy__c objProductHierarchyBackhoe = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyBackhoe.Child__c = objProductBackhoe.Id;
        insert objProductHierarchyBackhoe;

        ProductHierarchy__c objProductHierarchyMower = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyMower.Child__c = objProductMower.Id;
        insert objProductHierarchyMower;

        ProductHierarchy__c objProductHierarchyCabin = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyCabin.Child__c = objProductCabin.Id;
        insert objProductHierarchyCabin;

        ProductHierarchy__c objProductHierarchyOption = TestObjectCreator.objProductHierarchy.clone();
        objProductHierarchyOption.Child__c = objProductOption.Id;
        insert objProductHierarchyOption;



        Orders__c objOrders = TestObjectCreator.objOrders;
        insert objOrders;

        ProductOrderSummary__c objProductOrderSummary = TestObjectCreator.objProductOrderSummary;
        insert objProductOrderSummary;

        ProductOrderItem__c objProductOrderItemTractor = TestObjectCreator.objProductOrderItem;
        insert objProductOrderItemTractor;

        ProductOrderItem__c objProductOrderItemLoader = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemLoader.Type__c = 'Loader';
        System.debug('objProductLoader.Id :: ' + objProductLoader.Id);
        objProductOrderItemLoader.ProductId__c = objProductLoader.Id;
        insert objProductOrderItemLoader;

        ProductOrderItem__c objProductOrderItemBackhoe = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemBackhoe.ProductId__c = objProductBackhoe.Id;
        objProductOrderItemBackhoe.Type__c = 'Backhoe';
        insert objProductOrderItemBackhoe;

        ProductOrderItem__c objProductOrderItemFTire = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemFTire.ProductId__c = objProductFTire.Id;
        objProductOrderItemFTire.Type__c = 'F-Tire';
        insert objProductOrderItemFTire;

        ProductOrderItem__c objProductOrderItemRTire = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemRTire.Type__c = 'R-Tire';
        objProductOrderItemRTire.ProductId__c = objProductRTire.Id;
        insert objProductOrderItemRTire;

        ProductOrderItem__c objProductOrderItemMower = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemMower.Type__c = 'Mower';
        objProductOrderItemMower.ProductId__c = objProductMower.Id;
        insert objProductOrderItemMower;

        ProductOrderItem__c objProductOrderItemOption = TestObjectCreator.objProductOrderItem.clone();
        objProductOrderItemOption.Type__c = 'R-Tire';
        objProductOrderItemOption.ProductId__c = objProductOption.Id;
        insert objProductOrderItemOption;

        CreateOrderController.getIsPortalUser();
        Map<String, Object> mapResult = CreateOrderController.getData(objOrders.Id);
        CreateOrderController.getConfiguration(objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getTire(objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getLoader(objProductTractor.Id, objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getBackhoe(objProductTractor.Id, objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getMower(objProductTractor.Id, objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getCabin(objProductTractor.Id, objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getOption(objProductTractor.Id, objProductTractor.Name, TestObjectCreator.objBasePriceList.Id);
        CreateOrderController.getTractorImage(objProductTractor.Id);
        CreateOrderController.doSaveOrderItem(objOrders.Id, String.valueOf(mapResult.get('listOrderSummary')), 1000);
        CreateOrderController.doCheckOrderStatus(objOrders.Id);
        CreateOrderController.doSubmit(objOrders.Id);

    }
}