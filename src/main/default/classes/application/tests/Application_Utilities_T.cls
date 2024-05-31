@isTest
private class Application_Utilities_T {
  @IsTest
  static void sObjectNameFromId() {
   Id acctId = TriggerTestUtility.getFakeId(Account.SObjectType);
   Test.startTest();
   String result = Application_Utilities.getInstance().sObjectNameFromId(acctId);
   Test.stopTest();
   Assert.areEqual(
     String.valueOf(Account.SObjectType),
     result,
     'The result should be the name of the Account SObject'
   );
  }

}
