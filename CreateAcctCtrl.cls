public with sharing class CreateAcctCtrl {
    public forseva1__OnlineCreditApplication__c oca {get; private set;}
    private ApexPages.StandardController stdController;
    public boolean attachmentAdded = false;
    public Id recordId {get; set;}
    public String pageMode {get;private set;}
    
    public CreateAcctCtrl() {
    }
    
    public CreateAcctCtrl(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        this.oca = (forseva1__OnlineCreditApplication__c)stdController.getRecord();
        Id recordId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('@@@1 recordId=' + recordId);
        pageMode = ApexPages.currentPage().getParameters().get('pageMode') == 'readOnly' ? 'true' : 'false';
        // instantiate the list with a single attachment
        //newAttachments = new List<Attachment>();
        //mapIdAttachment = new Map<Id,Attachment>();
        //addMore();        
        if(recordId != null) { 
          this.oca = Database.query('select ' + getAllFields('forseva1__OnlineCreditApplication__c').get('forseva1__OnlineCreditApplication__c') + ' from forseva1__OnlineCreditApplication__c where id = :recordId');  
        }
    }

    public static Map<String, String> getAllFields(String sobjectname){
        if(!Schema.getGlobalDescribe().containsKey(sobjectname)) return new Map<String, String>{'Exception' => 'Invalid object name'};
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();
  
        List<String> accessiblefields = new List<String>();
  
        for(Schema.SObjectField field : fields.values()){
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }
  
        String allfields='';
  
        for(String fieldname : accessiblefields)
            allfields += fieldname+',';
  
        allfields = allfields.subString(0,allfields.length()-1);
    
        return new Map<String, String>{sobjectname => allfields};
    }
    
    public PageReference createAccount()
    {   
        System.Debug('@@@ oca=' + oca);
        recordId = this.oca.Id;
        if(this.oca != null)
        {
            system.debug('oca inside CreateAccount***' + this.oca);
            if(this.oca.Account__c == null)
            {
                //Get the record types
                //RecordType usRT = [Select  r.Id, r.SobjectType,DeveloperName From RecordType r where r.SobjectType='Account' and DeveloperName  = 'US_Customer'];
                
                Account acct = new Account();             
                acct.Name = this.oca.forseva1__Business_Name__c;
                acct.BillingStreet = this.oca.forseva1__Billing_Address__c;
                acct.BillingCity = this.oca.forseva1__Billing_City__c;
                acct.BillingState = this.oca.forseva1__Billing_State_Province__c;
                acct.BillingPostalCode = this.oca.forseva1__Billing_Zip_Postal_Code__c;
                acct.BillingCountry = this.oca.forseva1__Billing_Country__c;
                //acct.ShippingStreet = this.oca.Owner_Management_Apt_Suite__c != null ? this.oca.Owner_Management_Address__c + ' ' + this.oca.Owner_Management_Apt_Suite__c : this.oca.Owner_Management_Address__c;
                //acct.ShippingCity = this.oca.Owner_Management_City__c;
                //acct.ShippingState = this.oca.Owner_Management_State__c;
                //acct.ShippingPostalCode = this.oca.Owner_Management_Zip__c;
                acct.Phone = this.oca.forseva1__Phone__c;
                acct.Fax = this.oca.forseva1__Fax__c;
                                                
                insert acct;    
                if(acct.Id != null)
                {
                    system.debug('this.oca***' + this.oca);
                    system.debug('acct.id***' + acct.id);
                    this.oca.Account__c = acct.Id;
                    update this.oca;
                    
                    //check if owners on the application
                    try {
                          forseva1__OnlineCreditApplicationOwner__c[] ocaoList = [Select id
                                                                                          , forseva1__Owner_Name__c
                                                                                          , forseva1__Owner_Address__c
                                                                                          , forseva1__Owner_City__c
                                                                                          , forseva1__Owner_State__c
                                                                                          , forseva1__Owner_Zip__c
                                                                                          , forseva1__Owner_Country__c
                                                                                          , forseva1__Owner_Title__c
                                                                                          , forseva1__Owner_Email__c
                                                                                          , forseva1__Owner_Phone__c
                                                                                          , forseva1__Owner_Fax__c
                                                                                          , Social_Security__c
                                                                                          , Ownership__c
                                                                                          from forseva1__OnlineCreditApplicationOwner__c
                                                                                          where forseva1__Owner_Name__c != null
                                                                                          and forseva1__Online_Credit_Application__r.id =: this.oca.Id ];
                                                                                                                                                                            
                        if (ocaoList.size() > 0)    {   //contacts need to be created
                                String delimitspace = ' ';
                                
                                //loop through all the owners
                                for(forseva1__OnlineCreditApplicationOwner__c owners : ocaoList) {
                                        Contact cnt = new Contact();
                                        cnt.AccountId = acct.Id;
                                        cnt.Firstname = owners.forseva1__Owner_Name__c.substringBefore(delimitspace);
                                        cnt.Lastname = owners.forseva1__Owner_Name__c.substringAfter(delimitspace);
                                        cnt.MailingStreet = owners.forseva1__Owner_Address__c;
                                        cnt.MailingCity = owners.forseva1__Owner_City__c;
                                        cnt.MailingState = owners.forseva1__Owner_State__c;
                                        cnt.MailingPostalCode = owners.forseva1__Owner_Zip__c;
                                        cnt.MailingCountry = owners.forseva1__Owner_Country__c;
                                        cnt.Phone = owners.forseva1__Owner_Phone__c;
                                        cnt.Fax = owners.forseva1__Owner_Fax__c;
                                        cnt.Title = owners.forseva1__Owner_Title__c;
                                        cnt.Email = owners.forseva1__Owner_Email__c;
                                        cnt.Social_Security__c = owners.Social_Security__c;
                                        
                                        insert cnt;
                                
                                }
                        }
                                                                                                                                                                            
                    
                    }
                    catch (QueryException e) {
                                                    //sfIdValid = false;
                            }
                    catch (Exception e) {
                                    //writeErrorRecord('Unknown exception handled: ' + e.getMessage() + ' for record = ' + record);
                                    //sfIdValid = false;
                            }
                    
                }
            }
            else
            {
                ApexPages.Message info = new ApexPages.Message(ApexPages.Severity.INFO, 'Account already exits.');
                ApexPages.addMessage(info);
                return null;
            }
            Pagereference ref = new Pagereference('/' + recordId);
            return ref;
        }
        return null;
    }
    
    
    
  
}