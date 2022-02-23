@isTest
private class DedupeLeadTest {
    @isTest static void createLeadNoDupes() {
        String leadOwner = UserInfo.getUserId();

        Lead myLead = new Lead();
        myLead.FirstName = 'Sansa';
        myLead.LastName = 'Stark';
        myLead.Company = 'Winterfell Hotels';
        myLead.Email = 'sstark@winterfellhotels.com';
        myLead.Description = 'The North Remembers';
        myLead.OwnerId = leadOwner;
        insert myLead;

        Lead updatedLead = [SELECT OwnerId,
                                   Description
                            FROM Lead
                            WHERE Id = :myLead.Id];

        System.assertEquals(leadOwner, updatedLead.OwnerId);
        System.assertEquals(myLead.Description, updatedLead.Description);
    }

    @isTest static void createLeadMultipleDupes() {
        String email = 'sstark@winterfellhotels.com';

        // create 2 dupe contacts
        List<Contact> dupeContacts = new List<Contact>();
        Contact firstDupe = new Contact();
        firstDupe.FirstName = 'Sansa';
        firstDupe.LastName = 'Stark';
        firstDupe.Email = email;
        dupeContacts.add(firstDupe);

        Contact secondDupe = new Contact();
        secondDupe.FirstName = 'Sansa';
        secondDupe.LastName = 'Stark';
        secondDupe.Email = email;
        dupeContacts.add(secondDupe);
        insert dupeContacts;

        // Create dupe lead
        Lead myLead = new Lead();
        myLead.FirstName = 'Sansa';
        myLead.LastName = 'Stark';
        myLead.Company = 'Winterfell Hotels';
        myLead.Email = email;
        myLead.Description = 'The North Remembers';
        myLead.OwnerId = UserInfo.getUserId();
        insert myLead;

        Lead updatedLead = [SELECT OwnerId,
                                   Description
                            FROM Lead
                            WHERE Id = :myLead.Id];

        Group dataQualityQueue = [SELECT Id
                                    FROM Group
                                    WHERE DeveloperName = 'Data+Quality'
                                    LIMIT 1];

        System.assertEquals(dataQualityQueue.Id, updatedLead.OwnerId);
        System.assert(updatedLead.Description.contains(firstDupe.Id));
        System.assert(updatedLead.Description.contains(secondDupe.Id));
    }
}
