import { frontendURL } from '../../../helper/URLHelper';
import Index from './Index.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/pipeline'),
      name: 'pipeline_index',
      component: Index,
      meta: {
        permissions: ['administrator', 'agent'],
      },
    },
  ],
};
