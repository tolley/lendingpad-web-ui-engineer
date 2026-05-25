<template>
  <div class="user-table-container">
    <div id="user-table-filters">
      <button id="user-filter-button" @click="applyFilter" aria-label="Apply filter">
        <i class="filter bi bi-funnel-fill" aria-hidden="true"></i>
      </button>
      <div class="search-wrapper">
        <i class="bi bi-search search-icon" aria-hidden="true"></i>
        <input type="text" placeholder="Search" v-model="searchQuery" aria-label="Search users" />
      </div>
      <button class="add_new_user" @click="openAddUserModal">
        <i class="filter bi bi-plus-lg" aria-hidden="true"></i>
        Add User
      </button>
    </div>

    <table class="user-table">
      <thead>
        <tr>
          <th>
            <input type="checkbox" aria-label="Select all users" />
          </th>
          <th @click="sort('id')" class="sortable" :aria-sort="sortKey === 'id' ? (sortDir === 1 ? 'ascending' : 'descending') : 'none'">
            Id <span class="sort-icon" aria-hidden="true">{{ sortIcon('id') }}
            </span>
          </th>
          <th></th>
          <th @click="sort('name')" class="sortable" :aria-sort="sortKey === 'name' ? (sortDir === 1 ? 'ascending' : 'descending') : 'none'">
            Name <span class="sort-icon" aria-hidden="true">{{ sortIcon('name') }}</span>
          </th>
          <th>Description</th>
          <th @click="sort('status')" class="sortable status" :aria-sort="sortKey === 'status' ? (sortDir === 1 ? 'ascending' : 'descending') : 'none'">
            Status <span class="sort-icon" aria-hidden="true">{{ sortIcon('status') }}</span>
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
            <input type="checkbox" :aria-label="`Select ${user.name}`" />
          </td>
          <td>
            <b>{{ user.id }}</b>
          </td>
          <td>
            <button class="edit_user" @click="openEditUserModal(user)" 
                    :aria-label="`Edit ${user.name}`">
              <i class="bi bi-pencil-fill" aria-hidden="true"></i>
            </button>
          </td>
          <td>
            <span class="spn_name">{{ user.name }}</span>
            <span class="spn_phone">{{ formatPhone(user.phone) }}</span>
          </td>
          <td :title="user.description" :aria-label="user.description">{{ user.description.slice(0, 50) }}{{ user.description.length > 50 ? '…' : '' }}</td>
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
                role="button"
                tabindex="0"
                :aria-label="`Actions for ${user.name}`"
                :aria-expanded="openMenuIndex === user.id"
                aria-haspopup="true"
              ></i>
              <div
                v-if="openMenuIndex === user.id"
                class="action-dropdown"
                role="menu"
              >
                <button @click.stop="handleAction('view', user)" role="menuitem" :aria-label="`Invite ${user.name} as customer`">
                  <span>Invite Customer</span>
                  <i class="bi bi-person-plus" aria-hidden="true"></i>
                </button>
                <button @click.stop="handleAction('edit', user)" role="menuitem" :aria-label="`Send email to ${user.name}`">
                  <span>Send Email</span>
                  <i class="bi bi-envelope-plus" aria-hidden="true"></i>
                </button>
                <button class="cost_details_button" @click.stop="handleAction('archive', user)" role="menuitem" :aria-label="`Manage cost details for ${user.name}`">
                  <span>Manage Cost Details</span>
                  <i class="bi bi-currency-dollar" aria-hidden="true"></i>
                </button>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>

    <AddUser :show="showAddUserModal" @close="closeAddUserModal" @submit="submitNewUser" />
    <EditUser :show="showEditUserModal" :user="editUser" @close="closeEditUserModal" @submit="submitEditUser" />

    <nav class="pagination" aria-label="Table pagination">
      <div class="pagination-info" aria-live="polite" aria-atomic="true">
        {{ rangeStart }}–{{ rangeEnd }} of {{ sortedUsers.length }} users
      </div>
      <div class="pagination-size">
        <label>Rows per page:
          <select v-model="pageSize" @change="currentPage = 1" aria-label="Rows per page">
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
        <button class="page-btn" :disabled="currentPage === 1" @click="currentPage--" aria-label="Previous page">‹</button>
        <span aria-live="polite">{{ currentPage + '/' + totalPages }}</span>
        <button class="page-btn" :disabled="currentPage === totalPages" @click="currentPage++" aria-label="Next page">›</button>
      </div>
    </nav>
  </div>
</template>

<script>
import 'bootstrap-icons/font/bootstrap-icons.css';
import { users } from '../data/users.js';
import AddUser from './AddUser.vue';
import EditUser from './EditUser.vue';

export default {
  name: 'UserTable',
  components: { AddUser, EditUser },
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
      showAddUserModal: false,
      showEditUserModal: false,
      editUser: null,
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
    openAddUserModal() {
      this.showAddUserModal = true;
    },
    closeAddUserModal() {
      this.showAddUserModal = false;
    },
    submitNewUser(userData) {
      const nextId = this.users.length > 0 ? Math.max(...this.users.map(u => parseInt(u.id))) + 1 : 1;
      this.users.push({ ...userData, id: nextId });
      this.closeAddUserModal();
    },
    openEditUserModal(user) {
      this.editUser = { ...user };
      this.showEditUserModal = true;
    },
    closeEditUserModal() {
      this.showEditUserModal = false;
    },
    submitEditUser(userData) {
      const idx = this.users.findIndex(u => u.id === userData.id);
      if (idx !== -1) this.users.splice(idx, 1, { ...userData });
      this.closeEditUserModal();
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
  overflow: scroll;

  th {
    padding: 14px 16px;
    text-align: left;
    font-weight: 600;
    font-size: 0.85rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    min-width: 40px;

    &.status {
      min-width: 90px;
    }

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
      color: rgb( 2, 153, 2;)
    }

    div.negative {
      color: rgb(153, 2, 2);
    }
  }

  td {
    span.spn_phone {
      color: #999;
    }

    span.spn_name {
      color: #000;
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
  outline: 2px solid #3d70d2;
  outline-offset: -2px;
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
    background-color: #3d70d2;
    padding: 5px;
    border-radius: 10px;
    color: #fff;
    cursor: pointer;
  }

  button#user-filter-button {
    cursor: pointer;
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

  span {
    margin-top: 10px;
  }
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
