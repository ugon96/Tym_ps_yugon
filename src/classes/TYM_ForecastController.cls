/*************************************************************
 * @author : th.kim
 * @date : 2023-09-14
 * @group :
 * @group-content :
 * @description : Product별 Forecast 데이터 생성, 업데이트, 삭제
==============================================================
  * Ver       Date            Author            Modification
    1.0       2023-09-14      th.kim            Initial Version
**************************************************************/

public without sharing class TYM_ForecastController {

    public class Product2Wrapper {
        public String Id;
        public String Name;
        public String imgUrl;
        public Boolean isExistence;
        public List<Forecast__c> listForecast;
    }

    /**
     * @author th.kim
     * @description Product별 Forecast 데이터 가져오기
     * @param userId 사용자 Id
     * @param searchYear 검색한 년도
     *
     * @return mapReturn
     */
    @AuraEnabled
    public static Map<String, Object> searchForecast(String userId, String searchYear) {
        Map<String, Object> mapReturn = new Map<String, Object>();
        try {
            List<User> listUser = getUser(userId);
            if (!listUser.isEmpty()) {
                String accId = getAccountId(listUser);
                Set<String> fIdSet = new Set<String>();
                List<String> listIdProduct = new List<String>();
                List<Product2> listProduct = getProduct(accId, searchYear, fIdSet, listIdProduct);
                System.debug('listProduct: ' + listProduct);
                if (!listProduct.isEmpty()) {
                    Set<Id> prdIdSet = new Set<Id>();
                    for (Product2 prd : listProduct) {
                        prdIdSet.add(prd.Id);
                    }
                    Map<String, String> imgMap = getImgUrl(prdIdSet);
                    List<Product2Wrapper> listProductWrapper = new List<Product2Wrapper>();
                    for (Product2 product : listProduct) {
                        String imgUrl;
                        if (imgMap.containsKey(product.Id)) imgUrl = imgMap.get(product.Id);
                        Product2Wrapper proWrapper = new Product2Wrapper();
                        System.debug('Forecast__r: ' + product.Forecasts__r.size());
                        if (product.Forecasts__r.size() > 0) {
                            proWrapper.Id = product.Id;
                            proWrapper.Name = product.Name;
                            proWrapper.isExistence = true;
                            proWrapper.imgUrl = imgUrl;
                            proWrapper.listForecast = product.Forecasts__r;
                            listProductWrapper.add(proWrapper);
                        } else {
                            List<Forecast__c> listForecast = new List<Forecast__c>();
                            Forecast__c newForecast = new Forecast__c();
                            newForecast.Product__c = product.Id;
                            newForecast.X1__c = 0;
                            newForecast.X2__c = 0;
                            newForecast.X3__c = 0;
                            newForecast.X4__c = 0;
                            newForecast.X5__c = 0;
                            newForecast.X6__c = 0;
                            newForecast.X7__c = 0;
                            newForecast.X8__c = 0;
                            newForecast.X9__c = 0;
                            newForecast.X10__c = 0;
                            newForecast.X11__c = 0;
                            newForecast.X12__c = 0;
                            // newForecast.Probability01__c = 0;
                            // newForecast.Probability02__c = 0;
                            // newForecast.Probability03__c = 0;
                            // newForecast.Probability04__c = 0;
                            // newForecast.Probability05__c = 0;
                            // newForecast.Probability06__c = 0;
                            // newForecast.Probability07__c = 0;
                            // newForecast.Probability08__c = 0;
                            // newForecast.Probability09__c = 0;
                            // newForecast.Probability10__c = 0;
                            // newForecast.Probability11__c = 0;
                            // newForecast.Probability12__c = 0;
                            newForecast.Year__c = searchYear;
                            newForecast.Dealership__c = accId;
                            listForecast.add(newForecast);
                            proWrapper.Id = product.Id;
                            proWrapper.Name = product.Name;
                            proWrapper.imgUrl = imgUrl;
                            proWrapper.isExistence = false;
                            proWrapper.listForecast = listForecast;
                            listProductWrapper.add(proWrapper);
                        }
                    }
                    System.debug('products: ' + JSON.serialize(listProductWrapper));
                    mapReturn.put('products', JSON.serialize(listProductWrapper));
                } else {
                    mapReturn.put('null', null);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mapReturn;
    }

    /**
     * @author th.kim
     * @description Product별 Forecast 생성, 업데이트, 삭제
     * @param productWrapperJSON product JSON 데이터
     * @param userId 사용자 Id
     * @param searchYear 검색한 년도
     * @param deleteList 삭제할 Forecast Id 리스트
     *
     * @return mapReturn
     */
    @AuraEnabled
    public static Map<String, Object> dmlForecast(String productWrapperJSON, String userId, String searchYear, List<String> deleteList) {

        Map<String, Object> mapReturn = new Map<String, Object>();
        List<Forecast__c> listCreate = new List<Forecast__c>();
        List<Forecast__c> listUpdate = new List<Forecast__c>();
        List<String> listIdProduct = new List<String>();
        List<Product2> listProductAfterDML = new List<Product2>();
        List<Product2Wrapper> listProductWrapperReturn = new List<Product2Wrapper>();

        try {
            List<Product2Wrapper> listProductWrapper = (List<Product2Wrapper>) JSON.deserialize(productWrapperJSON, List<Product2Wrapper>.class);
            System.debug('listProductWrapper: ' + listProductWrapper);
            for (Product2Wrapper item : listProductWrapper) {
                listIdProduct.add(item.Id);
                for (Forecast__c itemForecast : item.listForecast) {
                    if (String.isEmpty(itemForecast.Id)) {
                        listCreate.add(itemForecast);
                    } else {
                        listUpdate.add(itemForecast);
                    }
                }
            }

            System.debug('listCreate: ' + listCreate);
            System.debug('listUpdate: ' + listUpdate);

            Set<String> fIdSet = new Set<String>();
            if (!listCreate.isEmpty()) {
                 insert listCreate;
                for (Forecast__c f : listCreate) {
                    fIdSet.add(f.Id);
                }
            }
            if (!listUpdate.isEmpty()) {
                update listUpdate;
                for (Forecast__c f : listUpdate) {
                    fIdSet.add(f.Id);
                }
            }

            List<Forecast__c> deleteForecastList = [SELECT Id FROM Forecast__c WHERE Id IN :deleteList];
            if(!deleteForecastList.isEmpty()) delete deleteForecastList;
            System.debug('deleteForecastList :: ' + deleteForecastList);

            List<User> listUser = getUser(userId);
            String accId = getAccountId(listUser);
            listProductAfterDML = getProduct(accId, searchYear, fIdSet, listIdProduct);
            System.debug('listProductAfterDML: ' + listProductAfterDML);
            Set<Id> prdIdSet = new Set<Id>();
            for (Product2 prd : listProductAfterDML) {
                prdIdSet.add(prd.Id);
            }
            Map<String, String> imgMap = getImgUrl(prdIdSet);
            for (Product2 itemPro : listProductAfterDML) {
                String imgUrl;
                if (imgMap.containsKey(itemPro.Id)) imgUrl = imgMap.get(itemPro.Id);
                Product2Wrapper proWrapper = new Product2Wrapper();
                proWrapper.Id = itemPro.Id;
                proWrapper.Name = itemPro.Name;
                proWrapper.imgUrl = imgUrl;
                proWrapper.isExistence = true;
                proWrapper.listForecast = itemPro.Forecasts__r;
                listProductWrapperReturn.add(proWrapper);
            }
            mapReturn.put('products', JSON.serialize(listProductWrapperReturn));
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return mapReturn;
    }

    /**
     * @author th.kim
     * @description 현재 사용자 리스트 가져오기
     * @param userId 사용자 Id
     *
     * @return listUser
     */
    private static List<User> getUser(String userId) {
        try {
            List<User> listUser = [
                    SELECT Id, Username, UserType, Profile.Name, ContactId, AccountId
                    FROM User
                    WHERE Id = :userId
                    LIMIT 1
            ];
            return listUser;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author th.kim
     * @description 현재 Account 사용자의 정보 가져오기
     * @param listUser 현재 사용자 리스트 데이터
     *
     * @return accId
     */
    private static String getAccountId(List<User> listUser) {
        String accId = listUser[0].AccountId;
        return accId;
    }

    /**
     * @author th.kim
     * @description product에 담겨 있는 파일 이미지 띄우기 위한 url 가져오기
     * @param prdIdSet Product Id Set
     *
     * @return returnMap
     */
    private static Map<String, String> getImgUrl(Set<Id> prdIdSet) {
        Map<String, String> returnMap = new Map<String, String>();
        try {
            Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();

            List<ContentVersion> cvList = [SELECT Id, FirstPublishLocationId, CreatedDate FROM ContentVersion WHERE FirstPublishLocationId IN :prdIdSet];

            // 중복 제거하고 최근 값만 Map에 추가
            for (ContentVersion cv : cvList) {
                if (!cvMap.containsKey(cv.FirstPublishLocationId) || cv.CreatedDate > cvMap.get(cv.FirstPublishLocationId).CreatedDate) {
                    cvMap.put(cv.FirstPublishLocationId, cv);
                }
            }

            String basicUrl = '/sfc/servlet.shepherd/version/download/';
            for (ContentVersion cv : cvMap.values()) {
                returnMap.put(cv.FirstPublishLocationId, basicUrl + cv.Id);
            }

            if (returnMap.isEmpty()) returnMap.put('null', null);
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            returnMap.put('null', null);
        }
        return returnMap;
    }

    /**
     * @author th.kim
     * @description 조건별 Product의 정보 가져오기 위한 Dynamic Query
     * @param accId 현재 사용자의 Account Id
     * @param year 선택한 년도
     * @param fIdSet dml 작업 후 리프레쉬를 위한 Upsert 완료된 Forecast Id Set
     * @param listIdProduct Product Id 리스트
     *
     * @return prdList
     */
    private static List<Product2> getProduct(String accId, String year, Set<String> fIdSet, List<String> listIdProduct) {
        try {
            String query;
            query = 'SELECT Id, Name, ';
            query += ' (SELECT Id, Product__c, X1__c, X2__c, X3__c, X4__c, X5__c, X6__c, X7__c, X8__c, X9__c, X10__c, X11__c, X12__c ';
            query += ' FROM Forecasts__r ';
            query += ' WHERE Dealership__c = :accId AND Year__c = :year ';
            if (!fIdSet.isEmpty()) query += ' AND Id IN :fIdSet ';
            query += ') FROM Product2 ';
            query += ' WHERE ItemGroupCode__c = \'112\' ';
            if (!listIdProduct.isEmpty()) query += ' AND Id IN :listIdProduct ';
            query += ' ORDER BY Product2.Name ';

            System.debug('query :: ' + query);
            List<Product2> prdList = Database.query(query);
            System.debug('prdList :: ' + prdList);

            return prdList;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }
}