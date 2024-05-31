@IsTest
private class MultiReportTemplateNewItemController_T {
  private static final String FILENAME = 'unit_test_file';
  private static final String SHEETNAME = 'unit-test-sheet';
  private static mrexport__MultiReport_Export_Template__c template;
  static ReportTestHelper helper;

  private static void createTemplate() {
    template = (mrexport__MultiReport_Export_Template__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Template__c',
      new Map<String, Object>{
        'Name' => 'Unit Test Template',
        'mrexport__Export_File_Name__c' => FILENAME,
        'mrexport__Description__c' => 'This is tempplate from an Apex unit Test'
      }
    );
  }

  private static void init() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initSimple();
    TriggerBase.clearBypass('Account');
    createTemplate();
  }

  @IsTest(SeeAllData=true)
  static void getReportName() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initSimple();
    TriggerBase.clearBypass('Account');
    Test.startTest();
    String reportName = MultiReportTemplateNewItemController.getReportName(
      helper.getReportId()
    );
    Test.stopTest();

    Assert.areEqual(
      helper.getReportName(),
      reportName,
      'Report Names should match'
    );
  }

  @IsTest(SeeAllData=true)
  static void getReportNameError() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initGrouped();
    TriggerBase.clearBypass('Account');
    String errorMessage;
    Test.startTest();
    try {
      String reportName = MultiReportTemplateNewItemController.getReportName(
        helper.getReportId()
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    Assert.isTrue(errorMessage != null, 'should be an Error Message');
  }

  @IsTest(SeeAllData=true)
  static void createTemplateItem() {
    init();
    mrexport__MultiReport_Export_Item__c item = new mrexport__MultiReport_Export_Item__c(
      mrexport__Report_Id__c = helper.getReportId(),
      mrexport__Report_Name__c = helper.getReportName(),
      mrexport__Sheet_Name__c = SHEETNAME,
      mrexport__MultiReport_Export_Template__c = template.Id
    );
    Test.startTest();
    MultiReportTemplateNewItemController.upsertTemplateItem(
      JSON.serialize(item)
    );
    Test.stopTest();

    List<mrexport__MultiReport_Export_Item__c> items = [
      SELECT Id
      FROM mrexport__MultiReport_Export_Item__c
      WHERE mrexport__MultiReport_Export_Template__c = :template.Id
    ];

    Assert.areEqual(1, items.size(), 'there should be 1 template item');
  }

  @IsTest
  static void createTemplateItemError() {
    MultiReport_Export_Item__c item = new MultiReport_Export_Item__c(
      Sheet_Name__c = SHEETNAME
    );
    String errorMessage;
    Test.startTest();
    try {
      MultiReportTemplateNewItemController.upsertTemplateItem(
        JSON.serialize(item)
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    Assert.isTrue(errorMessage != null, 'should be an Error Message');
  }
}
