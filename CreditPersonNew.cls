global with sharing class CreditPersonNew extends forseva1.CreditPersonDefault {
    
    // Used by blended reports.
    global override List<forseva1.Person> getCreditSubject(ID acctId) {
        return getCreditSubjectPubx(acctId);    
    }
    global override List<forseva1.Person> getCreditSubjectUsingParameterString(String parameterString) {
        return getCreditSubjectUsingParameterStringPub(parameterString);
    }

    public List<forseva1.Person> getCreditSubjectUsingParameterStringPub(String parameterString) {
        ID accountId = null;
        list<String> nvpList = parameterString.split(',');
        for (String nvp: nvpList) {
            String nm = getNameFromNvp(nvp);
            String val = getValueFromNvp(nvp);
            if (nm == 'accountId')
                accountId = id.valueOf(val);
        }
        return getCreditSubjectPubx(accountId);        

    }
    
    
    // Public Interface
    private List<forseva1.Person> getCreditSubjectPubx(ID acctId) {
        String qstring = ' Select Salutation, MailingStreet, MailingState, MailingPostalCode, MailingCity, LastName, Id, FirstName, Title, Social_Security__c, Birthdate'
                       + ' From Contact ' 
                       + ' where accountId = \'' + acctId + '\'';
        List<Contact> contacts = Database.query(qstring);
                                  
        List<forseva1.Person> persons = new List<forseva1.Person>();
        for (Contact ct : contacts) { 
            forseva1.Person p = new forseva1.Person();
            p.UnparsedAddress = ct.MailingStreet;
            p.StreetName = ct.MailingStreet;
            p.City = ct.MailingCity;
            p.FirstName = ct.FirstName;
            p.LastName = ct.LastName;
            p.PostalCode = ct.MailingPostalCode;
            p.State = ct.MailingState;
            p.personId = ct.id;
            p.SSN = ct.Social_Security__c;
            if (ct.Birthdate != null)
              p.age = ct.Birthdate.monthsBetween(Date.today())/12;
              p.DateOfBirth = ct.Birthdate;
            persons.add(p);
        } 
        
        System.debug(' in CreditPersonNew....persons = ' + persons);
        return persons;        
    }
    
    private String getNameFromNvp(String nvp) {
        list<String> lst = nvp.split(':');
        return lst[0];
    }
    private String getValueFromNvp(String nvp) {
        System.debug(' nvp=' + nvp);
        list<String> lst = nvp.split(':');
        return lst[1];
    }
  
}