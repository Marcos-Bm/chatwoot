/* eslint-disable */
<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useStore } from 'vuex';
import { useAccount } from 'dashboard/composables/useAccount';
import KanbanBoard from './components/KanbanBoard.vue';
import pipelineApi from './api';
import { useAlert } from 'dashboard/composables';

const store = useStore();
const { accountId } = useAccount();
const isLoading = ref(true);
const pipelineData = ref({});

const stages = [
  { key: 'new', label: 'Novo Lead' },
  { key: 'qualified', label: 'Qualificado' },
  { key: 'negotiation', label: 'Em Negociação' },
  { key: 'followup', label: 'Follow-up' },
  { key: 'freezer', label: 'Geladeira' },
  { key: 'closed', label: 'Fechado' },
  { key: 'lost', label: 'Perdido' },
];

const fetchPipeline = async () => {
  isLoading.value = true;
  try {
    const response = await pipelineApi.get(accountId.value);
    pipelineData.value = response.data.payload;
  } catch (error) {
    useAlert(error.message || 'Erro ao carregar o pipeline');
  } finally {
    isLoading.value = false;
  }
};

const handleCardMoved = async ({ card, newStage, oldStage }) => {
  const oldList = pipelineData.value[oldStage];
  const newList = pipelineData.value[newStage] || [];
  
  if (!oldList) return;
  
  // Otimista
  pipelineData.value[oldStage] = oldList.filter(c => c.id !== card.id);
  pipelineData.value[newStage] = [card, ...newList];

  const oldLabel = `pipeline:${oldStage}`;
  const newLabel = `pipeline:${newStage}`;
  
  const currentLabels = card.labels || [];
  const updatedLabels = currentLabels.filter(l => l !== oldLabel && l !== newLabel);
  updatedLabels.push(newLabel);

  try {
    await pipelineApi.updateLabels(accountId.value, card.conversation_id, updatedLabels);
    card.labels = updatedLabels;
  } catch (error) {
    useAlert('Erro ao atualizar estágio do lead. Revertendo...');
    fetchPipeline();
  }
};

// Debounce helper
let timeoutId = null;
const debouncedFetchPipeline = () => {
  if (timeoutId) clearTimeout(timeoutId);
  timeoutId = setTimeout(() => {
    fetchPipeline();
  }, 1000); // 1s debounce
};

let unsubscribe;

onMounted(() => {
  fetchPipeline();
  
  // Escuta todas as mutações do Vuex (as mensagens e labels chegam via ActionCable e atualizam o Vuex)
  unsubscribe = store.subscribe((mutation, state) => {
    // Se houve atualização em conversas, labels, ou mensagens
    if (
      mutation.type.includes('conversations/') ||
      mutation.type.includes('messages/')
    ) {
      debouncedFetchPipeline();
    }
  });
});

onUnmounted(() => {
  if (unsubscribe) unsubscribe();
  if (timeoutId) clearTimeout(timeoutId);
});

</script>

<template>
  <div class="pipeline-container flex flex-col h-full w-full bg-n-background">
    <div class="pipeline-header p-4 border-b border-n-weak flex justify-between items-center bg-white dark:bg-n-solid-1 shadow-sm z-10">
      <h1 class="text-2xl font-semibold text-n-slate-12">Pipeline de Leads</h1>
      <button 
        @click="fetchPipeline" 
        class="button primary small"
        :disabled="isLoading"
      >
        <span v-if="isLoading" class="i-lucide-loader animate-spin mr-1"></span>
        Atualizar
      </button>
    </div>
    
    <div class="pipeline-board flex-1 overflow-x-auto p-4 custom-scrollbar">
      <KanbanBoard 
        v-if="!isLoading || Object.keys(pipelineData).length > 0"
        :stages="stages"
        :data="pipelineData"
        @card-moved="handleCardMoved"
      />
      <div v-else class="flex h-full items-center justify-center">
        <span class="i-lucide-loader animate-spin text-4xl text-n-slate-11"></span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.pipeline-container {
  height: 100%;
}
.custom-scrollbar::-webkit-scrollbar {
  height: 8px;
  width: 8px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background-color: var(--color-slate-6);
  border-radius: 4px;
}
</style>
