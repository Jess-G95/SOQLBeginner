trigger DedupeLead on Lead (before insert) {

    // Get the data quality queue record ready for future use
    Group dataQualityGroup = [SELECT Id
                                FROM Group
                                WHERE DeveloperName = 'Data_Quality'
                                LIMIT 1];

    for (Lead myLead : Trigger.new) {

        // searching for matching contact(s)
        List<Contact> matchingContacts = [SELECT Id
                                            FROM Contact
                                           WHERE Email = :myLead.Email];
        System.debug(matchingContacts.size() + ' contact(s) found.');

        // If matches are found
        if (!matchingContacts.isEmpty()) {
            // Assign the lead to the data quality queue
            myLead.OwnerId = dataQualityGroup.Id;
            
            // Add the dupe contact IDs into the lead description
            String dupeContactsMessage = 'Duplicate contact(s) found:\n';
            for (Contact matchingContact : matchingContacts) {
                dupeContactsMessage += matchingContact.FirstName + ' '
                                    + matchingContact.LastName + ', '
                                    + matchingContact.Account.Name + ' ('
                                    + matchingContact.Id + ')\n';
            }
            myLead.Description = dupeContactsMessage + '\n' + myLead.Description;

        }
    }

}