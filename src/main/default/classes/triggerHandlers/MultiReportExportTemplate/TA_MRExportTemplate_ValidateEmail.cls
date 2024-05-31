public without sharing class TA_MRExportTemplate_ValidateEmail implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
  public void beforeInsert(List<MultiReport_Export_Template__c> newList) {
    Set<String> templateNames = new Set<String>();
    for (MultiReport_Export_Template__c mret : newList) {
      if (mret.Email_Template_Name__c != null) {
        templateNames.add(mret.Email_Template_Name__c);
      }
    }
    findAndSetEmailTemplates(newList, templateNames, null);
  }

  public void beforeUpdate(
    List<MultiReport_Export_Template__c> newList,
    List<MultiReport_Export_Template__c> oldList
  ) {
    Map<Id, MultiReport_Export_Template__c> oldMap = new Map<Id, MultiReport_Export_Template__c>(
      oldList
    );
    Set<Id> recordIdsWithChangedEmailTemplates = new Set<Id>();
    Set<String> templateNames = new Set<String>();
    for (MultiReport_Export_Template__c mret : newList) {
      MultiReport_Export_Template__c oldRecord = oldMap.get(mret.Id);
      if (
        mret.Email_Template_Name__c == null &&
        oldRecord.Email_Template_Name__c != null
      ) {
        mret.Email_Template_Id__c = null;
        continue;
      }
      if (mret.Email_Template_Name__c != oldRecord.Email_Template_Name__c) {
        templateNames.add(mret.Email_Template_Name__c);
        recordIdsWithChangedEmailTemplates.add(mret.Id);
      }
    }
    findAndSetEmailTemplates(
      newList,
      templateNames,
      recordIdsWithChangedEmailTemplates
    );
  }

  private void findAndSetEmailTemplates(
    List<MultiReport_Export_Template__c> newList,
    Set<String> templateNames,
    Set<Id> recordIdsWithChanges
  ) {
    if (templateNames.size() > 0) {
      Map<String, EmailTemplate> templatesByName = new Map<String, EmailTemplate>();
      for (EmailTemplate et : [
        SELECT Id, Name
        FROM EmailTemplate
        WHERE Name IN :templateNames
      ]) {
        templatesByName.put(et.Name, et);
      }
      for (MultiReport_Export_Template__c mret : newList) {
        if (
          recordIdsWithChanges == null || recordIdsWithChanges.contains(mret.Id)
        ) {
          if (
            mret.Email_Template_Name__c != null &&
            templatesByName.containsKey(mret.Email_Template_Name__c)
          ) {
            mret.Email_Template_Id__c = templatesByName.get(
                mret.Email_Template_Name__c
              )
              .Id;
          }
          if (
            mret.Email_Template_Name__c != null &&
            !templatesByName.containsKey(mret.Email_Template_Name__c)
          ) {
            mret.addError(
              'Could not find the Email Template "' +
                mret.Email_Template_Name__c +
                '"'
            );
          }
        }
      }
    }
  }
}
