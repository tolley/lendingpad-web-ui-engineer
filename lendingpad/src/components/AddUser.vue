<template>
  <div v-if="show" class="modal-overlay" @click.self="$emit('close')" role="dialog" aria-modal="true" aria-labelledby="add-user-dialog-title">
    <div class="modal">
      <div class="modal-header">
        <h2 id="add-user-dialog-title">Add New User</h2>
        <button class="modal-close" @click="$emit('close')" aria-label="Close"><i class="bi bi-x-lg" aria-hidden="true"></i></button>
      </div>
      <form class="modal-form" @submit.prevent="handleSubmit">
        <div class="form-row">
          <label>Name
            <input v-model="form.name" type="text" required aria-required="true" placeholder="Full name" />
          </label>
          <label>Phone
            <input v-model="form.phone" type="tel" placeholder="10-digit phone" />
          </label>
        </div>
        <div class="form-full">
          <label>Description
            <input v-model="form.description" type="text" placeholder="Loan type or description" />
          </label>
        </div>
        <div class="form-row">
          <label>Status
            <select v-model="form.status" required aria-required="true">
              <option value="open">Open</option>
              <option value="pending">Pending</option>
              <option value="due">Due</option>
              <option value="inactive">Inactive</option>
            </select>
          </label>
          <label>Rate (%)
            <input v-model.number="form.rate" type="number" step="0.01" min="0" placeholder="0.00" />
          </label>
        </div>
        <div class="form-row">
          <label>Balance
            <input v-model.number="form.balance" type="number" step="0.01" placeholder="0.00" />
          </label>
          <label>Deposit
            <input v-model.number="form.deposit" type="number" step="0.01" min="0" placeholder="0.00" />
          </label>
        </div>
        <div class="modal-actions">
          <button type="button" class="btn-cancel" @click="$emit('close')">Cancel</button>
          <button type="submit" class="btn-submit">Add User</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AddUser',
  props: {
    show: { type: Boolean, required: true },
  },
  emits: ['close', 'submit'],
  data() {
    return {
      form: { name: '', phone: '', description: '', status: 'open', rate: 0, balance: 0, deposit: 0 },
    };
  },
  watch: {
    show(val) {
      if (val) this.form = { name: '', phone: '', description: '', status: 'open', rate: 0, balance: 0, deposit: 0 };
    },
  },
  methods: {
    handleSubmit() {
      this.$emit('submit', { ...this.form });
    },
  },
};
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;

  .modal {
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
    width: 520px;
    max-width: 95vw;
    padding: 28px 32px 24px;

    .modal-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;

      h2 {
        font-size: 1.2rem;
        font-weight: 700;
        color: #2c3e50;
        margin: 0;
      }

      .modal-close {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 1rem;
        color: #888;
        flex-shrink: 0;

        &:hover {
          color: #333;
        }
      }
    }

    .modal-form {
      display: flex;
      flex-direction: column;
      gap: 14px;

      label {
        display: flex;
        flex-direction: column;
        gap: 4px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #555;

        input, select {
          padding: 8px 10px;
          border: 1px solid #dde2e8;
          border-radius: 6px;
          font-size: 0.95rem;
          color: #34495e;
          outline: none;

          &:focus {
            border-color: #00F;
            box-shadow: 0 0 0 2px rgba(0, 0, 255, 0.1);
          }
        }
      }

      .form-row {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        align-items: flex-start;

        label {
          flex: 1 1 180px;
        }
      }

      .form-full {
        display: flex;
        flex-direction: column;

        label {
          flex: 1 1 100%;
        }
      }

      .modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 6px;

        .btn-cancel {
          padding: 8px 18px;
          border: 1px solid #dde2e8;
          background: #fff;
          border-radius: 6px;
          cursor: pointer;
          font-size: 0.9rem;
          color: #555;

          &:hover {
            background: #f5f7fa;
          }
        }

        .btn-submit {
          padding: 8px 18px;
          background: #3d70d2;
          color: #fff;
          border: none;
          border-radius: 6px;
          cursor: pointer;
          font-size: 0.9rem;
          font-weight: 600;

          &:hover {
            background: #0000cc;
          }
        }
      }
    }
  }
}
</style>
