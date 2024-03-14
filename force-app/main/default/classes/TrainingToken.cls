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
