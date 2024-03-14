public with sharing class TrainingTokenComplex {
    private static string getProfileUserType() {
        Profile profile = [SELECT Name, Id, UserType FROM Profile WHERE Id =: UserInfo.getProfileId()];
        return profile.UserType;
    }
    
    public static string getFilter() {
        String filter = '';
        String kbExpression = '';
        switch on getProfileUserType() {
            // Partner
            when 'System Administrator' {
                kbExpression += ' (@objecttype=Knowledge AND (@sfisvisibleinpkb==True OR @sfkbisvisibleinprm==True))';
            }
            // Customer
            when 'CustomerSuccess' {
                kbExpression += ' (@objecttype=Knowledge AND (@sfisvisibleinpkb==True OR @sfkbisvisibleincsp==True))';
            }
            // Employee - See all internal KB
            when 'Standard' {
                kbExpression += ' (@objecttype=Knowledge AND @sfisvisibleinapp=True)';
            }
            // Member / Guest
            when 'Member', 'Guest' {
                kbExpression += ' (@objecttype=Knowledge AND @sfisvisibleinpkb==True)';
            }
            when
            else {
                kbExpression += ' (@sfisvisibleinpkb==True)';
            }
        }

        String filterRest = '@source=(Pete) NOT @objecttype==(Account)';
        filter = String.format('({0}) OR ({1})', new String[] {
            filterRest,
            kbExpression
        });
        return filter;
    }


    @AuraEnabled
    public static string getToken() {

        String filter = '';
        // Create the access to my Custom settings
        searchToken__c customSetting = searchToken__c.getOrgDefaults();
        // Generate a token using the Globals class provided by Coveo.
        // See the Globals Class documentation: https://docs.coveo.com/en/1075/coveo-for-salesforce/globals-class
        String token = CoveoV2.Globals.generateSearchToken(new Map < String, Object > {
            'filter' => getFilter(),
            'searchHub' => customSetting.searchHub__c,
            'additionalUserIdentities' => new List < CoveoV2.UserIdentity > {
                new CoveoV2.UserIdentity('goku@saiyan.com'),
                new CoveoV2.UserIdentity('Unauthenticated', 'Email Security Provider', 'VirtualGroup')
            }
        });
        Map < String, Object > endpoint = CoveoV2.Globals.getEndpointData();
        endpoint.put('token', token);
        return JSON.serialize(endpoint);
    }
}
