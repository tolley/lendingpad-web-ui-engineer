import Vue from 'vue';
import Router from 'vue-router';
import LoanTable from '@/components/LoanTable';

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/',
      name: 'LoanTable',
      component: LoanTable,
    },
  ],
});
