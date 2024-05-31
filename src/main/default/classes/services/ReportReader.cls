public with sharing class ReportReader {
  public class ComplexReport_Exception extends Exception {
  }
  private static final String COMPLEX_REPORT_ERROR = 'The select report contains groupings. Only simple un-grouped reports are supported at this time';
  private String reportId;
  private Reports.reportResults results {
    get {
      if (results == null) {
        results = Reports.ReportManager.runReport(reportId, true);
      }
      return results;
    }
    set;
  }
  private Reports.Dimension dimension {
    get {
      if (dimension == null) {
        dimension = results.getGroupingsDown();
      }
      return dimension;
    }
    set;
  }
  private Reports.ReportMetadata metadata {
    get {
      if (metaData == null) {
        metadata = results.getReportMetadata();
      }
      return metadata;
    }
    set;
  }

  public ReportReader(String reportId) {
    this.reportId = reportId;
  }

  public String getReportName() {
    return metadata.getName();
  }

  public Boolean isSimpleReport() {
    return dimension.getGroupings().size() == 0;
  }

  public Report getReportSobject() {
    Map<String, Object> record = new Map<String, Object>{
      'Id' => this.metadata.getId(),
      'Name' => this.metadata.getName()
    };
    return (Report) JSON.deserialize(JSON.serialize(record), Report.class);
  }

  public void throwComplexReportError() {
    throw new ComplexReport_Exception(COMPLEX_REPORT_ERROR);
  }
}
