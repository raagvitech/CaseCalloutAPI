public with sharing class GenericConstant 
{
    public static final List<String> MANADATORYFIELD = new List<String>{'accountnumber','tlsdocumentationlink'};
    public static final Map<String,Boolean> ONLINESOURCEFIELDVALUECHECK = new Map<String,Boolean>{'Proof Of Occupancy' => true};
    public static final Map<String,String> MATCHINGFIELD = new Map<String,String>{'origin' => 'Origin','accountnumber' => 'CAC_ID__c'};
    public static final Id GENERALRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
    public static final String OPENCLOSE_CASE_COMMENT = 'Proof of Occurrancy documentation has been received{0}.';
    public static final String OPEN_CASE_COMMENT = 'Please use the link provided to access and review the documentation.';
    public static final String CLOSED_CASE_COMMENTS = 'Case was already Closed, so Document Link has not been updated.Refer to the SharePoint folder to find and review the documentation.';
    public static final String GENERALRECORDTYPE = 'General';
    public static final String ORDERREMEDIATION = 'Order Remediation';
    public static final String CASESTATUS = 'Open';
    public static final String CASEPPRIORITY = 'Medium';
    public static final String CASECONTACTREASON = 'Query or Manage My Order';
    public static final String CASEDESCRRIPTION = 'Case created automatically as Account does not match original Case{0}.';
}