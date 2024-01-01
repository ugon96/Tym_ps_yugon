/*************************************************************
 * @author : th.kim
 * @date : 2023-10-04
 * @group :
 * @group-content :
 * @description :
==============================================================
 * Ver          Date            Author          Modification
   1.0          2023-10-04      th.kim          Initial Version
**************************************************************/

@IsTest
public class TYM_ForecastController_TEST {

    static Product2 product;
    static Account acc;
    static Forecast__c forecast;
    static ContentVersion cv;
    static String userId = UserInfo.getUserId();
    static String searchYear = '2023';

    static {
        product = new Product2(
                Name = 'test',
                ItemGroupCode__c = '112'
        );
        insert product;

        acc = new Account(
                Name = 'test'
        );
        insert acc;

        cv = new ContentVersion(
            Title = 'test',
            FirstPublishLocationId = product.Id,
            VersionData = Blob.valueOf('/services/data/v58.0/sobjects/ContentVersion/0681m000002VVkRAAW/VersionData'),
            PathOnClient = 'test.png'
        );
        insert cv;

        forecast = new Forecast__c(
                X1__c = 0,
                X2__c = 0,
                X3__c = 0,
                X4__c = 0,
                X5__c = 0,
                X6__c = 0,
                X7__c = 0,
                X8__c = 0,
                X9__c = 0,
                X10__c = 0,
                X11__c = 0,
                X12__c = 0,
                Year__c = searchYear,
                Product__c = product.Id,
                Dealership__c = acc.Id
        );
        insert forecast;
    }

    @IsTest
    static void testSearchForecast() {
        Test.startTest();
        TYM_ForecastController.searchForecast(userId, searchYear);
        Test.stopTest();
    }

    @IsTest
    static void testDmlForecast() {
        Test.startTest();
        List<Product2> prdList = [SELECT Id, Name FROM Product2];
        List<Forecast__c> fList = [
            SELECT Id,
                    Name,
                    X1__c,
                    X2__c,
                    X3__c,
                    X4__c,
                    X5__c,
                    X6__c,
                    X7__c,
                    X8__c,
                    X9__c,
                    X10__c,
                    X11__c,
                    X12__c,
                    Year__c,
                    Product__c,
                    Dealership__c
            FROM Forecast__c
        ];

        List<TYM_ForecastController.Product2Wrapper> wrapperList = new List<TYM_ForecastController.Product2Wrapper>();
        for(Product2 p : prdList) {
            String basicUrl = '/sfc/servlet.shepherd/version/download/';
            TYM_ForecastController.Product2Wrapper wrapper = new TYM_ForecastController.Product2Wrapper();
            wrapper.Id = p.Id;
            wrapper.Name = p.Name;
            wrapper.imgUrl = basicUrl + p.Id;
            List<Forecast__c> newFList = new List<Forecast__c>();
            for(Forecast__c f : fList) {
                newFList.add(f);
            }
            wrapper.listForecast = newFList;
            wrapperList.add(wrapper);
        }
        List<String> deleteList = new List<String>();
        for(Forecast__c data : [SELECT Id FROM Forecast__c]) {
            deleteList.add(data.Id);
        }

        TYM_ForecastController.dmlForecast(JSON.serialize(wrapperList), userId, searchYear, deleteList);
        Test.stopTest();
    }
}