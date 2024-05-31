@IsTest
private class MultiReportRunExportController_T {
  private static final String FILENAME = 'unit_test_file';
  private static final String SHEETNAME = 'unit-test-sheet';
  private static final String EMAIL_TEMPLATE_NAME = 'Unit Test Email Template';
  private static final String EMAIL_TEMPLATE_DEVELOPER_NAME = 'unit_test_email_template_dev_name_fuisid8';
  private static MultiReport_Export_Template__c template;
  private static MultiReport_Export_Item__c item;
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

  private static void createTemplateAndItem() {
    createTemplate();
    item = (mrexport__MultiReport_Export_Item__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Item__c',
      new Map<String, Object>{
        'mrexport__Report_Id__c' => helper.getReportId(),
        'mrexport__Report_Name__c' => helper.getReportName(),
        'mrexport__Sheet_Name__c' => SHEETNAME,
        'mrexport__MultiReport_Export_Template__c' => template.Id
      }
    );
  }

  private static void init() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initSimple();
    TriggerBase.clearBypass('Account');
    createTemplateAndItem();
  }

  @IsTest(SeeAllData=true)
  static void getTemplateAndItems() {
    init();
    System.debug(template);
    Test.startTest();
    MultiReport_Export_Template__c result = MultiReportRunExportController.getTemplateAndItems(
      String.valueOf(template.Id)
    );
    Test.stopTest();
    System.debug(result);
    Assert.areEqual(
      FILENAME,
      result.Export_File_Name__c,
      'File Name should be ' + FILENAME
    );

    Assert.areEqual(
      1,
      result.MultiReport_Export_Items__r.size(),
      'should have one Export Item'
    );
  }

  @IsTest(SeeAllData=true)
  static void getReportData() {
    init();
    Test.startTest();
    Report2XlsxSheet result = MultiReportRunExportController.getReportData(
      item.Id
    );
    Test.stopTest();

    Assert.areEqual(
      SHEETNAME,
      result.sheetName,
      'Sheet name should be ' + SHEETNAME
    );
  }

  @IsTest
  static void sendFileInEmail() {
    createTemplate();

    Test.startTest();
    Blob fileBlob = Blob.valueOf('This is the file');
    String base64File = EncodingUtil.base64Encode(fileBlob);
    Map<String, String> emailData = new Map<String, String>{
      'base64' => base64File,
      'fileName' => 'UnitTestFile',
      'emailTemplateId' => TriggerTestUtility.getFakeId(
        EmailTemplate.sObjectType
      ),
      'recipients' => 'tester@unittesting.com'
    };
    MultiReportRunExportController.sendFileInEmail(emailData);
    Test.stopTest();
  }
}
