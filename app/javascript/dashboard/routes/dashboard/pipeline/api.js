/* eslint-disable */
import ApiClient from 'dashboard/api/ApiClient';

class PipelineAPI extends ApiClient {
  constructor() {
    super('pipelines', { accountScoped: true });
  }

  updateLabels(accountId, conversationId, labels) {
    return window.axios.post(`/api/v1/accounts/${accountId}/conversations/${conversationId}/labels`, { labels });
  }
}

export default new PipelineAPI();
