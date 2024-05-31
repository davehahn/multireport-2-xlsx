import { api, wire } from "lwc";
import LightningModal from "lightning/modal";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import getColumnHeaders from "@salesforce/apex/MultiReportHeaderOverrideModalController.getColumnHeaders";
import updateHeaderOverrides from "@salesforce/apex/MultiReportHeaderOverrideModalController.updateHeaderOverrides";
import Toast from "lightning/toast";
import { reduceErrors } from "c/utils";

export default class MultiReportHeaderOverrideModal extends LightningModal {
  @api itemId;
  @api templateId;
  @api reportId;
  isBusy = true;
  currentOverrides = [];
  allOverrides = [];
  _allHeaders;
  _recordsLoaded = false;
  _columnsLoaded = false;

  @wire(getRelatedListRecords, {
    parentRecordId: "$itemId",
    relatedListId: "mrexport__MultiReport_Export_Header_Overrides__r",
    fields: [
      "mrexport__MultiReport_Export_Header_Override__c.mrexport__Field_Label__c",
      "mrexport__MultiReport_Export_Header_Override__c.mrexport__Override_Value__c",
      "mrexport__MultiReport_Export_Header_Override__c.mrexport__MultiReport_Export_Item__c",
      "mrexport__MultiReport_Export_Header_Override__c.mrexport__MultiReport_Export_Template__c"
    ]
  })
  wiredOverides(result) {
    if (result.data) {
      this.currentOverrides = result.data.records.map((record) => {
        return {
          Id: record.id,
          mrexport__Field_Label__c: record.fields.mrexport__Field_Label__c.value,
          mrexport__Override_Value__c: record.fields.mrexport__Override_Value__c.value,
          mrexport__MultiReport_Export_Item__c:
            record.fields.mrexport__MultiReport_Export_Item__c.value,
          mrexport__MultiReport_Export_Template__c:
            record.fields.mrexport__MultiReport_Export_Template__c.value
        };
      });
      this._recordsLoaded = true;
      this._init();
    }
    if (result.error) {
      this._handleError(result.error);
    }
  }

  @wire(getColumnHeaders, { reportId: "$reportId" })
  wiredHeaders(result) {
    if (result.data) {
      this._allHeaders = result.data;
      this._columnsLoaded = true;
      this._init();
    }
    if (result.error) {
      this._handleError(result.error);
    }
  }

  handleCancel() {
    this.close();
  }

  handleOverrideChange(event) {
    const value = event.currentTarget.value;
    const label = event.currentTarget.label;
    this.allOverrides.find(
      (h) => h.mrexport__Field_Label__c === label
    ).mrexport__Override_Value__c = value;
  }

  handleSave() {
    this.isBusy = true;
    const toSend = this.allOverrides.reduce((acc, ele) => {
      if (ele.mrexport__Override_Value__c !== undefined) {
        acc.push(ele);
      }
      if (
        ele.Id &&
        (ele.mrexport__Override_Value__c === undefined || ele.mrexport__Override_Value__c === null)
      ) {
        acc.push(ele);
      }
      return acc;
    }, []);
    updateHeaderOverrides({ jsonOverrides: JSON.stringify(toSend) })
      .then(() => {
        Toast.show({
          label: "Success!",
          message: "Header Overrides created Successfully",
          variant: "success",
          mode: "dissmissible"
        });
        this.close("success");
      })
      .catch((error) => {
        this._handleError(error);
      });
  }

  _init() {
    if (this._recordsLoaded && this._columnsLoaded) {
      this._processColumnHeaders();
      this.isBusy = false;
    }
  }

  _processColumnHeaders() {
    this.allOverrides = this._allHeaders.reduce((acc, header) => {
      const current = this.currentOverrides.find(
        (overRide) => overRide.mrexport__Field_Label__c === header
      );
      if (current === undefined) {
        acc.push({
          mrexport__Field_Label__c: header,
          mrexport__MultiReport_Export_Item__c: this.itemId,
          mrexport__MultiReport_Export_Template__c: this.templateId
        });
        return acc;
      }
      acc.push(current);
      return acc;
    }, []);
    console.log(this.allOverrides);
  }

  _handleError(error) {
    Toast.show({
      label: "There was an Error!",
      message: reduceErrors(error).join(", "),
      variant: "error",
      mode: "dissmissible"
    });
    this.close();
  }
}
