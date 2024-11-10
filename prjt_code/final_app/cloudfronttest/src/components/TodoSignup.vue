<template>
	<div>
		<table>
			<tr>
				<th>닉네임</th>
				<td>
					<input v-model="signup.nickname" type="text" maxlength="20">
					<div v-if="signup.nickname === ''">
						닉네임은 필수 입력 항목입니다.
					</div>
				</td>
			</tr>
			<tr>
				<th>아이디</th>
				<td>
					<input v-model="signup.email" type="email" maxlength="30">
					<div v-if="!emailValid && signup.email !== ''">
						이메일 형식으로 입력해주세요.
					</div>
					<div v-if="!emailValid && signup.email === ''">
						이메일은 필수 입력 항목입니다.
					</div>
				</td>
			</tr>
			<tr>
				<th>비밀번호</th>
				<td>
					<input v-model="signup.password" type="password" maxlength="16" @blur="passwordValid">
					<div v-if="signup.password === ''">
						비밀번호는 필수 입력 항목입니다.
					</div>
					<div v-if="!passwordValidFlag">
						비밀번호는 최소 8자 이상, 숫자, 특수문자를 포함해야 합니다.
					</div>
				</td>
			</tr>
			<tr>
				<th>비밀번호 확인</th>
				<td>
					<input v-model="passwordCheck" type="password" maxlength="16" @input="passwordCheckValid">
					<div v-if="!passwordCheckFlag && passwordCheck !== ''">
						비밀번호가 동일하지 않습니다.
					</div>
				</td>
			</tr>
		</table>
		<button @click="register">회원가입</button>
	</div>
</template>

<script>
import axios from 'axios';

export default {
	data() {
		return {
			signup: {
				nickname: '',
				email: '',
				password: '',
			},
			passwordValidFlag: true,
			passwordCheck: '',
			passwordCheckFlag: true,
		};
	},
	computed: {
		emailValid() {
			return /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(this.signup.email);
		},
	},
	methods: {
		passwordValid() {
			const regex = /^(?=.*\d)(?=.*[!@#$%^&*])(?=.*[a-z]).{8,}$/;
			if (this.signup.password === '') {
				this.passwordValidFlag = false;
			} else if (regex.test(this.signup.password)) {
				this.passwordValidFlag = true;
			} else {
				this.passwordValidFlag = false;
			}
		},
		passwordCheckValid() {
			if (this.passwordCheck === '') {
				this.passwordCheckFlag = true;
			} else if (this.signup.password === this.passwordCheck) {
				this.passwordCheckFlag = true;
			} else {
				this.passwordCheckFlag = false;
			}
		},
		register() {
			if (this.emailValid && this.passwordValidFlag && this.passwordCheckFlag && this.signup.nickname !== '') {
				// const url = 'http://internal-test-LB-ECS-backend-970728-249192087.ca-central-1.elb.amazonaws.com'; // 가상의 API URL
				const data = {
					nickname: this.signup.nickname,
					email: this.signup.email,
					password: this.signup.password,
				};
				axios.post(`/api/signup`,{
					nickname: this.signup.nickname,
					email: this.signup.email,
					passwd: this.signup.password,
					check: this.signup.password
				}
					

				).then(response => {
					this.$router.push("/about")
						console.log('회원 가입 성공:', response.data);
						alert('회원 가입이 완료되었습니다.');
						this.$emit('user-signed-up', this.signup.nickname); // 이벤트를 발생시켜 userNickname을 전달
					})
					.catch(error => {
						console.error('회원 가입 실패:', error);
						alert('회원 가입 중 오류가 발생했습니다.');
					});
			} else {
				alert('입력 정보를 다시 확인해주세요.');
			}
		},
	},
};
</script>

<style scoped>
table {
	width: 95%;
	border-collapse: collapse;
	margin-top: 20px;
	margin-left: auto;
	margin-right: auto;
	border-radius: 10px; 
}

th, td {
	padding: 10px;
	border: 2px solid #acd2dd;
}

th {
	width: 30%;
	text-align: left;
}

td {
	width: 80%;
}

input {
	width: calc(100% - 20px);
	padding: 5px;
	margin-top: 5px;
	margin-bottom: 5px;
	border: 1px solid gray;
	border-radius: 5px;
}

div {
	margin-top: 5px;
	color: rgb(131, 125, 125);
	font-size: 14px;
}

button {
	margin-top: 10px;
	color: white;
	background-color: lightblue;
	width: 85px;
	height: 40px;
	cursor: pointer;
	border: none;
	border-radius: 5px;
}
</style>
