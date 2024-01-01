({
    showToast: function(component, event, helper) {
        var title = "Success";
        var message = "Success.";
        var type = "success"; 
        var mode = "dismissable";

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "mode": mode,
            "type" : type
        });
        toastEvent.fire();
    },

    showToastError: function(component, event, helper) {
        var title = "Error";
        var message = "Error.";
        var type = "error"; 
        var mode = "dismissable";

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "mode": mode,
            "type" : type
        });
        toastEvent.fire();
    },

})