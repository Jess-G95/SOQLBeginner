@isTest
private class ComparableOppsTest {
    @isTest static void noComparableOpps() {
        Account acc = new Account();
        acc.Name = 'Winterfell Hotels';
        acc.Industry = 'Hospitality';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Winterfell Hotels';
        opp.AccountId = acc.Id;
        opp.Amount = 100;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        insert opp;

        List<Comparable__c> comparables = [SELECT Id
                                    FROM Comparable__c
                                    WHERE Base_Opportunity__c = :opp.Id];
        
        System.assertEquals(0, comparables.size());
    }

    @isTest static void multipleComparableOpps() {

        Account acc = new Account();
        acc.Name = 'Winterfell Hotels';
        acc.Industry = 'Hospitality';
        insert acc;

        List<Opportunity> ComparableOpps = new List<Opportunity>();
        Opportunity comp1 = new Opportunity();
        comp1.Name = 'Winterfell Hotels';
        comp1.AccountId = acc.Id;
        comp1.Amount = 105;
        comp1.StageName = 'Closed Won';
        comp1.CloseDate = Date.today().addDays(-1);
        ComparableOpps.add(comp1);

        Opportunity comp2 = new Opportunity();
        comp2.Name = 'Winterfell Hotels';
        comp2.AccountId = acc.Id;
        comp2.Amount = 95;
        comp2.StageName = 'Closed Won';
        comp2.CloseDate = Date.today().addDays(-100);
        ComparableOpps.add(comp2);
        insert comparableOpps;

        Opportunity baseOpp = new Opportunity();
        baseOpp.Name = 'Winterfell Hotels';
        baseOpp.AccountId = acc.Id;
        baseOpp.Amount = 100;
        baseOpp.StageName = 'Prospecting';
        baseOpp.CloseDate = Date.today();
        insert baseOpp;

        List<Comparable__c> comparables = [SELECT Id,
                                                  Comparable_Opportunity__c
                                           FROM Comparable__c
                                           WHERE Base_Opportunity__c = :baseOpp.Id
                                           ORDER BY Comparable_Opportunity__r.CloseDate DESC];

        System.assertEquals(comp1.Id, comparables.get(0).Comparable_Opportunity__c);
        System.assertEquals(comp2.Id, comparables.get(1).Comparable_Opportunity__c);
    }
}