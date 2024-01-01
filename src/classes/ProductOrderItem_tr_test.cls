/************************************************************************************
 * Description :
 *
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2023-12-27       mw.jung          Create
*************************************************************************************/

@IsTest
private class ProductOrderItem_tr_test {
    @IsTest
    static void testBehavior() {

        ProductOrderItem__c objProduct = TestObjectCreator.objProductOrderItem;
        objProduct.Status__c = 'Opened';
        insert objProduct;

        ProductOrderItem__c updateProduct = new ProductOrderItem__c(
                Id = objProduct.Id,
                Status__c = 'Closed'
        );
        update updateProduct;

    }
}