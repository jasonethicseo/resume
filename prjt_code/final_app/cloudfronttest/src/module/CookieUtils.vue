
<template>
    <div></div>
</template>
  
<script>
export default {
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
    }
  }
};
</script>