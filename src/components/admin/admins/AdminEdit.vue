<template>
  <div class="admin-edit-container">
    <h1 class="page-title">修改密码</h1>
    
    <div class="form-container">
      <el-card>
        <el-form 
          :model="passwordForm" 
          :rules="passwordRules" 
          ref="passwordFormRef" 
          label-width="120px" 
          class="password-form"
        >
          <el-form-item label="当前密码" prop="old_password">
            <el-input 
              v-model="passwordForm.old_password" 
              type="password" 
              placeholder="请输入当前密码"
              show-password
            ></el-input>
          </el-form-item>
          
          <el-form-item label="新密码" prop="new_password">
            <el-input 
              v-model="passwordForm.new_password" 
              type="password" 
              placeholder="请输入新密码"
              show-password
            ></el-input>
          </el-form-item>
          
          <el-form-item label="确认新密码" prop="confirm_password">
            <el-input 
              v-model="passwordForm.confirm_password" 
              type="password" 
              placeholder="请再次输入新密码"
              show-password
            ></el-input>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="submitPasswordForm" :loading="loading">
              修改密码
            </el-button>
            <el-button @click="resetForm">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
    
    <h1 class="page-title mt-30">修改个人信息</h1>
    
    <div class="form-container">
      <el-card>
        <el-form 
          :model="profileForm" 
          :rules="profileRules" 
          ref="profileFormRef" 
          label-width="120px" 
          class="profile-form"
        >
          <el-form-item label="手机号">
            <el-input 
              v-model="profileForm.phone_number" 
              disabled
            ></el-input>
          </el-form-item>
          
          <el-form-item label="姓名" prop="full_name">
            <el-input 
              v-model="profileForm.full_name" 
              placeholder="请输入姓名"
            ></el-input>
          </el-form-item>
          
          <el-form-item label="电子邮箱" prop="email">
            <el-input 
              v-model="profileForm.email" 
              placeholder="请输入电子邮箱"
            ></el-input>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="submitProfileForm" :loading="profileLoading">
              保存信息
            </el-button>
            <el-button @click="resetProfileForm">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const profileLoading = ref(false);
const passwordFormRef = ref(null);
const profileFormRef = ref(null);

// API基础URL，确保没有尾斜杠
const apiBaseUrl = computed(() => {
  if (API_BASE_URL.endsWith('/')) {
    return API_BASE_URL.slice(0, -1);
  }
  return API_BASE_URL;
});

// 密码表单
const passwordForm = reactive({
  old_password: '',
  new_password: '',
  confirm_password: ''
});

// 个人信息表单
const profileForm = reactive({
  admin_id: null,
  phone_number: '',
  full_name: '',
  email: '',
  role: ''
});

// 密码表单验证规则
const passwordRules = reactive({
  old_password: [
    { required: true, message: '请输入当前密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符之间', trigger: 'blur' }
  ],
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符之间', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value === passwordForm.old_password) {
          callback(new Error('新密码不能与当前密码相同'));
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ],
  confirm_password: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.new_password) {
          callback(new Error('两次输入的密码不一致'));
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ]
});

// 个人信息表单验证规则
const profileRules = reactive({
  full_name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度在2-20个字符之间', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入电子邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
});

// 获取当前管理员信息
const fetchAdminInfo = async () => {
  profileLoading.value = true;
  try {
    const adminId = localStorage.getItem('admin_id');
    if (!adminId) {
      ElMessage.error('未找到管理员信息，请重新登录');
      return;
    }
    
    const response = await fetch(`${apiBaseUrl.value}/admin/info`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      }
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API请求失败: ${response.status} ${errorText}`);
    }
    
    const data = await response.json();
    
    if (data.code === 200) {
      const adminInfo = data.data;
      profileForm.admin_id = adminInfo.admin_id;
      profileForm.phone_number = adminInfo.phone_number;
      profileForm.full_name = adminInfo.full_name;
      profileForm.email = adminInfo.email;
      profileForm.role = adminInfo.role;
    } else {
      ElMessage.error(data.message || '获取管理员信息失败');
    }
  } catch (error) {
    console.error('获取管理员信息失败:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    profileLoading.value = false;
  }
};

// 提交修改密码表单
const submitPasswordForm = async () => {
  if (!passwordFormRef.value) return;
  
  passwordFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    loading.value = true;
    try {
      const adminId = localStorage.getItem('admin_id');
      if (!adminId) {
        ElMessage.error('未找到管理员信息，请重新登录');
        loading.value = false;
        return;
      }
      
      const response = await fetch(`${apiBaseUrl.value}/admin/admins/change-password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
        },
        body: JSON.stringify({
          admin_id: parseInt(adminId),
          old_password: passwordForm.old_password,
          new_password: passwordForm.new_password
        })
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API请求失败: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success('密码修改成功');
        resetForm();
      } else {
        ElMessage.error(data.message || '密码修改失败');
      }
    } catch (error) {
      console.error('密码修改失败:', error);
      ElMessage.error('操作失败，请稍后再试');
    } finally {
      loading.value = false;
    }
  });
};

// 提交个人信息表单
const submitProfileForm = async () => {
  if (!profileFormRef.value) return;
  
  profileFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    profileLoading.value = true;
    try {
      const adminId = localStorage.getItem('admin_id');
      if (!adminId) {
        ElMessage.error('未找到管理员信息，请重新登录');
        profileLoading.value = false;
        return;
      }
      
      const response = await fetch(`${apiBaseUrl.value}/admin/admins/${adminId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
        },
        body: JSON.stringify({
          admin_id: parseInt(adminId),
          full_name: profileForm.full_name,
          email: profileForm.email,
          current_admin_id: parseInt(adminId)
        })
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API请求失败: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success('个人信息更新成功');
        fetchAdminInfo(); // 刷新信息
      } else {
        ElMessage.error(data.message || '个人信息更新失败');
      }
    } catch (error) {
      console.error('个人信息更新失败:', error);
      ElMessage.error('操作失败，请稍后再试');
    } finally {
      profileLoading.value = false;
    }
  });
};

// 重置密码表单
const resetForm = () => {
  if (passwordFormRef.value) {
    passwordFormRef.value.resetFields();
  }
};

// 重置个人信息表单
const resetProfileForm = () => {
  if (profileFormRef.value) {
    fetchAdminInfo(); // 重新获取信息
  }
};

// 生命周期钩子
onMounted(() => {
  // 检查管理员身份
  const isAdmin = localStorage.getItem('isAdmin') === 'true';
  if (!isAdmin) {
    ElMessage.error('只有管理员才能访问此页面');
    return;
  }
  
  // 加载管理员信息
  fetchAdminInfo();
});
</script>

<style scoped>
.admin-edit-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.form-container {
  max-width: 600px;
  margin-bottom: 30px;
}

.mt-30 {
  margin-top: 30px;
}

:deep(.el-form-item__label) {
  font-weight: 500;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-button:focus),
:deep(.el-button:focus-visible) {
  outline: none !important;
  box-shadow: none !important;
  border-color: initial;
}
</style> 