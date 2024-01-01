/************************************************************************************
 * File Name   		: ExceptionClass
 * Author	  		: ugon96@gmail.com
 * Date				: 2023-11-14
 * @Group              : Daeunextier 
 * Description 		: 
 * Modification Log
 * Ver       Date            Author      		    Modification
 * 1.0     2023-11-14       ugon96@gmail.com         Initial Version
*************************************************************************************/

public with sharing class ExceptionClass {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    public static void testExtendedException() {
        try {
            Integer i=0;
            // Your code here
            if (i < 5) throw new OtherException('This is bad');
        } catch (BaseException e) {
            // This catches the OtherException
            System.debug(e.getMessage());
        }
    }
}