/**
 * Created by DAEU on 2023-12-06 (006).
 */

public with sharing class ToolingAPIUtility {
    public class RootObjectMeta{
//        Attributes attributes;
        Metadata Metadata;
        public String FullName;
//        String Id;
//        String DeveloperName;
//        String MasterLabel;
//        String Description;
//        String NamespacePrefix;
//        String ManageableState;
//        String CreatedDate;
//        String CreatedById;
//        String LastModifiedDate;
//        String LastModifiedById;
    }
    public class Attributes{
        String type;
        String url;
    }

    public class Metadata {
        public List<CustomValue> customValue;
        public String description;
        public String masterLabel;
//        public Boolean sorted;
//        public String urls;
    }

    public class CustomValue {
        public String color;
//        public Boolean default;
        public String description;
        public Boolean isActive;
        public String label;
//        public String urls;
        public String valueName;
    }

    public class CustomField {
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public String queryLocator;
        public String entityTypeName;
        public List<Record> records;
    }


    public class Record {
        public Attributes attributes;
        public String Id;
        public String MasterLabel;
    }
    public static String getCustomFieldID() {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        System.debug(Url.getOrgDomainUrl().toExternalForm());
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()+'/services/data/v59.0/tooling/query/?q=Select+Id,MasterLabel+FROM+GlobalValueSet+WHERE+developername=\'state\'');

        req.setMethod('GET');

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getStatus());
        System.debug('res.getBody() :: ' + res.getBody());

        CustomField customField = (CustomField) JSON.deserialize((res.getBody()), CustomField.class);


        return customField.records[0].attributes.url;
    }
    public static HttpResponse ToolingAPI() {

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('https://tym--dev.sandbox.my.salesforce.com/services/data/v59.0/tooling/sobjects/GlobalValueSet/000000000000000AAA');

        req.setMethod('GET');

        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getStatus());
        System.debug('res.getBody() :: ' + res.getBody());

        RootObjectMeta objRoot = (RootObjectMeta) JSON.deserialize(res.getBody(), RootObjectMeta.class);
        System.debug(objRoot);

        CustomValue objCV = new CustomValue();
        objCV.isActive = true;
        objCV.label = 'Test_tk1';
        objCV.valueName = 'Test1';

        CustomValue objCVTest = new CustomValue();
        objCVTest.isActive = true;
        objCVTest.label = 'Test_tk_test';
        objCVTest.valueName = 'Test_tk_test';

        objRoot.Metadata.customValue.add(objCV);
        objRoot.Metadata.customValue.add(objCVTest);
        objRoot.FullName += '__gvs';





        req.setEndpoint('https://tym--dev.sandbox.my.salesforce.com/services/data/v59.0/tooling/sobjects/GlobalValueSet/0Nt1m000000A7YxCAK');
        req.setMethod('PATCH');

        String strBody = JSON.serialize(objRoot);
        System.debug('strBody ; ' + strBody);
        req.setBody(strBody);

        res = h.send(req);
        System.debug(res);
        System.debug(res.getStatus());
        System.debug(res.getBody());

        return res;
    }
}