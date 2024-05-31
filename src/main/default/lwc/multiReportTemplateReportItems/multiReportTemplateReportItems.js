import { LightningElement, api, wire } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { deleteRecord } from "lightning/uiRecordApi";
import LightningConfirm from "lightning/confirm";
import { refreshApex } from "@salesforce/apex";
import Toast from "lightning/toast";
import { reduceErrors } from "c/utils";
import NewModal from "c/multiReportTemplateNewItemModel";
import HeaderOverrideModal from "c/multiReportHeaderOverrideModal";

export default class MultiReportTemplateReportItems extends LightningElement {
  @api recordId;
  items = [];
  wiredItems;
  selectedReportIds = [];
  isBusy = false;

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: "mrexport__MultiReport_Export_Items__r",
    fields: [
      "mrexport__MultiReport_Export_Item__c.Id",
      "mrexport__MultiReport_Export_Item__c.mrexport__Report_Id__c",
      "mrexport__MultiReport_Export_Item__c.mrexport__Report_Name__c",
      "mrexport__MultiReport_Export_Item__c.mrexport__Sheet_Name__c",
      "mrexport__MultiReport_Export_Item__c.mrexport__Header_Override_Count__c"
    ]
  })
  itemsInfo(result) {
    this.wiredItems = result;
    if (result.data) {
      this.items = result.data.records;
      console.log(JSON.parse(JSON.stringify(this.items)));
      this.selectedReportIds = this.items.map(
        (item) => item.fields.mrexport__Report_Id__c.value
      );
    }
    if (result.error) {
      console.log('eeror here');
      this._handleError(result.error);
    }
  }

  get reportCount() {
    return this.items.length;
  }

  async handleAddReport() {
    const result = await NewModal.open({
      size: "small",
      parentRecordId: this.recordId,
      currentReportIds: this.selectedReportIds
    });
    if (result) {
      Toast.show({
        label: "Success!",
        message: "Report was added to the Template",
        variant: "success",
        mode: "dismissible"
      });
      refreshApex(this.wiredItems);
    }
  }

  handleActionMenu(event) {
    if (event.detail.value === "edit") {
      this._doEdit(event.target.value);
    }
    if (event.detail.value === "override") {
      this._doHeaderOverrides(event.target.value);
    }
    if (event.detail.value === "delete") {
      this._doDelete(event.target.value);
    }
  }

  _handleError(error) {
    //console.log(reduceErrors(error).join(", "));
    Toast.show({
      label: "There was an Error!",
      message: reduceErrors(error).join(", "),
      variant: "error",
      mode: "dissmissible"
    });
  }

  async _doEdit(itemId) {
    const result = await NewModal.open({
      size: "small",
      parentRecordId: this.recordId,
      currentReportIds: this.selectedReportIds,
      itemId: itemId
    });
    if (result) {
      Toast.show({
        label: "Success!",
        message: "Item was Updated",
        variant: "success",
        mode: "dismissible"
      });
      refreshApex(this.wiredItems);
    }
  }

  async _doHeaderOverrides(itemId) {
    const reportId = this.items.find((item) => item.fields.Id.value === itemId)
      .fields.mrexport__Report_Id__c.value;
    const result = await HeaderOverrideModal.open({
      size: "small",
      itemId: itemId,
      templateId: this.recordId,
      reportId: reportId
    });
    if (result === "success") {
      refreshApex(this.wiredItems);
    }
  }

  async _doDelete(itemId) {
    const result = await LightningConfirm.open({
      message: `Revove this report form the template`,
      variant: "header",
      theme: "warning",
      label: "Are you sure?"
    });
    if (result) {
      this.isBusy = true;
      deleteRecord(itemId)
        .then(() => {
          refreshApex(this.wiredItems);
          Toast.show({
            label: "Success",
            message: "Record Deleted",
            variant: "success",
            mode: "dismissible"
          });
        })
        .catch((error) => {
          Toast.show({
            label: "Error Deleting Record",
            message: error.body.message,
            variant: "error",
            mode: "dismissible"
          });
        })
        .finally(() => {
          this.isBusy = false;
        });
    }
  }
}
