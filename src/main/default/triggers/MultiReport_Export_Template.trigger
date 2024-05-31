trigger MultiReport_Export_Template on mrexport__MultiReport_Export_Template__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
}
