window.coveoCustomScripts['default'] = function (promise) {
    
  //Initialize on domcontentloaded
  // Save a constant which is a reference to the Coveo Search interface
  // Used throughout js code to reference
  const Search = Coveo.$$(document).find("#search");
        
  /*
      @Community
      After Coveo has performed its initialization, we need to do a little more setup.
      This setup creates the helper functions for fields where we need to do a little processing on the value before showing it.
  */

  Coveo.$$(Search).on("afterInitialization", () => {
    Coveo.TemplateHelpers.registerTemplateHelper("source", (sourceValue) => {
                    console.log('inside the questionstatusupdate');
                    console.log(sourceValue);
                    if (sourceValue == 'Pete_Dev_SF') return "Main Source";
                    else return "Not Main Source";
                });

  })
}
