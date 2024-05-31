@IsTest
private class TA_MRExportTemplate_ValidateEmail_T {
  private static final List<String> EMAIL_TEMPLATE_NAMES = new List<String>{
    'Unit Test Email Template',
    'Unit Test Email Template2'
  };
  private static final List<String> EMAIL_TEMPLATE_DEVELOPER_NAMES = new List<String>{
    'Unit_Test_Email_Template_agth3',
    'Unit_Test_Email_Template2_khsjr5'
  };
  private static final String MULTIREPORT_TEMPLATE_NAME = 'Unit Test Template';

  private static EmailTemplate emTemplate;
  private static mrexport__MultiReport_Export_Template__c exportTemplate;

  @TestSetup
  static void testDataSetup() {
    TestDataFactory.createSObjectList(
      'EmailTemplate',
      new Map<String, Object>{
        'isActive' => true,
        'Name' => EMAIL_TEMPLATE_NAMES,
        'DeveloperName' => EMAIL_TEMPLATE_DEVELOPER_NAMES,
        'TemplateType' => 'text',
        'FolderId' => UserInfo.getUserId(),
        'Subject' => 'Unit Test Email'
      },
      2
    );
  }

  private static void createExportTemplate(Boolean forUpdateTest) {
    Map<String, Object> params = new Map<String, Object>();
    params.put('Name', MULTIREPORT_TEMPLATE_NAME);
    params.put('mrexport__Export_File_Name__c', 'UnitTestFileName');
    params.put('mrexport__Description__c', 'This is template from an Apex unit Test');
    if (forUpdateTest) {
      params.put('mrexport__Email_Template_Name__c', emTemplate.Name);
      params.put('mrexport__Email_Template_Id__c', emTemplate.Id);
    }
    TriggerBase.bypass('mrexport__MultiReport_Export_Template__c');
    exportTemplate = (mrexport__MultiReport_Export_Template__c) TestDataFactory.createSobject(
      'mrexport__MultiReport_Export_Template__c',
      params,
      forUpdateTest
    );
    TriggerBase.clearBypass('mrexport__MultiReport_Export_Template__c');
  }

  private static Emailtemplate getEmailTemplate(String name) {
    return [
      SELECT Id, Name
      FROM EmailTemplate
      WHERE Name = :name
    ];
  }

  @IsTest
  static void beforeInsertTA() {
    emTemplate = getEmailTemplate(EMAIL_TEMPLATE_NAMES[0]);
    createExportTemplate(false);
    exportTemplate.Email_Template_Name__c = EMAIL_TEMPLATE_NAMES[0];
    List<mrexport__MultiReport_Export_Template__c> newList = new List<mrexport__MultiReport_Export_Template__c>{
      exportTemplate
    };

    Test.startTest();
    new TA_MRExportTemplate_ValidateEmail().beforeInsert(newList);
    Test.stopTest();

    Assert.areEqual(
      emTemplate.Id,
      newList[0].Email_Template_Id__c,
      'Email_Template_Id__c should be populated'
    );
  }

  @IsTest
  static void beforeInsertTAfail() {
    emTemplate = getEmailTemplate(EMAIL_TEMPLATE_NAMES[0]);
    createExportTemplate(false);
    exportTemplate.Email_Template_Name__c = EMAIL_TEMPLATE_NAMES[0] + ' WRONG';
    List<MultiReport_Export_Template__c> newList = new List<MultiReport_Export_Template__c>{
      exportTemplate
    };

    Test.startTest();
    new TA_MRExportTemplate_ValidateEmail().beforeInsert(newList);
    Test.stopTest();

    Assert.isTrue(newList[0].hasErrors(), 'There should be an error message');
  }

  @IsTest
  static void beforeUpdateTAremoveEmailTemplate() {
    emTemplate = getEmailTemplate(EMAIL_TEMPLATE_NAMES[0]);
    createExportTemplate(true);
    MultiReport_Export_Template__c newRecord = exportTemplate.clone(
      true,
      true,
      true,
      true
    );
    newRecord.Email_Template_Name__c = null;
    List<MultiReport_Export_Template__c> oldList = new List<MultiReport_Export_Template__c>{
      exportTemplate
    };
    List<MultiReport_Export_Template__c> newList = new List<MultiReport_Export_Template__c>{
      newRecord
    };

    Test.startTest();
    new TA_MRExportTemplate_ValidateEmail().beforeUpdate(newList, oldList);
    Test.stopTest();

    Assert.isNull(
      newList[0].Email_Template_Id__c,
      'Email Template Id should be empty'
    );
  }

  @IsTest
  static void beforeUpdateTAchangeEmailTemplate() {
    emTemplate = getEmailTemplate(EMAIL_TEMPLATE_NAMES[0]);
    createExportTemplate(true);
    MultiReport_Export_Template__c newRecord = exportTemplate.clone(
      true,
      true,
      true,
      true
    );
    newRecord.Email_Template_Name__c = EMAIL_TEMPLATE_NAMES[1];
    List<MultiReport_Export_Template__c> oldList = new List<MultiReport_Export_Template__c>{
      exportTemplate
    };
    List<MultiReport_Export_Template__c> newList = new List<MultiReport_Export_Template__c>{
      newRecord
    };

    Test.startTest();
    new TA_MRExportTemplate_ValidateEmail().beforeUpdate(newList, oldList);
    Test.stopTest();

    EmailTemplate newEmailTemplate = getEmailTemplate(EMAIL_TEMPLATE_NAMES[1]);

    Assert.areEqual(
      newList[0].Email_Template_Id__c,
      newEmailTemplate.Id,
      'Email Template Id should be of new Email Template'
    );
  }
}
