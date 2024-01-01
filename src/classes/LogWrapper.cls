/************************************************************************************
 * File Name   		: LogWrapper
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-10-20
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-10-20       ugon96@gmail.com         Initial Version
*************************************************************************************/

public class LogWrapper {
    public String status;
    public String errorCode;
    public String errorMessage;
    public Datetime requestTime;
    public String requestHeader;
    public String requestBody;
    public Datetime responseTime;
    public String responseHeader;
    public String responseBody;
    public Integer requestCount;    // 몇 번째 Call인지 체크
    public String enqueueJobId;    // 몇 번째 Call인지 체크

    public LogWrapper() {
    }
}