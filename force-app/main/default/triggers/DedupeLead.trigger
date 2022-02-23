trigger DedupeLead on Lead (before insert) {

    // Get the data quality queue record ready for future use
    List<Group> dataQualityGroup = [SELECT Id
                                FROM Group
                                WHERE DeveloperName = 'Data_Quality'
                                LIMIT 1];

    for (Lead myLead : Trigger.new) {
        if (myLead.Email != null) {

            String firstNameMatch;
            if (myLead.FirstName != null) {
                firstNameMatch = myLead.FirstName.subString(0, 1) + '%';
            }

            String companyMatch = '%' + myLead.Company + '%';

            // searching for matching contact(s)
            List<Contact> matchingContacts = [SELECT Id,
                                                     FirstName,
                                                     LastName,
                                                     Account.Name
                                                FROM Contact
                                               WHERE (Email != null
                                                 AND Email = :myLead.Email)
                                                  OR (FirstName != null
                                                 AND FirstName LIKE :firstNameMatch
                                                 AND LastName = :myLead.LastName
                                                 AND Account.Name LIKE :companyMatch)];
            System.debug(matchingContacts.size() + ' contact(s) found.');

            // If matches are found
            if (!matchingContacts.isEmpty()) {
                // Assign the lead to the data quality queue
                if (!dataQualityGroup.isEmpty()) {
                    myLead.OwnerId = dataQualityGroup.get(0).Id;
                }
                
                // Add the dupe contact IDs into the lead description
                String dupeContactsMessage = 'Duplicate contact(s) found:\n';
                for (Contact matchingContact : matchingContacts) {
                    dupeContactsMessage += matchingContact.FirstName + ' '
                                        + matchingContact.LastName + ', '
                                        + matchingContact.Account.Name + ' ('
                                        + matchingContact.Id + ')\n';
                }
                if (myLead.Description != null) {
                    dupeContactsMessage += '\n' + myLead.Description;
                }
                myLead.Description = dupeContactsMessage + '\n' + myLead.Description;

            }
        }
    }

}