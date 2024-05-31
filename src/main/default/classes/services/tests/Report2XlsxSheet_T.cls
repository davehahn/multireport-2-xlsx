@IsTest
private class Report2XlsxSheet_T {
  private static final String FILENAME = 'unit_test_file';
  private static final String SHEETNAME = 'unit-test-sheet';
  static ReportTestHelper helper;
  static mrexport__MultiReport_Export_Template__c template;
  static mrexport__MultiReport_Export_Item__c item;

  private static void init() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initSimple();
    TriggerBase.clearBypass('Account');
  }

  private static void initForExportItem() {
    template = (mrexport__MultiReport_Export_Template__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Template__c',
      new Map<String, Object>{
        'Name' => 'Unit Test Template',
        'mrexport__Export_File_Name__c' => FILENAME,
        'mrexport__Description__c' => 'This is tempplate from an Apex unit Test',
        'mrexport__Boolean_True_Value__c' => 'Yes',
        'mrexport__Boolean_False_Value__c' => 'No',
        'mrexport__Date_Format_String__c' => 'MMM dd, yyyy',
        'mrexport__DateTime_Format_String__c' => 'MMM dd, yyyy hh:mm a'
      }
    );
    item = (mrexport__MultiReport_Export_Item__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Item__c',
      new Map<String, Object>{
        'mrexport__Report_Id__c' => helper.getReportId(),
        'mrexport__Report_Name__c' => helper.getReportName(),
        'mrexport__Sheet_Name__c' => SHEETNAME,
        'mrexport__MultiReport_Export_Template__c' => template.Id
      }
    );
    TestDataFactory.createSObject(
      'mrexport__MultiReport_Export_Header_Override__c',
      new Map<String, Object>{
        'mrexport__MultiReport_Export_Item__c' => item.Id,
        'mrexport__MultiReport_Export_Template__c' => template.Id,
        'mrexport__Field_Label__c' => 'Account Name',
        'mrexport__Override_Value__c' => 'Unit Test Name'
      }
    );
  }

  @IsTest(SeeAllData=true)
  static void fromReportId() {
    init();

    Test.startTest();
    Report2XlsxSheet result = new Report2XlsxSheet(helper.getReportId()).run();
    Test.stopTest();

    Assert.isTrue(result.header.size() > 0, 'Header should have Data');
    Assert.isTrue(
      result.columnTypes.size() > 0,
      'Column Types should have data'
    );
    Assert.isTrue(result.rows.size() > 0, 'Rows should have data');
  }

  @IsTest(SeeAllData=true)
  static void fromExportItem() {
    init();
    initForExportItem();
    Test.startTest();
    Report2XlsxSheet result = new Report2XlsxSheet(item).run();
    Test.stopTest();

    Assert.isTrue(result.header.size() > 0, 'Header should have Data');
    Assert.isTrue(
      result.columnTypes.size() > 0,
      'Column Types should have data'
    );
    Assert.isTrue(result.rows.size() > 0, 'Rows should have data');
  }

  @IsTest(SeeAllData=true)
  static void fromExportItemId() {
    init();
    initForExportItem();
    Test.startTest();
    Report2XlsxSheet result = new Report2XlsxSheet(item.Id).run();
    Test.stopTest();

    Assert.isTrue(result.header.size() > 0, 'Header should have Data');
    Assert.isTrue(
      result.columnTypes.size() > 0,
      'Column Types should have data'
    );
    Assert.isTrue(result.rows.size() > 0, 'Rows should have data');
  }

  @IsTest
  static void invalidIdToConstructor() {
    Id invalidId = TriggerTestUtility.getFakeId(Account.sObjectType);
    String errMsg;
    try {
      Report2XlsxSheet result = new Report2XlsxSheet(invalidId);
    } catch (Exception e) {
      errMsg = e.getMessage();
    }

    Assert.isTrue(errMsg != null, 'There should be an error message');
  }
}
