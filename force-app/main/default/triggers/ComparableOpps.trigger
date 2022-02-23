trigger ComparableOpps on Opportunity (after insert) {
    
    for (Opportunity opp : Trigger.new) {

        Opportunity oppWithAccountInfo = [SELECT Id,
                                                 Account.Industry
                                            FROM Opportunity
                                            WHERE Id = :opp.Id
                                            LIMIT 1];

        Decimal minAmount = opp.Amount * 0.9;
        Decimal maxAmount = opp.Amount * 1.1;

        List<Opportunity> ComparableOpps = [SELECT Id
                                             FROM Opportunity
                                             WHERE Amount >= :minAmount
                                             AND Amount <= :maxAmount
                                             AND Account.Industry = :oppWithAccountInfo.Account.Industry
                                             AND StageName = 'Closed Won'
                                             AND CloseDate >= LAST_N_DAYS:365
                                             AND Id != :opp.Id];
        System.debug('Comparable opp(s) found: ' + ComparableOpps);

        List<Comparable__c> junctionObjToInsert = new List<Comparable__c>();
        for (Opportunity comp : ComparableOpps) {
            Comparable__c junctionObj = new Comparable__c();
            junctionObj.Base_Opportunity__c = opp.Id;
            junctionObj.Comparable_Opportunity__c = comp.Id;
            junctionObjToInsert.add(junctionObj);
        }
        insert junctionObjToInsert;
    }

}