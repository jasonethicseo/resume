<template>
  <div class="home">
    <h2 class="name">TODO LIST</h2>
    <img alt="Vue logo" src="../assets/Todolist_MainImage.png">
    <TodoList msg="Welcome to Your Vue.js App"/>
  </div>
</template>

<script>
// @ is an alias to /src
import TodoList from '@/components/TodoMain.vue'

export default {
  name: 'HomeView',
  components: {
    TodoList
  }
}
</script>
<style scoped>
.name{
  margin-top: 10%;
  margin-bottom: 0%;
  font-size: 400%;
}
</style>
