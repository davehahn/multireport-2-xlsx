public with sharing class Application_Settings {
  private static Application_Settings instance;

  private Boolean emailDeliverability;

  /* Public Methods */
  public Boolean emailDeliverabilityEnabled() {
    if (emailDeliverability == null) {
      emailDeliverability = true;
      try {
        Messaging.reserveSingleEmailCapacity(1);
      } catch (Exception e) {
        emailDeliverability = false;
      }
      emailDeliverability = Test.isRunningTest() ? false : emailDeliverability;
    }
    return emailDeliverability;
  }

  /* Static Methods */
  public static Application_Settings getInstance() {
    if (instance == null) {
      instance = new Application_Settings();
    }
    return instance;
  }
}
