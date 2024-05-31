import { api, wire } from "lwc";
import LightningModal from "lightning/modal";
import Toast from "lightning/toast";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import REPORTID_FIELD from "@salesforce/schema/MultiReport_Export_Item__c.Report_Id__c";
import REPORTNAME_FIELD from "@salesforce/schema/MultiReport_Export_Item__c.Report_Name__c";
import SHEETNAME_FIELD from "@salesforce/schema/MultiReport_Export_Item__c.Sheet_Name__c";
import getReportName from "@salesforce/apex/MultiReportTemplateNewItemController.getReportName";
import upsertRecord from "@salesforce/apex/MultiReportTemplateNewItemController.upsertTemplateItem";
import { reduceErrors } from "c/utils";

export default class MultiReportTemplateNewItemModel extends LightningModal {
  @api itemId;
  @api parentRecordId;
  @api currentReportIds;
  recordPickerValue;
  selectedReportId;
  selectedReportName;
  sheetName;
  inputsValid = false;
  isBusy = false;
  filter;
  pickerReady = false;

  @wire(getRecord, {
    recordId: "$itemId",
    fields: [REPORTID_FIELD, REPORTNAME_FIELD, SHEETNAME_FIELD]
  })
  wiredItem(result) {
    if (result.data) {
      this.selectedReportId = getFieldValue(result.data, REPORTID_FIELD);
      this.selectedReportName = getFieldValue(result.data, REPORTNAME_FIELD);
      this.sheetName = getFieldValue(result.data, SHEETNAME_FIELD);
    }
    if (result.error) {
      this._handleError(result.error);
    }
  }

  connectedCallback() {
    const criteria = this.currentReportIds.reduce((acc, reportId) => {
      acc.push({
        fieldPath: "Id",
        operator: "ne",
        value: reportId
      });
      return acc;
    }, []);
    this.filter = {
      criteria: criteria
    };
    this.pickerReady = true;
  }

  get renderPicker() {
    return !this.reportSelected && this.pickerReady;
  }

  get reportSelected() {
    return this.selectedReportId !== undefined;
  }

  get disableSave() {
    return !this.inputsValid || this.isBusy;
  }

  renderedCallback() {
    this._checkValidity();
  }

  handleReportChange(event) {
    const reportId = event.detail.recordId;
    if (reportId === null || reportId === undefined) {
      return;
    }
    if (this.currentReportIds && this.currentReportIds.indexOf(reportId) >= 0) {
      return;
    }
    this.isBusy = true;
    getReportName({ reportId: reportId })
      .then((result) => {
        this.selectedReportName = result;
        this.selectedReportId = reportId;
      })
      .catch((error) => {
        this._handleError(error);
      })
      .finally(() => {
        this.isBusy = false;
      });
  }

  handleSheetNameChange(event) {
    this.sheetName = event.detail.value;
    this._checkValidity();
  }

  handleCancel() {
    this.close();
  }

  handleSave() {
    this.isBusy = true;
    const recordData = {
      Id: this.itemId,
      mrexport__Report_Id__c: this.selectedReportId,
      mrexport__Report_Name__c: this.selectedReportName,
      mrexport__Sheet_Name__c: this.sheetName,
      mrexport__MultiReport_Export_Template__c: this.parentRecordId
    };
    upsertRecord({ data: JSON.stringify(recordData) })
      .then(() => {
        this.close(true);
      })
      .catch((error) => {
        this.isBusy = false;
        this._handleError(error);
      });
  }

  handleClear() {
    this.selectedReportId = undefined;
    this.selectedReportName = undefined;
    this.sheetName = undefined;
  }

  _checkValidity() {
    this.inputsValid = [
      ...this.template.querySelectorAll("lightning-input")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    console.log(`Are Valid = ${this.inputsValid}`);
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
