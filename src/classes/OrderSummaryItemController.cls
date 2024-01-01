/************************************************************************************
 * File Name   		: OrderSummaryItemController
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-19
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-19       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class OrderSummaryItemController {

    public class OrderSummaryWrapper {
        public String Id;
        public String poNumber;
        public Integer qty;
        public String notes;
        public Boolean isRetailed;
        public Boolean isAssembled;
        public Double subtotal;
        public ProductOrderItem objTractor;
        public ProductOrderItem objLoader;
        public ProductOrderItem objBackhoe;
        public ProductOrderItem objMower;
        public ProductOrderItem objTires;
        public List<ProductOrderItem> listOptions;
        public OrderSummaryWrapper() {
            this.poNumber = '';
            this.qty = 0;
            this.notes = '';
            this.isRetailed = false;
            this.isAssembled = true;
            this.subtotal = 0;
            this.objTractor = null;
            this.objLoader = null;
            this.objBackhoe = null;
            this.objMower = null;
            this.objTires = null;
            this.listOptions = null;
        }
    }
    public class ProductOrderItem {
        public String Id;
        public String label;
        public String configName;
        public String ProductCode;
        public String value;
        public String child;
        public String parent;
        public Double price;
        public Boolean isAssembled;
        public Boolean checked;
        public ProductOrderItem() {
            this.label = '';
            this.ProductCode = '';
            this.configName = '';
            this.value = '';
            this.child = null;
            this.parent = null;
            this.Id = null;
            this.price = 0;
            this.isAssembled = false;
            this.checked = false;
        }
    }

    @AuraEnabled
    public static String getTractorImage(String productId){
        System.debug('getTractorImage start');
        try {
            String imgUrl = '';
            List<Product2> listProduct2 = [SELECT Id, ImageUrl__c FROM Product2 WHERE Id = :productId];
            if (listProduct2 != null && listProduct2.size() > 0) {
                if(listProduct2.get(0).ImageUrl__c != null){
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