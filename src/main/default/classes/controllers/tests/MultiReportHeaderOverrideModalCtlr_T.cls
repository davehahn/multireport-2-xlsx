@IsTest
public class MultiReportHeaderOverrideModalCtlr_T {
  private static final String FILENAME = 'unit_test_file';
  private static final String SHEETNAME = 'unit-test-sheet';
  private static mrexport__MultiReport_Export_Template__c template;
  private static mrexport__MultiReport_Export_Item__c item;
  private static mrexport__MultiReport_Export_Header_Override__c headerOverride;
  private static ReportTestHelper helper;
  private static List<String> columnLabels;

  private static void createTemplate() {
    columnLabels = helper.getColumnLabels();
    template = (mrexport__MultiReport_Export_Template__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Template__c',
      new Map<String, Object>{
        'Name' => 'Unit Test Template',
        'mrexport__Export_File_Name__c' => FILENAME,
        'mrexport__Description__c' => 'This is template from an Apex unit Test'
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
    headerOverride = (mrexport__MultiReport_Export_Header_Override__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Header_Override__c',
      new Map<String, Object>{
        'mrexport__MultiReport_Export_Item__c' => item.Id,
        'mrexport__MultiReport_Export_Template__c' => template.Id,
        'mrexport__Field_Label__c' => columnLabels[0],
        'mrexport__Override_Value__c' => 'Test Override'
      }
    );
  }

  @IsTest(SeeAllData=true)
  static void getHeaderColumns() {
    helper = new ReportTestHelper(0).initSimple();
    Test.startTest();
    List<String> result = MultiReportHeaderOverrideModalController.getColumnHeaders(
      helper.getReportId()
    );
    Test.stopTest();

    Assert.areEqual(
      helper.getColumnLabels().size(),
      result.size(),
      'Column s should match'
    );
  }

  @IsTest(seeAllData=true)
  static void updateHeaderOverrides() {
    helper = new ReportTestHelper(0).initSimple();
    createTemplate();
    List<String> overrideLabels = new List<String>{
      'Column Override 2',
      'Column Override 3'
    };
    List<String> fieldLabels = new List<String>{
      columnLabels[2],
      columnLabels[3]
    };
    List<mrexport__MultiReport_Export_Header_Override__c> overrides = (List<mrexport__MultiReport_Export_Header_Override__c>) TestDataFactory.createSobjectList(
      'mrexport__MultiReport_Export_Header_Override__c',
      new Map<String, Object>{
        'mrexport__MultiReport_Export_Item__c' => item.Id,
        'mrexport__MultiReport_Export_Template__c' => template.Id,
        'mrexport__Field_Label__c' => fieldLabels,
        'mrexport__Override_Value__c' => overrideLabels
      },
      2,
      false
    );
    headerOverride.Override_Value__c = null;
    overrides.add(headerOverride);
    Test.startTest();
    MultiReportHeaderOverrideModalController.updateHeaderOverrides(
      JSON.serialize(overrides)
    );
    Test.stopTest();

    List<mrexport__MultiReport_Export_Header_Override__c> result = [
      SELECT Id
      FROM mrexport__MultiReport_Export_Header_Override__c
      WHERE mrexport__MultiReport_Export_Item__c = :item.Id
    ];

    Assert.isTrue(result.size() == 2, 'should have 2 Overrides');
  }
}
