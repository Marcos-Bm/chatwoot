<script setup>
/* eslint-disable */
import draggable from 'vuedraggable';
import LeadCard from './LeadCard.vue';

const props = defineProps({
  stage: {
    type: Object,
    required: true,
  },
  cards: {
    type: Array,
    required: true,
  },
});

const emit = defineEmits(['card-moved']);

const onDragChange = (event) => {
  if (event.added) {
    emit('card-moved', {
      card: event.added.element,
      newStage: props.stage.key,
      oldStage: event.added.element.current_stage
    });
  }
};

const getGhostClass = () => {
  return 'ghost-card';
};
</script>

<template>
  <div class="pipeline-column bg-n-surface-1 border border-n-weak rounded-md flex flex-col w-[320px] flex-shrink-0 max-h-full">
    <div class="column-header p-3 border-b border-n-weak bg-n-surface-2 rounded-t-md flex justify-between items-center">
      <h3 class="font-medium text-n-slate-12">{{ stage.label }}</h3>
      <span class="badge bg-n-slate-3 text-n-slate-11 px-2 py-0.5 rounded-full text-xs">
        {{ cards.length }}
      </span>
    </div>
    
    <div class="column-body flex-1 overflow-y-auto p-2">
      <draggable
        :list="cards"
        item-key="id"
        group="pipeline"
        @change="onDragChange"
        :ghost-class="getGhostClass()"
        class="min-h-[200px] h-full space-y-2"
        :animation="200"
      >
        <template #item="{ element }">
          <LeadCard :card="element" />
        </template>
      </draggable>
    </div>
  </div>
</template>

<style scoped>
.pipeline-column {
  /* Hide scrollbar for cleaner look */
  scrollbar-width: none;
}
.pipeline-column::-webkit-scrollbar {
  display: none;
}

.ghost-card {
  opacity: 0.5;
  background: var(--color-background-muted);
  border: 2px dashed var(--color-border-strong);
}
</style>
