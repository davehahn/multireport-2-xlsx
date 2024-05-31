public with sharing class MultiReportExportController {
  @AuraEnabled
  public static Report getReport(String reportId) {
    ReportReader reader = new ReportReader(reportId);
    if (!reader.isSimpleReport()) {
      reader.throwComplexReportError();
    }
    return reader.getReportSobject();
  }

  @AuraEnabled
  public static Report2XlsxSheet getReportData(String reportId) {
    return new Report2XlsxSheet(reportId).run();
  }
}