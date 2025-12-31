/**
 * BulkPaymentFeature LWC
 *
 * Author: Abhishek D
 * Created Date: 19 December 2025
 * Last Modified By: Abhishek D
 * Last Modified Date: 19 December 2025
 *
 * Description:
 * Lightning Web Component used to select and process bulk payments for
 * purchase and sales invoices. Communicates with `BulkPaymentFeatureController`
 * Apex methods to fetch invoice and bank account data and to execute
 * bulk payment processing.
 */
import { LightningElement, api, track } from 'lwc';
import LightningAlert from 'lightning/alert';
import getPurchaseInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getPurchaseInvoiceDetails';
import getSalesInvoiceDetails from '@salesforce/apex/BulkPaymentFeatureController.getSalesInvoiceDetails';
import getBankAccounts from '@salesforce/apex/BulkPaymentFeatureController.getBankAccounts';
import processPurchaseInvoiceBulkPayment from '@salesforce/apex/BulkPaymentFeatureController.processPurchaseInvoiceBulkPayment';
import processSalesInvoiceBulkPayment from '@salesforce/apex/BulkPaymentFeatureController.processSalesInvoiceBulkPayment';
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

    /**
     * connectedCallback
     * Component lifecycle hook. Validates selected records, loads bank
     * accounts and loads invoice details when `recordIds` are provided.
     */
    connectedCallback() {
        // console.log('Record Ids :', this.recordIds);
        this.checkRecordsIsSelected();
        this.loadBankAccounts();
        if (this.recordIds) {
            this.getObjectTypeAndLoadInvoiceDetails();
        }
    }

    /**
     * checkRecordsIsSelected
     * Ensures that `recordIds` is present and shows an alert if none
     * were provided by the host page.
     */
    checkRecordsIsSelected() {
        if (!this.recordIds) {
            this.showAlertAndReturn('Error', 'Select Invoices with Outstanding Balance', 'error');
        }
    }

    /**
     * loadBankAccounts
     * Calls Apex to retrieve chart-of-accounts records filtered for
     * bank accounts and populates `bankAccountOptions` for the UI.
     */
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

    /**
     * getApexControllerMethodForGetDetails
     * Returns the appropriate Apex method to fetch invoice details
     * depending on the determined invoice type (Purchase or Sales).
     */
    getApexControllerMethodForGetDetails() {
        if (this.invoiceType === 'Purchase') {
            return getPurchaseInvoiceDetails;
        } else if (this.invoiceType === 'Sales') {
            return getSalesInvoiceDetails;
        }

        return null;
    }

    /**
     * getApexControllerMethodForProcessBulkPayment
     * Returns the appropriate Apex method to process bulk payments
     * depending on whether the invoices are Purchase or Sales type.
     */
    getApexControllerMethodForProcessBulkPayment() {
        if (this.invoiceType === 'Purchase') {
            return processPurchaseInvoiceBulkPayment;
        } else if (this.invoiceType === 'Sales') {
            return processSalesInvoiceBulkPayment;
        }
        return null;
    }

    /**
     * getObjectTypeAndLoadInvoiceDetails
     * Determines the sObject type of the provided recordIds and sets
     * `invoiceType` accordingly before loading the invoice details.
     */
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
                    // console.log('Invoice Type:', this.invoiceType);
                    const recordIdArray = this.recordIds.split(',').map(id => id.trim());
                    this.loadInvoiceDetails(recordIdArray);
                })
                .catch(error => {
                    console.error('Error fetching invoice type:', error);
                });
        }
    }

    /**
     * loadInvoiceDetails
     * Loads invoice header records via the appropriate Apex method,
     * maps additional display fields, validates currency consistency
     * and preselects all returned records for payment.
     */
    loadInvoiceDetails(recordIdArray) {
        const apexControllerMethod = this.getApexControllerMethodForGetDetails();

        if (!apexControllerMethod) {
            console.error('No Apex controller method found for invoice type:', this.invoiceType);
            return;
        }

        this.isLoading = true;

        apexControllerMethod({ invoiceIds: recordIdArray })
            .then(async result => {
                // Add accountName field for datatable display
                this.invoiceRecords = result.map(invoice => ({
                    ...invoice,
                    accountName: invoice.natdev24__Account__r?.Name || ''
                }));
                this.selectedRows = this.invoiceRecords.map(inv => inv.Id);
                // console.log('Loaded Invoices:', this.invoiceRecords);
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
        /**
         * handleRowSelection
         * Updates `selectedRows` when the user changes selection in the
         * datatable.
         */
        this.selectedRows = event.detail.selectedRows.map(row => row.Id);
        // console.log('Selected Rows:', this.selectedRows);
    }

    handlePaymentFieldChange(event) {
        /**
         * handlePaymentFieldChange
         * Generic handler for changes to the payment input fields. The
         * target element must include a `data-field` attribute matching
         * the component property to update.
         */
        const field = event.target.dataset.field;
        this[field] = event.target.value;

        // console.log(`Payment field changed: ${field} = ${this[field]}`);
    }

    /**
     * totalAmount (getter)
     * Computes the total outstanding amount for the currently selected
     * invoices, formatted to two decimal places as a string.
     */
    get totalAmount() {
        return this.invoiceRecords
            .filter(inv => this.selectedRows.includes(inv.Id))
            .reduce((sum, inv) => sum + (inv.natdev24__Balance_Outstanding__c || 0), 0)
            .toFixed(2);
    }

    /**
     * handlePay
     * Validates payment inputs, builds the parameters required by the
     * Apex bulk payment method and invokes processing. Shows success
     * or error alerts to the user.
     */
    async handlePay() {
        try {
            this.isLoading = true;

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

            let params = {
                exchangeRate: this.exchangeRate,
                selectedNominalCode: this.bankAccount,
                totalInvoiceAmount: this.totalAmount,
                postingDate: this.paymentDate,
                reference: this.paymentReference
            }

            // console.log('Processing payments:', {
            //     HeaderList: selectedInvoices,
            //     exchangeRate: this.exchangeRate,
            //     selectedNominalCode: this.bankAccount,
            //     totalInvoiceAmount: this.totalAmount,
            //     postingDate: this.paymentDate,
            //     reference: this.paymentReference
            // });

            const processApexMethod = await this.getApexControllerMethodForProcessBulkPayment();

            if (this.invoiceType === 'Purchase') {
                params.piHeaderList = selectedInvoices;
            } else if (this.invoiceType === 'Sales') {
                params.siHeaderList = selectedInvoices;
            }

            const result = await processApexMethod(params);

            if (result) {
                await this.showAlertAndReturn(
                    'Success',
                    'Selected Invoices are paid with Outstanding Amount',
                    'success'
                );
            }

        } catch (error) {
            console.error('Error processing bulk payment:', error);
            await this.showAlert('Error', 'An error occurred while processing payments.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleCancel() {
        /**
         * handleCancel
         * Navigates the user back to the list view for the invoice object.
         */
        // console.log('Cancel clicked - forcing navigation');
        url = `/lightning/o/${this.invoiceInfo.apiName}/list?filterName=Recent`
        window.location.replace(url);
    }

    /**
     * showAlert
     * Helper that opens a LightningAlert modal with the provided title
     * and message.
     */
    async showAlert(title, message, theme = 'success') {
        await LightningAlert.open({
            message,
            theme,
            label: title
        });
    }

    /**
     * showAlertAndReturn
     * Shows an alert and then navigates back to the invoice list after a
     * short delay.
     */
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