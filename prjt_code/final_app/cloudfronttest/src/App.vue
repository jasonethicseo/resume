<template>
    <nav>
      <router-link to="/">Main</router-link> 
    </nav>
    <nav class="navbar navbar-light bg-light" v-if="!showSignup">
    <form class="container-fluid justify-content-start">
      <router-link v-if="!isLoggedIn" class="btn btn-outline-primary mx-2" to="about">로그인</router-link>
      <button v-if="isLoggedIn" class="btn btn-outline-danger mx-2" @click="logout">로그아웃</button>
      <router-link class="btn btn-outline-success mx-2" to="list">list</router-link>
      <div class="navbar-text ml-auto">
        {{ greetingMessage }}
      </div>
    </form>
  </nav>
    <div id="app">
    <!-- 메인 화면에서는 TodoSignup를 렌더링하지 않음 -->
    <router-view v-if="!showSignup" />
    <!-- TodoSignup 컴포넌트는 회원가입 페이지에서만 렌더링 -->
    <TodoSignup v-if="showSignup" @user-signed-up="updateUserNickname" />
    <nav v-if="!showSignup"></nav>
  </div>
</template>

<script>
import TodoSignup from './components/TodoSignup.vue';
import Cookies from 'js-cookie';

export default {
  components: {
    TodoSignup,
  },
  data() {
    return {
      // 사용자의 닉네임을 데이터로 정의합니다.
      userNickname: '',
      // 회원가입 페이지를 보여줄지 여부를 결정하는 데이터
      showSignup: false,
      // 로그인 상태를 관리하는 데이터
      isLoggedIn: false,

    };
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

    updateUserNickname(nickname) {
      if (nickname && nickname.trim() !== '') {
        this.userNickname = nickname; // TodoSignup.vue로부터 받은 닉네임을 업데이트
        // 회원가입 후 메인 화면으로 돌아갑니다.
        this.showSignup = false;
        this.isLoggedIn = true;
        Cookies.set('nickname', nickname); // 쿠키에 닉네임 저장
      }
    },

    checkLoginStatus() {

      if (this.getCookie('nickName')) {
        this.userNickname != '';
        this.isLoggedIn = true;
      } else {
        this.isLoggedIn = false;
      }
    },

    logout() {
      Cookies.remove('cookies'); // 쿠키 삭제
      this.userNickname = '';
      this.isLoggedIn = false;
    }
  },

  computed: {
    greetingMessage() {
      const nickName = this.getCookie('nickName');
      return this.isLoggedIn ? nickName + ` 님 환영합니다람쥐!` : '로그인 해주세요!!';
    }
  },

  mounted() {
    this.checkLoginStatus();
  }
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

nav {
  padding: 30px;
}

nav a {
  font-weight: bold;
  color: #2c3e50;
}

nav a.router-link-exact-active {
  color: #2c3e50;
}

.navbar-text {
  margin-left: auto;
}

.btn-about {
  background-color: #007bff; /* Bootstrap primary color */
  color: #fff; /* White text */
}

.btn-list {
  background-color: #28a745; /* Bootstrap success color */
  color: #fff; /* White text */
}
</style>
