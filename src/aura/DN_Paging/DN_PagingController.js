/**
 * Created by 천유정 on 2022-08-17.
 */

({
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
    },
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    }
});