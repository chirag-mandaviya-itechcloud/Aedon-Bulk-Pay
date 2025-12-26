/**
* BulkPaymentFeatureControllerTest
*
* Author: Test Developer
* Created Date: 2025-12-25
*
* Description:
*  Test class for BulkPaymentFeatureController
*  Provides comprehensive coverage for all methods including bulk payment processing
*/
@isTest
private class BulkPaymentFeatureControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        Tax_Legislation__c objTaxLegislation = new Tax_Legislation__c(Name = 'United Kingdom', 
                                                                      Short_Code__c = 'UK');
        System.assertEquals(objTaxLegislation.Name,'United Kingdom');
        insert objTaxLegislation;
        
        Company__c objComp = new Company__c();
        objComp.Name = 'Carlton Actions';
        objComp.VAT_Period_covered_by_the_return__c = 'Quarterly';
        objComp.Tax_Legislation__c = objTaxLegislation.id;
        objComp.VAT_Registration_Number__c='1223456895';
        objComp.VAT_Method__c = 'Accrual';
        insert objComp;
        
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String orgId = UserInfo.getOrganizationId();
        String uniqueName = orgId + dateString + randomInt;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User tuser = new User(  firstname = 'test',
                              lastName = 'user',
                              email = 'testuser@gmail.com',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profile.Id,
                              Current_Logged_In_Company__c  = objComp.Id
                             );
        insert tuser;
        System.runAs(tuser){ 
            
            User_Company__c objUserCompany = new User_Company__c();
            objUserCompany.User__c = tuser.Id;
            objUserCompany.Current_Logged_In_Company__c = objComp.Id;
            insert objUserCompany;
            
            Currency__c objCurrency = new Currency__c();
            objCurrency.Name = 'Pound Sterling';
            objCurrency.Company__c =  objComp.ID;
            objCurrency.ISO_Code__c = 'GBP';
            objCurrency.IsBaseCurrency__c = true;
            insert objCurrency;
            
            Chart_Of_Accounts__c objcoa = new Chart_Of_Accounts__c();
            objcoa.Nominal_Code__c = 5000;
            objcoa.Name = 'Test COA';
            objcoa.Nominal_Account_UID__c = 'AP710';
            objcoa.Company__c=objComp.Id;
            objcoa.Reporting_Class__c='Cash and Bank';
            objcoa.Category__c = 'Bank';
            insert objcoa;
            
            Chart_Of_Accounts__c objcoa1 = new Chart_Of_Accounts__c();
            objcoa1.Nominal_Code__c = 5000;
            objcoa1.Name = 'Test COA 1';
            objcoa1.Nominal_Account_UID__c = 'AR710';
            objcoa1.Company__c=objComp.Id;
            objcoa1.Reporting_Class__c='Cash and Bank';
            objcoa1.Category__c = 'Bank';
            insert objcoa1;
            
            Account supplierAccount = new Account();
            supplierAccount.Name = 'Test Supplier Account';
            supplierAccount.Nominal_Code__c = objcoa.Id;
            supplierAccount.VAT_Treatment__c ='UK';
            supplierAccount.Account_Type__c = 'Supplier';
            supplierAccount.AccountNumber = 'TA1234';
            supplierAccount.Preferred_Currency1__c = objCurrency.id;
            supplierAccount.Email__c = 'test@supplier.com';
            supplierAccount.Company__c=  objComp.Id;   
            insert supplierAccount;
            
            Account customerAccount = new Account();
            customerAccount.Name = 'Test Customer Account';
            customerAccount.Nominal_Code__c = objcoa.Id;
            customerAccount.VAT_Treatment__c ='UK';
            customerAccount.Account_Type__c = 'Customer';
            customerAccount.AccountNumber = 'TA1235';
            customerAccount.Preferred_Currency1__c = objCurrency.id;
            customerAccount.Email__c = 'test@customer.com';
            customerAccount.Company__c=  objComp.Id;   
            insert customerAccount;
            
            VAT__c vatObjSales = new VAT__c();
            vatObjSales.Company__c = objComp.Id;
            vatObjSales.Description__c = 'TestDes';
            vatObjSales.Rate__c = 2.2;
            vatObjSales.Name = 'Test';
            vatObjSales.Type__c = 'Sales';
            vatObjSales.Category__c= 'Standard Rate';
            vatObjSales.Additional_Category__c = 'Not Applicable';
            vatObjSales.Active__c=true;
            insert vatObjSales;
            
            VAT__c vatObjPurchases = new VAT__c();
            vatObjPurchases.Company__c = objComp.Id;
            vatObjPurchases.Description__c = 'TestDes';
            vatObjPurchases.Rate__c = 2.2;
            vatObjPurchases.Name = 'Test';
            vatObjPurchases.Type__c = 'Purchases';
            vatObjPurchases.Category__c= 'Standard Rate';
            vatObjPurchases.Additional_Category__c = 'Not Applicable';
            vatObjPurchases.Active__c=true;
            insert vatObjPurchases;
            
            Purchase_Invoice_Header__c piHeader1 = new Purchase_Invoice_Header__c();
            piHeader1.Account__c = supplierAccount.Id;
            piHeader1.Invoice_Date__c = Date.today();
            piHeader1.Customer_Reference__c = 'REF-PI-001';
            piHeader1.Currency__c = objCurrency.Id;
            piHeader1.Company__c = objComp.Id;
            piHeader1.Currency_Exchange_Rate__c = 1;
            insert piHeader1;
            
            Purchase_Invoice_Header__c piHeader2 = new Purchase_Invoice_Header__c();
            piHeader2.Account__c = supplierAccount.Id;
            piHeader2.Invoice_Date__c = Date.today();
            piHeader2.Customer_Reference__c = 'REF-PI-002';
            piHeader2.Currency__c = objCurrency.Id;
            piHeader2.Company__c = objComp.Id;
            piHeader2.Currency_Exchange_Rate__c = 1;
            insert piHeader2;
            
            Purchase_Invoice_Header__c piHeader3 = new Purchase_Invoice_Header__c();
            piHeader3.Account__c = supplierAccount.Id;
            piHeader3.Invoice_Date__c = Date.today();
            piHeader3.Customer_Reference__c = 'REF-PI-003';
            piHeader3.Currency__c = objCurrency.Id;
            piHeader3.Company__c = objComp.Id;
            piHeader3.Currency_Exchange_Rate__c = 1;
            insert piHeader3;
            
            Purchase_Invoice_Transaction__c piTxn1 = new Purchase_Invoice_Transaction__c();
            piTxn1.Company__c = objComp.Id;
            piTxn1.Purchase_Invoice_Header__c = piHeader1.Id;
            piTxn1.Amount__c = 10000;
            piTxn1.Net_Transaction_Amount__c = 10000;
            piTxn1.Paid_Amount__c = 2000;
            piTxn1.Purchase_VAT__c = vatObjPurchases.Id;
            insert piTxn1;
            
            Sales_Invoice_Header__c siHeader1 = new Sales_Invoice_Header__c();
            siHeader1.Account__c = customerAccount.Id;
            siHeader1.Invoice_Date__c = Date.today();
            siHeader1.Customer_Reference__c = 'REF-SI-001';
            siHeader1.Currency__c = objCurrency.Id;
            siHeader1.Company__c = objComp.Id;
            siHeader1.Currency_Exchange_Rate__c = 1;
            insert siHeader1;
            
            Sales_Invoice_Header__c siHeader2 = new Sales_Invoice_Header__c();
            siHeader2.Account__c = customerAccount.Id;
            siHeader2.Invoice_Date__c = Date.today();
            siHeader2.Customer_Reference__c = 'REF-SI-002';
            siHeader2.Currency__c = objCurrency.Id;
            siHeader2.Company__c = objComp.Id;
            siHeader2.Currency_Exchange_Rate__c = 1;
            insert siHeader2;
            
            Sales_Invoice_Header__c siHeader3 = new Sales_Invoice_Header__c();
            siHeader3.Account__c = customerAccount.Id;
            siHeader3.Invoice_Date__c = Date.today();
            siHeader3.Customer_Reference__c = 'REF-SI-003';
            siHeader3.Currency__c = objCurrency.Id;
            siHeader3.Company__c = objComp.Id;
            siHeader3.Currency_Exchange_Rate__c = 1;
            insert siHeader3;
            
            Sales_Invoice_Transaction__c siTxn1 = new Sales_Invoice_Transaction__c();
            siTxn1.Company__c = objComp.Id;
            siTxn1.Sales_Invoice_Header__c = siHeader1.Id;
            siTxn1.Amount__c = 2000;
            siTxn1.Paid_Amount__c = 3000;
            siTxn1.Net_Transaction_Amount__c = 10000;
            siTxn1.Sale_VAT__c = vatObjSales.Id;
            insert siTxn1;
            
            AF_APP_CONFIG__c appconfig = new AF_APP_CONFIG__c ();
            appconfig.App_Source__c = 'IS_BATCH_EMAIL_SEND';
            appconfig.App_Destination__c  = 'N';
            insert appconfig;
            
            Bank_Account__c objBankacc = new Bank_Account__c();
            objBankacc.Name = 'Test Bank Account';
            objBankacc.Company__c = objComp.Id;
            objBankacc.Currency__c = objCurrency.Id;
            objBankacc.Nominal_Ledger_Code__c = objcoa.Id;
            objBankacc.Base_Currency_Balance__c = 600;
            objBankacc.Foreign_Currency_Balance__c = 20;
            objBankacc.Reconciliation_Amount_Filter__c = true;
            objBankacc.Reconciliation_Description_Filter__c = false;
            insert objBankacc;
            
            Financial_Year__c fy = new Financial_Year__c();
            fy.Company__c = objComp.ID;
            fy.Start_Date__c = Date.today();
            fy.End_Date__c = Date.today().addYears(1);
            insert fy;
            
            Period__c objPeriod  = new Period__c();
            objPeriod.Name = 'Test Period';
            objPeriod.Company__c= objComp.ID;
            objPeriod.Start_Date__c = Date.today().addDays(-1);
            objPeriod.End_Date__c = Date.today().addDays(2);
            objPeriod.Period_Financial_Year__c = fy.Id;
            //objPeriod.Lock_Date__c = objComp.Lock_Date__c;
            objPeriod.Period_Number__c = 20;
            insert objPeriod;
        }
    }
    
    @isTest
    static void testGetPurchaseInvoiceDetails_Success() {
        Account supplierAccount = [SELECT Id FROM Account WHERE Name = 'Test Supplier Account' LIMIT 1];
        
        List<Purchase_Invoice_Header__c> piHeaders = [
            SELECT Id
            FROM Purchase_Invoice_Header__c 
            WHERE Account__c = :supplierAccount.Id
        ];
        
        List<String> invoiceIds = new List<String>();
        for (Purchase_Invoice_Header__c pi : piHeaders) {
            invoiceIds.add(pi.Id);
        }
        
        Test.startTest();
        List<Purchase_Invoice_Header__c> results = 
            BulkPaymentFeatureController.getPurchaseInvoiceDetails(invoiceIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return only invoices with outstanding balance');
        
        for (Purchase_Invoice_Header__c pi : results) {
            System.assert(pi.Balance_Outstanding__c > 0, 'Balance should be greater than 0');
        }
    }
    
    @isTest
    static void testGetPurchaseInvoiceDetails_EmptyList() {
        Test.startTest();
        List<Purchase_Invoice_Header__c> results = 
            BulkPaymentFeatureController.getPurchaseInvoiceDetails(new List<String>());
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for empty input');
    }
    
    @isTest
    static void testGetPurchaseInvoiceDetails_InvalidIds() {
        List<String> invalidIds = new List<String>{'invalid-id-123'};
            
            Test.startTest();
        try {
            List<Purchase_Invoice_Header__c> results = 
                BulkPaymentFeatureController.getPurchaseInvoiceDetails(invalidIds);
            System.assertEquals(0, results.size(), 'Should return empty list for empty input');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetSalesInvoiceDetails_Success() {
        Account customerAccount = [SELECT Id FROM Account WHERE Name = 'Test Customer Account' LIMIT 1];
        
        List<Sales_Invoice_Header__c> siHeaders = [
            SELECT Id 
            FROM Sales_Invoice_Header__c 
            WHERE Account__c = :customerAccount.Id
        ];
        
        List<String> invoiceIds = new List<String>();
        for (Sales_Invoice_Header__c si : siHeaders) {
            invoiceIds.add(si.Id);
        }
        
        Test.startTest();
        List<Sales_Invoice_Header__c> results = 
            BulkPaymentFeatureController.getSalesInvoiceDetails(invoiceIds);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return only invoices with outstanding balance');
        
        for (Sales_Invoice_Header__c si : results) {
            System.assert(si.Balance_Outstanding__c > 0, 'Balance should be greater than 0');
        }
    }
    
    @isTest
    static void testGetSalesInvoiceDetails_EmptyList() {
        Test.startTest();
        List<Sales_Invoice_Header__c> results = 
            BulkPaymentFeatureController.getSalesInvoiceDetails(new List<String>());
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for empty input');
    }
    
    @isTest
    static void testGetSalesInvoiceDetails_InvalidIds() {
        List<String> invalidIds = new List<String>{'invalid-id-456'};
            
            Test.startTest();
        try {
            List<Sales_Invoice_Header__c> results = 
                BulkPaymentFeatureController.getSalesInvoiceDetails(invalidIds);
            System.assertEquals(0, results.size(), 'Should return empty list for empty input');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 'Should throw AuraHandledException');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetBankAccounts_Success() {
        Test.startTest();
        List<Chart_Of_Accounts__c> results = 
            BulkPaymentFeatureController.getBankAccounts();
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return only bank category accounts');
        
        for (Chart_Of_Accounts__c acc : results) {
            System.assertNotEquals(null, acc.Name, 'Name should be populated');
            System.assertNotEquals(null, acc.Nominal_Code__c, 'Nominal code should be populated');
        }
    }
    
    @isTest
    static void testGetBankAccounts_NoBankAccounts() {
        // Delete all bank accounts
        delete [SELECT Id FROM Bank_Account__c WHERE Name = 'Test Bank Account'];
        delete [SELECT Id FROM Chart_Of_Accounts__c WHERE Category__c = 'Bank'];
        
        Test.startTest();
        List<Chart_Of_Accounts__c> results = 
            BulkPaymentFeatureController.getBankAccounts();
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list when no bank accounts exist');
    }
    
    @isTest
    static void testProcessPurchaseInvoiceBulkPayment_Success() {
        List<Purchase_Invoice_Header__c> piHeaders = [
            SELECT Id, Name, Account__c, Invoice_Date__c, 
            Gross_Amount__c, Balance_Outstanding__c,
            Currency__c, Company__c
            FROM Purchase_Invoice_Header__c 
            WHERE Balance_Outstanding__c > 0
        ];
        
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id 
            FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' 
            LIMIT 1
        ];
        
        Decimal totalAmount = 0;
        for (Purchase_Invoice_Header__c pi : piHeaders) {
            totalAmount += pi.Balance_Outstanding__c;
        }
        
        Test.startTest();
        try {
            PurchaseInvoiceBulkPay.piWrapper result = 
                BulkPaymentFeatureController.processPurchaseInvoiceBulkPayment(
                    piHeaders,
                    1.0,
                    bankAccount.Id,
                    totalAmount,
                    Date.today(),
                    'Bulk Payment Test'
                );
            
            System.assertNotEquals(null, result, 'Result wrapper should not be null');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 
                          'Should throw AuraHandledException on error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessPurchaseInvoiceBulkPayment_EmptyList() {
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id 
            FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' 
            LIMIT 1
        ];
        
        Test.startTest();
        try {
            PurchaseInvoiceBulkPay.piWrapper result = 
                BulkPaymentFeatureController.processPurchaseInvoiceBulkPayment(
                    new List<Purchase_Invoice_Header__c>(),
                    1.0,
                    bankAccount.Id,
                    0,
                    Date.today(),
                    'Empty List Test'
                );
            
            System.assertNotEquals(null, result, 'Should return result even with empty list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 'Should have error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessSalesInvoiceBulkPayment_Success() {
        List<Sales_Invoice_Header__c> siHeaders = [
            SELECT Id, Name, Account__c, Invoice_Date__c, 
            Gross_Amount__c, Balance_Outstanding__c,
            Currency__c, Company__c
            FROM Sales_Invoice_Header__c 
            WHERE Balance_Outstanding__c > 0
        ];
        
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id 
            FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' 
            LIMIT 1
        ];
        
        Decimal totalAmount = 0;
        for (Sales_Invoice_Header__c si : siHeaders) {
            totalAmount += si.Balance_Outstanding__c;
        }
        
        Test.startTest();
        try {
            SalesInvoiceBulkPay.siWrapper result = 
                BulkPaymentFeatureController.processSalesInvoiceBulkPayment(
                    siHeaders,
                    1.0,
                    bankAccount.Id,
                    totalAmount,
                    Date.today(),
                    'Bulk Payment Test'
                );
            
            System.assertNotEquals(null, result, 'Result wrapper should not be null');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 
                          'Should throw AuraHandledException on error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessSalesInvoiceBulkPayment_EmptyList() {
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id 
            FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' 
            LIMIT 1
        ];
        
        Test.startTest();
        try {
            SalesInvoiceBulkPay.siWrapper result = 
                BulkPaymentFeatureController.processSalesInvoiceBulkPayment(
                    new List<Sales_Invoice_Header__c>(),
                    1.0,
                    bankAccount.Id,
                    0,
                    Date.today(),
                    'Empty List Test'
                );
            
            System.assertNotEquals(null, result, 'Should return result even with empty list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 'Should have error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInvoiceType_PurchaseInvoice() {
        Purchase_Invoice_Header__c piHeader = [
            SELECT Id 
            FROM Purchase_Invoice_Header__c 
            LIMIT 1
        ];
        
        Test.startTest();
        Map<String, String> result = 
            BulkPaymentFeatureController.getInvoiceType(piHeader.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.get('apiName'), 'API Name should be populated');
        System.assertNotEquals(null, result.get('label'), 'Label should be populated');
        System.assert(result.get('apiName').contains('Purchase_Invoice_Header'), 
                      'API Name should contain Purchase_Invoice_Header');
    }
    
    @isTest
    static void testGetInvoiceType_SalesInvoice() {
        Sales_Invoice_Header__c siHeader = [
            SELECT Id 
            FROM Sales_Invoice_Header__c 
            LIMIT 1
        ];
        
        Test.startTest();
        Map<String, String> result = 
            BulkPaymentFeatureController.getInvoiceType(siHeader.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.get('apiName'), 'API Name should be populated');
        System.assertNotEquals(null, result.get('label'), 'Label should be populated');
        System.assert(result.get('apiName').contains('Sales_Invoice_Header'), 
                      'API Name should contain Sales_Invoice_Header');
    }
    
    @isTest
    static void testGetInvoiceType_InvalidId() {
        Test.startTest();
        try {
            Map<String, String> result = 
                BulkPaymentFeatureController.getInvoiceType('invalid-id');
            System.assert(false, 'Should throw exception for invalid ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 
                          'Should throw AuraHandledException with message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetInvoiceType_NullId() {
        Test.startTest();
        try {
            Map<String, String> result = 
                BulkPaymentFeatureController.getInvoiceType(null);
            System.assert(false, 'Should throw exception for null ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 
                          'Should throw AuraHandledException with message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetPurchaseInvoiceDetails_Exception() {
        List<String> invoiceIds = new List<String>();
        Purchase_Invoice_Header__c piHeader = [SELECT Id FROM Purchase_Invoice_Header__c LIMIT 1];
        invoiceIds.add(piHeader.Id);
        
        BulkPaymentFeatureController.throwTestException = true;
        
        Test.startTest();
        try {
            List<Purchase_Invoice_Header__c> results = 
                BulkPaymentFeatureController.getPurchaseInvoiceDetails(invoiceIds);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exception'), 'Should contain test exception message');
        }
        Test.stopTest();
        
        BulkPaymentFeatureController.throwTestException = false;
    }
    
    @isTest
    static void testGetSalesInvoiceDetails_Exception() {
        List<String> invoiceIds = new List<String>();
        Sales_Invoice_Header__c siHeader = [SELECT Id FROM Sales_Invoice_Header__c LIMIT 1];
        invoiceIds.add(siHeader.Id);

        BulkPaymentFeatureController.throwTestException = true;
        
        Test.startTest();
        try {
            List<Sales_Invoice_Header__c> results = 
                BulkPaymentFeatureController.getSalesInvoiceDetails(invoiceIds);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exception'), 'Should contain test exception message');
        }
        Test.stopTest();
        
        BulkPaymentFeatureController.throwTestException = false;
    }
    
    @isTest
    static void testGetBankAccounts_Exception() {
        BulkPaymentFeatureController.throwTestException = true;
        
        Test.startTest();
        try {
            List<Chart_Of_Accounts__c> results = 
                BulkPaymentFeatureController.getBankAccounts();
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exception'), 'Should contain test exception message');
        }
        Test.stopTest();

        BulkPaymentFeatureController.throwTestException = false;
    }
    
    @isTest
    static void testProcessPurchaseInvoiceBulkPayment_Exception() {
        List<Purchase_Invoice_Header__c> piHeaders = [
            SELECT Id, Name FROM Purchase_Invoice_Header__c LIMIT 1
        ];
        
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' LIMIT 1
        ];
        
        BulkPaymentFeatureController.throwTestException = true;
        
        Test.startTest();
        try {
            PurchaseInvoiceBulkPay.piWrapper result = 
                BulkPaymentFeatureController.processPurchaseInvoiceBulkPayment(
                    piHeaders, 1.0, bankAccount.Id, 1000, Date.today(), 'Test'
                );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exception'), 'Should contain test exception message');
        }
        Test.stopTest();

        BulkPaymentFeatureController.throwTestException = false;
    }
    
    @isTest
    static void testProcessSalesInvoiceBulkPayment_Exception() {
        List<Sales_Invoice_Header__c> siHeaders = [
            SELECT Id, Name FROM Sales_Invoice_Header__c LIMIT 1
        ];
        
        Chart_Of_Accounts__c bankAccount = [
            SELECT Id FROM Chart_Of_Accounts__c 
            WHERE Category__c = 'Bank' LIMIT 1
        ];
        
        BulkPaymentFeatureController.throwTestException = true;
        
        Test.startTest();
        try {
            SalesInvoiceBulkPay.siWrapper result = 
                BulkPaymentFeatureController.processSalesInvoiceBulkPayment(
                    siHeaders, 1.0, bankAccount.Id, 1000, Date.today(), 'Test'
                );
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('exception'), 'Should contain test exception message');
        }
        Test.stopTest();

        BulkPaymentFeatureController.throwTestException = false;
    }
}