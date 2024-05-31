public with sharing class MultiReportRunExportController {
  @AuraEnabled
  public static MultiReport_Export_Template__c getTemplateAndItems(
    String templateId
  ) {
    return [
      SELECT
        Id,
        Name,
        Export_File_Name__c,
        Email_Template_Id__c,
        Email_Recipients__c,
        Auto_Send_Email__c,
        Add_Column_Filter__c,
        (
          SELECT Id, Report_Id__c, Report_Name__c, Sheet_Name__c
          FROM MultiReport_Export_Items__r
        )
      FROM MultiReport_Export_Template__c
      WHERE Id = :templateId
    ];
  }

  @AuraEnabled
  public static Report2XlsxSheet getReportData(String exportItemId) {
    return new Report2XlsxSheet(exportItemId).run();
  }

  @AuraEnabled
  public static void sendFileInEmail(Map<String, String> emailData) {
    List<String> toAddresses = emailData.get('recipients').split(',');
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    Blob fileBlob = EncodingUtil.base64Decode(emailData.get('base64'));
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(emailData.get('fileName'));
    efa.setBody(fileBlob);
    email.setToAddresses(toAddresses);
    email.setTargetObjectId(UserInfo.getUserId());
    email.setSaveAsActivity(false);
    email.setTemplateId(emailData.get('emailTemplateId'));
    email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ efa });
    if (Application_Settings.getInstance().emailDeliverabilityEnabled()) {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
  }
}
