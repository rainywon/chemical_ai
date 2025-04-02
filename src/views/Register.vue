<template>
  <div>
    <h2>用户注册</h2>
    <form @submit.prevent="handleSubmit">
      <div>
        <label for="phone">手机号:</label>
        <input v-model="phone" type="text" id="phone" required />
      </div>
      <div>
        <label for="verificationCode">验证码:</label>
        <input v-model="verificationCode" type="text" id="verificationCode" required />
        <button @click="sendVerificationCode">发送验证码</button>
      </div>
      <div>
        <label for="password">密码:</label>
        <input v-model="password" type="password" id="password" required />
      </div>
      <button type="submit">注册</button>
    </form>
  </div>
</template>

<script setup name="Register">
import { ref } from "vue";
import axios from "axios";

const phone = ref("");
const verificationCode = ref("");
const password = ref("");

const sendVerificationCode = async () => {
  try {
    const response = await axios.post("/api/send_sms", { phone: phone.value });
    alert(response.data.message);
  } catch (error) {
    console.error(error);
  }
};

const handleSubmit = async () => {
  try {
    const response = await axios.post("/api/register", {
      phone: phone.value,
      verification_code: verificationCode.value,
      password: password.value,
    });
    alert(response.data.message);
  } catch (error) {
    console.error(error);
  }
};
</script>
