import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import LightningAlert from 'lightning/alert';
import getPurchaseInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getPurchaseInvoiceDetails';

export default class BulkPaymentFeature extends LightningElement {
    @api recordIds;
    @api availableActions = [];

    @track invoiceRecords = [];
    // @track filteredInvoices = [];
    @track selectedRows = [];
    @track filterAccount = '';
    @track filterFromDate = '';
    @track filterToDate = '';
    @track filterReference = '';
    @track paymentDate = '';
    @track bankAccount = '';
    @track exchangeRate = '';
    @track paymentReference = '';

    isLoading = false;

    // Define columns for lightning-datatable
    columns = [
        {
            label: 'Invoice',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Account',
            fieldName: 'accountName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Invoice Date',
            fieldName: 'natdev24__Invoice_Date__c',
            type: 'date',
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            }
        },
        {
            label: 'Customer Reference',
            fieldName: 'natdev24__Customer_Reference__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Gross Amount',
            fieldName: 'natdev24__Gross_Amount__c',
            type: 'number'
        },
        {
            label: 'Outstanding Amount',
            fieldName: 'natdev24__Balance_Outstanding__c',
            type: 'number'
        },

    ];

    connectedCallback() {
        console.log('Record Ids :', this.recordIds);
        if (this.recordIds) {
            const recordIdArray = this.recordIds.split(',').map(id => id.trim());
            this.loadInvoiceDetails(recordIdArray);
        }
    }

    loadInvoiceDetails(recordIdArray) {
        this.isLoading = true;
        getPurchaseInvoiceDetails({ invoiceIds: recordIdArray })
            .then(result => {
                // Add accountName field for datatable display
                this.invoiceRecords = result.map(invoice => ({
                    ...invoice,
                    accountName: invoice.natdev24__Account__r?.Name || ''
                }));
                // this.filteredInvoices = [...this.invoiceRecords];
                this.selectedRows = this.invoiceRecords.map(inv => inv.Id);
                console.log('Loaded Invoices:', this.invoiceRecords);
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading invoices:', error);
                this.showToast('Error', 'Failed to load invoice details', 'error');
                this.isLoading = false;
            });
    }

    // handleFilterChange(event) {
    //     const field = event.target.dataset.field;
    //     this[field] = event.target.value;
    //     console.log(`Filter changed: ${field} = ${this[field]}`);
    // }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(row => row.Id);
        console.log('Selected Rows:', this.selectedRows);
    }

    handlePaymentFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    get totalAmount() {
        return this.invoiceRecords
            .filter(inv => this.selectedRows.includes(inv.Id))
            .reduce((sum, inv) => sum + (inv.natdev24__Balance_Outstanding__c || 0), 0)
            .toFixed(2);
    }

    // filterInvoices() {
    //     const filteredPI = this.invoiceRecords.filter(invoice => {
    //         const matchAccount = !this.filterAccount ||
    //             invoice.accountName.toLowerCase().includes(this.filterAccount.toLowerCase());
    //         const matchReference = !this.filterReference ||
    //             invoice.Name.toLowerCase().includes(this.filterReference.toLowerCase());

    //         let matchFromDate = true;
    //         let matchToDate = true;
    //         if (this.filterFromDate && invoice.natdev24__Invoice_Date__c) {
    //             matchFromDate = invoice.natdev24__Invoice_Date__c >= this.filterFromDate;
    //         }
    //         if (this.filterToDate && invoice.natdev24__Invoice_Date__c) {
    //             matchToDate = invoice.natdev24__Invoice_Date__c <= this.filterToDate;
    //         }

    //         return matchAccount && matchReference && matchFromDate && matchToDate;
    //     });

    //     console.log('Filtered Invoices:', filteredPI);
    //     return filteredPI;
    // }

    // handleApplyFilter() {
    //     // this.filteredInvoices = [...this.filterInvoices()];
    //     // Clear selection when filters change
    //     this.selectedRows = [];
    //     this.showToast('Success', 'Filters applied', 'success');
    // }

    // handleApplyClearFilter() {
    //     this.filteredInvoices = [...this.invoiceRecords];
    //     this.filterAccount = '';
    //     this.filterFromDate = '';
    //     this.filterToDate = '';
    //     this.filterReference = '';
    //     this.selectedRows = [];
    //     this.showToast('Success', 'Filters cleared', 'success');
    // }

    handlePay() {
        const selectedInvoices = this.invoiceRecords.filter(inv =>
            this.selectedRows.includes(inv.Id)
        );

        if (selectedInvoices.length === 0) {
            this.showToast('Warning', 'Please select at least one invoice', 'warning');
            return;
        }

        if (!this.paymentDate || !this.bankAccount) {
            this.showToast('Warning', 'Please fill in payment details', 'warning');
            return;
        }

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
        window.location.replace('/lightning/o/natdev24__Purchase_Invoice_Header__c/list?filterName=Recent');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    async showAlert(title, message, theme = 'success') {
        await LightningAlert.open({
            message,
            theme,
            label: title
        });
    }
}
