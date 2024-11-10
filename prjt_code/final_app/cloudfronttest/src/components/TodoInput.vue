<template>
  <div class="inputBox shadow">
    <input type="text" v-model="newTodoItem" v-on:keyup.enter="addTodo()">
    <button class="addButton" @click="addTodo()">
      <i class="bi bi-file-plus"></i>
      <svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" fill="currentColor" class="bi bi-file-plus" viewBox="0 0 13 16">
        <path d="M8.5 6a.5.5 0 0 0-1 0v1.5H6a.5.5 0 0 0 0 1h1.5V10a.5.5 0 0 0 1 0V8.5H10a.5.5 0 0 0 0-1H8.5z"/>
        <path d="M2 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2zm10-1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1"/>
      </svg>
    </button>
  </div>
</template>

<script>
import { createApp } from 'vue';

// import { contains } from 'bootstrap-vue-3/dist/utils';

export default ({
  data() {
    return {
      newTodoItem: ''
    };
  },
  methods: {
    addTodo() {
      if (this.newTodoItem.trim() !== '') {

        const cookies = this.$cookies.get('cookies'); 
        const memberId = cookies.split('_')[1]; // VueCookies를 사용하여 쿠키를 가져옵니다.
        const nickname = cookies.split('_')[0];
        console.log(this.$cookies.get('memberId'))

        console.log(this.newTodoItem);


        this.axios.post(`/api/todos`, {
          memberId: memberId,
          content: this.newTodoItem
        })
        .then((res) => {
          console.log(res.status);
          console.log(res.data);
          this.clearInputbox();
        })
        .catch((error) => {
          console.log(error);
        })
        .finally(() => {
          console.log("항상 마지막에 실행");
        });
      }
    },
    clearInputbox() {
      this.newTodoItem = '';
    }
  }
});
</script>

<style scoped>
.inputBox {
  background: white;
  padding: 20 10px;
  height: 50px;
  line-height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
}

.inputBox input {
  border-style: none;
  font-size: 1rem;
  flex: 1;
  padding: 0 10px;
}

.addButton {
  background: lightgray;
  color: white;
  border: none;
  border-radius: 5px;
  padding: 3px 10px;
  cursor: pointer;
  align-items: center;
  transition: background-color 0.3s ease;
}

.addButton:hover {
  background-color: gray;
}

.addButton svg {
  margin-right: 5px;
}


</style>