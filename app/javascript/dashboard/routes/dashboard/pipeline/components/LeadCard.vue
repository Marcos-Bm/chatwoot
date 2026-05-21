<!-- eslint-disable -->
<script setup>
import { computed } from 'vue';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
});

const formattedLastActivity = computed(() => {
  if (!props.card.last_activity_at) return 'Sem atividade';
  return formatDistanceToNow(new Date(props.card.last_activity_at * 1000), { addSuffix: true, locale: ptBR });
});

const formattedUpdatedAt = computed(() => {
  if (!props.card.updated_at) return '';
  return formatDistanceToNow(new Date(props.card.updated_at), { addSuffix: true, locale: ptBR });
});

const timeInStage = computed(() => {
  if (!props.card.updated_at) return '';
  return formatDistanceToNow(new Date(props.card.updated_at), { locale: ptBR });
});

const priorityColor = computed(() => {
  // Mock logic based on score or tags if available, using a default visual for now
  if (props.card.score > 50) return 'bg-n-red-5 border-n-red-8';
  if (props.card.score > 20) return 'bg-n-yellow-5 border-n-yellow-8';
  return 'bg-n-background border-n-weak';
});
</script>

<template>
  <div 
    class="lead-card p-3 rounded-md shadow-sm border cursor-grab hover:shadow-md transition-shadow relative"
    :class="priorityColor"
  >
    <div class="flex items-start gap-3 mb-2">
      <img 
        v-if="card.contact_avatar" 
        :src="card.contact_avatar" 
        alt="Avatar" 
        class="w-10 h-10 rounded-full object-cover border border-n-weak"
      />
      <div v-else class="w-10 h-10 rounded-full bg-n-brand-6 text-white flex items-center justify-center font-bold text-sm">
        {{ card.contact_name?.charAt(0)?.toUpperCase() || 'U' }}
      </div>
      
      <div class="flex-1 min-w-0">
        <h4 class="font-medium text-sm text-n-slate-12 truncate">{{ card.contact_name || 'Desconhecido' }}</h4>
        <div class="text-xs text-n-slate-10 truncate">{{ card.contact_phone_number || 'Sem telefone' }}</div>
      </div>
    </div>
    
    <div class="text-xs text-n-slate-11 mb-2 bg-n-surface-2 p-2 rounded line-clamp-2 italic">
      "{{ card.messages_preview || 'Sem mensagens' }}"
    </div>
    
    <div class="flex flex-wrap gap-1 mb-2">
      <span 
        v-for="label in card.labels" 
        :key="label" 
        class="text-[10px] px-1.5 py-0.5 rounded-sm bg-n-slate-3 text-n-slate-11"
      >
        {{ label.replace('pipeline:', '') }}
      </span>
    </div>
    
    <div class="flex justify-between items-end mt-3 border-t border-n-weak pt-2">
      <div class="flex flex-col gap-0.5">
        <div class="flex items-center gap-1 text-[10px] text-n-slate-10">
          <span class="i-lucide-clock size-3"></span>
          Últ. Interação: {{ formattedLastActivity }}
        </div>
        <div class="flex items-center gap-1 text-[10px] text-n-slate-10">
          <span class="i-lucide-hourglass size-3"></span>
          No estágio há: {{ timeInStage }}
        </div>
      </div>
      
      <div v-if="card.assignee_name" class="text-[10px] px-1.5 py-0.5 bg-n-brand-3 text-n-brand-11 rounded-sm max-w-[80px] truncate" title="Responsável">
        {{ card.assignee_name }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.lead-card {
  user-select: none;
}
.lead-card:active {
  cursor: grabbing;
}
</style>
