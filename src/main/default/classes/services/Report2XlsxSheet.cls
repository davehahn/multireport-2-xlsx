public with sharing class Report2XlsxSheet {
  public class Report2XLsxSheet_Exception extends Exception {
  }
  public class CustomFormatter {
    public String boolTrueValue;
    public String boolFalseValue;
    public String dateFormat;
    public String dateTimeFormat;

    public String doFormat(String dataType, Reports.ReportDataCell cell) {
      if (!this.hasCustomFormatter(dataType)) {
        return cell.getLabel();
      }
      switch on dataType {
        when 'BOOLEAN_DATA' {
          return this.formatBoolean(cell);
        }
        when 'DATE_DATA' {
          return this.formatDate(cell);
        }
        when 'DATETIME_DATA' {
          return this.formatDateTime(cell);
        }
        when else {
          return cell.getLabel();
        }
      }
    }

    private Boolean hasCustomFormatter(String dataType) {
      switch on dataType {
        when 'BOOLEAN_DATA' {
          return this.hasBooleanCustomFormat();
        }
        when 'DATE_DATA' {
          return this.hasDateCustomFormat();
        }
        when 'DATETIME_DATA' {
          return this.hasDateTimeCustomFormat();
        }
        when else {
          return false;
        }
      }
    }

    private Boolean hasBooleanCustomFormat() {
      return this.boolFalseValue != null && this.boolTrueValue != null;
    }

    private Boolean hasDateCustomFormat() {
      return this.dateFormat != null;
    }

    private Boolean hasDateTimeCustomFormat() {
      return this.dateTimeFormat != null;
    }

    private String formatBoolean(Reports.ReportDataCell cell) {
      return cell.getLabel() == 'true'
        ? this.boolTrueValue
        : this.boolFalseValue;
    }

    private String formatDate(Reports.ReportDataCell cell) {
      return doDateFormating(this.dateFormat, cell);
    }

    private String formatDateTime(Reports.ReportDataCell cell) {
      return doDateFormating(this.dateTimeFormat, cell);
    }

    private String doDateFormating(
      String formatString,
      Reports.ReportDataCell cell
    ) {
      DateTime dt = (DateTime) cell.getValue();
      if (dt == null) {
        return '';
      }
      return dt.format(formatString);
    }
  }
  private Reports.reportResults reportResults;

  @auraEnabled
  public Id reportId;
  @AuraEnabled
  public String sheetName;
  @AuraEnabled
  public List<String> header;
  @AuraEnabled
  public List<List<object>> rows;

  public List<String> fieldNames;
  public List<String> columnTypes;

  private List<Reports.ReportFilter> originalFilters;
  private Reports.ReportMetadata reportMetadata;
  private Map<String, String> headerOverrides;
  private CustomFormatter customFormatter;
  private mrexport__MultiReport_Export_Item__c exportItem;

  public Report2XlsxSheet(mrexport__MultiReport_Export_Item__c exportItem) {
    this.exportItem = exportItem;
    this.setupFromExportItem();
  }

  public Report2XlsxSheet(Id recordId) {
    String sObjectType = Application_Utilities.getInstance()
      .sObjectNameFromId(recordId);
    switch on sObjectType {
      when 'mrexport__MultiReport_Export_Item__c' {
        this.setupFromExportItemId(recordId);
      }
      when 'Report' {
        this.setupFromReportId(recordId);
      }
      when else {
        throw new Report2XlsxSheet_Exception(
          'sObjects of type ' + sObjectType + ' are not supported'
        );
      }
    }
  }

  public void setHeaderOverrides(
    List<mrexport__MultiReport_Export_Header_Override__c> headerOverrides
  ) {
    for (mrexport__MultiReport_Export_Header_Override__c hor : headerOverrides) {
      this.headerOverrides.put(hor.Field_Label__c, hor.Override_Value__c);
    }
  }

  public Report2XlsxSheet run() {
    init();
    return this;
  }

  private void setupFromReportId(Id recordId) {
    this.reportId = recordId;
    this.headerOverrides = new Map<String, String>();
    this.customFormatter = new CustomFormatter();
  }

  private void setupFromExportItemId(Id recordId) {
    this.exportItem = [
      SELECT
        Id,
        mrexport__Report_Id__c,
        mrexport__Report_Name__c,
        mrexport__Sheet_Name__c,
        mrexport__MultiReport_Export_Template__r.mrexport__Boolean_False_Value__c,
        mrexport__MultiReport_Export_Template__r.mrexport__Boolean_True_Value__c,
        mrexport__MultiReport_Export_Template__r.mrexport__Date_Format_String__c,
        mrexport__MultiReport_Export_Template__r.mrexport__DateTime_Format_String__c,
        (
          SELECT Id, mrexport__Field_Label__c, mrexport__Override_Value__c
          FROM mrexport__MultiReport_Export_Header_Overrides__r
        )
      FROM mrexport__MultiReport_Export_Item__c
      WHERE Id = :recordId
    ];
    this.setupFromExportItem();
  }

  private void setupFromExportItem() {
    this.reportId = exportItem.mrexport__Report_Id__c;
    this.sheetName = exportItem.mrexport__Sheet_Name__c;
    this.headerOverrides = new Map<String, String>();
    this.customFormatter = new CustomFormatter();
    if (exportItem.mrexport__MultiReport_Export_Header_Overrides__r.size() > 0) {
      this.setHeaderOverrides(
        exportItem.mrexport__MultiReport_Export_Header_Overrides__r
      );
    }
    this.setCustomFormatters();
  }

  private void init() {
    this.reportResults = Reports.ReportManager.runReport(this.reportId, true);
    this.reportMetadata = this.reportResults.getReportMetadata();
    this.originalFilters = this.reportMetadata.getReportFilters();
    setSheetName();
    buildHeaderAndTypesList();
    buildRows();
  }

  private void setCustomFormatters() {
    try {
      mrexport__MultiReport_Export_Template__c template = this.exportItem.mrexport__MultiReport_Export_Template__r;
      this.customFormatter.boolTrueValue = template.mrexport__Boolean_True_Value__c;
      this.customFormatter.boolFalseValue = template.mrexport__Boolean_False_Value__c;
      this.customFormatter.dateFormat = template.mrexport__Date_Format_String__c;
      this.customFormatter.dateTimeFormat = template.mrexport__DateTime_Format_String__c;
    } catch (Exception e) {
    }
  }

  private void setSheetName() {
    if (this.sheetName == null) {
      String reportName = this.reportMetadata.getName();
      this.sheetName = reportName.subString(0, 30);
    }
  }

  private void buildHeaderAndTypesList() {
    this.header = new List<String>();
    this.columnTypes = new List<String>();
    this.fieldNames = new List<String>();
    Reports.ReportExtendedMetadata rmd = this.reportResults.getReportExtendedMetadata();
    Map<String, Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();
    for (String key : colMap.KeySet()) {
      this.fieldNames.add(colMap.get(key).getName());
      this.columnTypes.add(String.valueOf(colMap.get(key).getDataType()));
      if (colMap.get(key).getDataType().name() != 'ID_DATA') {
        String fieldLabel = colMap.get(key).getLabel();
        if (this.headerOverrides.containsKey(fieldLabel)) {
          this.header.add(this.headerOverrides.get(fieldLabel));
        } else {
          this.header.add(colMap.get(key).getLabel());
        }
      }
    }
  }

  private void buildRows() {
    this.rows = new List<List<Object>>();
    List<String> recordIds = new List<String>();
    String idFieldName;
    Boolean allData = false;
    Reports.reportResults results = this.reportResults;
    while (allData == false) {
      Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap()
        .get('T!T');
      for (Reports.ReportDetailRow rowData : factDetails.getRows()) {
        List<Object> row = new List<Object>();
        List<Reports.ReportDataCell> cells = rowData.getDataCells();
        for (Integer i = 0; i < cells.size(); i++) {
          if (this.columnTypes[i] == 'ID_DATA') {
            recordIds.add(cells[i].getLabel());
            idFieldName = this.fieldNames[i];
            continue;
          }
          row.add(this.customFormatter.doFormat(this.columnTypes[i], cells[i]));
        }
        this.rows.add(row);
      }
      allData = recordIds.size() == 0 ? true : results.getAllData();
      if (!allData) {
        String idString = String.join(recordIds, ',');
        List<Reports.ReportFilter> allfilters = this.originalFilters;
        Reports.ReportFilter idFilter = new Reports.ReportFilter(
          idFieldName,
          'notEqual',
          idString
        );
        allfilters.add(idFilter);
        reportMetadata.setReportFilters(allfilters);
        results = Reports.ReportManager.runReport(
          this.reportId,
          reportMetadata,
          true
        );
      }
    }
  }
}
