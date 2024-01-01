/**
 * Created by 천유정 on 2023-11-28.
 */

public without sharing class TestObjectCreator {

    public static String strSalespersonRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Salesperson').getRecordTypeId();
    public static String strEndCustomerRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('EndCustomer').getRecordTypeId();
    public static String strTractorRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId();
    public static String strLoaderRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Loader').getRecordTypeId();
    public static String strBackhoeRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Backhoe').getRecordTypeId();
    public static String strMidMountMowerRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('MidMountMower').getRecordTypeId();
    public static String strCabinRT = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Cabin').getRecordTypeId();
    // public static String strManualRT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Manual').getRecordTypeId(); 

    /************************************************************************************
    * User - User (Profile : TYM USA)
    ************************************************************************************/
    public static User objUserTYMUSA{
        get {
            if (objUserTYMUSA == null) {
                objUserTYMUSA = new User();
                String username = 'TYMUSA';
                while(true){
                    if ([SELECT id FROM User WHERE Username = :username+'@tymusa.com'].isEmpty()) {
                        break;
                    }else{
                        username += '1';
                    }
                }
                objUserTYMUSA.Username = username + '@tymusa.com';
                System.debug(objUserTYMUSA.Username);
                objUserTYMUSA.LastName = 'LastTest';
                objUserTYMUSA.Email = 'testemail@test.com';
                objUserTYMUSA.Alias = 'test';
                objUserTYMUSA.TimeZoneSidKey = 'America/New_York';
                objUserTYMUSA.LocaleSidKey = 'en_US';
                objUserTYMUSA.EmailEncodingKey = 'ISO-8859-1';
                objUserTYMUSA.LanguageLocaleKey = 'en_US';
                objUserTYMUSA.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TYM USA'].Id;

            }
            return objUserTYMUSA;
        }
        set;
    }

    /************************************************************************************
    * User - User (Profile : TYM Dealer)
    ************************************************************************************/
    public static User objUserTYMDealer{
        get {
            if (objUserTYMDealer == null) {
                if (objSalesperson == null) insert objSalesperson;
                objUserTYMDealer = new User();
                String username = 'TYMDealer';
                while(true){
                    if ([SELECT id FROM User WHERE Username = :username+'@tymusa.com'].isEmpty()) {
                        break;
                    }else{
                        username += '1';
                    }
                }
                objUserTYMDealer.Username = username + '@tymusa.com';
                System.debug(objUserTYMDealer.Username);
                objUserTYMDealer.LastName = 'LastTest';
                objUserTYMDealer.Email = 'testemailDealer@test.com';
                objUserTYMDealer.Alias = 'testr';
                objUserTYMDealer.TimeZoneSidKey = 'America/New_York';
                objUserTYMDealer.LocaleSidKey = 'en_US';
                objUserTYMDealer.EmailEncodingKey = 'ISO-8859-1';
                objUserTYMDealer.LanguageLocaleKey = 'en_US';
                objUserTYMDealer.ContactId = objSalesperson.Id;
                objUserTYMDealer.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TYM Dealer'].Id;
                objUserTYMDealer.UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' LIMIT 1].Id;

            }
            return objUserTYMDealer;
        }
        set;
    }

    /************************************************************************************
    *  Account - Dealership
    *************************************************************************************/
    public static Account objAccount {
        get {
            if (objAccount == null) {
                if (objUserTYMUSA == null) insert objUserTYMUSA;
                if (objPriceList.Id == null) insert objPriceList;
                if (objAddress.Id == null) insert objAddress;
                objAccount = new Account();
                objAccount.Name = 'Test Dealership';
                objAccount.LaborRate__c = 0.1;
                objAccount.Phone = '010-1234-1234';
                objAccount.Email__c = 'TestDealership@tymusa.com';
                objAccount.Active__c = 'Active';
                objAccount.TerritoryManagerID__c = objUserTYMUSA.Id;
                objAccount.BPCode__c = '000000000';
                objAccount.PriceListId__c = objPriceList.Id;  //Price List의 Id값;
                objAccount.PriceListParts__c = objPriceList.Id; // Price List의 Id값;
//                objAccount.BillingAddress__c = objAddress.Id; // Address의 Id값;
//                objAccount.ShippingAddress__c = objAddress.Id; // Address의 Id값;
            }
            return objAccount;
        }
        set;
    }

    /************************************************************************************
    *  Contact - Contact (RecordType : EndCustomer)
    *************************************************************************************/
    public static Contact objEndCustomer {
        get {
            if (objEndCustomer == null) {
                if (objAccount.Id == null) insert objAccount;
                objEndCustomer = new Contact();
                objEndCustomer.RecordTypeId = strEndCustomerRT;
                objEndCustomer.LastName = 'Test EndCustomer';
                objEndCustomer.AccountId = objAccount.Id;
                objEndCustomer.UserStatus__c = 'Active';
            }
            return objEndCustomer;
        }
        set;
    }

    /************************************************************************************
    *  Contact - Contact (RecordType : Salesperson)
    *************************************************************************************/
    public static Contact objSalesperson {
        get {
            if (objSalesperson == null) {
                if (objAccount.Id == null) insert objAccount;
                objSalesperson = new Contact();
                objSalesperson.RecordTypeId = strSalespersonRT;
                objSalesperson.LastName = 'Test Salesperson';
                objSalesperson.AccountId = objAccount.Id;
                objSalesperson.UserStatus__c = 'Active';
            }
            return objSalesperson;
        }
        set;
    }

    /************************************************************************************
    *  Product2 - ItemGroupCode__c(tractor)
    *************************************************************************************/
    public static Product2 objProductTractor {
        get {
            if (objProductTractor == null) {
                objProductTractor = new Product2();
                objProductTractor.ProductName__c = 'Test Product';
                // objProductTractor.ProductCode = 'objProductTractor';
                objProductTractor.Name = 'objProductTractor';
                objProductTractor.ItemGroupCode__c = '112';
                objProductTractor.IsActive = true;
                objProductTractor.LP__c = false;
                objProductTractor.ExternalId__c = 'objProductTractor';
            }
            return objProductTractor;
        }
        set;
    }
    /************************************************************************************
    *  Product2 - ItemGroupCode__c(loader)
    *************************************************************************************/
    public static Product2 objProductLoader {
        get {
            if (objProductLoader == null) {
                objProductLoader = new Product2();
                objProductLoader.ProductName__c = 'Test Product Loader';
                // objProductLoader.ProductCode = 'objProductLoader';
                objProductLoader.Name = 'objProductLoader';
                objProductLoader.ItemGroupCode__c = '113';
                objProductLoader.IsActive = true;
                objProductLoader.LP__c = false;
                objProductLoader.ExternalId__c = 'objProductLoader';
            }
            return objProductLoader;
        }
        set;
    }
    /************************************************************************************
    *  Product2 - ItemGroupCode__c(f-tire)
    *************************************************************************************/
    public static Product2 objProductFTire {
        get {
            if (objProductFTire == null) {
                objProductFTire = new Product2();
                objProductFTire.ProductName__c = 'Test Product';
                objProductFTire.Name = 'objProductFTire';
                // objProductFTire.ProductCode = 'objProductFTire';
                objProductFTire.ItemGroupCode__c = '115';
                objProductFTire.IsActive = true;
                objProductFTire.LP__c = false;
                objProductFTire.ExternalId__c = 'objProductFTire';
            }
            return objProductFTire;
        }
        set;
    }
    /************************************************************************************
    *  Product2 - ItemGroupCode__c(r-tire)
    *************************************************************************************/
    public static Product2 objProductRTire {
        get {
            if (objProductRTire == null) {
                objProductRTire = new Product2();
                objProductRTire.ProductName__c = 'Test Product';
                objProductRTire.Name = 'objProductRTire';
                // objProductRTire.ProductCode = 'objProductRTire';
                objProductRTire.ItemGroupCode__c = '116';
                objProductRTire.IsActive = true;
                objProductRTire.LP__c = false;
                objProductRTire.ExternalId__c = 'objProductRTire';
            }
            return objProductRTire;
        }
        set;
    }

    /************************************************************************************
    *  Product2 - ItemGroupCode__c(backhoe)
    *************************************************************************************/
    public static Product2 objProductBackhoe {
        get {
            if (objProductBackhoe == null) {
                objProductBackhoe = new Product2();
                objProductBackhoe.ProductName__c = 'Test Product Backhoe';
                objProductBackhoe.Name = 'objProductBackhoe';
                // objProductBackhoe.ProductCode = 'objProductBackhoe';
                objProductBackhoe.ItemGroupCode__c = '114';
                objProductBackhoe.IsActive = true;
                objProductBackhoe.LP__c = false;
                objProductBackhoe.ExternalId__c = 'objProductBackhoe';
            }
            return objProductBackhoe;
        }
        set;
    }

    /************************************************************************************
    *  Product2 - ItemGroupCode__c(Mid Mount Mower)
    *************************************************************************************/
    public static Product2 objProductMower {
        get {
            if (objProductMower == null) {
                objProductMower = new Product2();
                objProductMower.ProductName__c = 'Test Product Backhoe';
                objProductMower.Name = 'objProductMower';
                // objProductMower.ProductCode = 'objProductMower';
                objProductMower.ItemGroupCode__c = '120';
                objProductMower.IsActive = true;
                objProductMower.LP__c = false;
                objProductMower.ExternalId__c = 'objProductMower';
            }
            return objProductMower;
        }
        set;
    }

    /************************************************************************************
    *  Product2 - ItemGroupCode__c(parts)
    *************************************************************************************/
    public static Product2 objProductParts {
        get {
            if (objProductParts == null) {
                objProductParts = new Product2();
                objProductParts.ProductName__c = 'Test Product';
                objProductParts.Name = 'test';
                objProductParts.ItemGroupCode__c = '119';
                objProductParts.IsActive = true;
                objProductParts.LP__c = false;
                objProductParts.ExternalId__c = 'objProductParts';
            }
            return objProductParts;
        }
        set;
    }

    /************************************************************************************
    *  ProductHierarchy__c
    *************************************************************************************/
    public static ProductHierarchy__c objProductHierarchy {
        get {
            if (objProductHierarchy == null) {
                if (objProductTractor.Id == null) insert objProductTractor;
                objProductHierarchy = new ProductHierarchy__c();
                objProductHierarchy.Parent__c = objProductTractor.Id;
                objProductHierarchy.Child__c = objProductTractor.Id;
            }
            return objProductHierarchy;
        }
        set;
    }

    /************************************************************************************
    *  PartsHierarchy__c
    *************************************************************************************/
    public static PartsHierarchy__c objPartsHierarchy {
        get {
            if (objPartsHierarchy == null) {
                if (objProductTractor.Id == null) insert objProductTractor;
                objPartsHierarchy = new PartsHierarchy__c();
                objPartsHierarchy.Lv1__c = 'TRACTOR';
                objPartsHierarchy.Lv2__c = 'T654SCUS1';
                objPartsHierarchy.Lv3__c = 'T654SC';
                objPartsHierarchy.Section__c = 'TK1';
                objPartsHierarchy.SectionName__c = 'TRACTOR KIT';
                objPartsHierarchy.ApplyDateTo__c = Date.newInstance(2016, 12, 9);
                objPartsHierarchy.ApplyDateFrom__c = Date.newInstance(2017, 12, 9);
                objPartsHierarchy.ProductId__c = objProductTractor.Id;
                objPartsHierarchy.SupplyPartId__c = objProductTractor.Id;
            }
            return objPartsHierarchy;
        }
        set;
    }

    /************************************************************************************
    *  Claim
    *************************************************************************************/
    public static Case objClaim {
        get {
            if (objClaim == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objUserTYMDealer == null) insert objUserTYMDealer;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objClaim = new Case();
                objClaim.AccountId = objAccount.Id;
                objClaim.ContactId = objSalesperson.Id;
                objClaim.ClaimType__c = 'Retailed';  // 2023.12.26 jiae.tak 수정
                objClaim.CauseCode__c = 'Cabin';
                objClaim.CauseCode2__c = 'Bent';
                objClaim.CauseCode3__c = 'Etc';
                objClaim.Subject = 'Test Claim';
                objClaim.FailureDate__c = Date.newInstance(2017, 12, 9);
                objClaim.RepairDate__c = Date.newInstance(2017, 12, 10);
                objClaim.Failure_Cause__c = 'fail';
                objClaim.Status = 'Accepted';
                objClaim.PhotOf0HourMeter__c = 'photo1';
                objClaim.PhotoOfSerialNumber__c = 'photo2';
                objClaim.PhotoTractoDuringRepair__c = 'photo3';
                objClaim.ResponsibilityID__c = objUserTYMDealer.Id;
                objClaim.Approver1__c = objUserTYMDealer.Id;
                objClaim.Approver2__c = objUserTYMDealer.Id;
                objClaim.Approver3__c = objUserTYMDealer.Id;
                objClaim.EndCustomer_id__c = objEndCustomer.Id;
                objClaim.AssetId = objAssetTractor.Id; // Asset의 Id값

            }
            return objClaim;
        }
        set;
    }

    /************************************************************************************
    *  LaborCode__c
    *************************************************************************************/
    public static LaborCode__c objLaborCode{
        get {
            if (objLaborCode == null) {
                if (objLaborCodeMaster.Id == null) insert objLaborCodeMaster;
                if (objClaim.Id == null) insert objClaim;
                objLaborCode = new LaborCode__c();
                objLaborCode.ClaimId__c = objClaim.Id;
                objLaborCode.LaborHour__c = 4;
                objLaborCode.LaborCost__c = 5;
                objLaborCode.LaborCost__c = 3;
                objLaborCode.LaborCost__c = 2;
                objLaborCode.ApprovedLaborHour__c = 1;
                objLaborCode.LaborCodeMasterId__c = objLaborCodeMaster.Id; //LaborCodeMasterId__c의 Id값
            }
            return objLaborCode;
        }
        set;
    }

    /************************************************************************************
    *  LaborCodeMaster__c
    *************************************************************************************/
    public static LaborCodeMaster__c objLaborCodeMaster{
        get {
            if (objLaborCodeMaster == null) {
                objLaborCodeMaster = new LaborCodeMaster__c();
                objLaborCodeMaster.Name = 'Test Labor Code Master';
                //objLaborCodeMaster.Description__c = 'ASSY';
                objLaborCodeMaster.LaborHour__c = 5;
                objLaborCodeMaster.IsActive__c = true;
                objLaborCodeMaster.Model__c = '1905H';
                objLaborCodeMaster.LaborCode__c = '1905H_TM';
                objLaborCodeMaster.LaborGroup__c = '1905H_TM';
                objLaborCodeMaster.ExternalId__c = '1905H_TM';
            }
            return objLaborCodeMaster;
        }
        set;
    }

    /************************************************************************************
    *  Parts__c
    *************************************************************************************/
    public static Parts__c objParts{
        get {
            if (objParts == null) {
                if (objClaim.Id == null) insert objClaim;
                if (objProductParts.Id == null) insert objProductParts;
                // if (objARInvoiceItem.Id == null) insert objARInvoiceItem;
                objParts = new Parts__c();
                objParts.ClaimId__c = objClaim.Id;
                objParts.ProductId__c = objProductParts.Id;
                // objParts.InvoiceItem__c = objARInvoiceItem.Id; // InvoiceItem__c의 Id값
                objParts.CausalPart__c = true;
                objParts.LP__c = true;
                objParts.LocalParts__c = 'Anti-freeze';
                objParts.ApprovedPartValue__c = 1;
                objParts.Quantity__c = 1;
                objParts.PartValue__c = 2;
            }
            return objParts;
        }
        set;
    }

    /************************************************************************************
    *  PartsOrder__c
    *************************************************************************************/
    public static PartsOrder__c objPartsOrder{
        get {
            if (objPartsOrder == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objUserTYMDealer == null) insert objUserTYMDealer;
                objPartsOrder = new PartsOrder__c();
                objPartsOrder.DealershipId__c = objAccount.Id;
                objPartsOrder.SalespersonId__c = objSalesperson.Id;
                objPartsOrder.OrderType__c = 'Daily';
                objPartsOrder.PartialShipment__c = 'Allowed';
                objPartsOrder.ShippingMode__c = 'Truck';
                objPartsOrder.Status__c = 'Created';
                objPartsOrder.ApprovalDate__c = null;
                objPartsOrder.ApprovalStatus__c = null;
                objPartsOrder.ResponsibilityID__c = objUserTYMDealer.Id;
            }
            return objPartsOrder;
        }
        set;
    }

    /************************************************************************************
    *  PartsOrderItem__c
    *************************************************************************************/
    public static PartsOrderItem__c objPartsOrderItem{
        get {
            if (objPartsOrderItem == null) {
                if (objPartsOrder.Id == null) insert objPartsOrder;
                // if (objProductParts.Id == null) insert objProductParts;
                objPartsOrderItem = new PartsOrderItem__c();
                objPartsOrderItem.PartsOrderId__c = objPartsOrder.Id;
                // objPartsOrderItem.ProductId__c = objProductParts.Id;
                // objPartsOrderItem.Replacement__c = objProductParts.Id;
                objPartsOrderItem.Quantity__c = 1;
                objPartsOrderItem.Price__c = 1;
            }
            return objPartsOrderItem;
        }
        set;
    }

    /************************************************************************************
    *  Orders__c
    *************************************************************************************/
    public static Orders__c objOrders{
        get {
            if (objOrders == null) {
                // if (objUserTYMDealer == null) insert objUserTYMDealer;
                // if (objPriceList.Id == null) insert objPriceList;
                if (objAccount.Id == null) insert objAccount;
                if (objSalesperson.Id == null) insert objSalesperson;
                objOrders = new Orders__c();
                // objOrders.ParentOrder__c = objOrders.Id;
                objOrders.PaymentTermDev__c = objPriceList.Id; // price List의 id값
                objOrders.Dealership__c = objAccount.Id;
                objOrders.Salesperson__c = objSalesperson.Id;
                objOrders.Status__c = 'Created';
                objOrders.ApprovalNumber__c = '8f';
                objOrders.PONumber__c = '123';
                objOrders.FloorPlanCode__c = 'g456';
            }
            return objOrders;
        }
        set;
    }

    /************************************************************************************
    *  ProductOrderItem__c
    *************************************************************************************/
    public static ProductOrderItem__c objProductOrderItem{
        get {
            if (objProductOrderItem == null) {
                if (objOrders.Id == null) insert objOrders;
                if (objProductTractor.Id == null) insert objProductTractor;
                if (objProductOrderSummary.Id == null) insert objProductOrderSummary;
                objProductOrderItem = new ProductOrderItem__c();
                objProductOrderItem.OrdersId__c = objOrders.Id;
                objProductOrderItem.ProductId__c = objProductTractor.Id;
                objProductOrderItem.ProductOrderSummary__c = objProductOrderSummary.Id; //ProductOrderSummary__c의 id값
                objProductOrderItem.Type__c = 'Tractor';
                objProductOrderItem.Quantity__c = 1;
                objProductOrderItem.Price__c = 1.0;
                //objProductOrderItem.Description__c = 'test';
            }
            return objProductOrderItem;
        }
        set;
    }

    /************************************************************************************
    *  ProductOrderSummary__c
    *************************************************************************************/
    public static ProductOrderSummary__c objProductOrderSummary{
        get {
            if (objProductOrderSummary == null) {
                if (objOrders.Id == null) insert objOrders;
                objProductOrderSummary = new ProductOrderSummary__c();
                objProductOrderSummary.Name = 'test';
                objProductOrderSummary.Quantity__c = 1;
//                objProductOrderSummary.IsAssembeld__c = false;
                objProductOrderSummary.IsRetailed__c = false;
                objProductOrderSummary.Note__c = 't1';
                objProductOrderSummary.Orders__c = objOrders.Id;
            }
            return objProductOrderSummary;
        }
        set;
    }

    /************************************************************************************
    *  Asset - Asset (RecordType : Tractor)
    *************************************************************************************/
    public static Asset objAssetTractor{
        get {
            if (objAssetTractor == null) {
                if (objAccount.Id == null) insert objAccount;
                // if (objProductTractor.Id == null) insert objProductTractor;
                if (objOrders.Id == null) insert objOrders;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objSalesperson.Id == null) insert objSalesperson;
                objAssetTractor = new Asset();
                objAssetTractor.RecordTypeId = strTractorRT;
                objAssetTractor.AccountId = objAccount.Id;
                // objAssetTractor.Product2Id = objProductTractor.Id;
                objAssetTractor.LoaderId__c = objAssetTractor.Id;
                objAssetTractor.BackhoeId__c = objAssetTractor.Id;
                objAssetTractor.MidMountMower__c = objAssetTractor.Id;
                objAssetTractor.Cabin__c = objAssetTractor.Id;
                objAssetTractor.OrdersId__c = objOrders.Id;
                objAssetTractor.EndCustomerId__c = objEndCustomer.Id;
                objAssetTractor.SalespersonId__c = objSalesperson.Id;
                objAssetTractor.ContactId = objEndCustomer.Id;
                objAssetTractor.SerialNumber = 'T00';
                objAssetTractor.Status = 'In Stock';
                objAssetTractor.Name = 'T224H';
                objAssetTractor.Price = 1.0;
                objAssetTractor.Description = 'Test';
                objAssetTractor.EngineSerialNumber__c = 'E1234';
                objAssetTractor.RetailedDate__c = Date.newInstance(2017, 12, 10);
                objAssetTractor.RegisteredDate__c = Date.newInstance(2017, 12, 11);
                //objAssetTractor.EngineWarrantyDate__c = Date.newInstance(2017, 12, 11);
            }
            return objAssetTractor;
        }
        set;
    }

    /************************************************************************************
    *  Asset - Asset (RecordType : Loader)
    *************************************************************************************/
    public static Asset objAssetLoader{
        get {
            if (objAssetLoader == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objProductLoader.Id == null) insert objProductLoader;
                if (objOrders.Id == null) insert objOrders;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                if (objSalesperson.Id == null) insert objSalesperson;
                objAssetLoader = new Asset();
                objAssetLoader.RecordTypeId = strLoaderRT;
                objAssetLoader.AccountId = objAccount.Id;
                objAssetLoader.Product2Id = objProductLoader.Id;
                objAssetLoader.OrdersId__c = objOrders.Id;
                objAssetLoader.EndCustomerId__c = objEndCustomer.Id;
                objAssetTractor.SalespersonId__c = objSalesperson.Id;
                objAssetTractor.ContactId = objEndCustomer.Id;
                objAssetLoader.ParentId = objAssetTractor.Id;
                objAssetLoader.SerialNumber = 'T00';
                objAssetLoader.Status = 'Under Review';
                objAssetLoader.Name = 'LoaderT224H';
                objAssetLoader.Price = 1.0;
                objAssetLoader.Description = 'Test';
                objAssetLoader.RetailedDate__c = Date.newInstance(2017, 12, 10);
                objAssetLoader.RegisteredDate__c = Date.newInstance(2017, 12, 11);
            }
            return objAssetLoader;
        }
        set;
    }

    /************************************************************************************
    *  Asset - Asset (RecordType : Backhoe)
    *************************************************************************************/
    public static Asset objAssetBackhoe{
        get {
            if (objAssetBackhoe == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objProductBackhoe.Id == null) insert objProductBackhoe;
                if (objOrders.Id == null) insert objOrders;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objAssetBackhoe = new Asset();
                objAssetBackhoe.RecordTypeId = strBackhoeRT;
                objAssetBackhoe.AccountId = objAccount.Id;
                objAssetBackhoe.Product2Id = objProductBackhoe.Id;
                objAssetBackhoe.OrdersId__c = objOrders.Id;
                objAssetBackhoe.EndCustomerId__c = objEndCustomer.Id;
                objAssetBackhoe.SalespersonId__c = objSalesperson.Id;
                objAssetTractor.ContactId = objEndCustomer.Id;
                objAssetBackhoe.ParentId = objAssetTractor.Id;
                objAssetBackhoe.SerialNumber = 'T00';
                objAssetBackhoe.Status = 'Under Review';
                objAssetBackhoe.Name = 'BackT224H';
                objAssetBackhoe.Price = 1.0;
                objAssetBackhoe.Description = 'Test';
                objAssetBackhoe.RetailedDate__c = Date.newInstance(2017, 12, 10);
                objAssetBackhoe.RegisteredDate__c = Date.newInstance(2017, 12, 11);
            }
            return objAssetBackhoe;
        }
        set;
    }

    /************************************************************************************
    *  Asset - Asset (RecordType : MidMountMower)
    *************************************************************************************/
    public static Asset objAssetMidMountMower{
        get {
            if (objAssetMidMountMower == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objProductMower.Id == null) insert objProductMower;
                if (objOrders.Id == null) insert objOrders;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objAssetMidMountMower = new Asset();
                objAssetMidMountMower.RecordTypeId = strMidMountMowerRT;
                objAssetMidMountMower.AccountId = objAccount.Id;
                objAssetMidMountMower.Product2Id = objProductMower.Id;
                objAssetMidMountMower.OrdersId__c = objOrders.Id;
                objAssetMidMountMower.EndCustomerId__c = objEndCustomer.Id;
                objAssetBackhoe.SalespersonId__c = objSalesperson.Id;
                objAssetTractor.ContactId = objEndCustomer.Id;
                objAssetMidMountMower.ParentId = objAssetTractor.Id;
                objAssetMidMountMower.SerialNumber = 'T00';
                objAssetMidMountMower.Status = 'Under Review';
                objAssetMidMountMower.Name = 'MidMountMowerT224H';
                objAssetMidMountMower.Price = 1.0;
                objAssetMidMountMower.Description = 'Test';
                objAssetMidMountMower.RetailedDate__c = Date.newInstance(2017, 12, 10);
                objAssetMidMountMower.RegisteredDate__c = Date.newInstance(2017, 12, 11);
                objAssetMidMountMower.ExpirationDate__c = Date.newInstance(2017, 12, 11);
            }
            return objAssetMidMountMower;
        }
        set;
    }

    /************************************************************************************
    *  Asset - Asset (RecordType : Cabin)
    *************************************************************************************/
    public static Asset objAssetCabin{
        get {
            if (objAssetCabin == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objProductTractor.Id == null) insert objProductTractor;
                if (objOrders.Id == null) insert objOrders;
                if (objEndCustomer.Id == null) insert objEndCustomer;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objAssetCabin = new Asset();
                objAssetCabin.RecordTypeId = strCabinRT;
                objAssetCabin.AccountId = objAccount.Id;
                objAssetCabin.Product2Id = objProductTractor.Id;
                objAssetCabin.OrdersId__c = objOrders.Id;
                objAssetCabin.EndCustomerId__c = objEndCustomer.Id;
                objAssetBackhoe.SalespersonId__c = objSalesperson.Id;
                objAssetTractor.ContactId = objEndCustomer.Id;
                objAssetCabin.ParentId = objAssetTractor.Id;
                objAssetCabin.SerialNumber = 'T00';
                objAssetCabin.Status = 'Under Review';
                objAssetCabin.Name = 'Cabin224H';
                objAssetCabin.Price = 1.0;
                objAssetCabin.Description = 'Test';
                objAssetCabin.RetailedDate__c = Date.newInstance(2017, 12, 10);
                objAssetCabin.RegisteredDate__c = Date.newInstance(2017, 12, 11);
                objAssetCabin.ExpirationDate__c = Date.newInstance(2017, 12, 11);
            }
            return objAssetCabin;
        }
        set;
    }

    /************************************************************************************
    *  Warranty
    *************************************************************************************/
    public static Warranty__c objWarranty{
        get {
            if (objWarranty == null) {
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objWarranty = new Warranty__c();
                objWarranty.Model__c = objAssetTractor.Id;
                objWarranty.IsActive__c = true;
                objWarranty.ExtensionWarranty__c = 'warranty';
                objWarranty.ExpirationDate__c = Date.newInstance(2017, 12, 11);
                objWarranty.StartDate__c = Date.newInstance(2017, 12, 09);
            }
            return objWarranty;
        }
        set;
    }

    /************************************************************************************
     *  ARInvoice__c
     *************************************************************************************/
    public static ARInvoice__c objARInvoice{
        get {
            if (objARInvoice == null) {
                if (objPartsOrder.Id == null) insert objPartsOrder;
                if (objOrders.Id == null) insert objOrders;
                if (objAccount.Id == null) insert objAccount;
                if (objSalesperson.Id == null) insert objSalesperson;
                objARInvoice = new ARInvoice__c();
                objARInvoice.PartsOrderId__c = objPartsOrder.Id;
                objARInvoice.OrdersId__c = objOrders.Id;
                objARInvoice.Dealership__c = objAccount.Id;
                objARInvoice.ContactId__c = objSalesperson.Id;
                objARInvoice.Type__c = 'Part Order';
                objARInvoice.ShipFrom__c = '1';
                objARInvoice.ShipVia__c = '1';
                objARInvoice.ShippingNumber__c = '0001';
                objARInvoice.Freight__c = 3.0;
                objARInvoice.Discount__c = 5.0;
                objARInvoice.Total__c = 20.0;
                objARInvoice.Postingdate__c = Date.newInstance(2017, 12, 09);
                objARInvoice.Duedate__c = Date.newInstance(2017, 12, 09);
                objARInvoice.Postingdate__c = Date.newInstance(2017, 12, 09);
                objARInvoice.ShipDate__c = Date.newInstance(2017, 12, 09);
            }
            return objARInvoice;
        }
        set;
    }

    /************************************************************************************
     *  ARInvoiceItem__c
     *************************************************************************************/
    public static ARInvoiceItem__c objARInvoiceItem{
        get {
            if (objARInvoiceItem == null) {
                if (objARInvoice.Id == null) insert objARInvoice;
                if (objProductTractor.Id == null) insert objProductTractor;
                objARInvoiceItem = new ARInvoiceItem__c();
                objARInvoiceItem.Type__c = 'Part Order';
                objARInvoiceItem.CountryOfOrigin__c = 'BuSan';
                objARInvoiceItem.Model__c = 'model';
                objARInvoiceItem.Quantity__c = 5;
                objARInvoiceItem.UnitPrice__c = 5;
                objARInvoiceItem.Subtotal__c = 5;
                objARInvoiceItem.Total__c = 5;
                //objARInvoiceItem.Description__c = 'objARInvoiceItem';
                objARInvoiceItem.ARInvoiceMaster__c = objARInvoice.Id;
                objARInvoiceItem.Product__c = objProductTractor.Id;
            }
            return objARInvoiceItem;
        }
        set;
    }

    /************************************************************************************
     *  PriceList__c - BasePriceList__c
     *************************************************************************************/
    public static PriceList__c objBasePriceList{
        get {
            if (objBasePriceList == null) {
                objBasePriceList = new PriceList__c();
                objBasePriceList.Name = 'priceList';
                objBasePriceList.Factor__c = 2;
                objBasePriceList.ExternalId__c = '22';
                objBasePriceList.IsActive__c = true;
            }
            return objBasePriceList;
        }
        set;
    }

    /************************************************************************************
     *  PriceList__c
     *************************************************************************************/
    public static PriceList__c objPriceList{
        get {
            if (objPriceList == null) {
                if (objBasePriceList.Id == null) insert objBasePriceList;
                objPriceList = new PriceList__c();
                objPriceList.BasePriceList__c = objBasePriceList.Id;
                objPriceList.Name = 'priceList';
                objPriceList.Factor__c = 2;
                objPriceList.ExternalId__c = '33';
                objPriceList.IsActive__c = true;
            }
            return objPriceList;
        }
        set;
    }

    /************************************************************************************
     *  PriceListEntry__c
     *************************************************************************************/
    public static PriceListEntry__c objPriceListEntry{
        get {
            if (objPriceListEntry == null) {
                if (objPriceList.Id == null) insert objPriceList;
                if (objProductTractor.Id == null) insert objProductTractor;
                objPriceListEntry = new PriceListEntry__c();
                objPriceListEntry.PriceListID__c = objPriceList.Id;
                objPriceListEntry.ProductID__c = objProductTractor.Id;
                objPriceListEntry.Name = 'priceEntry';
                objPriceListEntry.ListPrice__c = 2;
                objPriceListEntry.ExternalId__c = 'P001';
                objPriceListEntry.ListPrice__c = 30;
                objPriceListEntry.CurrencyISO__c = 'test';
            }
            return objPriceListEntry;
        }
        set;
    }

    /************************************************************************************
     *  RetailProgram__c
     *************************************************************************************/
    public static RetailProgram__c objRetailProgram{
        get {
            if (objRetailProgram == null) {
                if (objAccount.Id == null) insert objAccount;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objRetailProgram = new RetailProgram__c();
                objRetailProgram.ProgramType__c = 'Rebate';
                objRetailProgram.AccountId__c = objAccount.Id;
                objRetailProgram.SalespersonId__c = objSalesperson.Id;
                objRetailProgram.AssetID__c = objAssetTractor.Id;
                objRetailProgram.Date__c = Date.newInstance(2017, 12, 09);
                objRetailProgram.Status__c = 'Under Review';
                //objRetailProgram.Description__c = 'retailDescription';
                objRetailProgram.IsPayToDealer__c = false;
            }
            return objRetailProgram;
        }
        set;
    }

    /************************************************************************************
     *  RetailProgramItem__c
     *************************************************************************************/
    public static RetailProgramItem__c objRetailProgramItem{
        get {
            if (objRetailProgramItem == null) {
                if (objRetailProgram.Id == null) insert objRetailProgram;
                if (objRetailProgramMaster.Id == null) insert objRetailProgramMaster;
                if (objProductTractor.Id == null) insert objProductTractor;
                if (objSalesperson.Id == null) insert objSalesperson;
                if (objAssetTractor.Id == null) insert objAssetTractor;
                objRetailProgramItem = new RetailProgramItem__c();
                objRetailProgramItem.RetailProgramID__c = objRetailProgram.Id;
                objRetailProgramItem.RetailProgramMasterID__c = objRetailProgramMaster.Id; //Retail Program Master의 id
                objRetailProgramItem.ProductID__c = objProductTractor.Id;
                objRetailProgramItem.SalespersonId__c = objSalesperson.Id;
                objRetailProgramItem.Asset__c = objAssetTractor.Id;
                objRetailProgramItem.Status__c = 'Approved';
                objRetailProgramItem.Adjusted__c = 10;
                objRetailProgramItem.Payout__c = 1;
                objRetailProgramItem.Unit__c = 1;
                objRetailProgramItem.Claimed__c = 12.0;
                //objRetailProgramItem.Description__c = 'Test';
            }
            return objRetailProgramItem;
        }
        set;
    }

    /************************************************************************************
     *  PayoutStructure__c
     *************************************************************************************/
    public static PayoutStructure__c objPayoutStructure{
        get {
            if (objPayoutStructure == null) {
                if (objRetailProgramMaster.Id == null) insert objRetailProgramMaster;
                objPayoutStructure = new PayoutStructure__c();
                objPayoutStructure.RetailProgramID__c = objRetailProgramMaster.Id; //Retail Program Master의 id
                objPayoutStructure.Registered__c = 10;
                objPayoutStructure.Amount__c = 10;
            }
            return objPayoutStructure;
        }
        set;
    }

    /************************************************************************************
     *  RetailProgramMaster__c
     *************************************************************************************/
    public static RetailProgramMaster__c objRetailProgramMaster{
        get {
            if (objRetailProgramMaster == null) {
                objRetailProgramMaster = new RetailProgramMaster__c();
                objRetailProgramMaster.Name = 'test1';
                objRetailProgramMaster.ProgramType__c = 'Volume Incentive';
                objRetailProgramMaster.PricingStructure__c = 'Dynamic';
                objRetailProgramMaster.ProgramType2__c = 'others';
                objRetailProgramMaster.IsAllowMultipleTimes__c = false;
                objRetailProgramMaster.IsFile__c = false;
                objRetailProgramMaster.Notes__c = 'test';
                objRetailProgramMaster.AdminNotes__c = 'test';
                objRetailProgramMaster.StartDate__c = Date.newInstance(2017, 12, 09);
                objRetailProgramMaster.EndDate__c = Date.newInstance(2017, 12, 10);
            }
            return objRetailProgramMaster;
        }
        set;
    }

    /************************************************************************************
     *  RetailProgramMasterItem__c
     *************************************************************************************/
    public static RetailProgramMasterItem__c objRetailProgramMasterItem{
        get {
            if (objRetailProgramMasterItem == null) {
                // if (objProductTractor.Id == null) insert objProductTractor;
                if (objRetailProgramMaster.Id == null) insert objRetailProgramMaster;
                objRetailProgramMasterItem = new RetailProgramMasterItem__c();
                // objRetailProgramMasterItem.ProductID__c = objProductTractor.Id;
                objRetailProgramMasterItem.RetailProgramID__c = objRetailProgramMaster.Id;
                objRetailProgramMasterItem.Amount__c = 1;
                objRetailProgramMasterItem.Discount__c = 1;
                objRetailProgramMasterItem.Unit__c = 1;
                objRetailProgramMasterItem.Payout__c = 1;
            }
            return objRetailProgramMasterItem;
        }
        set;
    }

    /************************************************************************************
     *  Knowledge  (RecordType : Manual)
     *************************************************************************************/
    public static Knowledge__kav objKnowledge{
        get {
            if (objKnowledge == null) {
                objKnowledge = new Knowledge__kav();
                // objKnowledge.RecordTypeId = strManualRT;
                objKnowledge.ValidationStatus = 'Work In Progress';
                objKnowledge.Title = 'Title';
                objKnowledge.UrlName = 'Title';
                objKnowledge.Answer__c = 'Answer';
                //objKnowledge.Description__c = 'description';
            }
            return objKnowledge;
        }
        set;
    }

    /************************************************************************************
     *  Address__c 
     *************************************************************************************/
    public static Address__c objAddress{
        get {
            if (objAddress == null) {
//                if (objAccount.Id == null) insert objAccount;
                objAddress = new Address__c();
                objAddress.Name = 'new address';
//                objAddress.Dealership__c = objAccount.Id;
                objAddress.BillorShip__c = 'Shipping address';
            }
            return objAddress;
        }
        set;
    }

    /************************************************************************************
        *  EngineReplacement__c
        *************************************************************************************/
    public static EngineReplacement__c objEngineReplacement{
        get {
            if (objEngineReplacement == null) {
                if (objAssetTractor.Id == null) insert objAssetTractor;
//                if (objAccount.Id == null) insert objAccount;
                objEngineReplacement = new EngineReplacement__c();
                objEngineReplacement.Status__c = 'Created';
                objEngineReplacement.EngineSerialNumber__c = 'E1234';
                objEngineReplacement.DealershipID__c = objAccount.Id;
                objEngineReplacement.AssetId__c = objAssetTractor.Id;
            }
            return objEngineReplacement;
        }
        set;
    }

    /************************************************************************************
     *  ContentVersion
     *************************************************************************************/
    public static ContentVersion objContentVersion {
        get {
            if (objContentVersion == null) {
                if(objProductTractor == null) insert objProductTractor;
                objContentVersion = new ContentVersion();
                objContentVersion.title = 'Test';
                objContentVersion.FirstPublishLocationId = objProductTractor.Id;
                objContentVersion.PathOnClient = 'Test';
                Blob b = Blob.valueOf('This is version data');

                objContentVersion.VersionData = Blob.valueOf(EncodingUtil.base64Encode(b));
            }
            return objContentVersion;
        }
        set;
    }

    public static void createObj() {
        if (objUserTYMUSA == null) insert objUserTYMUSA;
        if (objUserTYMDealer == null) insert objUserTYMDealer;
        if (objAccount == null) insert objAccount;
        if (objEndCustomer == null) insert objEndCustomer;
        if (objSalesperson == null) insert objSalesperson;
        if (objProductTractor == null) insert objProductTractor;
        if (objProductParts == null) insert objProductParts;
        if (objProductHierarchy == null) insert objProductHierarchy;
        if (objClaim == null) insert objClaim;
        if (objLaborCode == null) insert objLaborCode;
        if (objLaborCodeMaster == null) insert objLaborCodeMaster;
        if (objParts == null) insert objParts;
        if (objPartsOrder == null) insert objPartsOrder;
        if (objPartsOrderItem == null) insert objPartsOrderItem;
        if (objOrders == null) insert objOrders;
        if (objProductOrderItem == null) insert objProductOrderItem;
        if (objProductOrderSummary == null) insert objProductOrderSummary;
        if (objAssetTractor == null) insert objAssetTractor;
        if (objAssetLoader == null) insert objAssetLoader;
        if (objAssetBackhoe == null) insert objAssetBackhoe;
        if (objAssetMidMountMower == null) insert objAssetMidMountMower;
        if (objAssetCabin == null) insert objAssetCabin;
        if (objWarranty == null) insert objWarranty;
        if (objARInvoice == null) insert objARInvoice;
        if (objARInvoiceItem == null) insert objARInvoiceItem;
        if (objPriceList == null) insert objPriceList;
        if (objBasePriceList == null) insert objBasePriceList;
        if (objPriceListEntry == null) insert objPriceListEntry;
        if (objRetailProgram == null) insert objRetailProgram;
        if (objRetailProgramItem == null) insert objRetailProgramItem;
        if (objPayoutStructure == null) insert objPayoutStructure;
        if (objRetailProgramMaster == null) insert objRetailProgramMaster;
        if (objRetailProgramMasterItem == null) insert objRetailProgramMasterItem;
        if (objKnowledge == null) insert objKnowledge;
        if (objAddress == null) insert objAddress;
        if (objEngineReplacement == null) insert objEngineReplacement;
    }
}