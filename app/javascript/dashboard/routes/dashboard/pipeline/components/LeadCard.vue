/* eslint-disable */
<script setup>
import { computed } from 'vue';

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
});

const initials = computed(() => {
  const name = props.card.contact_name || 'Desconhecido';
  const parts = name.split(' ');
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name.substring(0, 2).toUpperCase();
});

const timeAgo = computed(() => {
  if (!props.card.last_activity_at) return '';
  const date = new Date(props.card.last_activity_at);
  const now = new Date();
  const diffInMinutes = Math.floor((now - date) / 60000);
  
  if (diffInMinutes < 60) return `${diffInMinutes}m atrás`;
  const diffInHours = Math.floor(diffInMinutes / 60);
  if (diffInHours < 24) return `${diffInHours}h atrás`;
  const diffInDays = Math.floor(diffInHours / 24);
  return `${diffInDays}d atrás`;
});

const displayLabels = computed(() => {
  // Filtra as labels de pipeline para não poluir visualmente, exibe apenas as outras tags
  return (props.card.labels || []).filter(l => !l.startsWith('pipeline:'));
});

// A cor da borda pode indicar se está "quente" (atualizado recentemente)
const cardPriorityClass = computed(() => {
  if (!props.card.last_activity_at) return 'border-n-weak border-l-4 border-l-n-weak';
  
  const date = new Date(props.card.last_activity_at);
  const diffInHours = (new Date() - date) / 3600000;
  
  if (diffInHours < 2) return 'border-n-weak border-l-4 border-l-green-500'; // Hot
  if (diffInHours < 24) return 'border-n-weak border-l-4 border-l-blue-400'; // Warm
  return 'border-n-weak border-l-4 border-l-gray-400'; // Cold
});

</script>

<template>
  <div 
    class="bg-white dark:bg-n-solid-2 rounded-md shadow-sm border p-3 cursor-grab hover:shadow-md transition-shadow"
    :class="cardPriorityClass"
  >
    <!-- Header: Avatar + Nome + Origem -->
    <div class="flex items-center gap-3 mb-2">
      <div class="flex-shrink-0">
        <img 
          v-if="card.contact_avatar" 
          :src="card.contact_avatar" 
          class="w-8 h-8 rounded-full object-cover"
        />
        <div v-else class="w-8 h-8 rounded-full bg-n-brand text-white flex items-center justify-center text-xs font-medium">
          {{ initials }}
        </div>
      </div>
      <div class="flex-1 min-w-0">
        <h4 class="text-sm font-semibold text-n-slate-12 truncate">{{ card.contact_name || 'Desconhecido' }}</h4>
        <div class="flex items-center text-xs text-n-slate-11 gap-1">
          <span class="i-lucide-smartphone w-3 h-3"></span>
          <span class="truncate">{{ card.contact_phone_number || 'Sem telefone' }}</span>
        </div>
      </div>
    </div>

    <!-- Message Preview -->
    <div class="mb-2 bg-n-alpha-1 p-2 rounded text-xs text-n-slate-12 line-clamp-2">
      {{ card.messages_preview || 'Nenhuma mensagem recente' }}
    </div>

    <!-- Metadata: Assignee & Time -->
    <div class="flex items-center justify-between text-xs text-n-slate-11 mb-2">
      <div class="flex items-center gap-1">
        <span class="i-lucide-user w-3 h-3"></span>
        <span class="truncate max-w-[80px]">{{ card.assignee_name || 'Não atribuído' }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span class="i-lucide-clock w-3 h-3"></span>
        <span>{{ timeAgo }}</span>
      </div>
    </div>

    <!-- Footer: Labels e Inbox -->
    <div class="flex flex-wrap items-center gap-1 mt-2 pt-2 border-t border-n-weak">
      <span class="text-[10px] bg-n-alpha-2 text-n-slate-11 px-1.5 py-0.5 rounded flex items-center gap-1">
        <span class="i-lucide-inbox w-3 h-3"></span>
        {{ card.inbox_name || 'Indefinido' }}
      </span>
      
      <span 
        v-for="label in displayLabels" 
        :key="label"
        class="text-[10px] bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-200 px-1.5 py-0.5 rounded truncate max-w-[60px]"
      >
        {{ label }}
      </span>
    </div>
  </div>
</template>
