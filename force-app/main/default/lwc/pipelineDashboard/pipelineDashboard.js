import { LightningElement, wire } from 'lwc';
import getPipelineData from '@salesforce/apex/ApplicationPipelineController.getPipelineData';

export default class PipelineDashboard extends LightningElement {
    pipelineData;
    error;

    @wire(getPipelineData)
    wiredPipeline({ error, data }) {
        if (data) {
            this.pipelineData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.pipelineData = undefined;
        }
    }
}