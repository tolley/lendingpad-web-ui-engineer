<template>
  <div class="user-table-container">
    <h1>User</h1>
    <table class="user-table">
      <thead>
        <tr>
          <th @click="sort('name')" class="sortable">
            Name <span class="sort-icon">{{ sortIcon('name') }}</span>
          </th>
          <th>Description</th>
          <th @click="sort('status')" class="sortable">
            Status <span class="sort-icon">{{ sortIcon('status') }}</span>
          </th>
          <th>Rate</th>
          <th>Balance</th>
          <th>Deposit</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(user, index) in sortedUsers" :key="index">
          <td>{{ user.name }}</td>
          <td>{{ user.description }}</td>
          <td>
            <span :class="['status-badge', user.status.toLowerCase()]">
              {{ user.status }}
            </span>
          </td>
          <td class="currency_type">
            <div>
              {{ formatCurrency(user.rate) }}
            </div>
            <sub>CAD</sub>
          </td>
          <td class="currency_type">
              <div>
                {{ formatCurrency(user.balance) }}
              </div>
              <sub>CAD</sub>
          </td>
          <td class="currency_type">
              <div>{{ formatCurrency(user.deposit) }}</div>
              <sub>CAD</sub>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'UserTable',
  data() {
    return {
      sortKey: null,
      sortDir: 1,
      users: [
        { name: 'Alice Johnson', description: '30-Year Fixed Mortgage', status: 'Active', rate: 6.75, balance: 284500, deposit: 15000 },
        { name: 'Bob Martinez', description: 'Home Equity Line of Credit', status: 'Pending', rate: 8.25, balance: 52000, deposit: 5000 },
        { name: 'Carol Smith', description: '15-Year Fixed Mortgage', status: 'Active', rate: 6.10, balance: 198750, deposit: 22000 },
        { name: 'David Lee', description: 'FHA Purchase Loan', status: 'Closed', rate: 7.00, balance: 0, deposit: 8500 },
        { name: 'Eva Chen', description: 'VA Home Loan', status: 'Active', rate: 5.90, balance: 312000, deposit: 0 },
        { name: 'Frank Nguyen', description: 'Jumbo Loan', status: 'Pending', rate: 7.50, balance: 875000, deposit: 50000 },
        { name: 'Alice Johnson', description: '30-Year Fixed Mortgage', status: 'Active', rate: 6.75, balance: 284500, deposit: 15000 },
        { name: 'Bob Martinez', description: 'Home Equity Line of Credit', status: 'Pending', rate: 8.25, balance: 52000, deposit: 5000 },
        { name: 'Carol Smith', description: '15-Year Fixed Mortgage', status: 'Active', rate: 6.10, balance: 198750, deposit: 22000 },
      ],
    };
  },
  computed: {
    sortedUsers() {
      if (!this.sortKey) return this.users;
      return [...this.users].sort((a, b) => {
        const valA = a[this.sortKey].toLowerCase();
        const valB = b[this.sortKey].toLowerCase();
        if (valA < valB) return -1 * this.sortDir;
        if (valA > valB) return 1 * this.sortDir;
        return 0;
      });
    },
  },
  methods: {
    sort(key) {
      if (this.sortKey === key) {
        this.sortDir *= -1;
      } else {
        this.sortKey = key;
        this.sortDir = 1;
      }
    },
    sortIcon(key) {
      if (this.sortKey !== key) return '⇅';
      return this.sortDir === 1 ? '↑' : '↓';
    },
    formatCurrency(value) {
      return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
    },
  },
};
</script>

<style scoped>
.user-table-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  margin-bottom: 20px;
  font-size: 1.6rem;
  color: #2c3e50;
}

.user-table {
  width: 100%;
  border-collapse: collapse;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  overflow: hidden;

  thead {
    background-color: #2c3e50;
    color: #fff;
  }

  th {
    padding: 14px 16px;
    text-align: left;
    font-weight: 600;
    font-size: 0.85rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;

    &.sortable {
      cursor: pointer;
      user-select: none;

      &:hover {
        background-color: #3d5166;
      }
    }
  }

  td.currency_type {
    text-align: right;
  }

}

.loan-table th.sortable:hover {
  background-color: #3d5166;
}

.sort-icon {
  margin-left: 4px;
  font-style: normal;
  opacity: 0.75;
}

.loan-table tbody tr {
  border-bottom: 1px solid #e8ecef;
  transition: background-color 0.15s;
}

.loan-table tbody tr:last-child {
  border-bottom: none;
}

.loan-table tbody tr:hover {
  background-color: #f5f7fa;
}

.loan-table td {
  padding: 14px 16px;
  font-size: 0.95rem;
  color: #34495e;
}

.status-badge {
  display: inline-block;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;

  &.active {
    background-color: #d4edda;
    color: #155724;
  }

  &.pending {
    background-color: #fff3cd;
    color: #856404;
  }

  &.closed {
    background-color: #f8d7da;
    color: #721c24;
  }
}

</style>
