/**
 * Created by ally6 on 2023-11-22.
 */

({
    fnInit : function(component, event, helper) {
       //Console log 찍고 확인해보기
       console.log('recordId ::' + component.get("v.recordId"));
       //helper로 이동
       helper.getInitData(component);
    },
});