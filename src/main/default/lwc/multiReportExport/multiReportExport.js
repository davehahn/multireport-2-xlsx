import { LightningElement } from "lwc";
import { reduceErrors } from "c/utils";
import Toast from "lightning/toast";
import XlsxJsLwc from "c/xlsxJsLwc";
import getReport from "@salesforce/apex/MultiReportExportController.getReport";
import getReportData from "@salesforce/apex/MultiReportExportController.getReportData";

const DEFAULT_FILENAME = "MultiReportExport";

export default class MultiReportExport extends LightningElement {
  _scriptsLoaded = false;
  recordPickerValue;
  renderPicker = false;
  selectedReports = [];
  xlsx;
  isBusy = false;
  runningExport = false;
  fileName = DEFAULT_FILENAME;
  reportsHeader = "Selected Reports";
  exportSucccessCount = 0;

  renderedCallback() {
    if (!this._scriptsLoaded) {
      this.xlsx = new XlsxJsLwc();
      this.xlsx.loadResources().then(() => {
        this._scriptsLoaded = true;
        this.renderPicker = true;
      });
    }
  }

  get selectedCount() {
    return this.selectedReports.length;
  }

  get disableExport() {
    return this.selectedReports.length === 0 || this.runningExport;
  }

  get filter() {
    const criteria = this.selectedReports.reduce((acc, report) => {
      acc.push({
        fieldPath: "Id",
        operator: "ne",
        value: report.Id
      });
      return acc;
    }, []);
    return {
      criteria: criteria
    };
  }

  handleFileNameChange(event) {
    this.fileName = event.detail.value;
  }

  handleReportChange(event) {
    const reportId = event.detail.recordId;
    this.renderPicker = false;
    getReport({ reportId: reportId })
      .then((result) => {
        this.selectedReports.push(result);
      })
      .catch((error) => {
        this._handleError(error);
      })
      .finally(() => {
        this.renderPicker = true;
      });
  }

  handleRemoveReport(event) {
    this.selectedReports = this.selectedReports.filter(
      (report) => report.Id !== event.target.value
    );
  }

  async handleExport() {
    this.runningExport = true;
    this.reportsHeader = "Exporting Report Data ....";
    const promises = this.selectedReports.map((report) => {
      return getReportData({ reportId: report.Id })
        .then((r) => {
          this.template
            .querySelector(`[data-report-id="${r.reportId}"]`)
            .classList.add("complete");
          this.exportSucccessCount++;
          return r;
        })
        .catch((error) => {
          this._handleError(error);
        });
    });
    const result = await Promise.all(promises);
    this.header = "Creating File ...";
    this.xlsx
      .createAndDownloadFile({
        fileName: this.fileName,
        sheets: result,
        autoDownload: true
      })
      .then(() => {
        Toast.show({
          label: "Success!",
          message: "Reports where exported and downloaded successfully",
          variant: "success",
          mode: "dismissible"
        });
        this.runningExport = false;
        this.exportSucccessCount = 0;
        this.selectedReports = [];
        this.fileName = DEFAULT_FILENAME;
      })
      .catch((error) => {
        this._handleError(error);
        this.runningExport = false;
      });
  }

  _handleError(error) {
    Toast.show({
      label: "There was an Error!",
      message: reduceErrors(error).join(", "),
      variant: "error",
      mode: "dissmissible"
    });
  }
}
