trigger caseStatusClosed on Case (before insert) {

    for (Case myCase : Trigger.new) {
        if (myCase.ContactId != null) {
            List<Case> casesTodayFromContact = [SELECT Id
                                                FROM Case
                                                WHERE ContactId = :myCase.ContactId
                                                AND CreatedDate = TODAY];

            if (casesTodayFromContact.size() >= 2) {
                myCase.Status = 'Closed';
            }
        }
    }

}