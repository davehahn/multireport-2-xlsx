@IsTest
private class ReportReader_T {
  static ReportTestHelper helper;

  @IsTest(SeeAllData=true)
  static void simple() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initSimple();
    TriggerBase.clearBypass('Account');

    Test.startTest();
    ReportReader reader = new ReportReader(helper.getReportId());
    Test.stopTest();

    Report result = reader.getReportSobject();
    Assert.areEqual(
      helper.getReportName(),
      reader.getReportName(),
      'names should match'
    );
    Assert.areEqual(helper.getReportId(), result.Id, 'Sobject Id should match');
    Assert.areEqual(
      helper.getReportName(),
      result.Name,
      'Sobject Name should match'
    );
    Assert.isTrue(reader.isSimpleReport(), 'should be a Simple report');
  }

  @IsTest(SeeAllData=true)
  static void grouped() {
    TriggerBase.bypass('Account');
    helper = new ReportTestHelper().initGrouped();
    TriggerBase.clearBypass('Account');

    Test.startTest();
    ReportReader reader = new ReportReader(helper.getReportId());
    Test.stopTest();

    Assert.isFalse(reader.isSimpleReport(), 'should NOT be a Simple report');
  }
}
