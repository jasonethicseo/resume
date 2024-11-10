<template>
  <div>
    <ul>
      <!-- 역순으로 정렬된 todoItems를 순회 -->
      <li v-for="(item, index) in reversedTodoItems" :key="item.id" :class="{ 'markedForDelete': item.markedForDelete }" @contextmenu.prevent="toggleDeleteStatus(item)">
        <span :class="{ 'deleted': item.markedForDelete }">
          <!--{{ item.content }}-->
          <div v-html="getTodoData(index)"></div>
        </span>
        <button class="removeBtn" @click="removeTodo(item, index)">
          <i class="bi bi-trash3"></i>
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-trash3" viewBox="0 0 16 16">
            <path d="M6.5 1h3a.5.5 0 0 1 .5.5v1H6v-1a.5.5 0 0 1 .5-.5M11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3A1.5 1.5 0 0 0 5 1.5v1H1.5a.5.5 0 0 0 0 1h.538l.853 10.66A2 2 0 0 0 4.885 16h6.23a2 2 0 0 0 1.994-1.84l.853-10.66h.538a.5.5 0 0 0 0-1zm1.958 1-.846 10.58a1 1 0 0 1-.997.92h-6.23a1 1 0 0 1-.997-.92L3.042 3.5zm-7.487 1a.5.5 0 0 1 .528.47l.5 8.5a.5.5 0 0 1-.998.06L5 5.03a.5.5 0 0 1 .47-.53Zm5.058 0a.5.5 0 0 1 .47.53l-.5 8.5a.5.5 0 1 1-.998-.06l.5-8.5a.5.5 0 0 1 .528-.47M8 4.5a.5.5 0 0 1 .5.5v8.5a.5.5 0 0 1-1 0V5a.5.5 0 0 1 .5-.5"/>
          </svg>
        </button>
      </li>
    </ul>
  </div>
</template>

<script>
import axios from 'axios';
import Cookies from 'js-cookie';

export default {
  data() {
    return {
      todoItems: [],
      htmlCode: ""
    };
  },
  computed: {
    // todoItems 배열을 역순으로 정렬한 배열을 반환하는 계산된 속성
    reversedTodoItems() {
      return this.todoItems.slice().reverse();
    }
  },
  methods: {

    getCookie(name) {
      const cookies = Cookies.get('cookies');

      let memberId = '';
      let nickName = '';

      if (cookies != null && cookies != undefined && cookies != '') {
        if (name == 'nickName') {
          nickName = cookies.split('_')[0]
          return nickName;

        } else if (name = 'memberId') {
          memberId = cookies.split('_')[1]
          return memberId;
        }
      } else {
        return;
      }
    },

    isEmpty(value) {
      if (value === '' || value === undefined || value === null) {
        return true;
      } else {
        return false;
      }
    }, 
    
    // 삭제 상태를 토글하는 메서드
    toggleDeleteStatus(item) {
      item.markedForDelete = !item.markedForDelete;
    },

    // 삭제
    removeTodo(todoItem, index) {
      console.log(todoItem.contentId); // 고유 식별자 (예: id)
      axios.delete(`/api/todos/${todoItem.contentId}`)
        .then(response => {
          console.log('Todo deleted:', response.data);
          // 성공적으로 삭제되면 화면에서도 삭제
          this.todoItems.splice(index, 1);
        })
        .catch(error => {
          console.error('Error deleting todo:', error);
        });
    },

    // 조회
    fetchTodoItems() {

      // 쿠키 조회
      const memberId = this.getCookie('memberId');
      if (this.isEmpty(memberId)) {
        return;
      }

      axios.get(`/api/todos/${memberId}`)
        .then(response => {
          console.log(response.data)
          this.todoItems = response.data; // 서버에서 받아온 데이터를 todoItems에 저장
        })
        .catch(error => {
          console.error('Error fetching todo items:', error);
        });
    },

    //xss
    getTodoData(index) {
      // <img src=x onerror=alert('Cross Site Scripting') width='0' height='0'>
      // <img src=x onerror=alert('당신의_쿠키_정보를_빼돌렸습니다.') width='0' height='0'>
      //if (this.reversedTodoItems[index].content != '')
      return `${this.reversedTodoItems[index].content}`;
      //return '';
    }
  },

  mounted() {
    // 리스트 페이지가 마운트되면 데이터를 가져오기
    this.fetchTodoItems();
  }
};
</script>

<style scoped>
ul {
  list-style-type: none;
  padding-left: 10px;
  padding-right: 10px;
  margin-top: 0;
  text-align: left;
}
li {
  display: flex;
  min-height: 50px;
  height: 50px;
  line-height: 50px;
  margin: 0.5rem 0;
  padding: 0 0.9rem;
  background: white;
  border-radius: 5px;
}

.markedForDelete {
  text-decoration: line-through;
  opacity: 0.6; /* 선택 사항: 삭제된 항목의 투명도 조정 */
}

.deleted {
  color: #dc3545; /* 선택 사항: 삭제된 항목의 텍스트 색상 변경 */
}

.removeBtn {
  margin-left: auto;
  color: black;
  background: none;
  border: none;
  cursor: pointer;
}

.removeBtn:hover {
  color: white;
}
</style>
