import { LightningElement, api, track } from 'lwc';
import LightningAlert from 'lightning/alert';
import getPurchaseInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getPurchaseInvoiceDetails';
import getSalesInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getSalesInvoiceDetails';
import getBankAccounts from '@salesforce/apex/BulkPaymentFeatureController.getBankAccounts';
import processBulkPayment from '@salesforce/apex/BulkPaymentFeatureController.processBulkPayment';
import getInvoiceType from '@salesforce/apex/BulkPaymentFeatureController.getInvoiceType';

export default class BulkPaymentFeature extends LightningElement {
    @api recordIds;
    @api availableActions = [];

    @track invoiceRecords = [];
    @track selectedRows = [];
    @track paymentDate = '';
    @track bankAccount = '';
    @track exchangeRate = '';
    @track paymentReference = '';
    @track bankAccountOptions = [];
    @track invoiceType = '';
    @track invoiceInfo = {};
    @track isLoading = false;

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
            fieldName: this.accountNameFieldName,
            type: 'text',
            sortable: true
        },
        {
            label: 'Invoice Date',
            fieldName: this.invoiceDateFieldName,
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
            fieldName: this.customerReferenceFieldName,
            type: 'text',
            sortable: true
        },
        {
            label: 'Gross Amount',
            fieldName: this.grossAmountFieldName,
            type: 'number'
        },
        {
            label: 'Outstanding Amount',
            fieldName: this.outstandingAmountFieldName,
            type: 'number'
        },

    ];

    get accountNameFieldName() {
        return 'accountName';
    }

    get invoiceDateFieldName() {
        switch (this.invoiceType) {
            case 'Purchase':
                return 'natdev24__Invoice_Date__c';
            case 'Sales':
                return 'natdev24__Invoice_Date__c';
            default:
                return 'natdev24__Invoice_Date__c';
        }
    }

    get customerReferenceFieldName() {
        switch (this.invoiceType) {
            case 'Purchase':
                return 'natdev24__Customer_Reference__c';
            case 'Sales':
                return 'natdev24__Customer_Reference__c';
            default:
                return 'natdev24__Customer_Reference__c';
        }
    }

    get grossAmountFieldName() {
        switch (this.invoiceType) {
            case 'Purchase':
                return 'natdev24__Gross_Amount__c';
            case 'Sales':
                return 'natdev24__Gross_Amount__c';
            default:
                return 'natdev24__Gross_Amount__c';
        }
    }

    get outstandingAmountFieldName() {
        switch (this.invoiceType) {
            case 'Purchase':
                return 'natdev24__Balance_Outstanding__c';
            case 'Sales':
                return 'natdev24__Balance_Outstanding__c';
            default:
                return 'natdev24__Balance_Outstanding__c';
        }
    }

    connectedCallback() {
        console.log('Record Ids :', this.recordIds);
        this.checkRecordsIsSelected();
        this.loadBankAccounts();
        if (this.recordIds) {
            this.getObjectTypeAndLoadInvoiceDetails();
        }
    }

    checkRecordsIsSelected() {
        if (!this.recordIds) {
            this.showAlertAndReturn('Error', 'Select Invoices with Outstanding Balance', 'error');
        }
    }

    loadBankAccounts() {
        getBankAccounts()
            .then(result => {
                // console.log('Bank Accounts fetched:', result);
                this.bankAccountOptions = result.map(acc => ({
                    label: acc.Name,
                    value: acc.Id
                }));
                // console.log('Loaded Bank Accounts:', this.bankAccountOptions);
            })
            .catch(error => {
                console.error('Error loading bank accounts:', error);
            });
    }

    getApexControllerMethod() {
        if (this.invoiceType === 'Purchase') {
            return getPurchaseInvoiceDetails;
        } else if (this.invoiceType === 'Sales') {
            return getSalesInvoiceDetails;
        }

        return null;
    }

    getObjectTypeAndLoadInvoiceDetails() {
        if (this.recordIds && this.recordIds.length > 0) {
            let recId = this.recordIds.split(',')[0].trim();

            getInvoiceType({ recordId: recId })
                .then(result => {
                    this.invoiceInfo = result;
                    if (result.apiName.includes('Purchase_Invoice')) {
                        this.invoiceType = 'Purchase';
                    } else if (result.apiName.includes('Sales_Invoice')) {
                        this.invoiceType = 'Sales';
                    }
                    console.log('Invoice Type:', this.invoiceType);
                    const recordIdArray = this.recordIds.split(',').map(id => id.trim());
                    this.loadInvoiceDetails(recordIdArray);
                })
                .catch(error => {
                    console.error('Error fetching invoice type:', error);
                });
        }
    }

    loadInvoiceDetails(recordIdArray) {
        const apexControllerMethod = this.getApexControllerMethod();
        this.isLoading = true;

        apexControllerMethod({ invoiceIds: recordIdArray })
            .then(async result => {
                // Add accountName field for datatable display
                this.invoiceRecords = result.map(invoice => ({
                    ...invoice,
                    accountName: invoice.natdev24__Account__r?.Name || ''
                }));
                this.selectedRows = this.invoiceRecords.map(inv => inv.Id);
                console.log('Loaded Invoices:', this.invoiceRecords);
                this.isLoading = false;

                if (this.invoiceRecords.length === 0) {
                    await this.showAlertAndReturn(
                        'Error',
                        'Select Invoices with Outstanding Balance',
                        'error'
                    );
                }

                const currencies = new Set(
                    this.invoiceRecords.map(inv => inv.natdev24__Currency__r.Name)
                );

                if (currencies.size > 1) {
                    await this.showAlertAndReturn(
                        'Error',
                        'Select Invoices with same Currency',
                        'error'
                    );
                }
            })
            .catch(error => {
                console.error('Error loading invoices:', error);
                this.isLoading = false;
            });
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(row => row.Id);
        console.log('Selected Rows:', this.selectedRows);
    }

    handlePaymentFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;

        console.log(`Payment field changed: ${field} = ${this[field]}`);
    }

    get totalAmount() {
        return this.invoiceRecords
            .filter(inv => this.selectedRows.includes(inv.Id))
            .reduce((sum, inv) => sum + (inv.natdev24__Balance_Outstanding__c || 0), 0)
            .toFixed(2);
    }

    async handlePay() {
        const selectedInvoices = this.invoiceRecords.filter(inv =>
            this.selectedRows.includes(inv.Id)
        );

        if (!this.paymentDate || !this.bankAccount || !this.exchangeRate || !this.paymentReference) {
            await this.showAlert(
                'Error',
                'Please fill all mandatory payment details.',
                'error'
            );
            return;
        }

        // console.log('Processing payments:', {
        //     piHeaderList: selectedInvoices,
        //     exchangeRate: this.exchangeRate,
        //     selectedNominalCode: this.bankAccount,
        //     totalInvoiceAmount: this.totalAmount,
        //     postingDate: this.paymentDate,
        //     reference: this.paymentReference
        // });

        const result = await processBulkPayment({
            piHeaderList: selectedInvoices,
            exchangeRate: this.exchangeRate,
            selectedNominalCode: this.bankAccount,
            totalInvoiceAmount: this.totalAmount,
            postingDate: this.paymentDate,
            reference: this.paymentReference
        });

        if (result) {
            await this.showAlertAndReturn(
                'Success',
                'Selected Invoices are paid with Outstanding Amount',
                'success'
            );
        }
    }

    handleCancel() {
        // console.log('Cancel clicked - forcing navigation');
        url = `/lightning/o/${this.invoiceInfo.apiName}/list?filterName=Recent`
        window.location.replace(url);
    }

    async showAlert(title, message, theme = 'success') {
        await LightningAlert.open({
            message,
            theme,
            label: title
        });
    }

    async showAlertAndReturn(title, message, theme = 'success') {
        await LightningAlert.open({
            message,
            theme,
            label: title
        });
        setTimeout(() => {
            this.handleCancel();
        }, 300);
    }
}
