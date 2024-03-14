
Pre requisites
https://trailhead.salesforce.com/content/learn/modules/lex_dev_lc_vf_fundamentals
https://trailhead.salesforce.com/content/learn/projects/quickstart-lightning-components
https://trailhead.salesforce.com/content/learn/modules/lex_dev_lc_basics?trail_id=lex_dev



1. Structure of a Custom Component
	- CMP -> The Wrapper
		- Aura:Component
		- Aura:Attributes
		- Aura:Handler
		- CoveoV2:CommunitySearch
		- Static Resource
	- Controller
		- Function
	- Design
		- Attributes

2. Aura Component with a Simple Controller (Auto Select a Facet)
	- Create a Component with a Simple Controller Use Case
```html
<aura:component access="global" implements='forceCommunity:availableForAllPageTypes'>
  <aura:attribute name="name" type="String" default="Pete_CommunitySearchLoggedIn" access="global" />
  <aura:attribute name="debug" type="Boolean" default="false" access="global" />
  <aura:attribute name="searchHub" type="String" default="" access="global" />
  <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
  
  <CoveoV2:CommunitySearch  name="{!v.name}"
                            aura:id="auraSimpleController"
                            debug="{!v.debug}"
                            searchHub="{!v.searchHub}"
                            customScripts="{!$Resource.searchUI}">
  </CoveoV2:CommunitySearch>
</aura:component>
```

```html
<design:component label="Community Search With all the SearchUI component">
    <design:attribute name="name" label="Name" />
    <design:attribute name="debug" label="Debug" />
    <design:attribute name="searchHub" label="Search Hub" />
</design:component>
```

```js
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
```

3. Aura Component with a Custom Token

TrainingToken.cls
```java
public with sharing class TrainingToken {
    // Annotate the method so that it's accessible from the Lightning component
     @AuraEnabled
     public static string getToken() {
         // Generate a token using the Globals class provided by Coveo.
         // See the Globals Class documentation: https://docs.coveo.com/en/1075/coveo-for-salesforce/globals-class
        Map<String, Object> endpoint = CoveoV2.Globals.getEndpointData();
        endpoint.put('token', CoveoV2.Globals.generateSearchToken(new Map<String, Object> {
         'searchHub' => '<MY_SEARCH_HUB>',
         'additionalUserIdentities' => new List < CoveoV2.UserIdentity > {
                new CoveoV2.UserIdentity('goku@planetvegeta.com')
            }
         }));
        return JSON.serialize(endpoint);
    }
}

```

-------------------------------------------------------
EndpointTrainingToken

```html
<aura:component controller="<MY_APEX_CLASS>" >
    <!-- GET THE ENDPOINT INITIALIZATION DATA -->
    <aura:method name="getEndpoint" action="{!c.getTokenAction}" access="global">
        <aura:attribute name="name" type="String" />
    </aura:method>
    <!-- RENEW THE ENDPOINT ACCESS TOKEN -->
    <aura:method name="renewAccessToken" action="{!c.getTokenAction}" access="global">
        <aura:attribute name="name" type="String" />
    </aura:method>
</aura:component>

```


```js
({
    getTokenAction: function(component, event, helper) {
        const getTokenAction = component.get('c.getToken');
        var getTokenPromise = new Promise(function (resolve, reject) {
            getTokenAction.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var responseData = response.getReturnValue();
                    resolve(JSON.parse(responseData));
                } else if (response.getState() === 'ERROR') {
                    reject(Error('Error generating token'));
                }
            });
        });

        $A.enqueueAction(getTokenAction);
        return getTokenPromise;
    }
});

```

-----------------------------------------
AuraWrapperTrainingToken
```HTML
<!-- https://docs.coveo.com/en/2745/coveo-for-salesforce/generating-a-custom-search-token-for-lightning-components-using-lightning-locker -->
<aura:component implements="forceCommunity:availableForAllPageTypes" access="global" >
    <aura:attribute name="name" type="String" default="" access="global" />
    <aura:attribute name="debug" type="Boolean" default="false" access="global" />
    <aura:attribute name="searchHub" type="String" default="" access="global" />
  
<aura:attribute name="endpointHandler" type="Aura.Component[]" access="global">
    <c:cEndpointHandlerComm></c:cEndpointHandlerComm>
</aura:attribute> 

    <CoveoV2:CommunitySearch  
                        name="{!v.name}" 
                        aura:id="coveoCommunitySearch"
                        debug="{!v.debug}"
                        searchHub="{!v.searchHub}"
                        endpointHandler="{!v.endpointHandler}"
>
    </CoveoV2:CommunitySearch>

</aura:component>
```

4. Aura Component with a Static resources

