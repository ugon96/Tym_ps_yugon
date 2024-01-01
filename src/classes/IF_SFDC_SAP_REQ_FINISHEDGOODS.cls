/**
 * Created by nhkim on 2023-12-05.
 */

public with sharing class IF_SFDC_SAP_REQ_FINISHEDGOODS {
    private static final String IFID = 'IF_SFDC_SAP_REQ_FINISHEDGOODS';

    private String ItemCode;

    public IF_SFDC_SAP_REQ_FINISHEDGOODS(String itemCode) {
        this.ItemCode = itemCode;
    }

    private class Output {
        String responseCode;
        String ErrorMessage;
        // Data라는 명칭은 받아오는 결과에 따라 수정되어야 함
        List<FinishedGoods> Data;
        String isContinue;
    }

    public class FinishedGoods {
        public String ItemCode;
        public String Tractor;
        public String Loader;
        public String Backhoe;
        public String FrontTire;
        public String RearTire;
    }

    public List<FinishedGoods> executeCall() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '완제품 레코드를 SFDC에 생성';

        Integer successCnt = 0;
        Integer failCnt = 0;
        List<String> listErrorMessage = new List<String>();

        String responseBody;

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        List<FinishedGoods> listResult;

        if (ItemCode == null || ItemCode == '') {
            ItemCode = 'new';
        }

        try {
            IFUtil objIF = new IFUtil(IFID);
            HttpResponse response = objIF.webCallout('/' + this.ItemCode, true);
            responseBody = response.getBody();

            if (response.getStatusCode() == 200) {
                Output objOutput = (Output) JSON.deserialize(response.getBody(), Output.class);

                if (objOutput.Data != null) {
                    listResult = objOutput.Data;
                }
                else {
                    listResult = null;
                }
            }
            else {
                strStatus = 'ERROR';
                strMessage = response.getBody();
            }
        }
        catch (Exception e) {
            System.debug('Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber());
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = 'Error :: ' + e.getMessage() + 'Line Num : ' + e.getLineNumber();
        }

        LogWrapper.status = strStatus;
        LogWrapper.errorCode = strCode;
        LogWrapper.errorMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.responseBody = responseBody;

        IFUtil objIF = new IFUtil(IFID);
        objIF.setLog(LogWrapper);

        return listResult;
    }
}