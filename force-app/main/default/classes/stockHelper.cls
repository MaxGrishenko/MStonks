public with sharing class stockHelper {
    private static final String RANGE_SEPARATOR = ' - ';

    @AuraEnabled(cacheable=true)
    public static List<Stock__c> getStocks() {
        List<Stock__c> stocks = new List<Stock__c>();

        for (Stock__c s : [
                SELECT Id, LastModifiedDate, Logo__c, Company_Name__c, Name, Exchange__c, Close__c, Currency_Code__c, Change__c, Change_Percent__c, Open__c, Volume__c, Day_Range__c, Close_Previous__c, Volume_Average__c, Weeks_Range__c
                FROM Stock__c
                LIMIT 20
        ]) {
            stocks.add(s);
        }

        return scaleStocks(stocks);
    }

    @AuraEnabled(cacheable=true)
    public static Stock__c getStock(String stockId) {
        if (stockId == null) {
            return [SELECT Id, Logo__c, Name, Company_Name__c, Exchange__c, Close__c, Change__c, Change_Percent__c, Currency_Code__c FROM Stock__c LIMIT 1];
        }
        return [SELECT Id, Logo__c, Name, Company_Name__c, Exchange__c, Close__c, Change__c, Change_Percent__c, Currency_Code__c FROM Stock__c WHERE Id = :stockId LIMIT 1];
    }

    private static List<Stock__c> scaleStocks(List<Stock__c> stocks) {
        for(Stock__c s : stocks) {
            s.Close__c = scaleDecimal(s.Close__c);
            s.Change__c = scaleDecimal(s.Change__c);
            s.Change_Percent__c = scaleDecimal(s.Change_Percent__c);
            s.Open__c = scaleDecimal(s.Open__c);
            s.Close_Previous__c = scaleDecimal(s.Close_Previous__c);
            s.Volume__c = scaleDecimal(s.Volume__c);
            s.Volume_Average__c = scaleDecimal(s.Volume_Average__c);
            s.Day_Range__c = scaleRange(s.Day_Range__c);
            s.Weeks_Range__c = scaleRange(s.Weeks_Range__c);
        }

        return stocks;
    }

    private static Decimal scaleDecimal(Decimal value) {
        return value != null ? value.setScale(2) : value;
    }

    private static String scaleRange(String range) {
        List<String> values = range.split(RANGE_SEPARATOR);
        String left = String.valueOf(scaleDecimal(Decimal.valueOf(values[0])));
        String right = String.valueOf(scaleDecimal(Decimal.valueOf(values[1])));

        return left + RANGE_SEPARATOR + right;
    }
}