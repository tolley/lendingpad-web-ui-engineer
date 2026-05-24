<template>
  <div class="user-table-container">
    <div id="user-table-filters">
      <button id="user-filter-button" @click="applyFilter">
        <i class="filter bi bi-funnel-fill"></i>
      </button>
      <div class="search-wrapper">
        <i class="bi bi-search search-icon"></i>
        <input type="text" placeholder="Search" v-model="searchQuery" />
      </div>
      <button class="add_new_user">
        + Add User
      </button>
    </div>
    <table class="user-table">
      <thead>
        <tr>
          <th>
            <input type="checkbox" />
          </th>
          <th @click="sort('id')" class="sortable">
            Id <span class="sort-icon">{{ sortIcon('id') }}</span>
          </th>
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
        <tr v-for="(user) in paginatedUsers" :key="user.id">
          <td>
            <input type="checkbox" />
          </td>
          <td>
            <b>{{ user.id }}</b>
          </td>
          <td>
            <button>
              <i class="bi bi-pencil-fill"></i>
            </button>
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
                @click.stop="toggleMenu(user.id)"
              ></i>
              <div
                v-if="openMenuIndex === user.id"
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

    <div class="pagination">
      <div class="pagination-info">
        {{ rangeStart }}–{{ rangeEnd }} of {{ sortedUsers.length }} users
      </div>
      <div class="pagination-size">
        <label>Rows per page:
          <select v-model="pageSize" @change="currentPage = 1">
            <option :value="5">5</option>
            <option :value="10">10</option>
            <option :value="15">15</option>
            <option :value="20">20</option>
            <option :value="30">30</option>
            <option :value="420">40</option>
            <option :value="50">50</option>
          </select>
        </label>
      </div>
      <div class="pagination-controls">
        <button class="page-btn" :disabled="currentPage === 1" @click="currentPage--">‹</button>
        <span>{{ currentPage + '/' + totalPages }}</span>
        <button class="page-btn" :disabled="currentPage === totalPages" @click="currentPage++">›</button>
      </div>
    </div>
  </div>
</template>

<script>
import 'bootstrap-icons/font/bootstrap-icons.css';
import { users } from '../data/users.js';

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
      currentPage: 1,
      pageSize: 10,
      searchQuery: '',
      activeSearch: '',
      users,
    };
  },

  computed: {
    filteredUsers() {
      const q = this.activeSearch.trim().toLowerCase();
      if (!q) return this.users;
      return this.users.filter(u => u.name.toLowerCase().includes(q));
    },
    sortedUsers() {
      if( ! this.sortKey )
        return this.filteredUsers;

      // Need to sort the Id's by their numeric value
      if( this.sortKey == 'id' ) {
        return [...this.filteredUsers].sort((a, b) => {
          const valA = parseInt(a[this.sortKey]);
          const valB = parseInt(b[this.sortKey]);
          if (valA < valB) return -1 * this.sortDir;
          if (valA > valB) return 1 * this.sortDir;
          return 0;
        });
      } else {
        return [...this.filteredUsers].sort((a, b) => {
          const valA = String(a[this.sortKey]).toLowerCase();
          const valB = String(b[this.sortKey]).toLowerCase();
          if (valA < valB) return -1 * this.sortDir;
          if (valA > valB) return 1 * this.sortDir;
          return 0;
        });
      }
    },
    totalPages() {
      return Math.ceil(this.sortedUsers.length / this.pageSize);
    },
    rangeStart() {
      return (this.currentPage - 1) * this.pageSize + 1;
    },
    rangeEnd() {
      return Math.min(this.currentPage * this.pageSize, this.sortedUsers.length);
    },
    paginatedUsers() {
      return this.sortedUsers.slice(this.rangeStart - 1, this.rangeEnd);
    },
    visiblePages() {
      const pages = [];
      const total = this.totalPages;
      const cur = this.currentPage;
      if (total <= 7) {
        for (let i = 1; i <= total; i++) pages.push(i);
      } else {
        pages.push(1);
        if (cur > 3) pages.push('…');
        for (let i = Math.max(2, cur - 1); i <= Math.min(total - 1, cur + 1); i++) pages.push(i);
        if (cur < total - 2) pages.push('…');
        pages.push(total);
      }
      return pages;
    },
  },
  methods: {
    applyFilter() {
      this.activeSearch = this.searchQuery;
      this.currentPage = 1;
    },
    sort(key) {
      if (this.sortKey === key) {
        this.sortDir *= -1;
      } else {
        this.sortKey = key;
        this.sortDir = 1;
      }
      this.currentPage = 1;
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
  background-color: #708aa7;
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
  padding: 6px 10px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: capitalize;

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

.search-wrapper {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 8px;
  color: #888;
  pointer-events: none;
  font-size: 0.9rem;
}

.search-wrapper input {
  padding-left: 28px;
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

div#user-table-filters {
  text-align: left;

  button.add_new_user {
    float: right;
    background-color: #00F;
    padding: 5px;
    border-radius: 5px;
    color: #fff;
  }
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
  font-size: 0.88rem;
  color: #555;
  flex-wrap: wrap;
  gap: 8px;
}

.pagination-controls {
  display: flex;
  gap: 4px;
}

.page-btn {
  min-width: 32px;
  height: 32px;
  padding: 0 8px;
  border: 1px solid #dde2e8;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.88rem;
  color: #34495e;
  transition: background 0.15s, color 0.15s;

  &:hover:not(:disabled):not(.ellipsis) {
    background: #f0f4ff;
    border-color: #00F;
    color: #00F;
  }

  &.active {
    background: #00F;
    color: #fff;
    border-color: #00F;
    font-weight: 600;
  }

  &:disabled {
    opacity: 0.4;
    cursor: default;
  }

  &.ellipsis {
    border: none;
    background: none;
    cursor: default;
  }
}

.pagination-size label {
  display: flex;
  align-items: center;
  gap: 6px;

  select {
    border: 1px solid #dde2e8;
    border-radius: 6px;
    padding: 4px 6px;
    font-size: 0.88rem;
    cursor: pointer;
  }
}

</style>
