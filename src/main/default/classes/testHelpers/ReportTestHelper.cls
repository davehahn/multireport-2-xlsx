@IsTest
public with sharing class ReportTestHelper {
  private static final String ACCOUNT_PREFIX = 'Unit Test Acct-';
  private Integer ACCOUNT_COUNT = 8;
  private static final String SIMPLE_REPORT_NAME = 'Apex_Unit_Test_Report_Simple_Accounts';
  private static final String GROUPED_REPORT_NAME = 'Apex_Unit_Test_Report_Grouped_Accounts';
  private Report theReport;
  private Reports.ReportDescribeResult reportDescribe;
  private List<Reports.DetailColumn> reportDetailColumns {
    get {
      if (reportDetailColumns == null) {
        reportDetailColumns = reportDescribe.getReportExtendedMetadata()
          .getDetailColumnInfo()
          .values();
      }
      return reportDetailColumns;
    }
    set;
  }

  public ReportTestHelper() {
    createAccountData();
  }

  public ReportTestHelper(Integer accountCount) {
    this.ACCOUNT_COUNT = accountCount;
    createAccountData();
  }

  public ReportTestHelper initSimple() {
    this.setupReport(SIMPLE_REPORT_NAME);
    return this;
  }

  public void setAccountCount(Integer count) {
    System.debug('Setting Account Count to ' + count);
    this.ACCOUNT_COUNT = count;
  }

  public ReportTestHelper initGrouped() {
    this.setupReport(GROUPED_REPORT_NAME);
    return this;
  }

  public String getReportId() {
    return this.theReport.Id;
  }

  public String getReportName() {
    return this.theReport.Name;
  }

  public List<String> getColumnLabels() {
    List<String> result = new List<String>();
    for (Reports.DetailColumn col : this.reportDetailColumns) {
      result.add(col.getLabel());
    }
    return result;
  }

  private void createAccountData() {
    if (this.ACCOUNT_COUNT == 0) {
      return;
    }
    List<String> names = new List<String>();
    for (Integer i = 0; i < ACCOUNT_COUNT; i++) {
      names.add(ACCOUNT_PREFIX + String.valueOf(i));
    }
    List<Account> accounts = (List<Account>) TestDataFactory.createSobjectList(
      'Account',
      new Map<String, Object>{
        'Name' => names,
        'Description' => 'For Unit Test'
      },
      ACCOUNT_COUNT
    );
  }

  private void setupReport(String reportName) {
    List<Report> reportList = [
      SELECT Id, Name, DeveloperName
      FROM Report
      WHERE DeveloperName = :reportName
    ];
    theReport = reportList.get(0);
    this.reportDescribe = Reports.ReportManager.describeReport(theReport.Id);
    Reports.ReportMetadata reportMetadata = reportDescribe.getReportMetadata();

    // Add a filter.
    List<Reports.ReportFilter> filters = new List<Reports.ReportFilter>();
    Reports.ReportFilter newFilter = new Reports.ReportFilter();
    newFilter.setColumn('ACCOUNT_NAME');
    newFilter.setOperator('contains');
    newFilter.setValue(ACCOUNT_PREFIX);
    filters.add(newFilter);
    reportMetadata.setReportFilters(filters);
  }
}
