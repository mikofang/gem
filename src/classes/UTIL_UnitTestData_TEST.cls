/*
    © 2019, Salesforce.org.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2011 (1.x)
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Provides automated generation of unit test data for tests throughout the org
*/
@isTest
public class UTIL_UnitTestData_TEST {
    /*******************************************************************************************************
    * @description The opportunity closed won stage
    *******************************************************************************************************/
    private static string closedWonStage;
    private static string openStage;
    public static String giftEntryPS = 'Gift Entry';

    /*******************************************************************************************************
    * @description Returns opportunity closed won stage
    * @return String the opportunity closed won stage
    *******************************************************************************************************/
    public static String getClosedWonStage(){
        if (closedWonStage == null){
            List<OpportunityStage> closedWonStages = [select masterlabel from opportunitystage where isActive = true and iswon = true];

            if(closedWonStages.size()>0){
                closedWonStage = closedWonStages[0].masterlabel;
            } else {
                closedWonStage = '';
            }
        }

        return closedWonStage;
    }

    /*******************************************************************************************************
    * @description Returns opportunity open stage
    * @return String the opportunity open stage
    *******************************************************************************************************/
    public static String getOpenStage(){
        if (openStage == null){
            List<OpportunityStage> openStages = [select masterlabel from opportunitystage where isActive = true and isclosed = false];

            if(openStages.size()>0){
                openStage = openStages[0].masterlabel;
            } else {
                openStage = '';
            }
        }

        return openStage;
    }

    /*******************************************************************************************************
    * @description Returns a Contact
    * @return Contact the new Contact
    *******************************************************************************************************/
    public static Contact getContact() {
        Contact contact =  new Contact(FirstName = 'Test', LastName = 'Testerson' + Datetime.now().getTime(),
                hed__WorkEmail__c = 'fakeemail@salesforce.org', hed__Preferred_Email__c = 'Work Email',
                hed__WorkPhone__c = '206-777-8888', hed__PreferredPhone__c = 'Work Phone',OtherCity = 'Seattle');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        contact.setOptions(dmo);
        return contact;
    }

    /*******************************************************************************************************
    * @description Returns an Account
    * @param recTypeId the Account record type id
    * @return Account the new Account
    *******************************************************************************************************/
    public static Account getAccount(ID recTypeId) {
        Account acc = new Account(Name = 'Yet Another Org ' + Datetime.now().getTime(), RecordTypeId = recTypeId, Website = 'salesforce.org');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        acc.setOptions(dmo);
        return acc;
    }

    /*******************************************************************************************************
    * @description Returns a list of new Contacts
    * @param n the number of new Contact
    * @return List<Contact> the list of new Contact
    *******************************************************************************************************/
    public static List<Contact> getMultipleTestContacts(Integer n) {
        List<contact> ContactsToAdd = new List<contact>();
        for(Integer i=0; i<n; i++) {
            Contact newCon = new Contact(FirstName = i + 'Test' + i, LastName = i + 'Contact_forTests' + i, hed__WorkEmail__c = 'fakeemail' + i + '@salesforce.org',
                    hed__Preferred_Email__c = 'Work Email', hed__WorkPhone__c = i + '06-777-888' + i, hed__PreferredPhone__c = 'Work Phone', OtherCity = 'Seattle');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            newCon.setOptions(dmo);
            ContactsToAdd.add(newCon);
        }
        return ContactsToAdd;
    }

    /*******************************************************************************************************
    * @description Returns a list of new Account
    * @param n the number of new Account
    * @return List<Account> the list of new Account
    *******************************************************************************************************/
    public static List<Account> getMultipleTestAccounts(Integer n, ID recTypeId) {
        List<Account> AcctsToAdd = new List<Account>();
        for(Integer i=0; i<n; i++) {
            Account acc = new Account(Name = i + 'Yet Another Org ' + i, RecordTypeId = recTypeId, Website = i + 'salesforce.org');
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            acc.setOptions(dmo);
            AcctsToAdd.add(acc);
        }
        return AcctsToAdd;
    }

    /*******************************************************************************************************
    * @description Returns a new User
    * @param strUsername the name of the new User
    * @return User the new user
    *******************************************************************************************************/
    public static User createNewUserForTests(String strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u;
        // to work around mixed DML errors during tests, you must create user account in its own transaction. got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            u = new User(alias = 'jsmith', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith',
                    languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                    username=strUsername);
            insert u;
        }
        return u;
    }

    /*******************************************************************************************************
    * @description Assign our Gift Entry permission set to the provided user Id
    * @param userId the Id of the user 
    * @return void
    *******************************************************************************************************/
    public static void assignGiftEntryPermissionSetToUser(Id userId) {

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label =: giftEntryPS];
        
        // to work around mixed DML errors during tests, you must create user account in its own transaction. got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
        }
    }

    /*******************************************************************************************************
    * @description Returns a new User
    * @param strUsername the name of the new User
    * @return User the new user
    *******************************************************************************************************/
    public static Opportunity getOpenOpportunity(Contact donor, Decimal amt) {
        Opportunity opp = new Opportunity(
            name = 'Opp ' + Datetime.now().getTime(),
            npsp__Primary_Contact__c = donor.Id,
            StageName = getOpenStage(),
            CloseDate = System.Today(),
            Amount = amt
        );
        return opp;
    }

    /*******************************************************************************************************
    * @description Returns a new User
    * @param strUsername the name of the new User
    * @return User the new user
    *******************************************************************************************************/
    public static npe01__OppPayment__c getUnpaidPayment(Opportunity opp, Decimal amt) {
        npe01__OppPayment__c payment = new npe01__OppPayment__c(
            npe01__Opportunity__c = opp.Id,
            npe01__Scheduled_Date__c = System.Today(),
            npe01__Payment_Amount__c = amt
        );
        return payment;
    }


    /**
     * @description         Create a new user with a given username and profile
     *
     * @param userName      UserName to use
     * @param profileName   Profile to look for. This needs to be a built-in profile e.g. 'Read Only' or 'Standard User'
     *
     * @return              The newly created user
     */
    public static User createNewUserWithProfile(String userName, String profileName) {

        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName];
        User u;
        System.runAs( new User(Id = UserInfo.getUserId())) {
            u = new User(
                    UserName = userName,
                    Alias = 'jsmith',
                    Email = 'jsmith@acme.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Testing',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    TimezoneSidKey = 'America/Los_Angeles'
            );
            insert u;
        }
        return u;
    }

    /******************************************************************************************************
    * @description Helper method to return an Opportunity, contactId is optional
    * @return void
    *******************************************************************************************************/
    
    public static Opportunity getTestOpportunity(Id accountId, Id contactId){

        return new Opportunity(
            Name = 'Test Opp ' + Datetime.now().getTime(),
            AccountId = accountId,
            npsp__Primary_Contact__c = contactId,
            CloseDate = System.Today(),
            Amount = 100,
            StageName = getClosedWonStage()
        );

    }

    /******************************************************************************************************
    * @description Helper method to insert GEM related TDTM
    * @return void
    *******************************************************************************************************/
    public static void insertTDTMForTest() {
        Post_Install_Script.insertTdtmDefaults();
    }
}