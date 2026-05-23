<template>
  <div class="user-table-container">
    <div>
      <button>C</button>
      <input type="text" value="" />
      <button>D</button>
    </div>
    <table class="user-table">
      <thead>
        <tr>
          <th>
            <input type="checkbox" />
          </th>
          <th>IDs</th>
          <th>edit</th>
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
          <th>&nbsp;</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(user, index) in sortedUsers" :key="index">
          <td>
            <input type="checkbox" />
          </td>
          <td>
            <b>{{  user.id }}</b>
          </td>
          <td>
            <button>E</button>
          </td>
          <td>
            <span class="name">{{ user.name }}</span>
            <span class="phone">{{ formatPhone(user.phone) }}</span>
          </td>
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
            <div :class="user.balance < 0? 'negative': 'positive'">
              {{ formatCurrency(user.balance) }}
            </div>
            <sub>CAD</sub>
          </td>

          <td class="currency_type">
              <div>{{ formatCurrency(user.deposit) }}</div>
              <sub>CAD</sub>
          </td>
          <td class="actions-cell">
            <div class="action-menu-wrapper">
              <i
                class="bi bi-three-dots-vertical action-dots"
                @click.stop="toggleMenu(index)"
              ></i>
              <div
                v-if="openMenuIndex === index"
                class="action-dropdown"
              >
                <button @click.stop="handleAction('view', user)">
                  <span>Invite Customer</span>
                  <i class="bi bi-person-plus"></i>
                </button>
                <button @click.stop="handleAction('edit', user)">
                  <span>Send Email</span>
                  <i class="bi bi-envelope-plus"></i>
                </button>
                <button class="cost_details_button" @click.stop="handleAction('archive', user)">
                  <span>Manage Cost Details</span>
                  <i class="bi bi-currency-dollar"></i>
                </button>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import 'bootstrap-icons/font/bootstrap-icons.css';

export default {
  name: 'UserTable',
  mounted() {
    document.addEventListener('click', this.closeMenu);
  },
  beforeUnmount() {
    document.removeEventListener('click', this.closeMenu);
  },
  data() {
    return {
      sortKey: null,
      sortDir: 1,
      openMenuIndex: null,
      users: [
        { id: 1, name: 'Alice Johnson', description: '30-Year Fixed Mortgage', status: 'open', rate: 6.75, balance: 284500, deposit: 15000, phone: '5711231234' },
        { id: 2, name: 'Bob Martinez', description: 'Home Equity Line of Credit', status: 'pending', rate: 8.25, balance: 52000, deposit: 5000, phone: '8047829834' },
        { id: 3, name: 'Carol Smith', description: '15-Year Fixed Mortgage', status: 'due', rate: 6.10, balance: -198750, deposit: 22000, phone: '7032781199' },
        { id: 4, name: 'David Lee', description: 'FHA Purchase Loan', status: 'inactive', rate: 7.00, balance: 0, deposit: 8500, phone: '2040122200' },
        { id: 5, name: 'Eva Chen', description: 'VA Home Loan', status: 'open', rate: 5.90, balance: 312000, deposit: 0, phone: '7031231234' },
        { id: 6, name: 'Frank Nguyen', description: 'Jumbo Loan', status: 'pending', rate: 7.50, balance: 875000, deposit: 50000, phone: '4349629988' },
        { id: 7, name: 'Alice Johnson', description: '30-Year Fixed Mortgage', status: 'open', rate: 6.75, balance: -284500, deposit: 15000, phone: '5712007722' },
        { id: 8, name: 'Bob Martinez', description: 'Home Equity Line of Credit', status: 'pending', rate: 8.25, balance: 52000, deposit: 5000, phone: '8881231234' },
        { id: 9, name: 'Carol Smith', description: '15-Year Fixed Mortgage', status: 'open', rate: 6.10, balance: 198750, deposit: 22000, phone: '5716980022' },
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
      // Remove the currency symbol
      const currencyParts = Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).formatToParts(value);

      const formattedCurrency = currencyParts
        .map(part => part.value)
        .join('')
        .trim();

      return formattedCurrency;
    },
    formatPhone(phoneNum) {
      return phoneNum;
    },
    toggleMenu(index) {
      this.openMenuIndex = this.openMenuIndex === index ? null : index;
    },
    closeMenu() {
      this.openMenuIndex = null;
    },
    handleAction(action, user) {
      this.closeMenu();
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

    div.positive {
      color: #0F0;
    }

    div.negative {
      color: #F00;
    }
  }

}

.user-table th.sortable:hover {
  background-color: #3d5166;
}

.sort-icon {
  margin-left: 4px;
  font-style: normal;
  opacity: 0.75;
}

.user-table tbody tr {
  border-bottom: 1px solid #e8ecef;
  transition: background-color 0.15s;
}

.user-table tbody tr:last-child {
  border-bottom: none;
}

.user-table tbody tr:hover {
  background-color: #f5f7fa;
}

.user-table td {
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

  &.open {
    color: rgb(35, 35, 236);
    background-color: rgb(127, 127, 221);
  }

  &.inactive {
    background-color: #EEE;
    color: #222;
  }

  &.pending {
    background-color: #fff3cd;
    color: #856404;
  }

  &.due {
    background-color: #f8d7da;
    color: #be2b3a;
  }
}

.actions-cell {
  position: relative;
  width: 40px;
}

.action-menu-wrapper {
  position: relative;
  display: inline-block;
}

.action-dots {
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 1.1rem;
  color: #666;

  &:hover {
    background-color: #e8ecef;
    color: #333;
  }
}

.action-dropdown {
  position: absolute;
  right: 0;
  top: calc(100% + 4px);
  background: #fff;
  border: 1px solid #dde2e8;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  min-width: 205px;
  z-index: 100;
  padding: 6px 0;

  hr {
    border: none;
    border-top: 1px solid #e8ecef;
    margin: 4px 0;
  }

  button {
    display: inline;
    align-items: center;
    gap: 8px;
    width: 100%;
    padding: 8px 16px;
    background: none;
    border: none;
    text-align: right;
    font-size: 0.9rem;
    color: #00F;
    cursor: pointer;

    span {
      float: left;
    }

    &:hover {
      background-color: #f5f7fa;
    }

    &.danger {
      color: #be2b3a;

      &:hover {
        background-color: #fdf0f1;
      }
    }

    &.cost_details_button {
      color: #0F0;
    }
  }
}

</style>
