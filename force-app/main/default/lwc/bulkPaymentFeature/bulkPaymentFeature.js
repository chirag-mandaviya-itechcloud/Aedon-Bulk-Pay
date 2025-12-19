import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import getPurchaseInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getPurchaseInvoiceDetails';

export default class BulkPaymentFeature extends LightningElement {
    @api recordIds;

    // Flow attributes - these allow Flow to detect when to move forward
    @api availableActions = [];

    @track invoiceRecords = [];
    @track filterAccount = '';
    @track filterFromDate = '';
    @track filterToDate = '';
    @track filterReference = '';
    @track paymentDate = '';
    @track bankAccount = '';
    @track exchangeRate = '';
    @track paymentReference = '';

    isLoading = false;

    connectedCallback() {
        console.log('Record Ids :', this.recordIds);
        if (this.recordIds) {
            const recordIdArray = this.recordIds.split(',').map(id => id.trim());
            this.loadInvoiceDetails(recordIdArray);
        }
    }

    loadInvoiceDetails(recordIdArray) {
        this.isLoading = true;
        try {
            getPurchaseInvoiceDetails({ invoiceIds: recordIdArray }).then(result => {
                this.invoiceRecords = result;
                console.log('Loaded Invoices:', this.invoiceRecords);
            }).catch(error => {
                console.error('Error loading invoices:', error);
            });
        } catch (error) {
            console.error('Error loading invoices:', error);
            this.showToast('Error', 'Failed to load invoice details', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleFilterChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleRowSelection(event) {
        const invoiceId = event.target.dataset.id;
        this.invoiceRecords = this.invoiceRecords.map(inv =>
            inv.Id === invoiceId ? { ...inv, isSelected: event.target.checked } : inv
        );
    }

    handlePaymentFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    get totalAmount() {
        return this.invoiceRecords
            .filter(inv => inv.isSelected)
            .reduce((sum, inv) => sum + (inv.Outstanding_Amount__c || 0), 0)
            .toFixed(2);
    }

    filteredInvoices() {
        return this.invoiceRecords.filter(invoice => {
            const matchAccount = !this.filterAccount ||
                invoice.Account__r?.Name.toLowerCase().includes(this.filterAccount.toLowerCase());
            const matchReference = !this.filterReference ||
                invoice.Name.toLowerCase().includes(this.filterReference.toLowerCase());

            // Date filtering
            let matchFromDate = true;
            let matchToDate = true;

            if (this.filterFromDate && invoice.Invoice_Date__c) {
                matchFromDate = invoice.Invoice_Date__c >= this.filterFromDate;
            }

            if (this.filterToDate && invoice.Invoice_Date__c) {
                matchToDate = invoice.Invoice_Date__c <= this.filterToDate;
            }

            return matchAccount && matchReference && matchFromDate && matchToDate;

        });
    }

    handleApplyFilter() {
        this.invoiceRecords = [...this.filteredInvoices()];
        this.showToast('Success', 'Filters applied', 'success');
    }

    handlePay() {
        const selectedInvoices = this.invoiceRecords.filter(inv => inv.isSelected);
        if (selectedInvoices.length === 0) {
            this.showToast('Warning', 'Please select at least one invoice', 'warning');
            return;
        }

        if (!this.paymentDate || !this.bankAccount) {
            this.showToast('Warning', 'Please fill in payment details', 'warning');
            return;
        }

        // Call Apex to process payments
        console.log('Processing payments:', {
            invoices: selectedInvoices,
            paymentDate: this.paymentDate,
            bankAccount: this.bankAccount,
            exchangeRate: this.exchangeRate,
            reference: this.paymentReference
        });

        this.showToast('Success', 'Payments posted successfully', 'success');
    }

    handleCancel() {
        console.log('Cancel clicked - forcing navigation');
        // Nuclear option - always works
        window.location.replace('/lightning/o/natdev24__Purchase_Invoice_Header__c/list?filterName=Recent');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
