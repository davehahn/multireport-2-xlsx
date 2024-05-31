public with sharing class MultiReportHeaderOverrideModalController {
  @AuraEnabled(Cacheable=true)
  public static List<String> getColumnHeaders(String reportId) {
    List<string> columns = new List<String>();
    Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(
      reportId
    );
    Reports.ReportExtendedMetadata xMeta = describe.getReportExtendedMetadata();
    for (Reports.DetailColumn col : xMeta.getDetailColumnInfo().values()) {
      columns.add(col.getLabel());
    }
    return columns;
  }

  @AuraEnabled
  public static void updateHeaderOverrides(String jsonOverrides) {
    List<MultiReport_Export_Header_Override__c> toProcess = (List<MultiReport_Export_Header_Override__c>) JSON.deserialize(
      jsonOverrides,
      List<MultiReport_Export_Header_Override__c>.class
    );
    List<MultiReport_Export_Header_Override__c> toUpsert = new List<MultiReport_Export_Header_Override__c>();
    List<MultiReport_Export_Header_Override__c> toDelete = new List<MultiReport_Export_Header_Override__c>();
    for (MultiReport_Export_Header_Override__c o : toProcess) {
      System.debug(o);
      if (
        o.Id != null &&
        (o.Override_Value__c == null ||
        o.Override_Value__c.length() == 0)
      ) {
        toDelete.add(o);
        continue;
      }
      toUpsert.add(o);
    }
    if (toUpsert.size() > 0) {
      upsert toUpsert;
    }
    if (toDelete.size() > 0) {
      delete toDelete;
    }
  }
}
