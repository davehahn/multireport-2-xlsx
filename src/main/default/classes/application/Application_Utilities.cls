public virtual class Application_Utilities {
  private class Application_Utilities_Exception extends Exception {
  }
  private static Application_Utilities instance;

  /* Public Methods */
  public String sObjectNameFromId(Id objId) {
    return Id.valueOf(objId).getSObjectType().getDescribe().getName();
  }

  /* Static Methods */
  public static Application_Utilities getInstance() {
    if (instance == null) {
      instance = new Application_Utilities();
    }
    return instance;
  }

  /* Private Methods */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  private Application_Utilities() {
  }
}
