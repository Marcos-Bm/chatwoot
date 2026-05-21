/* eslint-disable */
import ApiClient from '../../api/ApiClient';

export default {
  get(accountId) {
    return ApiClient.get(`/api/v1/accounts/${accountId}/pipelines`);
  },
  
  // A atualização do estágio é feita atualizando as labels da conversa,
  // portanto não precisamos de um endpoint específico para update aqui.
  // O backend escuta o evento de label alterada e atualiza a pipeline.
  updateLabels(accountId, conversationId, labels) {
    return ApiClient.post(`/api/v1/accounts/${accountId}/conversations/${conversationId}/labels`, {
      labels
    });
  }
};
