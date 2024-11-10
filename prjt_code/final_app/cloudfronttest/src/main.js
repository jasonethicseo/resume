import { createApp } from 'vue';
import App from './App.vue';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
import router from './router';
import axios from 'axios';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import VueCookies from 'vue-cookies';

const app = createApp(App);

// axios 설정 전역으로 등록
app.config.globalProperties.axios = axios;

// Font Awesome component 등록
app.component('font-awesome-icon', FontAwesomeIcon);

// Router 사용
app.use(router);

// VueCookies 전역으로 등록
app.use(VueCookies);
app.config.globalProperties.$cookies = VueCookies;

// Cookie 설정
// cookie 7일동안 유지
app.config.globalProperties.$cookies.config("7d");

// 마운트
app.mount('#app');
