@IsTest
private with sharing class MultiReportExportController_T {
    private static final String FILENAME = 'unit_test_file';
    private static final String SHEETNAME = 'unit-test-sheet';
    private static MultiReport_Export_Template__c template;
    static ReportTestHelper helper;
  
    private static void init() {
      TriggerBase.bypass('Account');
      helper = new ReportTestHelper().initSimple();
      TriggerBase.clearBypass('Account');
    }
  
    @IsTest(SeeAllData=true)
    static void tests() {
      init();
      Test.startTest();
      Report resultReport = MultiReportExportController.getReport(helper.getReportId());
      Report2XlsxSheet result = MultiReportExportController.getReportData(
        helper.getReportId()
      );
      Test.stopTest();
  
      Assert.areEqual(
        helper.getReportId(),
        resultReport.Id,
        'Report Id\'s match'
      );
      Assert.isTrue(result.rows.size() > 0, 'Rows should have data');
    }
}