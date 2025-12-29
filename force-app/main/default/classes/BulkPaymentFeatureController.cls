public class BulkPaymentFeatureController {
    
    // Add this flag -> for Cover Exceptions in the Testclass
    @TestVisible
    private static Boolean throwTestException = false;

    @AuraEnabled
    public static List<natdev24__Purchase_Invoice_Header__c> getPurchaseInvoiceDetails(List<String> invoiceIds){
        try {
            // Add test exception trigger
            if(Test.isRunningTest() && throwTestException) {
                throw new AuraHandledException('Test exception in getPurchaseInvoiceDetails');
            }
            
            return [SELECT Id, Name, natdev24__Account__r.Name, natdev24__Invoice_Date__c, natdev24__Gross_Amount__c, natdev24__Balance_Outstanding__c, natdev24__Customer_Reference__c,natdev24__Currency__r.name FROM natdev24__Purchase_Invoice_Header__c WHERE Id IN :invoiceIds AND natdev24__Balance_Outstanding__c > 0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<natdev24__Sales_Invoice_Header__c> getSalesInvoiceDetails(List<String> invoiceIds){
        try {
            // Add test exception trigger
            if(Test.isRunningTest() && throwTestException) {
                throw new AuraHandledException('Test exception in getSalesInvoiceDetails');
            }
            
            return [SELECT Id, Name, natdev24__Account__r.Name, natdev24__Invoice_Date__c, natdev24__Gross_Amount__c, natdev24__Balance_Outstanding__c, natdev24__Customer_Reference__c,natdev24__Currency__r.name FROM natdev24__Sales_Invoice_Header__c WHERE Id IN :invoiceIds AND natdev24__Balance_Outstanding__c > 0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<natdev24__Chart_Of_Accounts__c> getBankAccounts(){
        try {
            // Add test exception trigger
            if(Test.isRunningTest() && throwTestException) {
                throw new AuraHandledException('Test exception in getBankAccounts');
            }
            
            List<natdev24__Chart_Of_Accounts__c> bankAccounts = [Select Id,Name,natdev24__Nominal_Account__c, natdev24__Nominal_Code__c from natdev24__Chart_Of_Accounts__c  where natdev24__Category__c = 'Bank'];

            return bankAccounts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PurchaseInvoiceBulkPay.piWrapper processPurchaseInvoiceBulkPayment(List<natdev24__Purchase_Invoice_Header__c> piHeaderList, Decimal exchangeRate, String selectedNominalCode,Decimal totalInvoiceAmount, Date postingDate, String reference){
        try {
            // Add test exception trigger
            if(Test.isRunningTest() && throwTestException) {
                throw new AuraHandledException('Test exception in processPurchaseInvoiceBulkPayment');
            }
            PurchaseInvoiceBulkPay.piWrapper resultWrapper = PurchaseInvoiceBulkPay.bulkPayPI1(piHeaderList,exchangeRate,selectedNominalCode,postingDate,totalInvoiceAmount,null,piHeaderList,null,reference);
            return resultWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SalesInvoiceBulkPay.siWrapper processSalesInvoiceBulkPayment(List<natdev24__Sales_Invoice_Header__c> siHeaderList, Decimal exchangeRate, String selectedNominalCode,Decimal totalInvoiceAmount, Date postingDate, String reference){
        try {
            // Add test exception trigger
            if(Test.isRunningTest() && throwTestException) {
                throw new AuraHandledException('Test exception in processSalesInvoiceBulkPayment');
            }
            SalesInvoiceBulkPay.siWrapper resultWrapper = SalesInvoiceBulkPay.bulkPaySI1(siHeaderList,exchangeRate,selectedNominalCode,postingDate,totalInvoiceAmount,null,siHeaderList,null,reference);
            return resultWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getInvoiceType(String recordId){
        try {
            Id recId = Id.valueOf(recordId);
            Schema.DescribeSObjectResult objectDescribe = recId.getSobjectType().getDescribe();

            return new Map<string, String>{
                'apiName' => objectDescribe.getName(),
                'label' => objectDescribe.getLabel()
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}