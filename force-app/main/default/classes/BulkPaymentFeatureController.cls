public class BulkPaymentFeatureController {
    @AuraEnabled
    public static List<natdev24__Purchase_Invoice_Header__c> getPurchaseInvoiceDetails(List<String> invoiceIds){
        try {
            return [SELECT Id, Name, natdev24__Account__r.Name, natdev24__Invoice_Date__c, natdev24__Gross_Amount__c, natdev24__Balance_Outstanding__c, natdev24__Net_Amount__c FROM natdev24__Purchase_Invoice_Header__c WHERE Id IN :invoiceIds];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
