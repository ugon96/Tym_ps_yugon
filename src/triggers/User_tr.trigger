/************************************************************************************
 * File Name        : User_tr
 * Author           : ugon96@gmail.com
 * Date             : 2023-11-13
 * @Group              : Daeunextier 
 * Description      : 
 * Modification Log
 * Ver       Date            Author                 Modification
 * 1.0     2023-11-13       ugon96@gmail.com         Initial Version
*************************************************************************************/

trigger User_tr on User (after insert, after update) {
    new User_tr().run();
}