({
// https://docs.coveo.com/en/1375/coveo-for-salesforce/searchui-lightning-component 
  // LightningComponentController.js
  doInit: function (component, event, helper) {
    var auraSimpleController = component.find(
      "auraSimpleController"
    );
    var coveoSearchUI = cCommunitySearchUIComponent.get("v.searchUI");
    coveoSearchUI.executeImmediate(function (cmp, rootInterface, Coveo) {
      console.log("executeImmediate");
    });
    coveoSearchUI.registerAfterInit(function (cmp, rootInterface, Coveo) {
      console.log("registerAfterInit");
      var root = Coveo.$$(document).find("#search");
      Coveo.$$(root).on("afterInitialization", function (e, args) {
        $('.CoveoDynamicFacet[data-title="Source"]').coveo().selectValue('Pete_GW2');
      });
    });
  }
});
