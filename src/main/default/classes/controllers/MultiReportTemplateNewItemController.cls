public with sharing class MultiReportTemplateNewItemController {
  @AuraEnabled
  public static String getReportName(String reportId) {
    ReportReader reader = new ReportReader(reportId);
    if (!reader.isSimpleReport()) {
      reader.throwComplexReportError();
    }
    return reader.getReportName();
  }

  @AuraEnabled
  public static void upsertTemplateItem(String data) {
    try {
      MultiReport_Export_Item__c item = (MultiReport_Export_Item__c) JSON.deserialize(
        data,
        MultiReport_Export_Item__c.class
      );
      upsert item;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
