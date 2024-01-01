/************************************************************************************
 * File Name        : ContentVersion_tr
 * Author           : ugon96@gmail.com
 * Date             : 2023-10-16
 * @Group              : Daeunextier 
 * Description      : 
 * Modification Log
 * Ver       Date            Author                 Modification
 * 1.0     2023-10-16       ugon96@gmail.com         Initial Version
*************************************************************************************/

trigger ContentVersion_tr on ContentVersion (after insert, after delete) {
    new ContentVersion_tr().run();
}