import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BulkPaymentFeature extends LightningElement {
    // Input from Flow
    @api recordIds;

    recordIdArray = [];
    selectedRecords = [];
    isLoading = false;

    connectedCallback() {
        // Parse comma-separated record IDs from URL/Flow
        console.log('Record Ids are===>', this.recordIds);
        if (this.recordIds) {
            this.recordIdArray = this.recordIds.split(',').map(id => id.trim());
            this.loadRecordDetails();
        }
    }

    async loadRecordDetails() {
        this.isLoading = true;
        try {
            // In real implementation, call Apex to get record details
            // For demo, creating mock data
            this.selectedRecords = this.recordIdArray.map((id, index) => ({
                Id: id,
                Name: `Record ${index + 1}`,
                currentValue: 'Current Value'
            }));

            console.log('Loaded Records:', this.selectedRecords);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
