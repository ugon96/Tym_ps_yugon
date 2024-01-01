({
  doInit: function (c, event, helper) {
    //auth may need to be restarted in safari if Storage Access is not granted on load
    let authRestarted = false;
    //get current user context
    const instanceMatch = window.location.href.match(new RegExp("https://(.*?)\\."));
    const instanceId = instanceMatch[1];
    const userId = $A.get("$SObjectType.CurrentUser.Id");
    //build the agents chat url
    c.set(
      "v.agentsFrame",
      "https://adminagents.ai/canvas/record/" +
        c.get("v.sObjectName") +
        "/" +
        instanceId +
        "/" +
        userId +
        "/" +
        c.get("v.recordId") +
        "/" +
        c.get("v.contextId") +
        "/" +
        c.get("v.agents") +
        "/new"
    );
    //render the agents chat frame
    c.set("v.ready", true);
    //listen to the frame in case Storage Access is granted post load
    window.addEventListener(
      "message",
      function (e) {
        if (!e.origin.endsWith("adminagents.ai")) {
          return;
        }
        //auth-check is the agents chat frame checking if the canvas auth is complete
        //only respond if it is the case
        if (e.data == "auth-check" && !c.get("v.canvasLoading")) {
          e.source.postMessage({ auth: instanceId + "-" + userId }, "*");
        }
        //auth-restart in case Storage Access is granted post load we need the canvas auth to run again but only one.
        if (e.data == "auth-restart" && !authRestarted) {
          authRestarted = true;
          c.set("v.canvasLoading", true);
        }
      },
      false
    );
  },
  canvasAppLoad: function (c, event, helper) {
    c.set("v.canvasLoading", false);
  },
});