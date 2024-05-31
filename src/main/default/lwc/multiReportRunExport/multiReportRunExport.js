import { LightningElement, api } from "lwc";
import Toast from "lightning/toast";
import { reduceErrors } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import XlsxJsLwc from "c/xlsxJsLwc";

import getTemplateAndItems from "@salesforce/apex/MultiReportRunExportController.getTemplateAndItems";
import getReportData from "@salesforce/apex/MultiReportRunExportController.getReportData";
import sendFileInEmail from "@salesforce/apex/MultiReportRunExportController.sendFileInEmail";

export default class MultiReportRunExport extends LightningElement {
  header = "Exporting Report Data......";
  _recordId;
  _scriptsLoaded = false;
  _gotTemplate = false;
  xlsx;
  sheetJs;
  exportItems;
  fileName;
  _autoSendEmail;
  _addColumnFilters;
  _emailTemplateId;
  _emailRecipients;

  @api
  get recordId() {
    return this._recordId;
  }

  set recordId(recordId) {
    if (recordId !== this._recordId) {
      this._recordId = recordId;
    }
    this._fetchTemplateAndItems();
  }

  renderedCallback() {
    if (!this._scriptsLoaded) {
      this.xlsx = new XlsxJsLwc();
      this.xlsx.loadResources().then(() => {
        this._scriptsLoaded = true;
        //this._init();
      });
    }
  }

  _fetchTemplateAndItems() {
    getTemplateAndItems({ templateId: this.recordId })
      .then((result) => {
        this.exportItems = result.MultiReport_Export_Items__r;
        this.fileName = result.Export_File_Name__c;
        this._autoSendEmail = result.Auto_Send_Email__c;
        this._addColumnFilters = result.Add_Column_Filter__c;
        this._emailRecipients = result.Email_Recipients__c;
        this._emailTemplateId = result.Email_Template_Id__c;
        this._gotTemplate = true;
        this._init();
      })
      .catch((error) => {
        this._handleError(error);
      });
  }

  _init() {
    //if (this._scriptsLoaded && this._gotTemplate) {
    this._buildReportData();
    //}
  }

  async _buildReportData() {
    const promiseArray = this.exportItems.map((item) => {
      return getReportData({ exportItemId: item.Id })
        .then((r) => {
          this.template
            .querySelector(`[data-report-id="${r.reportId}"]`)
            .classList.add("complete");
          return r;
        })
        .catch((error) => {
          this._handleError(error);
        });
    });
    const result = await Promise.all(promiseArray);
    this.header = "Creating File ...";
    this.xlsx
      .createAndDownloadFile({
        fileName: this.fileName,
        sheets: result,
        autoDownload: !this._autoSendEmail,
        columnFilters: this._addColumnFilters
      })
      .then((fileData) => {
        if (fileData) {
          this.header = "Sending Email with File ...";
          fileData.emailTemplateId = this._emailTemplateId;
          fileData.recipients = this._emailRecipients;
          return sendFileInEmail({ emailData: fileData });
        }
        return Promise.resolve("downloaded");
      })
      .then((r) => {
        const msg = r
          ? "Reports where exported and downloaded successfully"
          : "Reports where exported and emailed successfully";
        this._handleSuccess(msg);
      })
      .catch((error) => {
        this._handleError(error);
      });
  }

  _handleSuccess(message) {
    this.dispatchEvent(new CloseActionScreenEvent());
    Toast.show({
      label: "Success!",
      message: message,
      variant: "success",
      mode: "dismissible"
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
