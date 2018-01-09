/*
@description: Test Class for methods on PopoverController
@author: Dimpi Vora
@created: 01/03/2018
*/

@isTest
public class PopoverController_Test {
    static String COMMERCIAL_PROFILE_NAME = 'Commercial Sales';
    static String CONTACT_RECORD_TYPE = 'Contact';
    static String CALL_REPORT_SUBJECT = 'Test Call Report Popover';
    static Integer NUMCONTACTS = 1;
    
    //Set up Test Data - Account, CallReport, User and Contact
    @testSetup static void setup() {
        Account acc = TestDataFactory.createAccount(1, 'Business', true)[0];
        List<User> users = TestDataFactory.createUsersWithContacts(NUMCONTACTS,COMMERCIAL_PROFILE_NAME,acc.Id,CONTACT_RECORD_TYPE);
        Contact contact = TestDataFactory.createContact(NUMCONTACTS, acc.Id, CONTACT_RECORD_TYPE, true)[0];
        Event event = TestDataFactory.createCallReportEvent(Datetime.now().addDays(-3),60,users[0].Id,acc.Id,CALL_REPORT_SUBJECT,true);
    }
    
    static testMethod void testGetPopupDetails() {
        Event event = [SELECT Id, OwnerId, Entity__c, Call_Type__c, Call_Report__c, Subject FROM Event WHERE Subject='Test Call Report Popover' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE OwnerId = :event.OwnerId AND AccountId= :event.Entity__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Id =:event.OwnerId];
        
        String eventStr = 'Subject,Call_Method__c,Call_Type__c,Completed__c,Confidential__c';
        String contactStr = 'Name, Title__c, AccountId.Name, Phone, Email';
        Integer fieldLimit = 4;
        
        Test.startTest();
        System.runAs(u) {
            //Test for fieldlimit less than the query field parameters
            Map<String, List<Object>> resultEvent = PopoverController.getPopoverDetails('Event',String.valueOf(event.Id),eventStr,fieldLimit);
            List<Object> titles = resultEvent.get('titles');
            List<Object> fields = resultEvent.get('fields');
            
            System.assertEquals(titles.size(),fieldLimit);
            System.assertEquals(fields.size(),fieldLimit);
            
            PopoverController.titles = new List<String>();
            PopoverController.queryFields = new List<String>();
            PopoverController.dataTypeList = new List<String>();
            
            //Test with lookup relationship for Contact object
            Map<String, List<Object>> resultContact = PopoverController.getPopoverDetails('Contact',String.valueOf(con.Id),contactStr,5);
            List<Object> titlesContact = resultContact.get('titles');
            List<Object> fieldsContact = resultContact.get('fields');
            
            System.assertEquals(titlesContact.size(),5);
            System.assertEquals(fieldsContact.size(),5);
            
            PopoverController.titles = new List<String>();
            PopoverController.queryFields = new List<String>();
            PopoverController.dataTypeList = new List<String>();
            
            //Test for duplicate query field parameters
            String dupFields = 'Subject,Call_Method__c,Call_Type__c,Subject,Confidential__c';
            Map<String, List<Object>> eventMap = PopoverController.getPopoverDetails('Event',String.valueOf(event.Id),dupFields,5);
            List<Object> title = resultEvent.get('titles');
            List<Object> field = resultEvent.get('fields');
            
            System.assert(title.size()!=5);
            System.assert(field.size()!=5);
            
            PopoverController.titles = new List<String>();
            PopoverController.queryFields = new List<String>();
            PopoverController.dataTypeList = new List<String>();
            
            //Test for bad data
            Map<String, List<Object>> resultMap = PopoverController.getPopoverDetails('Event','1',eventStr,5);
            System.assert((resultMap.get('data')).size() == 0);
        }
        Test.stopTest();
    }
    
}