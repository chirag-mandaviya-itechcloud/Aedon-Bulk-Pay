public class BulkPaymentFeatureController {
    @AuraEnabled
    public static List<natdev24__Purchase_Invoice_Header__c> getPurchaseInvoiceDetails(List<String> invoiceIds){
        try {
            return [SELECT Id, Name, natdev24__Account__r.Name, natdev24__Invoice_Date__c, natdev24__Gross_Amount__c, natdev24__Balance_Outstanding__c, natdev24__Customer_Reference__c,natdev24__Currency__r.name FROM natdev24__Purchase_Invoice_Header__c WHERE Id IN :invoiceIds AND natdev24__Balance_Outstanding__c > 0];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<natdev24__Chart_Of_Accounts__c> getBankAccounts(){
        try {
            List<natdev24__Chart_Of_Accounts__c> bankAccounts = [Select Id,Name,natdev24__Nominal_Account__c, natdev24__Nominal_Code__c from natdev24__Chart_Of_Accounts__c  where natdev24__Category__c = 'Bank'];

            return bankAccounts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
