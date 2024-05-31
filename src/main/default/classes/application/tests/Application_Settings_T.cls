@IsTest
private class Application_Settings_T {
  private static final String STANDARD_PROFILE_NAME = 'Standard User';

  private static user createUser(){
    Profile std = [SELECT Id FROM Profile WHERE Name = :STANDARD_PROFILE_NAME];
    return (User)TestDataFactory.createSobject('User', new Map<String, Object>{
      'ProfileId' => std.Id,
      'UserName' => 'unit@tester.com'
    });
  }
  @IsTest
  static void emailDeliverability() {
    Test.startTest();
    Application_Settings settings = Application_Settings.getInstance();
    Test.stopTest();

    System.assert(
      settings.emailDeliverabilityEnabled() == false,
      'Email Deliverability should be false'
    );
  }

  @IsTest
  static void emailDeliverabilityStandardUser() {
    User u = createUser();
    System.runAs(u) {
      Test.startTest();
      Application_Settings settings = Application_Settings.getInstance();
      Test.stopTest();

      System.assert(
        settings.emailDeliverabilityEnabled() == false,
        'Email Deliverability should be false'
      );
    }
  }
}
