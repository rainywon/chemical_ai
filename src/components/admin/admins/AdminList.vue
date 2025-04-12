<template>
  <div class="admin-list-container">
    <h1 class="page-title">管理员列表</h1>
    
    <!-- 搜索过滤区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchParams" class="search-form">
        <el-form-item label="手机号">
          <el-input v-model="searchParams.phoneNumber" placeholder="请输入手机号" clearable></el-input>
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="searchParams.fullName" placeholder="请输入姓名" clearable></el-input>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="searchParams.role" placeholder="请选择角色" clearable>
            <el-option label="超级管理员" value="admin"></el-option>
            <el-option label="操作员" value="operator"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchAdmins">
            <i class="el-icon-search"></i> 搜索
          </el-button>
          <el-button @click="resetSearchParams">
            <i class="el-icon-refresh"></i> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 操作按钮区域 -->
    <div class="operation-container">
      <el-button type="primary" @click="handleAddAdmin">
        <i class="el-icon-plus"></i> 新增管理员
      </el-button>
    </div>

    <!-- 管理员列表表格 -->
    <div class="table-container">
      <el-table
        :data="adminList"
        border
        stripe
        style="width: 100%"
        v-loading="loading"
        :header-cell-style="{background:'#f5f7fa', color:'#606266', fontWeight: 'bold'}"
        :cell-style="{ padding: '12px 8px' }"
      >
        <el-table-column prop="admin_id" label="ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="phone_number" label="手机号" min-width="120" align="center"></el-table-column>
        <el-table-column prop="full_name" label="姓名" min-width="120" align="center"></el-table-column>
        <el-table-column prop="role" label="角色" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.role === 'admin' ? 'danger' : 'success'">
              {{ scope.row.role === 'admin' ? '超级管理员' : '操作员' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="150" align="center"></el-table-column>
        <el-table-column prop="status" label="状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="last_login_time" label="最后登录时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="created_at" label="创建时间" min-width="160" align="center"></el-table-column>
        <el-table-column label="操作" min-width="200" align="center">
          <template #default="scope">
            <el-button
              size="small"
              type="primary"
              @click="handleEditAdmin(scope.row)"
            >
              编辑
            </el-button>
            <el-button
              size="small"
              :type="scope.row.status === 1 ? 'danger' : 'success'"
              @click="handleToggleStatus(scope.row)"
            >
              {{ scope.row.status === 1 ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="totalItems"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :current-page="currentPage"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </div>

    <!-- 添加/编辑管理员对话框 -->
    <el-dialog 
      :title="isEdit ? '编辑管理员' : '新增管理员'" 
      v-model="adminDialogVisible" 
      width="500px" 
      :close-on-click-modal="false"
    >
      <el-form 
        :model="adminForm" 
        :rules="adminRules" 
        ref="adminFormRef" 
        label-width="100px"
      >
        <el-form-item label="手机号" prop="phone_number">
          <el-input v-model="adminForm.phone_number" placeholder="请输入手机号" :disabled="isEdit"></el-input>
        </el-form-item>
        <el-form-item label="姓名" prop="full_name">
          <el-input v-model="adminForm.full_name" placeholder="请输入姓名"></el-input>
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="adminForm.email" placeholder="请输入邮箱"></el-input>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="adminForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="超级管理员" value="admin"></el-option>
            <el-option label="操作员" value="operator"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input v-model="adminForm.password" type="password" placeholder="请输入密码"></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm_password" v-if="!isEdit">
          <el-input v-model="adminForm.confirm_password" type="password" placeholder="请再次输入密码"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="adminDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitAdminForm">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const adminList = ref([]);
const totalItems = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);
const adminDialogVisible = ref(false);
const isEdit = ref(false);
const adminFormRef = ref(null);

// API基础URL，确保没有尾斜杠
const apiBaseUrl = computed(() => {
  if (API_BASE_URL.endsWith('/')) {
    return API_BASE_URL.slice(0, -1);
  }
  return API_BASE_URL;
});

// 搜索参数
const searchParams = reactive({
  phoneNumber: '',
  fullName: '',
  role: ''
});

// 管理员表单
const adminForm = reactive({
  admin_id: null,
  phone_number: '',
  full_name: '',
  email: '',
  role: 'operator',
  password: '',
  confirm_password: '',
  status: 1
});

// 表单验证规则
const adminRules = reactive({
  phone_number: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ],
  full_name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度在2-20个字符之间', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6-20个字符之间', trigger: 'blur' }
  ],
  confirm_password: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== adminForm.password) {
          callback(new Error('两次输入的密码不一致'));
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ]
});

// 获取管理员列表
const fetchAdminList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value.toString());
    params.append('page_size', pageSize.value.toString());
    
    if (searchParams.phoneNumber && searchParams.phoneNumber.trim()) {
      params.append('phone_number', searchParams.phoneNumber.trim());
    }
    
    if (searchParams.fullName && searchParams.fullName.trim()) {
      params.append('full_name', searchParams.fullName.trim());
    }
    
    if (searchParams.role && searchParams.role.trim()) {
      params.append('role', searchParams.role.trim());
    }

    // 获取并添加当前管理员ID
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      const adminIdNum = parseInt(adminId);
      if (!isNaN(adminIdNum)) {
        params.append('admin_id', adminIdNum.toString());
      }
    }
    
    // 发送请求
    const response = await fetch(`${apiBaseUrl.value}/admin/admins?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
      }
    });
    
    // 检查响应状态
    if (!response.ok) {
      const errorText = await response.text();
      console.error('API错误响应:', response.status, errorText);
      throw new Error(`API请求失败: ${response.status} ${errorText}`);
    }
    
    const data = await response.json();
    
    if (data.code === 200) {
      adminList.value = data.data.admins;
      totalItems.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取管理员列表失败');
    }
  } catch (error) {
    console.error('获取管理员列表失败:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 搜索管理员
const searchAdmins = () => {
  currentPage.value = 1;
  fetchAdminList();
};

// 重置搜索参数
const resetSearchParams = () => {
  Object.keys(searchParams).forEach(key => {
    searchParams[key] = '';
  });
  currentPage.value = 1;
  fetchAdminList();
};

// 处理分页大小变化
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchAdminList();
};

// 处理当前页变化
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchAdminList();
};

// 打开添加管理员对话框
const handleAddAdmin = () => {
  isEdit.value = false;
  resetAdminForm();
  adminDialogVisible.value = true;
};

// 打开编辑管理员对话框
const handleEditAdmin = (admin) => {
  isEdit.value = true;
  resetAdminForm();
  Object.keys(adminForm).forEach(key => {
    if (key in admin) {
      adminForm[key] = admin[key];
    }
  });
  adminDialogVisible.value = true;
};

// 重置管理员表单
const resetAdminForm = () => {
  adminForm.admin_id = null;
  adminForm.phone_number = '';
  adminForm.full_name = '';
  adminForm.email = '';
  adminForm.role = 'operator';
  adminForm.password = '';
  adminForm.confirm_password = '';
  adminForm.status = 1;
  if (adminFormRef.value) {
    adminFormRef.value.resetFields();
  }
};

// 提交管理员表单
const submitAdminForm = async () => {
  if (!adminFormRef.value) return;
  
  adminFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    loading.value = true;
    try {
      const adminId = localStorage.getItem('admin_id');
      if (adminId) {
        adminForm.current_admin_id = parseInt(adminId);
      }
      
      const url = isEdit.value 
        ? `${apiBaseUrl.value}/admin/admins/${adminForm.admin_id}` 
        : `${apiBaseUrl.value}/admin/admins`;
      
      const method = isEdit.value ? 'PUT' : 'POST';
      
      // 编辑时移除密码字段
      const submitData = { ...adminForm };
      if (isEdit.value) {
        delete submitData.password;
        delete submitData.confirm_password;
      }
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
        },
        body: JSON.stringify(submitData)
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API请求失败: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(isEdit.value ? '编辑管理员成功' : '添加管理员成功');
        adminDialogVisible.value = false;
        fetchAdminList();
      } else {
        ElMessage.error(data.message || (isEdit.value ? '编辑管理员失败' : '添加管理员失败'));
      }
    } catch (error) {
      console.error(isEdit.value ? '编辑管理员失败:' : '添加管理员失败:', error);
      ElMessage.error('操作失败，请稍后再试');
    } finally {
      loading.value = false;
    }
  });
};

// 处理状态切换
const handleToggleStatus = async (admin) => {
  const statusText = admin.status === 1 ? '禁用' : '启用';
  
  ElMessageBox.confirm(
    `确认${statusText}该管理员？`, 
    '提示', 
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    loading.value = true;
    try {
      const adminId = localStorage.getItem('admin_id');
      
      const response = await fetch(`${apiBaseUrl.value}/admin/admins/status`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
        },
        body: JSON.stringify({
          admin_id: admin.admin_id,
          status: admin.status === 1 ? 0 : 1,
          current_admin_id: adminId ? parseInt(adminId) : null
        })
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API请求失败: ${response.status} ${errorText}`);
      }
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage.success(`${statusText}管理员成功`);
        fetchAdminList();
      } else {
        ElMessage.error(data.message || `${statusText}管理员失败`);
      }
    } catch (error) {
      console.error(`${statusText}管理员失败:`, error);
      ElMessage.error('操作失败，请稍后再试');
    } finally {
      loading.value = false;
    }
  }).catch(() => {
    // 用户取消操作
  });
};

// 生命周期钩子
onMounted(() => {
  // 检查管理员身份
  const isAdmin = localStorage.getItem('isAdmin') === 'true';
  if (!isAdmin) {
    ElMessage.error('只有管理员才能访问此页面');
    return;
  }
  
  // 加载管理员列表
  fetchAdminList();
});
</script>

<style scoped>
.admin-list-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.search-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.operation-container {
  margin-bottom: 20px;
}

.table-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}

/* 修复按钮点击后出现的黑色边框 */
:deep(.el-button:focus),
:deep(.el-button:focus-visible) {
  outline: none !important;
  box-shadow: none !important;
  border-color: initial;
}

/* 改善表格内容样式 */
:deep(.el-table__header-wrapper th) {
  font-weight: bold;
}

:deep(.el-pagination) {
  margin-top: 20px;
  justify-content: flex-end;
}
</style> 