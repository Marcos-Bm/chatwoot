<script setup>
/* eslint-disable */
import PipelineColumn from './PipelineColumn.vue';

const props = defineProps({
  stages: {
    type: Array,
    required: true,
  },
  data: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['card-moved']);

const onCardMoved = (eventData) => {
  emit('card-moved', eventData);
};
</script>

<template>
  <div class="kanban-board flex gap-4 h-full items-start">
    <PipelineColumn
      v-for="stage in stages"
      :key="stage.key"
      :stage="stage"
      :cards="data[stage.key] || []"
      @card-moved="onCardMoved"
    />
  </div>
</template>

<style scoped>
.kanban-board {
  min-height: 100%;
}
</style>
